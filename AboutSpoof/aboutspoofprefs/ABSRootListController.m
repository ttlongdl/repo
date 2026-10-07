#import "ABSRootListController.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIKit.h>

@implementation ABSRootListController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}
- (void)apply:(id)sender {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
        CFSTR("com.ttlongdl.aboutspoof/Reload"), NULL, NULL, true);
    system("killall -9 Preferences");
}
@end
