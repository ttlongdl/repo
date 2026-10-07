#import <Foundation/Foundation.h>
#import <substrate.h>
#import <CoreFoundation/CoreFoundation.h>
#import <dlfcn.h>

typedef CFPropertyListRef (*MGCopyAnswer_t)(CFStringRef);
static MGCopyAnswer_t originalMGCopyAnswer = NULL;

static NSString *const kSpoofedModelName = @"iPhone 18 Pro";

static CFPropertyListRef spoofedMGCopyAnswer(CFStringRef key) {
    if (key && CFGetTypeID(key) == CFStringGetTypeID()) {
        NSString *name = (__bridge NSString *)key;
        if ([name isEqualToString:@"UserAssignedDeviceName"]) {
            return (__bridge_retained CFStringRef)kSpoofedModelName;
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
