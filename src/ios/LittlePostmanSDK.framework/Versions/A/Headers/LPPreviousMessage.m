//
//  LPPreviousMessage.m
//  LittlePostmanIOS
//
//  Created by Benjamin Broll on 30.09.14.
//  Copyright (c) Little Postman GmbH. All rights reserved.
//

#import "LPPreviousMessage.h"
#import "LPARCHelper.h"

@implementation LPPreviousMessage

#pragma mark Properties

@synthesize messageId, content, timestamp;


#pragma mark Init & Dealloc

- (id)initWithMessageId:(NSInteger)mid jsonDictionary:(NSDictionary *)json {
    if ((self = [super init])) {
        NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] LP_AUTORELEASE];
        dateFormat.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        messageId = mid;
        content = [[json objectForKey:@"content"] copy];
        
        id value = [json objectForKey:@"timestamp"];
        if ([value isKindOfClass:[NSString class]]) {
            NSString *timestampString = (NSString *)value;
            timestamp = [[dateFormat dateFromString:timestampString] copy];
        } else {
            timestamp = nil;
        }
    }
    
    return self;
}

- (void)dealloc {
    [content LP_RELEASE];
    [timestamp LP_RELEASE];
    
    [super LP_DEALLOC];
}

@end
