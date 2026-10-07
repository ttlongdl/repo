#import <Foundation/Foundation.h>
#import <substrate.h>
#import <CoreFoundation/CoreFoundation.h>
#import <dlfcn.h>

typedef CFPropertyListRef (*MGCopyAnswer_t)(CFStringRef);
static MGCopyAnswer_t originalMGCopyAnswer = NULL;
static NSString *const kPrefsPath = @"/var/mobile/Library/Preferences/com.ttlongdl.aboutspoof.plist";

static NSDictionary *Prefs(void) {
    return [NSDictionary dictionaryWithContentsOfFile:kPrefsPath] ?: @{};
}
static NSString *PrefString(NSString *key) {
    id value = Prefs()[key];
    return ([value isKindOfClass:NSString.class] && [value length] > 0) ? value : nil;
}

static CFPropertyListRef spoofedMGCopyAnswer(CFStringRef key) {
    if (key && CFGetTypeID(key) == CFStringGetTypeID()) {
        NSString *name = (__bridge NSString *)key;
        NSString *value = nil;

        if ([name isEqualToString:@"UserAssignedDeviceName"]) {
            value = PrefString(@"modelName");
        } else if ([name isEqualToString:@"ProductVersion"]) {
            value = PrefString(@"iosVersion");
        }

        if (value) return (__bridge_retained CFStringRef)value;
    }
    return originalMGCopyAnswer ? originalMGCopyAnswer(key) : NULL;
}

%ctor {
    @autoreleasepool {
        if (![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.Preferences"]) return;
        void *handle = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_LAZY);
        if (!handle) return;
        void *symbol = dlsym(handle, "MGCopyAnswer");
        if (symbol) MSHookFunction(symbol, (void *)&spoofedMGCopyAnswer, (void **)&originalMGCopyAnswer);
    }
}
