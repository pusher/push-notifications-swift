#import "AppDelegate.h"
@import PushNotifications;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // if using one instance id throughout the whole app do the following:
    [[PushNotifications shared] startWithInstanceId:@"YOUR_INSTANCE_ID"]; // Can be found here: https://dash.pusher.com
    [[PushNotifications shared] registerForRemoteNotifications];

    NSError *anyError;
    [[PushNotifications shared] addDeviceInterestWithInterest:@"debug-test" error:&anyError];
    
    // if using multiple instances do the following:
//    PushNotifications *pn1 = [[PushNotifications alloc] initWithInstanceId: @"YOUR_INSTANCE_ID_1"];
//    NSError *anyError;
//    [pn1 addDeviceInterestWithInterest:@"debug-potatoes" error:&anyError]
//
//    PushNotifications *pn2 = [[PushNotifications alloc] initWithInstanceId: @"YOUR_INSTANCE_ID_2"];
//    NSError *anyError;
//    [pn2 addDeviceInterestWithInterest:@"debug-carrots" error:&anyError]
    

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[PushNotifications shared] registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[PushNotifications shared] handleNotificationWithUserInfo:userInfo];
    NSLog(@"%@", userInfo);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Remote notification support is unavailable due to error: %@", error.localizedDescription);
}

@end
