/********* twinpush.m Cordova Plugin Implementation *******/

#import "TwinPush.h"

@interface TwinPush()
@property (nonatomic, retain) CDVInvokedUrlCommand* aliasCommand;
@property (nonatomic, retain) CDVInvokedUrlCommand* registerCallbackCommand;
@end

@implementation TwinPush

- (void)pluginInitialize {
    [super pluginInitialize];
    NSDictionary* settings = self.commandDelegate.settings;

    NSString* appId = settings[@"TwinPush_AppId".lowercaseString];
    NSString* apiKey = settings[@"TwinPush_ApiKey".lowercaseString];
    NSString* subdomain = settings[@"TwinPush_Subdomain".lowercaseString];
    if (subdomain != nil) {
        [[TwinPushManager manager] setServerSubdomain:subdomain];
    }
    if (appId != nil && apiKey != nil) {
        [[TwinPushManager manager] setupTwinPushManagerWithAppId:appId apiKey:apiKey delegate:self];
    }
    else {
        NSLog(@"ERROR initializing TwinPush plugin. API Key or APP Id not set in config.xml");
    }
}

- (void)setAlias:(CDVInvokedUrlCommand*)command
{
    NSLog(@"setAlias method called");
    NSString* alias = [command.arguments objectAtIndex:0];

    self.aliasCommand = command;
    [TwinPushManager manager].alias = alias;
}

- (void)setRegisterCallback:(CDVInvokedUrlCommand *)command {
    self.registerCallbackCommand = command;
}

- (void)getDeviceId:(CDVInvokedUrlCommand *)command {
    NSString* deviceId = [TwinPushManager manager].deviceId;
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:deviceId];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)isRegistered:(CDVInvokedUrlCommand *)command {
    BOOL registered = [TwinPushManager manager].registered;
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:registered];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

#pragma mark - TwinPushManagerDelegate

- (void)didFinishRegisteringDevice {
    NSLog(@"Device registered to TwinPush successfully");
    if (self.aliasCommand != nil) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Alias successfully set"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.aliasCommand.callbackId];
        self.aliasCommand = nil;
    }
    if (self.registerCallbackCommand != nil) {
        NSString* deviceId = [TwinPushManager manager].deviceId;
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:deviceId];
        pluginResult.keepCallback = @(YES);
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.registerCallbackCommand.callbackId];
    }
}

- (void)didFailRegisteringDevice:(NSString *)error {
    NSLog(@"Failed to register to TwinPush: %@", error);
    if (self.aliasCommand != nil) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.aliasCommand.callbackId];
        self.aliasCommand = nil;
    }
    if (self.registerCallbackCommand != nil) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        pluginResult.keepCallback = @(YES);
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.registerCallbackCommand.callbackId];
    }
}

- (void)didSkipRegisteringDevice {
    if (self.aliasCommand != nil) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Alias didn't change"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.aliasCommand.callbackId];
        self.aliasCommand = nil;
    }
    if (self.registerCallbackCommand != nil) {
        NSString* deviceId = [TwinPushManager manager].deviceId;
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:deviceId];
        pluginResult.keepCallback = @(YES);
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.registerCallbackCommand.callbackId];
    }
}

@end
