//
//  AppDelegate.h
//  TankBlue
//
//  Created by Henk Meewis on 12/23/17.
//  Copyright © 2017 Henk Meewis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CentralViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    CentralViewController *centralViewController;
    UINavigationController *navigationController;
}

@property (strong, nonatomic) UIWindow *window;


@end

