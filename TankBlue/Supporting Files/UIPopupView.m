//
//  UIPopupView.m
//  UIPopupSuite
//
//  Created by Aaron Wojnowski on 11-10-31.
//  Copyright (c) 2011 Aaron Wojnowski. All rights reserved.
//

#import "UIPopupView.h"

#import <QuartzCore/QuartzCore.h>

#pragma mark -
#pragma mark Image Tint

//  Created by Matt Gemmell on 04/07/2010.
//  Copyright 2010 Instinctive Code.

@interface UIImage (Tint)
    
-(UIImage *)tintImageWithColor:(UIColor *)color fraction:(CGFloat)fraction;
    
@end

#pragma mark -
#pragma mark Image Tint Implementation

//  Created by Matt Gemmell on 04/07/2010.
//  Copyright 2010 Instinctive Code.

@implementation UIImage (Tint)

-(UIImage *)tintImageWithColor:(UIColor *)color fraction:(CGFloat)fraction {
    
    if (color) {
		UIImage *image;
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
                UIGraphicsBeginImageContextWithOptions([self size], NO, 0.0); // 0.0 for scale means "scale for device's main screen".
            }
        #else
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
                UIGraphicsBeginImageContext([self size]);
            }
        #endif
		CGRect rect = CGRectZero;
		rect.size = [self size];
        
		[color set];
		UIRectFill(rect);
        
		[self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
        
		if (fraction > 0.0) {
			[self drawInRect:rect blendMode:kCGBlendModeSourceAtop alpha:fraction];
		}
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
        
		return image;
	}
    
	return self;
    
}

@end

#pragma mark -
#pragma mark Private Methods

@interface UIPopupView (Private)

-(NSString *)defaultTitleForPopupType:(UIPopupViewType)type;
-(UIImage *)tintImage:(UIImage *)image withColor:(UIColor *)color fraction:(CGFloat)fraction;
-(void)getRGBComponents:(CGFloat [3])components forColor:(UIColor *)color;

@end

#pragma mark -
#pragma mark Implementation

@implementation UIPopupView

@synthesize popupType=_popupType, introductionAnimation=_introductionAnimation, introductionAnimationLength=_introductionAnimationLength, introductionAnimationCompletionBlock=_introductionAnimationCompletionBlock, hideAnimation=_hideAnimation, hideAnimationLength=_hideAnimationLength;
@synthesize hideAnimationCompletionBlock=_hideAnimationCompletionBlock;
@synthesize popupView=_popupView, popupBackgroundAlpha=_popupBackgroundAlpha, popupBackgroundColor=_popupBackgroundColor, popupImageColor=_popupImageColor, popupCornerRadius=_popupCornerRadius, popupBorderColor=_popupBorderColor, popupBorderWidth=_popupBorderWidth;
@synthesize title=_title, titleAlignment=_titleAlignment;
@synthesize titleLabel=_titleLabel, titleColor=_titleColor;
@synthesize informationText=_informationText, informationTextAlignment=_informationTextAlignment;

#pragma mark -
#pragma mark View Lifecycle

-(id)init {
    
    self = [super init];
    if (self) {
        
        [self setPopupType:UIPopupViewTypeInformation];
        
        [self setIntroductionAnimation:UIPopupViewAnimationNone];
        [self setIntroductionAnimationLength:0.3];
        
        [self setHideAnimation:UIPopupViewAnimationNone];
        [self setHideAnimationLength:0.3];
        [self setHideAnimationCompletionBlock:nil];
        
        [self setPopupBackgroundColor:[UIColor blackColor]];
        [self setPopupBackgroundAlpha:0.75];
        [self setPopupImageColor:[UIColor whiteColor]];
        [self setPopupBorderColor:[UIColor whiteColor]];
        [self setPopupBorderWidth:0.0];
        
        [self setTitle:[self defaultTitleForPopupType:[self popupType]]];
        [self setTitleAlignment:NSTextAlignmentCenter];
        
        [self setInformationTextAlignment:NSTextAlignmentLeft];
        
        [self setTitleColor:[UIColor whiteColor]];
        
        [self setPopupCornerRadius:10.0];
                
    }
    return self;
    
}

-(void)dealloc {
    
    [self setIntroductionAnimationCompletionBlock:nil];
    [self setHideAnimationCompletionBlock:nil];
    
    [self setPopupView:nil];
    [self setPopupBackgroundColor:nil];
    [self setPopupImageColor:nil];
    [self setPopupBorderColor:nil];
    
    [self setTitle:nil];
    
    [self setTitleLabel:nil];
    [self setTitleColor:nil];
    
    [self setInformationText:nil];
    
}

#pragma mark -
#pragma mark Custom Methods

-(void)showAfterDelay:(float)seconds {
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self show];
    });
    
}

