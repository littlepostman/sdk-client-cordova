//
//  LPPushMessage.h
//  Little Postman SDK
//
//  Copyright (c) 2013-2014 Little Postman GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Lightweight object encapsulating a push message that was received by the
 * application.
 *
 * You can convert a message payload as it was received on the device in
 * -application:didFinishLaunchingWithOptions: or in -application:didReceiveRemoteNotification:
 * to an LPPushMessage object by passing the message payload to [LPPushClient messageFromPayload:]
 * method.
 */
@interface LPPushMessage : NSObject

/** @name Properties */

/** The id of the message. */
@property (readonly) NSInteger messageId;

/**
 * The message that was displayed to the user.
 *
 * Contains the information sent either as "content" or as "iosAlert".
 */
@property (readonly) NSString *message;

/**
 * Custom data that was sent along with the message.
 *
 * Contains the information sent either as "data" or as "iosData".
 */
@property (readonly) NSDictionary *data;


/** @name Initialization */

/**
 * Creates a new LPPushMessage object.
 *
 * This method should not directly be used. Instead, use the [LPPushClient messageFromPayload:] method
 * to construct an LPPushMessage object.
 *
 * @param messageId The id of the message.
 * @param message The message that was displayed to the user.
 * @param data Custom data that was sent along with the message.
 */
- (id)initWithMessageId:(NSInteger)messageId message:(NSString *)message data:(NSDictionary *)data;

@end
