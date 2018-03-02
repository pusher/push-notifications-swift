#import <Foundation/Foundation.h>
#import <PushNotifications/PushNotifications-Swift.h>

@interface NSBundle (MainBundle)
+ (NSBundle *)mainBundle;
@end

@implementation NSBundle (Main)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
+ (NSBundle *)mainBundle {
    return [NSBundle bundleForClass:[PushNotifications class]];
}
#pragma clang diagnostic pop

@end
