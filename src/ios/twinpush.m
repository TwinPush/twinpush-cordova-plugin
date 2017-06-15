/********* twinpush.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <TwinPushSDK/TwinPushManager.h>

@interface twinpush : CDVPlugin <TwinPushManagerDelegate> {
  // Member variables go here.
}

- (void)coolMethod:(CDVInvokedUrlCommand*)command;
@end

@implementation twinpush

-(void)pluginInitialize {
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

- (void)coolMethod:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = [command.arguments objectAtIndex:0];

    if (echo != nil && [echo length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