-(void)show {
    
    [self setFrame:[[self superview] frame]];
    [self setBackgroundColor:[UIColor clearColor]];
    [[[self subviews] mutableCopy] removeAllObjects];
    
    float superview_height = [[self superview] frame].size.height;
    float superview_width = [[self superview] frame].size.width;
    
    UIView *popupView_temp = [[UIView alloc] init];
    
    CGFloat components[3];
    [self getRGBComponents:components forColor:[self popupBackgroundColor]];
    [popupView_temp setBackgroundColor:[UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:[self popupBackgroundAlpha]]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    [titleLabel setText:[self title]];
    [titleLabel setTextAlignment:[self titleAlignment]];
    [titleLabel setTextColor:[self titleColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel sizeToFit];
    
    // Whether we should increase the width based on title size, or keep true to the 80x80 dimensions.
    if ([titleLabel frame].size.width > 80 - WIDTH_PADDING) {
        
        float title_width = [titleLabel frame].size.width;
        
        [titleLabel setFrame:CGRectMake((WIDTH_PADDING / 2.0), 6, title_width, 20)]; 
        
        [popupView_temp setFrame:CGRectMake((superview_width - (title_width + WIDTH_PADDING)) / 2.0, (superview_height - 80) / 2.0, (title_width + WIDTH_PADDING), 80)];
        
    } else {
        
        [titleLabel setFrame:CGRectMake(5, 5, 70, 20)]; 
        
        [popupView_temp setFrame:CGRectMake((superview_width - 80) / 2.0, (superview_height - 80) / 2.0, 80, 80)];
        
    }
    
    [popupView_temp addSubview:titleLabel];
    [self setTitleLabel:titleLabel];
    
    // Show custom objects.
    UIImageView *middle_image = nil;
    UIActivityIndicatorView *loading_activity = nil;
    UILabel *informationLabel = nil;
    
    CGRect middle_rect = CGRectMake(([popupView_temp frame].size.width - 20) / 2.0, ([popupView_temp frame].size.height - 20 + 20 /*label height*/) / 2.0, 20, 20);
    switch ([self popupType]) {
        case UIPopupViewTypeCancel:
            middle_image = [[UIImageView alloc] init];
            [middle_image setFrame:middle_rect];
            [middle_image setImage:[[UIImage imageNamed:@"UIPopupView_x.png"] tintImageWithColor:[self popupImageColor] fraction:0.0]];
            
            [popupView_temp addSubview:middle_image];
            break;
        case UIPopupViewTypeConfirm:
            middle_image = [[UIImageView alloc] init];
            [middle_image setFrame:middle_rect];
            [middle_image setImage:[[UIImage imageNamed:@"UIPopupView_checkmark.png"] tintImageWithColor:[self popupImageColor] fraction:0.0]];
            [popupView_temp addSubview:middle_image];
            break;
        case UIPopupViewTypeLoading:           
            loading_activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [loading_activity setFrame:middle_rect];
            [loading_activity startAnimating];
            [popupView_temp addSubview:loading_activity];
            break;
        case UIPopupViewTypeInformation:
            informationLabel = [[UILabel alloc] init];
            [informationLabel setFrame:CGRectMake((WIDTH_PADDING / 2.0), 35, 0, 0)];
            [informationLabel setNumberOfLines:0];
            [informationLabel setFont:[UIFont systemFontOfSize:14.0]];
            [informationLabel setBackgroundColor:[UIColor clearColor]];
            [informationLabel setTextColor:[UIColor whiteColor]];
            [informationLabel setTextAlignment:[self informationTextAlignment]];
            [informationLabel setText:[self informationText]];
            
            [informationLabel sizeToFit];
            
            int popup_height = [informationLabel frame].size.height + 45;
                    
            // If we should change the box and label sizes based on the text included.
            if ([informationLabel frame].size.width > [popupView_temp frame].size.width) {
                                
                [informationLabel setFrame:CGRectMake([informationLabel frame].origin.x, [informationLabel frame].origin.y, 300 - WIDTH_PADDING, 0)];
                [informationLabel setLineBreakMode:NSLineBreakByWordWrapping];
                [informationLabel sizeToFit];
                
                popup_height = [informationLabel frame].size.height + 45;
                                
                [popupView_temp setFrame:CGRectMake((superview_width - ([informationLabel frame].size.width + WIDTH_PADDING)) / 2.0, (superview_height - popup_height) / 2.0, ([informationLabel frame].size.width + WIDTH_PADDING), popup_height)];
                [[self titleLabel] setFrame:CGRectMake([[self titleLabel] frame].origin.x, [[self titleLabel] frame].origin.y, [informationLabel frame].size.width, 20)];
                            
            } else {
                                
                [popupView_temp setFrame:CGRectMake([popupView_temp frame].origin.x, (superview_height - popup_height) / 2.0, [popupView_temp frame].size.width, popup_height)];
                
            }
                        
            [popupView_temp addSubview:informationLabel];
            break;
        default:
            break;
    }
    
    [[popupView_temp layer] setCornerRadius:[self popupCornerRadius]];
    
    if ([self popupBorderWidth] > 0) {
        [[popupView_temp layer] setBorderColor:[[self popupBorderColor] CGColor]];
        [[popupView_temp layer] setBorderWidth:[self popupBorderWidth]];
    }
    
    [self addSubview:popupView_temp];
    [self setPopupView:popupView_temp];
    
    // marker 08/02/15 - fix this later on
    /*
    // Animate on the screen
    switch ([self introductionAnimation]) {
        case UIPopupViewAnimationNone:
            [[self popupView] setAlpha:1.0];
            break;
        case UIPopupViewAnimationFade:
            [[self popupView] setAlpha:0.0];
            [UIView animateWithDuration:[self introductionAnimationLength] animations:^{
                [[self popupView] setAlpha:1.0];
            }];
            break;
        case UIPopupViewAnimationEnlarge:                
            [[self popupView] setAlpha:0.0];
            [[self popupView] setTransform:CGAffineTransformMakeScale(0.5, 0.5)];
            [UIView animateWithDuration:[self introductionAnimationLength] animations:^{
                [[self popupView] setAlpha:1.0];
                [[self popupView] setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            }];
            break;  
        case UIPopupViewAnimationReverseEnlarge:
            [[self popupView] setAlpha:0.0];
            [[self popupView] setTransform:CGAffineTransformMakeScale(1.5, 1.5)];
            [UIView animateWithDuration:[self introductionAnimationLength] animations:^{
                [[self popupView] setAlpha:1.0];
                [[self popupView] setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            }];
            break;
        default:
            break;
    }
    */

    /*
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, [self introductionAnimationLength] * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        dispatch_async(dispatch_get_main_queue(), [self introductionAnimationCompletionBlock]);
    });
    */
}

-(void)hideAfterDelay:(float)seconds {
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self hide];
    });
    
}

