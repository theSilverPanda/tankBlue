//
//  UIPopupView.h
//  UIPopupSuite
//
//  Created by Aaron Wojnowski on 11-10-31.
//  Copyright (c) 2011 Aaron Wojnowski. All rights reserved.
//

/*
 
        Developed by Aaron Wojnowski for http://www.binpress.com
        Version 1.0.0
 
        ------------------------------------------------------------------------------------------------
 
        UIPopupView is a powerful class that was developed to fill what I felt to be a void in the iPhone SDK.
        It provides a simple way to give feedback to the user in the form of little popup views.  Although
        UIAlertView  somewhat served this purpose already, I wanted to develop something that was clean, re-usable,
        and a little less intrusive.  
 
        UIPopupView comes with four styles by default:
 
            - UIPopupViewTypeConfirm         =>  A UIPopupView containing a title and a checkmark image.         =>  Used for confirmations such as "Copied", "Deleted", etc.
            - UIPopupViewTypeCancel          =>  A UIPopupView containing a title and an "X" image.              =>  Used for notifications such as "Cancelled", "Error", etc.
            - UIPopupViewTypeLoading         =>  A UIPopupView containing a title and an activity indicator.     =>  Used for notifications such as "Loading", "Thinking", etc.
            - UIPopupViewTypeInformation     =>  A UIPopupView containing a title and some customizable text.    =>  Used for notifications with custom text such as "Instructions".
 
        In addition to having different styles, you can also customize the colors, text, and other aspects of the UIPopupView.  UIPopupView also has
        support for blocks so you can be notified when the popup appears, and when it disappears.
 
        ------------------------------------------------------------------------------------------------
        
        This class can be used for both non-commercial, and commercial use, and has been tested with iOS 4.0 and above.  
        Due to the use of blocks, <iOS4 support is trivial.
 
        Please don't distribute this project without authorization. ;-)
 
        If you require installation assistance, help, or just want to send some feedback,
        drop me a line at "speedyapocalypse@live.com".
 
        ------------------------------------------------------------------------------------------------
        -------------------------------------- SETUP TUTORIAL ------------------------------------------
        ------------------------------------------------------------------------------------------------
     
        1) Import the following into your project:
            - UIPopupView.h
            - UIPopupView.m
            - UIPopupView_checkmark.png
            - UIPopupView_checkmark@2x.png
            - UIPopupView_x.png
            - UIPopupView_x@2x.png
        2) Add the following framework to your project.
            - <QuartzCore>
        3) Import "UIPopupView.h" into your class.
        4) Create a new instance of the UIPopupView class like so:
     
                UIPopupView *popupView = [[UIPopupView alloc] init];
     
        5) Set the UIPopupViewType.
     
                [popupView setPopupType:UIPopupViewTypeLoading];
     
        6) Optionally utilize some of the UIPopupViewType methods and properties.
     
                [popupView setPopupBackgroundColor:[UIColor whiteColor]];
                [popupView setPopupBackgroundAlpha:0.5];
                [popupView setTitle:@"Loading!"];
     
        7) Add the UIPopupView to the view of your choice, and then utilize the -[show] method.
     
                [[self view] addSubview:popupView];
                [popupView show]; // or use -[showAfterDelay:]
     
        8) Use the -[hide] or -[hideAfterDelay:] method to hide the UIPopupView when you're finished.
     
                [popupView hide]; // or use [popupView hideAfterDelay:2.0];
     
        9) Since you're done with the popup, you can release it.
     
                [popupView release];
 
        ------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------
 
 
 */

#import <UIKit/UIKit.h>

#define WIDTH_PADDING 20 // The total width padding for the title and text (if 20, 10px padding on each side)

typedef enum {
    
    UIPopupViewTypeConfirm,
    UIPopupViewTypeCancel,
    UIPopupViewTypeLoading,
    UIPopupViewTypeInformation
    
} UIPopupViewType;

typedef enum {
    
    UIPopupViewAnimationFade,
    UIPopupViewAnimationEnlarge,
    UIPopupViewAnimationReverseEnlarge,
    UIPopupViewAnimationNone
    
} UIPopupViewAnimation;

