//
//  HDHexConversion.h
//  Bridge Simulator
//
//  Created by Henk Meewis on 5/3/13.
//  Copyright (c) 2013 HunterDouglas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDHexConversion : NSObject

- (NSString *)stringFromByte:(Byte)byte;
- (BOOL)isHexChar:(unichar)character;
- (Byte)byteFromString:(NSString *)value;
- (NSString *)convertIPAddress:(NSString *)ipAddress;
- (NSUInteger)convert16bitHexToInteger:(NSString *)hex;
- (NSString *)convertIntegerTo16bitHex:(NSInteger)value;

@end
