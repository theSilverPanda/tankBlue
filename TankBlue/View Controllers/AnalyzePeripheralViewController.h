//
//  AnalyzePeripheralViewController.h
//  TankBlue
//
//  Created by Henk Meewis on 7/3/18.
//  Copyright © 2018 Henk Meewis. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

@interface AnalyzePeripheralViewController : UIViewController <CBPeripheralDelegate>
{
    NSMutableArray *peripheralArray;
}

@property(nonatomic, strong) CBCentralManager *centralManager;
@property(nonatomic, strong) CBPeripheral *peripheral;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)rediscoverServicesButtonPressed:(id)sender;
- (IBAction)menuTestScreenButtonPressed:(id)sender;
- (IBAction)revisitDataButtonPressed:(id)sender;

@end
