//
//  CentralViewController.h
//  TankBlue
//
//  Created by Henk Meewis on 2/15/18.
//  Copyright © 2018 Henk Meewis. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
#import "HDHexConversion.h"
#import "HD_System.h"
#import "PeripheralViewController.h"

// HDHexConversion *hdHexConversion;
// HD_System *hdSystem;

@interface CentralViewController : UIViewController <CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    CBCentralManager *centralManager;
    NSMutableArray *peripheralItemsArray;
    PeripheralViewController *pvc;
    UIColor *buttonColor;

    __weak IBOutlet UITableView *peripheralsTableView;
    __weak IBOutlet UIButton *restartButton;
}

- (IBAction)restartButtonPressed:(id)sender;
- (void)restart;

@end
