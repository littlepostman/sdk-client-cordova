/********* LittlePostman.m Cordova Plugin Implementation *******/

#import "LittlePostman.h"


@implementation LittlePostman

- (void)configure:(CDVInvokedUrlCommand *)command
{
  CDVPluginResult *pluginResult = nil;

  NSString *clientAuthKey = [command.arguments objectAtIndex:0];
  NSString *environmentString = [command.arguments objectAtIndex:1];

  LPEnvironment environment = LPEnvironmentDevelopment;
  if ([environmentString isEqualToString:@"PROD"]) {
    environment = LPEnvironmentProduction;
  }

  self.pushClient = [[LPPushClient alloc] initWithClientKey:clientAuthKey environment:environment];

  if (self.pushClient) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerDidSucceed:) name:LPPushClientDidRegisterDeviceToken object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerDidFail:) name:LPPushClientRegisterDeviceTokenDidFail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unregisterDidSucceed:) name:LPPushClientDidUnregisterDeviceToken object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unregisterDidFail:) name:LPPushClientUnregisterDeviceTokenDidFail object:nil];

    [self processPendingPushReceivedJavaScriptCallIfNecessary];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self.pushClient description]];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
  }

  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)isRegistered:(CDVInvokedUrlCommand *)command
{
  CDVPluginResult *pluginResult = nil;

  if (self.pushClient) {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:self.pushClient.isDeviceTokenRegistered];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
  }

  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)register:(CDVInvokedUrlCommand *)command
{
  if (self.pushClient && !self.pendingRegisterCommand) {
    self.pendingRegisterCommand = command;

    [self startPushRegistrationFlow];
  } else {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }
}

- (void)unregister:(CDVInvokedUrlCommand *)command
{
  if (self.pushClient && !self.pendingUnregisterCommand) {
    self.pendingUnregisterCommand = command;

    [self.pushClient unregisterDeviceToken];
  } else {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }
}

- (void)setData:(CDVInvokedUrlCommand *)command
{
  if (self.pushClient && [self.pushClient isDeviceTokenRegistered]) {
    NSDictionary *data = [command argumentAtIndex:0];
    [self.pushClient setData:data];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:true];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  } else {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }
}


// ------------------------ Push registration flow

- (void)startPushRegistrationFlow {
    // determine, at runtime, whether the iOS version we're running on supports the new iOS 8
    // notification APIs
    SEL selector = NSSelectorFromString(@"registerUserNotificationSettings:");
    if ([UIApplication instancesRespondToSelector:selector]) {
      NSLog(@"start iOS 8+ push registration flow");

        // if the device supports the new iOS 8 notification APIs, make use of them
        UIUserNotificationType types = UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];

        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    } else {
      NSLog(@"start iOS 7 push registration flow");

        // if the device does not run on iOS 8 or later, we're falling back to the iOS 7 way of registering for
        // push notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
    }
}



// ------------------------ AppDelegate+LPSupport callbacks

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  self.pushClient.deviceToken = deviceToken;
  [self.pushClient registerDeviceToken];
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);

  [self registerDidFail:nil];
}

- (void)didReceivePushMessageWithPayload:(NSDictionary *)payload whileInForeground:(BOOL)inForeground {
  NSString *inForegroundString = @"true";
  if (!inForeground) {
    inForegroundString = @"false";
  }

  LPPushMessage *msg = [LPPushClient messageFromPayload:payload];

  NSDictionary *result = @{
    @"messageId" : [NSNumber numberWithInteger:msg.messageId],
    @"message" : msg.message,
    @"data" : msg.data
  };
  NSData *data = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
  NSString *messageJsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

  self.pendingPushReceivedJavaScriptCall = [NSString stringWithFormat:@"cordova.plugins.LittlePostman.onMessageReceived(%@, %@)", messageJsonString, inForegroundString];

  [self processPendingPushReceivedJavaScriptCallIfNecessary];
}

- (void)processPendingPushReceivedJavaScriptCallIfNecessary {
  if (self.pushClient != nil && self.pendingPushReceivedJavaScriptCall) {
    [self.commandDelegate evalJs:self.pendingPushReceivedJavaScriptCall];
    self.pendingPushReceivedJavaScriptCall = nil;
  }
}


// ------------------------ Little Postman SDK Notification callbacks

- (void)registerDidSucceed:(NSNotification *)notification {
    if (self.pendingRegisterCommand) {
      CDVInvokedUrlCommand *command = self.pendingRegisterCommand;
      self.pendingRegisterCommand = nil;

      CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)registerDidFail:(NSNotification *)notification {
  if (self.pendingRegisterCommand) {
    CDVInvokedUrlCommand *command = self.pendingRegisterCommand;
    self.pendingRegisterCommand = nil;

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:NO];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }
}

- (void)unregisterDidSucceed:(NSNotification *)notification {
    if (self.pendingUnregisterCommand) {
      CDVInvokedUrlCommand *command = self.pendingUnregisterCommand;
      self.pendingUnregisterCommand = nil;

      CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)unregisterDidFail:(NSNotification *)notification {
  if (self.pendingUnregisterCommand) {
    CDVInvokedUrlCommand *command = self.pendingUnregisterCommand;
    self.pendingUnregisterCommand = nil;

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:NO];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }
}

@end
