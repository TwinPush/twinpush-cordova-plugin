#import <Cordova/CDV.h>
#import <TwinPushSDK/TwinPushManager.h>

@interface TwinPush : CDVPlugin <TwinPushManagerDelegate>
- (void)setAlias:(CDVInvokedUrlCommand*)command;
- (void)setRegisterCallback:(CDVInvokedUrlCommand*)command;
- (void)getDeviceId:(CDVInvokedUrlCommand*)command;

- (void)setIntegerProperty:(CDVInvokedUrlCommand*)command;
- (void)setFloatProperty:(CDVInvokedUrlCommand*)command;
- (void)setBooleanProperty:(CDVInvokedUrlCommand*)command;
- (void)setStringProperty:(CDVInvokedUrlCommand*)command;
@end