@interface UIPopupView : UIView

/* This is the type of popup.
 
 UIPopupViewtypeConfirm     -> Displays a "checkmark" image with a title of your choice.
 UIPopupViewTypeCancel      -> Displays an "X" image with a title of your choice.
 UIPopupViewTypeLoading     -> Displays a UIAcitivtyIndicatorView with a title of your choice.
 UIPopupViewTypeInformation -> Displays a basic box with a title and text of your choice.
 
 */
@property (nonatomic, assign) UIPopupViewType popupType;

/* This is the introduction animation for when the popup is displayed using the -[show] method.  See the UIPopupViewIntroductionAnimation enum. */
@property (nonatomic, assign) UIPopupViewAnimation introductionAnimation;

/* This is the length of the hide animation. */
@property (nonatomic, assign) float introductionAnimationLength;

/* The block called when the introduction animation completes. */
@property (nonatomic, copy) void (^introductionAnimationCompletionBlock)(void);

/* This is the hide animation for when the popup is hidden using the -[hide] method.  See the UIPopupViewHideAnimation enum. */
@property (nonatomic, assign) UIPopupViewAnimation hideAnimation;

/* This is the length of the hide animation. */
@property (nonatomic, assign) float hideAnimationLength;

/* The block called when the hide animation completes. */
@property (nonatomic, copy) void (^hideAnimationCompletionBlock)(void);

/* This is the popup view that is displayed on the screen. */
@property (nonatomic, retain) UIView *popupView;

/* This is the popup view's background color.
 
 - Defaults -
 -[UIColor blackColor] 
 
 */
@property (nonatomic, retain) UIColor *popupBackgroundColor;

/* This is the popup view's alpha.
 
 1.0 = Opaque
 0.0 = Transparent
 
 - Defaults -
 0.75
 
 */
@property (nonatomic, assign) float popupBackgroundAlpha;

/*
 
 The popup image color.
 
 - Defaults -
 -[UIColor whiteColor]
 
 */
@property (nonatomic, retain) UIColor *popupImageColor;

/* The corner radius of the box.
 
 - Defaults -
 10.0
 
 */
@property (nonatomic, assign) float popupCornerRadius;

/* This is the border width on the box.
 
 - Defaults -
 0.0
 
 */
@property (nonatomic, assign) float popupBorderWidth;

/* This is the border color of the box border.
 
 - Defaults -
 -[UIColor whiteColor]
 
 */
@property (nonatomic, retain) UIColor *popupBorderColor;

/* This is the title text of the popup.
 
 - Defaults -
 UIPopupViewtypeConfirm     -> @"Confirmed"
 UIPopupViewTypeCancel      -> @"Cancelled"
 UIPopupViewTypeInformation -> @"Information"
 UIPopupViewTypeLoading     -> @"Loading"
 
 */
@property (nonatomic, copy) NSString *title;

/* This is the title alignment. */
@property (nonatomic, assign) NSTextAlignment titleAlignment;

/* The title color.
 
 - Defaults -
 -[UIColor whiteColor]
 
 */
@property (nonatomic, retain) UIColor *titleColor;

/* This is the title UILabel object. */
@property (nonatomic, retain) UILabel *titleLabel;

/* This is the information body text if using the UIPopupViewTypeInformation UIPopupViewType. */
@property (nonatomic, copy) NSString *informationText;

/* This is the information text alignment. */
@property (nonatomic, assign) NSTextAlignment informationTextAlignment;

/* Shows the UIPopupView with your selected animation after a certain delay. */
-(void)showAfterDelay:(float)seconds;

/* Shows the UIPopupView with your selected animation. */
-(void)show;

/* Hides the UIPopupView with your selected animation after the selected amount of seconds.  Once complete, removes the UIPopupView from its superview. */
-(void)hideAfterDelay:(float)seconds;

/* Hides the UIPopupView with your selected animation.  Once complete, removes the UIPopupView from its superview. */
-(void)hide;

@end
