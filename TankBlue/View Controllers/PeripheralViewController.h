//
//  PeripheralViewController.h
//  TankBlue
//
//  Created by Henk Meewis on 12/31/17.
//  Copyright © 2017 Henk Meewis. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

@interface PeripheralViewController : UIViewController <CBPeripheralDelegate, UITextFieldDelegate>
{
    CBCharacteristic *characteristicForWrite;
    NSString *responseString;
    int leftSpeed, rightSpeed, oldLeftSpeed, oldRightSpeed;
    CGFloat sliderSpeed, sliderAngle;
    NSTimer *signalTimer;
    
    __weak IBOutlet UITextField *sendTextField;
    __weak IBOutlet UILabel *connectedToLabel;
    __weak IBOutlet UITextView *messageTextView;
    __weak IBOutlet UISlider *speedSlider;
    __weak IBOutlet UILabel *speedLabel;
    __weak IBOutlet UISlider *angleSlider;
}

@property(nonatomic, strong) CBPeripheral *peripheral;

- (IBAction)previousButtonPressed:(id)sender;
- (IBAction)sendTextFieldEditingDidEnd:(id)sender;
- (IBAction)speedSliderValueChanged:(id)sender;
- (IBAction)angleSliderValueChanged:(id)sender;
- (IBAction)stopButtonPressed:(id)sender;
- (IBAction)resetResponsesButtonPressed:(id)sender;

- (void)gotoLastScreen;

@end
