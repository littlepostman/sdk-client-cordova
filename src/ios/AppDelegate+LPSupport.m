
#import "AppDelegate+LPSupport.h"

#import <objc/runtime.h>

#import "LittlePostman.h"


#define PLUGIN_NAME @"LittlePostman"

static char launchNotificationKey;


@implementation AppDelegate (LPSupport)

- (id) getCommandInstance:(NSString*)className
{
	return [self.viewController getCommandInstance:className];
}

// its dangerous to override a method from within a category.
// Instead we will use method swizzling. we set this up in the load call.
+ (void)load
{
    Method original, swizzled;

    original = class_getInstanceMethod(self, @selector(init));
    swizzled = class_getInstanceMethod(self, @selector(swizzled_init));
    method_exchangeImplementations(original, swizzled);

	original = class_getInstanceMethod(self, @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:));
    swizzled = class_getInstanceMethod(self, @selector(swizzled_application:didRegisterForRemoteNotificationsWithDeviceToken:));
    method_exchangeImplementations(original, swizzled);

	original = class_getInstanceMethod(self, @selector(application:didFailToRegisterForRemoteNotificationsWithError:));
    swizzled = class_getInstanceMethod(self, @selector(swizzled_application:didFailToRegisterForRemoteNotificationsWithError:));
    method_exchangeImplementations(original, swizzled);
}

- (AppDelegate *)swizzled_init
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishLaunching:) name:@"UIApplicationDidFinishLaunchingNotification" object:nil];

	return [self swizzled_init];
}


// ---------------- Handling the push registration flow

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"didRegisterUserNotificationSettings");

    // on iOS 8, register for receiving push notifications whenever the UIUserNotificationSettings have been registered
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)swizzled_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken");

    LittlePostman *littlePostman = [self getCommandInstance:PLUGIN_NAME];
    [littlePostman didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)swizzled_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError");

    LittlePostman *littlePostman = [self getCommandInstance:PLUGIN_NAME];
    [littlePostman didFailToRegisterForRemoteNotificationsWithError:error];
}


// ---------------- Handling incoming push notifications

- (void)didFinishLaunching:(NSNotification *)notification {
	if (notification && [notification userInfo]) {
		NSDictionary *launchOptions = [notification userInfo];
        self.launchNotification = [launchOptions objectForKey: @"UIApplicationLaunchOptionsRemoteNotificationKey"];
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (application.applicationState == UIApplicationStateActive) {
        [self didReceivePushMessageWithPayload:userInfo whileInForeground:YES];
    } else {
        self.launchNotification = userInfo;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (self.launchNotification) {
        [self didReceivePushMessageWithPayload:self.launchNotification whileInForeground:NO];
        self.launchNotification = nil;
    }
}

- (void)didReceivePushMessageWithPayload:(NSDictionary *)payload whileInForeground:(BOOL)inForeground {
    LittlePostman *littlePostman = [self getCommandInstance:PLUGIN_NAME];
    [littlePostman didReceivePushMessageWithPayload:payload whileInForeground:inForeground];
}


// ---------------- Storing the notification that was passed to -application:didFinishLaunchingWithOptions:

- (NSMutableArray *)launchNotification
{
   return objc_getAssociatedObject(self, &launchNotificationKey);
}

- (void)setLaunchNotification:(NSDictionary *)aDictionary
{
    objc_setAssociatedObject(self, &launchNotificationKey, aDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dealloc
{
    self.launchNotification	= nil; // clear the association and release the object
}

@end