-(void)hide {
    
    // marker 08/02/2015 - fix this later on
    /*
    // Animate off the screen, then remove ourselves.
    switch ([self hideAnimation]) {
        case UIPopupViewAnimationNone:
            [self removeFromSuperview];
            break;
        case UIPopupViewAnimationFade:
            [[self popupView] setAlpha:1.0];
            [UIView animateWithDuration:[self hideAnimationLength] animations:^{
                [[self popupView] setAlpha:0.0];
            }];
            break;
        case UIPopupViewAnimationEnlarge:
            [[self popupView] setAlpha:1.0];
            [UIView animateWithDuration:[self hideAnimationLength] animations:^{
                [[self popupView] setAlpha:0.0];
                [[self popupView] setTransform:CGAffineTransformMakeScale(1.5, 1.5)];
            }];
            break;  
        case UIPopupViewAnimationReverseEnlarge:
            [[self popupView] setAlpha:1.0];
            [[self popupView] setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            [UIView animateWithDuration:[self hideAnimationLength] animations:^{
                [[self popupView] setAlpha:0.0];
                [[self popupView] setTransform:CGAffineTransformMakeScale(0.5, 0.5)];
            }];
            break;
        default:
            break;
    }
    */
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, [self hideAnimationLength] * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self removeFromSuperview];
        // dispatch_async(dispatch_get_main_queue(), [self hideAnimationCompletionBlock]);
    });
}

#pragma mark -
#pragma mark Private Methods

-(NSString *)defaultTitleForPopupType:(UIPopupViewType)type {
    
    switch (type) {
        case UIPopupViewTypeConfirm:
            return @"Confirmed";
            break;
        case UIPopupViewTypeCancel:
            return @"Cancelled";
            break;
        case UIPopupViewTypeLoading:
            return @"Loading";
            break;  
        case UIPopupViewTypeInformation:
            return @"Information";
            break;
        default:
            return nil;
            break;
    }
    
}

-(void)getRGBComponents:(CGFloat [3])components forColor:(UIColor *)color {
    
    // marker 02/22/2015 - greatly simplified
    CGFloat alpha;
    [color getRed:&components[0] green:&components[1] blue:&components[2] alpha:&alpha];
}

#pragma mark -
#pragma mark Custom Setters

-(void)setPopupType:(UIPopupViewType)popupType {
    
    /* If the current title is equal to the default title of the old popup type, therefore the title can be changed. */
    if ([[self title] isEqualToString:[self defaultTitleForPopupType:[self popupType]]]) [self setTitle:[self defaultTitleForPopupType:popupType]];
    
    _popupType = popupType;
    
}

@end
