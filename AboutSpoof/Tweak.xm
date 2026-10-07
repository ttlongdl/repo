#import <Foundation/Foundation.h>
#import <substrate.h>
#import <CoreFoundation/CoreFoundation.h>
#import <dlfcn.h>

typedef CFPropertyListRef (*MGCopyAnswer_t)(CFStringRef);
static MGCopyAnswer_t originalMGCopyAnswer = NULL;
static NSString *const kPrefsPath = @"/var/mobile/Library/Preferences/com.ttlongdl.aboutspoof.plist";

static NSString *SpoofedModelName(void) {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:kPrefsPath];
    NSString *value = prefs[@"modelName"];
    if (![value isKindOfClass:NSString.class] || value.length == 0) {
        value = @"iPhone 18 Pro";
    }
    return value;
}

static CFPropertyListRef spoofedMGCopyAnswer(CFStringRef key) {
    if (key && CFGetTypeID(key) == CFStringGetTypeID()) {
        NSString *name = (__bridge NSString *)key;
        if ([name isEqualToString:@"UserAssignedDeviceName"]) {
            return (__bridge_retained CFStringRef)SpoofedModelName();
        }
    }
    return originalMGCopyAnswer ? originalMGCopyAnswer(key) : NULL;
}

%ctor {
    @autoreleasepool {
        if (![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.Preferences"]) return;
        void *handle = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_LAZY);
        if (!handle) return;
        void *symbol = dlsym(handle, "MGCopyAnswer");
        if (symbol) {
            MSHookFunction(symbol, (void *)&spoofedMGCopyAnswer, (void **)&originalMGCopyAnswer);
        }
    }
}
