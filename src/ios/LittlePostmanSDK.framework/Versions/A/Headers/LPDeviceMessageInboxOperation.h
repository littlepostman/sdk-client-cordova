//
//  LPDeviceMessageInboxOperation.h
//  LittlePostmanIOS
//
//  Created by Benjamin Broll on 30.09.14.
//  Copyright (c) 2014 NEXT Munich. The App Agency. All rights reserved.
//

#import "LPDeviceOperation.h"

@interface LPDeviceMessageInboxOperation : LPDeviceOperation

@property (nonatomic, readonly) NSArray *messages;

- (id)initForMessageInboxWithClientKey:(NSString *)clientKey token:(NSString *)token environment:(LPEnvironment)environment offset:(NSInteger)offset limit:(NSInteger)limit;

@end
