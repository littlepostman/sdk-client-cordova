//
//  LPDeviceMessageInboxOperation.m
//  LittlePostmanIOS
//
//  Created by Benjamin Broll on 30.09.14.
//  Copyright (c) 2014 NEXT Munich. The App Agency. All rights reserved.
//

#import "LPDeviceMessageInboxOperation.h"
#import "LPDeviceOperation+Private.h"

#import "LPARCHelper.h"
#import "LPPreviousMessage.h"


@implementation LPDeviceMessageInboxOperation

- (id)initForMessageInboxWithClientKey:(NSString *)clientKey token:(NSString *)t environment:(LPEnvironment)env offset:(NSInteger)offset limit:(NSInteger)limit {
    if ((self = [super initWithClientKey:clientKey token:t environment:env])) {
        self.mode = LPDeviceOperationModeMessageInbox;
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
        [params setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
        
        [self setRequestFunction:@"messageInbox" withParams:params];
    }
    
    return self;
}


- (NSArray *)messages {
    NSMutableArray *parsedMessages = [NSMutableArray array];
    
    NSDictionary *messages = [self functionResult];
    for (NSString *key in messages) {
        NSDictionary *message = [messages objectForKey:key];
        
        LPPreviousMessage *previousMessage = [[[LPPreviousMessage alloc] initWithMessageId:[key integerValue]
                                                                            jsonDictionary:message] LP_AUTORELEASE];
        [parsedMessages addObject:previousMessage];
    }
    
    [parsedMessages sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        LPPreviousMessage *m1 = (LPPreviousMessage *)obj1;
        LPPreviousMessage *m2 = (LPPreviousMessage *)obj2;
        
        // use m2 first to sort descendingly
        return [m2.timestamp compare:m1.timestamp];
    }];
    
    return parsedMessages;
}

@end
