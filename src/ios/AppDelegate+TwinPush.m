#import "AppDelegate+TwinPush.h"
#import <objc/runtime.h>
#import <TwinPushSDK/TwinPushManager.h>

@implementation AppDelegate (TwinPush)

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[TwinPushManager manager] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Application did fail registering for remote notifications: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Received notification with contents: %@", userInfo);
    [[TwinPushManager manager] application:application didReceiveRemoteNotification:userInfo];
}

@end
