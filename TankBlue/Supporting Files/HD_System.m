//
//  HD_System.m
//  HD-Cycler
//
//  Created by Henk Meewis on 9/5/13.
//  Copyright (c) 2013 Henk Meewis. All rights reserved.
//

#import "UIPopupView.h"
#import "HDHexConversion.h"

#import "HD_System.h"

extern HDHexConversion *hdHexConversion;

@implementation HD_System

- (id)init
{
    self = [super init];
    if(self) {
        fileManager = [NSFileManager defaultManager];
    }
    return self;
}

- (void)vibrate
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

- (BOOL)isPad
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

- (BOOL)isPrintable:(char)thisCharacter
{
    return (thisCharacter >= 32) && (thisCharacter <= 126);
}

- (NSString *)visualizeContent:(NSString *)content
{
    // pick content string apart
    unichar thisCharacter, thisCharacterArray[1];
    NSString *result = @"", *singleCharacter;
    BOOL newCharPrintable, lastCharPrintable = NO;
    
    for(NSInteger pointer = 0; pointer < [content length]; pointer++) {
        thisCharacter = [content characterAtIndex:pointer];
        
        newCharPrintable = [self isPrintable:thisCharacter];
        if(newCharPrintable) {
            if(!lastCharPrintable) result = [result stringByAppendingString:@" \""];
            thisCharacterArray[0] = thisCharacter;
            singleCharacter = [NSString stringWithCharacters:thisCharacterArray length:1];
        }
        else {
            singleCharacter = [NSString stringWithFormat:@"[%d]", thisCharacter];
            if(lastCharPrintable) result = [result stringByAppendingString:@"\" "];
        }
        
        result = [result stringByAppendingString:singleCharacter];
        lastCharPrintable = newCharPrintable;
    }
    if(lastCharPrintable) result = [result stringByAppendingString:@"\" "];
    
    return result;
}

- (NSString *)getValueStringForOneToNine:(NSUInteger)value
{
    NSString *valueString;
    switch(value) {
        case 1: valueString = @"one"; break;
        case 2: valueString = @"two"; break;
        case 3: valueString = @"three"; break;
        case 4: valueString = @"four"; break;
        case 5: valueString = @"five"; break;
        case 6: valueString = @"six"; break;
        case 7: valueString = @"seven"; break;
        case 8: valueString = @"eight"; break;
        case 9: valueString = @"nine";
    }
    return valueString;
}

- (NSString *)getValueStringForZeroToNineteen:(NSUInteger)value
{
    NSString *valueString;
    switch(value) {
        case 0: valueString = @"no"; break;
        case 10: valueString = @"ten"; break;
        case 11: valueString = @"eleven"; break;
        case 12: valueString = @"twelve"; break;
        case 13: valueString = @"thirteen"; break;
        case 14: valueString = @"fourteen"; break;
        case 15: valueString = @"fifteen"; break;
        case 16: valueString = @"sixteen"; break;
        case 17: valueString = @"seventeen"; break;
        case 18: valueString = @"eightteen"; break;
        case 19: valueString = @"nineteen"; break;
        default: valueString = [self getValueStringForOneToNine:value];
    }
    return valueString;
}

- (NSString *)getValueStringFor:(NSUInteger)value startingWithCapital:(BOOL)capital
{
    NSString *valueString;
    if(value < 20) {
        valueString = [self getValueStringForZeroToNineteen:value];
        if(capital) valueString = [valueString capitalizedString];
    }
    else if(value < 100) {
        valueString = @"a lot of";
        NSUInteger ones = value % 10, tens = value / 10;
        switch(tens) {
            case 2: valueString = @"twenty"; break;
            case 3: valueString = @"thirty"; break;
            case 4: valueString = @"forty"; break;
            case 5: valueString = @"fifty"; break;
            case 6: valueString = @"sixty"; break;
            case 7: valueString = @"seventy"; break;
            case 8: valueString = @"eighty"; break;
            case 9: valueString = @"ninety"; break;
        }
        if(capital) valueString = [valueString capitalizedString];
        if(ones) {
            valueString = [valueString stringByAppendingString:@"-"];
            valueString = [valueString stringByAppendingString:[self getValueStringForOneToNine:ones]];
        }
    }
    else valueString = [NSString stringWithFormat:@"%d", (uint)value];
    return valueString;
}

