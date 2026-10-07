#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>\n#import <substrate.h>\n#import <stdint.h>\n\nextern "C" CFPropertyListRef MGCopyAnswer(CFStringRef);

static NSString *const kPrefsPath = @"/var/mobile/Library/Preferences/com.ttlongdl.aboutspoof.plist";

static NSString *ABSValue(NSString *key) {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:kPrefsPath];
    id value = [prefs objectForKey:key];
    if ([value isKindOfClass:[NSString class]] && [value length] > 0) return value;
    return nil;
}

typedef unsigned long long addr_t;
static addr_t absStep(const uint8_t *buf, addr_t start, size_t length, uint32_t what, uint32_t mask) {
    for (addr_t p = start; p < start + length; p += 4)
        if ((*(uint32_t *)(buf + p) & mask) == what) return p;
    return 0;
}
static addr_t absBranch(const uint8_t *buf) { return absStep(buf, 0, 12, 0x14000000, 0xFC000000); }
static addr_t absFollow(const uint8_t *buf, addr_t branch) {
    long long w = *(uint32_t *)(buf + branch) & 0x3FFFFFF;
    w <<= 38; w >>= 36;
    return branch + w;
}

static CFPropertyListRef (*absOriginal)(CFStringRef, uint32_t *);
static CFPropertyListRef absReplacement(CFStringRef property, uint32_t *typeCode) {
    CFPropertyListRef realValue = absOriginal(property, typeCode);
    if (!property || CFGetTypeID(property) != CFStringGetTypeID()) return realValue;
    NSString *key = (__bridge NSString *)property;
    NSString *fake = nil;
    if ([key isEqualToString:@"marketing-name"]) fake = ABSValue(@"modelName");
    else if ([key isEqualToString:@"ProductVersion"]) fake = ABSValue(@"iosVersion");
    if (!fake) return realValue;
    if (realValue) CFRelease(realValue);
    return (__bridge_retained CFStringRef)fake;
}

%ctor {
    @autoreleasepool {
        if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Preferences"]) return;
        MSImageRef image = MSGetImageByName("/usr/lib/libMobileGestalt.dylib");
        if (!image) return;
        void *entry = MSFindSymbol(image, "_MGCopyAnswer");
        if (!entry) return;
        const uint8_t *ptr = (const uint8_t *)entry;
        addr_t branch = absBranch(ptr);
        if (!branch) return;
        void *target = (void *)(ptr + absFollow(ptr, branch));
        MSHookFunction(target, (void *)absReplacement, (void **)&absOriginal);
    }
}
