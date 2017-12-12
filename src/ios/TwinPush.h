#import <Cordova/CDV.h>
#import <TwinPushSDK/TwinPushManager.h>

@interface TwinPush : CDVPlugin <TwinPushManagerDelegate>
- (void)setAlias:(CDVInvokedUrlCommand*)command;
- (void)setRegisterCallback:(CDVInvokedUrlCommand*)command;
- (void)getDeviceId:(CDVInvokedUrlCommand*)command;
@end