- (UIView *)makeHeaderViewWithText:(NSString *)thisText
                      andTextColor:(UIColor *)thisTextColor
                       andTextSize:(NSUInteger)thisTextSize
                         andOffset:(CGFloat)offset
                    withBackground:(BOOL)backGround
{
    NSUInteger longLimit = [self isPad] ? 80 : 35;
    CGFloat screenWidth = [self isPad] ? 768.0 : 320.0;
    
    BOOL longLine = ([thisText length] > longLimit);
    CGFloat height = longLine ? 45.0 : 30.0;
    
    UIFont *font = [UIFont fontWithName:@"Arial-ItalicMT" size:thisTextSize];
    
    // DLog(@"make header view with text: %@", thisText);
    // if(longLine) DLog(@"long line");
    
    // create view for text
    CGRect frame = CGRectMake(offset, 0.0, screenWidth - offset, height);
    UILabel *textView = [[UILabel alloc] initWithFrame:frame];
    [textView setFont:font];
    if(longLine) [textView setNumberOfLines:2];
    [textView setTextColor:thisTextColor];
    [textView setText:thisText];
    
    frame = CGRectMake(0.0, 0.0, screenWidth, height);
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    if(backGround) {
        [headerView setBackgroundColor:[UIColor whiteColor]];
        [headerView setAlpha:0.75];
    }
    [headerView addSubview:textView];
    
    return headerView;
}

/* not used anymore - check out urlForDocumentDirectory
- (NSString *)pathForDocumentDirectory
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory,
        NSUserDomainMask,
        YES);
    
    // there is only one for iOS
    return [documentDirectories objectAtIndex:0];
}
*/

- (NSURL *)urlForDocumentDirectory
{
    NSArray *urlPaths = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    return [urlPaths objectAtIndex:0];
}

- (NSString *)generateUniqueKey
{
    // create a CFUUID object - it knows how to create unique identifier strings
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    NSString *uniqueKeyString = (__bridge NSString *)(newUniqueIDString);
    // [uniqueKeyString retain];
    
    // clean up
    CFRelease(newUniqueIDString);
    CFRelease(newUniqueID);

    // now make it a NSString object (use toll free bridging, at least as ARP were used)
    return uniqueKeyString;
}

- (void)displayBoolWithName:(NSString *)name andValue:(BOOL)value
{
    NSString *valueString = value ? @"true" : @"false";
    NSLog(@"  BOOL %@ == %@", name, valueString);
}

- (void)sendMethod:(NSString *)methodName toDelegate:(id)thisDelegate
{
    // DLog(@"send for method \"%@\"", methodName);
    SEL selector = NSSelectorFromString(methodName);
    
    // here follows some incomprehensible code from stackoverflow.com
    IMP imp = [thisDelegate methodForSelector:selector];
    void (* func)(id, SEL) = (void *)imp;
    func(thisDelegate, selector);
}

- (void)sendSelector:(SEL)thisSelector toDelegate:(id)thisDelegate
{
    // here follows some incomprehensible code from stackoverflow.com
    IMP imp = [thisDelegate methodForSelector:thisSelector];
    void (* func)(id, SEL) = (void *)imp;
    func(thisDelegate, thisSelector);
}

- (void)sendSelector:(SEL)thisSelector withObject:(NSNumber *)thisNumber toDelegate:(id)thisDelegate
{
    // here follows some incomprehensible code from stackoverflow.com
    IMP imp = [thisDelegate methodForSelector:thisSelector];
    void (* func)(id, SEL, NSNumber *) = (void *)imp;
    func(thisDelegate, thisSelector, thisNumber);
}

