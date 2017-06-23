/********* twinpush.m Cordova Plugin Implementation *******/

#import "TwinPush.h"

@interface TwinPush()
@property (nonatomic, retain) CDVInvokedUrlCommand* lastCommand;
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

    self.lastCommand = command;
    [TwinPushManager manager].alias = alias;
}

#pragma mark - TwinPushManagerDelegate

- (void)didFinishRegisteringDevice {
    NSLog(@"Device registered to TwinPush successfully");
    if (self.lastCommand != nil) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Alias successfully set"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.lastCommand.callbackId];
        self.lastCommand = nil;
    }
}

- (void)didFailRegisteringDevice:(NSString *)error {
    NSLog(@"Failed to register to TwinPush: %@", error);
    if (self.lastCommand != nil) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.lastCommand.callbackId];
        self.lastCommand = nil;
    }
}

- (void)didSkipRegisteringDevice {
    NSLog(@"TwinPush register information didn't change");
    if (self.lastCommand != nil) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Alias didn't change"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.lastCommand.callbackId];
        self.lastCommand = nil;
    }
}

@end
