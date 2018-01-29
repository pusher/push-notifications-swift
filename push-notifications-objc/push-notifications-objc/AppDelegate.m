#import "AppDelegate.h"
@import PushNotifications;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[PushNotifications shared] registerWithInstanceId:@"97c56dfe-58f5-408b-ab3a-158e51a860f2"];

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[PushNotifications shared] registerDeviceToken:deviceToken completion:^{
        NSError *anyError;
        [[PushNotifications shared] subscribeWithInterest:@"hello" error:&anyError completion:^{
            if (anyError) {
                NSLog(@"Error: %@", anyError);
            }
            else {
                NSLog(@"Subscribed to interest hello.");
            }
        }];
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"%@", userInfo);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Remote notification support is unavailable due to error: %@", error.localizedDescription);
}

@end