- (NSString *)base64EncodedStringWithString:(NSString *)name
{
    NSData *intermedeateName = [name dataUsingEncoding:NSUTF8StringEncoding];
    return [intermedeateName base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (NSString *)decodedBase64StringFromString:(NSString *)encodedString
{
    NSString *result;
    
    if(encodedString) {
        // DLog(@"base64 encoded string: %@", encodedString);
        
        // decode
        NSData *base64EncodedName = [encodedString dataUsingEncoding:NSUTF8StringEncoding];
        NSData *backToOriginalName = [[NSData alloc] initWithBase64EncodedData:base64EncodedName options:NSDataBase64DecodingIgnoreUnknownCharacters];
        result = [[NSString alloc] initWithData:backToOriginalName encoding:NSUTF8StringEncoding];
    }
    else result = @"not valid";
    
    return result;
}

- (void)showPopupViewWithText:(NSString *)text inView:(UIView *)thisView
{
    if(!popupViewActive) {
        popupView = [[UIPopupView alloc] init];
        [popupView setPopupType:UIPopupViewTypeLoading];
        [popupView setPopupBackgroundColor:[UIColor darkGrayColor]];
        [popupView setPopupBackgroundAlpha:0.7];
        [popupView setTitleColor:[UIColor yellowColor]];
        [popupView setTitle:text];
        [thisView addSubview:popupView];
        [popupView show]; // or use -[showAfterDelay:]
    }
    popupViewActive = true;
}

- (void)hidePopupViewAfterDelay:(CGFloat)delay
{
    if(popupViewActive) [popupView hideAfterDelay:delay];
    popupViewActive = false;
}

- (void)displayUnderlinedText:(NSString *)text inLabel:(UILabel *)textLabel
{
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                                                                         attributes:underlineAttribute];
    [textLabel setAttributedText:attributedText];
}

- (NSUInteger)read16bitValueFromBuffer:(unsigned char *)thisBuffer
                        withStartIndex:(unsigned char)startIndex
{
    return 256 * thisBuffer[startIndex] + thisBuffer[startIndex + 1];
}

- (NSString *)getNameFromBuffer:(unsigned char *)thisBuffer
                 withStartIndex:(unsigned char)startIndex
                      andLength:(unsigned char)length
{
    char *nameBuf = malloc(length);
    for(unsigned char n = 0; n < length; n++) nameBuf[n] = thisBuffer[startIndex + n];
    NSString *encodedName = [[NSString alloc] initWithBytesNoCopy:nameBuf length:length encoding:NSUTF8StringEncoding freeWhenDone:true];
    return [self decodedBase64StringFromString:encodedName];
}

- (void)displayBuffer:(unsigned char *)thisBuffer
           withOffset:(NSUInteger)addressOffset
            andLength:(NSUInteger)thisLength
{
    NSUInteger addressPointer = 0, byteCounterForLine, lineStartAddressPointer;
    NSString *bytePairString, *line, *addressString;
    
    NSLog(@"\n");
    
    // main loop for all data
    while(addressPointer < thisLength) {
        
        // start new line
        addressString = [hdHexConversion convertIntegerTo16bitHex:addressPointer + addressOffset];
        line = [NSString stringWithFormat:@"address: %@ - ", addressString];
        byteCounterForLine = 0;
        lineStartAddressPointer = addressPointer;
        
        // loop for hex data single line
        while((addressPointer < thisLength) && (byteCounterForLine++ < 32)) {
            bytePairString = [hdHexConversion stringFromByte:thisBuffer[addressPointer++]];
            line = [line stringByAppendingString:bytePairString];
        }
        
        // finish first part of line
        while(byteCounterForLine++ < 32) line = [line stringByAppendingString:@"  "];
        
        // start second part of line
        addressPointer = lineStartAddressPointer;
        byteCounterForLine = 0;
        NSString *singleCharString;
        unichar singleChar[1];
        line = [line stringByAppendingString:@"   "];
        
        // loop for printable data single line
        while((addressPointer < thisLength) && (byteCounterForLine++ < 32)) {
            singleChar[0] = thisBuffer[addressPointer++];
            if(![self isPrintable:singleChar[0]]) singleChar[0] = '.';
            singleCharString = [NSString stringWithCharacters:singleChar length:1];
            line = [line stringByAppendingString:singleCharString];
        }
        
        NSLog(@"%@", line);
    }
    NSLog(@"\n");
}

- (NSString *)getIDString:(NSUInteger)thisID
{
    return [NSString stringWithFormat:@"ID: 0x%04x (%d)", (uint)thisID, (uint)thisID];
}

- (NSString *)getIDStringWithDescription:(NSString *)description andID:(uint)thisID
{
    return [NSString stringWithFormat:@"%@ %@", description, [self getIDString:thisID]];
}

@end
