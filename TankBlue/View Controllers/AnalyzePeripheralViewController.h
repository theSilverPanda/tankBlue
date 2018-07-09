//
//  AnalyzePeripheralViewController.h
//  TankBlue
//
//  Created by Henk Meewis on 7/3/18.
//  Copyright © 2018 Henk Meewis. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

@interface AnalyzePeripheralViewController : UIViewController <CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *peripheralArray, *menuTableViewSectionsArray;
    bool menuTablePopulated;
    
    __weak IBOutlet UITextView *dataTextView;
    __weak IBOutlet UITableView *peripheralTableView;
}

@property(nonatomic, strong) CBCentralManager *centralManager;
@property(nonatomic, strong) CBPeripheral *peripheral;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)rediscoverServicesButtonPressed:(id)sender;
- (IBAction)menuTestScreenButtonPressed:(id)sender;

@end
