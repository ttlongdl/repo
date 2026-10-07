#import <Foundation/Foundation.h>
#import <Preferences/PSSpecifier.h>

static NSString *const kPrefsPath = @"/var/mobile/Library/Preferences/com.ttlongdl.aboutspoof.plist";

static NSString *ABSValue(NSString *key) {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:kPrefsPath];
    id value = [prefs objectForKey:key];
    if ([value isKindOfClass:[NSString class]] && [value length] > 0) return value;
    return nil;
}

%hook PSSpecifier
- (id)performGetter {
    NSString *sid = [self identifier];

    if ([sid isEqualToString:@"ProductModelName"]) {
        NSString *value = ABSValue(@"modelName");
        if (value) return value;
    }

    if ([sid isEqualToString:@"SW_VERSION_SPECIFIER"]) {
        NSString *value = ABSValue(@"iosVersion");
        if (value) return value;
    }

    return %orig;
}
%end

%ctor {
    @autoreleasepool {
        if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Preferences"]) {
            %init;
        }
    }
}
