//
//  LPPreviousMessage.h
//  LittlePostmanIOS
//
//  Created by Benjamin Broll on 30.09.14.
//  Copyright (c) 2014 Little Postman GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Lightweight object encapsulating a push message that has in the past been sent to the device
 * and which has been retrieved from the device's message inbox.
 *
 * You can retrieve LPPreviousMessage objects by calling the -[LPPushClient loadMessageInboxWithOffset:limit:]
 * method and observing the appropriate NSNotificationCenter notifications which contain the message list
 * or which indicate an error.
 */
@interface LPPreviousMessage : NSObject

/** @name Properties */

/** The id of the message. */
@property (readonly) NSInteger messageId;

/** The content of the message. */
@property (readonly) NSString *content;

/** The date at which the message was sent to the device. */
@property (readonly) NSDate *timestamp;


/** @name Initialization */

/**
 * Creates a new LPPreviousMessage object.
 *
 * This method should not directly be used. Instead, retrieve the message inbox using the
 * -[LPPushClient loadMessageInboxWithOffset:limit:] method.
 *
 * @param messageId The id of the message.
 * @param json The JSON data received from the LP JSON-RPC API.
 */
- (id)initWithMessageId:(NSInteger)messageId jsonDictionary:(NSDictionary *)json;

@end
