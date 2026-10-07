#import "ABSRootListController.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIKit.h>
#import <spawn.h>

extern char **environ;
static NSString *const kPrefsPath = @"/var/mobile/Library/Preferences/com.ttlongdl.aboutspoof.plist";

@implementation ABSRootListController
- (NSArray *)specifiers {
    if (!_specifiers) _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    return _specifiers;
}

- (void)restartPreferences {
    // Rootless Dopamine puts killall in /var/jb/usr/bin.
    pid_t pid = 0;
    const char *argv[] = {"killall", "-9", "Preferences", NULL};
    int status = posix_spawn(&pid, "/var/jb/usr/bin/killall", NULL, NULL, (char *const *)argv, environ);
    if (status != 0) {
        posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char *const *)argv, environ);
    }
}

- (void)apply:(id)sender {
    [self.view endEditing:YES];
    CFPreferencesAppSynchronize(CFSTR("com.ttlongdl.aboutspoof"));
    [self restartPreferences];
}

- (void)revert:(id)sender {
    [self.view endEditing:YES];
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPath] ?: [NSMutableDictionary dictionary];
    [prefs removeObjectForKey:@"modelName"];
    [prefs removeObjectForKey:@"iosVersion"];
    [prefs setObject:@YES forKey:@"reverted"];
    [prefs writeToFile:kPrefsPath atomically:YES];
    CFPreferencesAppSynchronize(CFSTR("com.ttlongdl.aboutspoof"));
    [self reloadSpecifiers];
    [self restartPreferences];
}
@end
