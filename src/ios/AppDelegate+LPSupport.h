
#import "AppDelegate.h"

@interface AppDelegate (LPSupport)

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (id)getCommandInstance:(NSString *)className;

@property (nonatomic, strong) NSDictionary *launchNotification;

@end
