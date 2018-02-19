//
//  HD_System.h
//  HD-Cycler
//
//  Created by Henk Meewis on 9/5/13.
//  Copyright (c) 2013 Henk Meewis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>

@class UIPopupView;

@interface HD_System : NSObject
{
    NSFileManager *fileManager;
    UIPopupView *popupView;
    BOOL popupViewActive;
}

- (void)vibrate;
- (BOOL)isPad;
- (BOOL)isPrintable:(char)thisCharacter;
- (NSString *)visualizeContent:(NSString *)content;
- (NSString *)getValueStringFor:(NSUInteger)value startingWithCapital:(BOOL)capital;
- (UIView *)makeHeaderViewWithText:(NSString *)thisText
                      andTextColor:(UIColor *)thisTextColor
                       andTextSize:(NSUInteger)thisTextSize
                         andOffset:(CGFloat)offset
                    withBackground:(BOOL)backGround;
- (NSURL *)urlForDocumentDirectory;
- (NSString *)generateUniqueKey;
- (void)displayBoolWithName:(NSString *)name andValue:(BOOL)value;
- (void)sendMethod:(NSString *)methodName toDelegate:(id)thisDelegate;
- (void)sendSelector:(SEL)thisSelector toDelegate:(id)thisDelegate;
- (void)sendSelector:(SEL)thisSelector withObject:(NSNumber *)thisNumber toDelegate:(id)thisDelegate;
- (NSString *)base64EncodedStringWithString:(NSString *)name;
- (NSString *)decodedBase64StringFromString:(NSString *)encodedString;
- (void)showPopupViewWithText:(NSString *)text inView:(UIView *)thisView;
- (void)hidePopupViewAfterDelay:(CGFloat)delay;
- (void)displayUnderlinedText:(NSString *)text inLabel:(UILabel *)textLabel;
- (NSUInteger)read16bitValueFromBuffer:(unsigned char *)thisBuffer
                        withStartIndex:(unsigned char)startIndex;
- (NSString *)getNameFromBuffer:(unsigned char *)thisBuffer
                 withStartIndex:(unsigned char)startIndex
                      andLength:(unsigned char)length;
- (void)displayBuffer:(unsigned char *)thisBuffer
           withOffset:(NSUInteger)addressOffset
            andLength:(NSUInteger)thisLength;
- (NSString *)getIDString:(NSUInteger)thisID;
- (NSString *)getIDStringWithDescription:(NSString *)description andID:(uint)thisID;

@end
