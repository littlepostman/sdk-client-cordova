
#import <Cordova/CDV.h>
#import <LittlePostmanSDK/LittlePostmanSDK.h>

@interface LittlePostman : CDVPlugin {

}

@property (strong) LPPushClient *pushClient;

@property (strong) CDVInvokedUrlCommand *pendingRegisterCommand;
@property (strong) CDVInvokedUrlCommand *pendingUnregisterCommand;

@property (strong) NSString *pendingPushReceivedJavaScriptCall;

// plugin actions
- (void)configure:(CDVInvokedUrlCommand *)command;

- (void)isRegistered:(CDVInvokedUrlCommand *)command;
- (void)register:(CDVInvokedUrlCommand *)command;
- (void)unregister:(CDVInvokedUrlCommand *)command;

- (void)setData:(CDVInvokedUrlCommand *)command;

// callbacks invoked by the application delegate
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

- (void)didReceivePushMessageWithPayload:(NSDictionary *)payload whileInForeground:(BOOL)inForeground;

@end
