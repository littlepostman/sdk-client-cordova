//
//  LPPushClient.h
//  Little Postman SDK
//
//  Copyright (c) 2013-2014 Little Postman GmbH. All rights reserved.
//

#define LPPushClientDidRegisterDeviceToken @"LPPushClientDidRegisterDeviceToken"
#define LPPushClientRegisterDeviceTokenDidFail @"LPPushClientRegisterDeviceTokenDidFail"

#define LPPushClientDidUnregisterDeviceToken @"LPPushClientDidUnregisterDeviceToken"
#define LPPushClientUnregisterDeviceTokenDidFail @"LPPushClientUnregisterDeviceTokenDidFail"

#define LPPushClientDidLoadMessageInbox @"LPPushClientDidLoadMessageInbox"
#define LPPushClientMessageInboxListKey @"LPPushClientMessageInboxListKey"
#define LPPushClientLoadMessageInboxDidFail @"LPPushClientLoadMessageInboxDidFail"


@class LPPushMessage;


/**
 * The device environment for which the device should be registered.
 *
 * Device can be registered on Little Postman servers either as development
 * or as production devices.
 */
typedef enum {
    LPEnvironmentDevelopment,
    LPEnvironmentProduction
} LPEnvironment;


/**
 * Main class to communicate between your app and the Little Postman servers.
 *
 * LPPushClient provides an easy-to-use class to facilitate communication with
 * the Little Postman servers. You can easily achieve the following tasks:
 *
 * 1. Device Management
 * 2. Tracking
 * 3. Data Storage
 * 4. Debugging
 *
 * Typically, the following steps are taken to activate push notifications in your
 * app and to subsequently register the device on Little Postman servers:
 *
 * 1. Initialize the LPPushClient using your app's client key and the appropriate
 *    device environment.
 * 2. Activate push notifications in your app by calling UIDevice's registerForRemoteNotificationTypes: method
 * 3. In your UIApplicationDelegate implementation, implement the method
 *    -application:didRegisterForRemoteNotificationsWithDeviceToken: by setting the provided device token using
 *    LPPushClient's deviceToken property and subsequently calling -registerDeviceToken
 *
 * @note This library requires iOS 5+ and can be used with MRR (manual retain/release)
 *       or ARC (automatic reference counting).
 */
@interface LPPushClient : NSObject <UIAlertViewDelegate>

/** @name Properties */

/**
 * The device token as it was provided by the
 * -application:didRegisterForRemoteNotificationsWithDeviceToken:
 * method.
 */
@property (nonatomic, retain) NSData *deviceToken;


#pragma mark Convenience Methods

/** @name Convenience Methods */

/**
 * Helper method to convert a device token into a string.
 *
 * @param token The device token as received in -application:didRegisterForRemoteNotificationsWithDeviceToken:
 *
 * @return The device token as an NSString
 */
+ (NSString *)deviceTokenAsString:(NSData *)token;

/**
 * Helper method to get a PushMessage object from a message's payload.
 *
 * @param payload The payload of a push message as received either in -application:didFinishLaunchingWithOptions:
 *                (UIApplicationLaunchOptionsRemoteNotificationKey) or in -application:didReceiveRemoteNotification:
 *
 * @return An instance of LPPushMessage representing the message payload
 */
+ (LPPushMessage *)messageFromPayload:(NSDictionary *)payload;


#pragma mark Initialization

/** @name Initialization */

/**
 * Initializes a new LPPushClient using the given key to authenticate with
 * the Little Postman servers.
 *
 * @param key The client key of the app on Little Postman.
 * @param environment The device environment to use. Use LPEnvironmentDevelopment for devices that
 *                    are used in a development context and use LPEnvironmentProduction for devices
 *                    that are used in a production context (like an App Store Distribution version).
 *
 * @return A fully initialized LPPushClient instance.
 */
- (id)initWithClientKey:(NSString *)key environment:(LPEnvironment)environment;


#pragma mark Registration

/** @name Registration */

/**
 * Checks whether the device token has already been registered with the server.
 *
 * @return Whether the device token is registered on Little Postman servers.
 */
- (BOOL)isDeviceTokenRegistered;

/**
 * Registers the device token with the server.
 */
- (void)registerDeviceToken;

/**
 * Unregisters the device token from the server.
 */
- (void)unregisterDeviceToken;


#pragma mark Tracking

/** @name Tracking */

/**
 * Notifies the server that the app has been launched.
 *
 * This provides statistical information about how many users have launched the app. The
 * information is, for example, used to target users based on their recent activity within
 * the app or to relate the timestamp of an app launch with the messages that have recently
 * been sent.
 */
- (void)notifyAppLaunch;

/**
 * Notifies the server that a given message has been received.
 *
 * This provides statistical information about how many users have opened the app due to a
 * certain push message and can be analyzed accordingly using the Little Postman tools.
 *
 * @param msg The message that was received. Use messageFromPayload to parse an LPPushMessage
 *            from a message payload that was received.
 */
- (void)notifyMessageHasBeenReceived:(LPPushMessage *)msg;


#pragma mark Data Storage

/** @name Data Storage */

/**
 * Associates the given data with the device token on the Little Postman server.
 *
 * The data can subsequently used to filter devices on the Little Postman servers and to
 * target individual devices accordingly.
 *
 * @param data The data to associate with the device.
 */
- (void)setData:(NSDictionary *)data;


#pragma mark Message Inbox

/** @name Message Inbox */

/**
 * Retrieves the device's message inbox from the Little Postman server.
 *
 * The message inbox contains all messages that have been sent to the current device.
 *
 * @param offset The offset of the first message to retrieve.
 * @param limit The maximum amount of messages to retrieve. A maximum of 100 messages can be
 *              retrieved in a single API call.
 */
- (void)loadMessageInboxWithOffset:(NSInteger)offset limit:(NSInteger)limit;


#pragma mark Device Detection

/** @name Device Detection */

/**
 * Starts device detection with the server.
 *
 * Device detection will display a UIAlertView which asks you to input an identifier you would
 * like to associate with the device. You can use the Little Postman tools to identify your
 * device on Little Postman servers using the given identifier.
 */
- (void)startDeviceDetection;

@end

