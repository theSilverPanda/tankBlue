//
//  MenuTestViewController.h
//  TankBlue
//
//  Created by Henk Meewis on 7/4/18.
//  Copyright © 2018 Henk Meewis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuTestViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *menuTableViewSectionsArray;
    bool menuTablePopulated;
    
    __weak IBOutlet UITableView *peripheralTableView;
}

- (IBAction)backButtonPessed:(id)sender;

@end
