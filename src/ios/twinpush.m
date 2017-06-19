/********* twinpush.m Cordova Plugin Implementation *******/

#import "TwinPush.h"

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

    [self.commandDelegate runInBackground:^{
        [TwinPushManager manager].alias = alias;
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Alias successfully set"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

#pragma mark - TwinPushManagerDelegate
- (void)showNotification:(TPNotification *)notification {
    // Empty implementation. Don't show native view over Cordova webview
}

@end
