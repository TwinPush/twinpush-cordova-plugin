#import <Cordova/CDV.h>
#import <TwinPushSDK/TwinPushManager.h>

enum {
    TPLocationPrecisionFine = 0,
    TPLocationPrecisionHigh,
    TPLocationPrecisionMedium,
    TPLocationPrecisionLow,
    TPLocationPrecisionCoarse
};
typedef NSUInteger TPLocationPrecision;


@interface TwinPush : CDVPlugin <TwinPushManagerDelegate>
- (void)setAlias:(CDVInvokedUrlCommand*)command;
- (void)setRegisterCallback:(CDVInvokedUrlCommand*)command;
- (void)getDeviceId:(CDVInvokedUrlCommand*)command;

- (void)setIntegerProperty:(CDVInvokedUrlCommand*)command;
- (void)setFloatProperty:(CDVInvokedUrlCommand*)command;
- (void)setBooleanProperty:(CDVInvokedUrlCommand*)command;
- (void)setStringProperty:(CDVInvokedUrlCommand*)command;

- (void)setLocation:(CDVInvokedUrlCommand*)command;
- (void)updateLocation:(CDVInvokedUrlCommand*)command;
@end
