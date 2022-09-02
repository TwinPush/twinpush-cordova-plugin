/********* twinpush.m Cordova Plugin Implementation *******/

#import "TwinPush.h"

@interface TwinPush()
@property (nonatomic, retain) CDVInvokedUrlCommand* aliasCommand;
@property (nonatomic, retain) CDVInvokedUrlCommand* registerCallbackCommand;
@property (nonatomic, retain) CDVInvokedUrlCommand* notificationOpenCallbackCommand;
@property (nonatomic, retain) TPNotification* lastReceivedNotification;
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

- (void)setAlias:(CDVInvokedUrlCommand*)command {
    NSString* alias = [command argumentAtIndex:0];

    self.aliasCommand = command;
    [TwinPushManager manager].alias = alias;
}

- (void)setRegisterCallback:(CDVInvokedUrlCommand *)command {
    self.registerCallbackCommand = command;
}

- (void)setNotificationOpenCallback:(CDVInvokedUrlCommand *)command {
    self.notificationOpenCallbackCommand = command;
    
    if (_lastReceivedNotification != nil) {
        [self sendNotificationOpenToCallback:_lastReceivedNotification];
        _lastReceivedNotification = nil;
    }
}

- (void)getDeviceId:(CDVInvokedUrlCommand *)command {
    NSString* deviceId = [TwinPushManager manager].deviceId;
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:deviceId];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)setIntegerProperty:(CDVInvokedUrlCommand*)command {
    NSString* key = [command argumentAtIndex:0];
    NSNumber* value = [command argumentAtIndex:1];
    
    [[TwinPushManager manager] setProperty:key withIntegerValue:value];
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:value.intValue];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)setFloatProperty:(CDVInvokedUrlCommand*)command {
    NSString* key = [command argumentAtIndex:0];
    NSNumber* value = [command argumentAtIndex:1];
    
    [[TwinPushManager manager] setProperty:key withFloatValue:value];
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:value.doubleValue];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)setBooleanProperty:(CDVInvokedUrlCommand*)command {
    NSString* key = [command argumentAtIndex:0];
    NSNumber* value = [command argumentAtIndex:1];
    
    [[TwinPushManager manager] setProperty:key withBooleanValue:value];
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:value.boolValue];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)setStringProperty:(CDVInvokedUrlCommand*)command {
    NSString* key = [command argumentAtIndex:0];
    NSString* value = [command argumentAtIndex:1];
    
    [[TwinPushManager manager] setProperty:key withStringValue:value];
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:value];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)setLocation:(CDVInvokedUrlCommand *)command {
    double latitude = [[command argumentAtIndex:0] doubleValue];
    double longitude = [[command argumentAtIndex:1] doubleValue];
    
    [[TwinPushManager manager] setLocationWithLatitude:latitude longitude:longitude];
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)updateLocation:(CDVInvokedUrlCommand *)command {
    TPLocationPrecision precision = [[command argumentAtIndex:0 withDefault:@(TPLocationPrecisionMedium)] unsignedIntegerValue];
    TPLocationAccuracy accuracy;
    switch (precision) {
        case TPLocationPrecisionLow:
            accuracy = TPLocationAccuracyLow;
            break;
        case TPLocationPrecisionHigh:
            accuracy = TPLocationAccuracyHigh;
            break;
        case TPLocationPrecisionFine:
            accuracy = TPLocationAccuracyFine;
            break;
        case TPLocationPrecisionCoarse:
            accuracy = TPLocationAccuracyCoarse;
            break;
        default:
            accuracy = TPLocationAccuracyMedium;
            break;
    }
    [[TwinPushManager manager] updateLocation:accuracy];
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)sendNotificationOpenToCallback:(TPNotification*)notification {
    NSISO8601DateFormatter* dateFormatter = [[NSISO8601DateFormatter alloc] init];
    NSDictionary* notificationDict = @{
        @"notificationId": notification.notificationId ?: [NSNull null],
        @"message": notification.message ?: [NSNull null],
        @"title": notification.title ?: [NSNull null],
        @"subtitle": notification.subtitle ?: [NSNull null],
        @"contentUrl": notification.contentUrl ?: [NSNull null],
        @"tags": notification.tags ?: [NSNull null],
        @"customProperties": notification.customProperties ?: [NSNull null],
        @"date": [dateFormatter stringFromDate:notification.date]
    };
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:notificationDict options:0 error:nil];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonString];
    [self.commandDelegate sendPluginResult:result callbackId:_notificationOpenCallbackCommand.callbackId];
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

- (void)showNotification:(TPNotification *)notification {
    if (_registerCallbackCommand != nil) {
        [self sendNotificationOpenToCallback:notification];
    }
    else {
        // Save notification in case the callback is registered after the notification is received
        self.lastReceivedNotification = notification;
    }
}

@end
