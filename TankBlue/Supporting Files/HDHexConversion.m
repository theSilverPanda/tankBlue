//
//  HDHexConversion.m
//  Bridge Simulator
//
//  Created by Henk Meewis on 5/3/13.
//  Copyright (c) 2013 HunterDouglas. All rights reserved.
//

#import "HDHexConversion.h"

@implementation HDHexConversion

- (id)init
{
    self = [super init];
    return self;
}

- (char)characterFromNibble:(Byte)nibble
{
    return (nibble < 10) ? 48 + nibble : 55 + nibble;
}

- (NSString *)stringFromByte:(Byte)byte
{
    char c_string[2];
    
    // first nibble
    Byte nibble = byte >> 4;
    c_string[0] = [self characterFromNibble:nibble];
    
    // second nibble
    nibble = byte & 0x0F;
    c_string[1] = [self characterFromNibble:nibble];
    
    NSString *result = [NSString stringWithCString:c_string encoding:NSASCIIStringEncoding];
    result = [result substringToIndex:2];
    
    return result;
}

- (BOOL)isHexChar:(unichar)character
{
    return ((character >= 48) && (character <= 57)) || ((character >= 65) && (character <= 70)) || ((character >= 97) && (character <= 102));
}

- (Byte)byteFromChar:(char)character
{
    Byte byte = '\0';
    if((character >= 48) && (character <= 57)) byte = character - 48;
    if((character >= 65) && (character <= 70)) byte = character - 55;
    if((character >= 97) && (character <= 102)) byte = character - 87;
    return byte;
}

- (Byte)byteFromString:(NSString *)value
{
    Byte byte = [self byteFromChar:[value characterAtIndex:0]];
    byte = byte << 4;
    
    byte += [self byteFromChar:[value characterAtIndex:1]];
    
    return byte;
}

- (NSString *)convertIPAddress:(NSString *)ipAddress
{
    NSString *number, *convertedIPAddress = @"0x";
    
    // convert 137.135.40.161 into 0x898728A1 (for instance)
    NSUInteger length = [ipAddress length], pointer = 0, start;
    NSRange range;
    Byte singleByte;
    
    // there are 4 sections in the IP address
    for(NSUInteger n = 0; n < 4; n++) {
        
        // find either next dot or end
        start = pointer;
        while((pointer < length) && ([ipAddress characterAtIndex:pointer] != '.')) pointer++;
        
        // separate single number
        range.location = start;
        range.length = pointer - start;
        number = [ipAddress substringWithRange:range];
        singleByte = [number intValue];
        
        // add to converted IP address string
        number = [self stringFromByte:singleByte];
        convertedIPAddress = [convertedIPAddress stringByAppendingString:number];
        
        // to proceed for the next section
        pointer++;
        start = pointer;
    }
    return convertedIPAddress;
}

- (NSUInteger)convert16bitHexToInteger:(NSString *)hex
{
    // 16 bit hex format: 0x012a
    NSUInteger result = 0;
    unichar thisChar;
    Byte singleByte;
    
    for(NSUInteger n = 0; n < 4; n++) {
        thisChar = [hex characterAtIndex:n + 2];
        singleByte = [self byteFromChar:thisChar];
        switch(n) {
            case 0:
                result = singleByte * 4096;
                break;
            case 1:
                result += singleByte * 256;
                break;
            case 2:
                result += singleByte * 16;
                break;
            case 3:
                result += singleByte;
                break;
        }
    }
    return result;
}

- (NSString *)convertIntegerTo16bitHex:(NSInteger)value
{
    NSString *hex = @"0x";
    
    Byte singleByte = value / 256;
    hex = [hex stringByAppendingString:[self stringFromByte:singleByte]];
    
    singleByte = value % 256;
    return [hex stringByAppendingString:[self stringFromByte:singleByte]];
}
@end
