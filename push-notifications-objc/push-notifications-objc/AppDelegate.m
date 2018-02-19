#import "AppDelegate.h"
@import PushNotifications;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[PushNotifications shared] startWithInstanceId:@"f918950d-476d-4649-b38e-6cc8d30e0827"];
    [[PushNotifications shared] registerForRemoteNotifications];

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
    [[PushNotifications shared] handleNotificationWithUserInfo:userInfo];
    NSLog(@"%@", userInfo);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Remote notification support is unavailable due to error: %@", error.localizedDescription);
}

@end
