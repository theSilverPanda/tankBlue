//
//  PeripheralViewController.m
//  TankBlue
//
//  Created by Henk Meewis on 12/31/17.
//  Copyright © 2017 Henk Meewis. All rights reserved.
//

#import "PeripheralViewController.h"
#import "HD_System.h"

extern HD_System *hdSystem;

@interface PeripheralViewController ()
@end

@implementation PeripheralViewController
@synthesize peripheral;

#define ItsMaxSpeed_ 255

- (id)init
{
    self = [super init];
    if(self) {
        NSLog(@"peripheral view controller initiated");
        characteristicForWrite = nil;
        responseString = @"";
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *connectedString = [NSString stringWithFormat:@"Connected to '%@'", [peripheral name]];
    [connectedToLabel setText:connectedString];
    [peripheral discoverServices:nil];
    signalTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(signalTimerTick) userInfo:nil repeats:true];
    oldLeftSpeed = 0;
    oldRightSpeed = 0;
}

- (void)signalTimerTick
{
    if((leftSpeed != oldLeftSpeed) || (rightSpeed != oldRightSpeed)) {
        NSString *speedString = [NSString stringWithFormat:@"%0.0f", [speedSlider value] * ItsMaxSpeed_];
        [speedLabel setText:speedString];
        if(characteristicForWrite) {
            NSString *messageString = [NSString stringWithFormat:@"run %d %d\0", rightSpeed, leftSpeed];
            NSLog(@"send '%@'", messageString);
            NSData *message = [messageString dataUsingEncoding:NSUTF8StringEncoding];
            [peripheral writeValue:message
                 forCharacteristic:characteristicForWrite
                              type:CBCharacteristicWriteWithoutResponse];
        }
    }
    oldLeftSpeed = leftSpeed;
    oldRightSpeed = rightSpeed;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
    if(error) NSLog(@"didDiscoverServices error: %@", [error localizedDescription]);
    else for(CBService *service in [peripheral services]) [self discoveredService:service];
}

- (void)discoveredService:(CBService *)service
{
    NSLog(@"discovered service with UUID: %@", [service UUID]);
    [peripheral discoverCharacteristics:nil forService:service];
    [peripheral discoverIncludedServices:nil forService:service];
    [peripheral readRSSI];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error
{
    if(error) NSLog(@"didDiscoverCharacteristicsForService error: %@", [error localizedDescription]);
    else for(CBCharacteristic *characteristic in [service characteristics]) [self discoveredCharacteristic:characteristic];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(nonnull CBService *)service error:(nullable NSError *)error
{
    NSLog(@"discovered %u included services", (uint)[[service includedServices] count]);
    if(error) NSLog(@"didDiscoverIncludedServicesForService error: %@", [error localizedDescription]);
    else for(CBService *includedService in [service includedServices]) [self discoveredIncludedService:includedService];
}

- (void)discoveredIncludedService:(CBService *)includedService
{
    NSLog(@"discovered included service with UUID: %@", [includedService UUID]);
}

- (void)discoveredCharacteristic:(CBCharacteristic *)characteristic
{
    CBCharacteristicProperties properties = [characteristic properties];
    NSLog(@"");
    NSLog(@"discovered characteristic with UUID(%@) and properties(%lu):", [characteristic UUID], properties);
    if(properties & CBCharacteristicPropertyBroadcast) NSLog(@"  CBCharacteristicPropertyBroadcast");
    if(properties & CBCharacteristicPropertyRead) NSLog(@"  CBCharacteristicPropertyRead");
    if(properties & CBCharacteristicPropertyWriteWithoutResponse) NSLog(@"  CBCharacteristicPropertyWriteWithoutResponse");
    if(properties & CBCharacteristicPropertyWrite) NSLog(@"  CBCharacteristicPropertyWrite");
    if(properties & CBCharacteristicPropertyNotify) NSLog(@"  CBCharacteristicPropertyNotify");
    if(properties & CBCharacteristicPropertyIndicate) NSLog(@"  CBCharacteristicPropertyIndicate");
    if(properties & CBCharacteristicPropertyAuthenticatedSignedWrites) NSLog(@"  CBCharacteristicPropertyAuthenticatedSignedWrites");
    if(properties & CBCharacteristicPropertyExtendedProperties) NSLog(@"  CBCharacteristicPropertyExtendedProperties");
    if(properties & CBCharacteristicPropertyNotifyEncryptionRequired) NSLog(@"  CBCharacteristicPropertyNotifyEncryptionRequired");
    if(properties & CBCharacteristicPropertyIndicateEncryptionRequired) NSLog(@"  CBCharacteristicPropertyIndicateEncryptionRequired");
    
    NSLog(@"discovered characteristic contains %lu descriptors", [[characteristic descriptors] count]);
    [hdSystem displayBoolWithName:@"isNotifying" andValue:[characteristic isNotifying]];
    
    if(properties & CBCharacteristicPropertyRead) [peripheral readValueForCharacteristic:characteristic];
    if(properties & CBCharacteristicPropertyNotify) [peripheral setNotifyValue:true forCharacteristic:characteristic];
    if(properties & CBCharacteristicPropertyWriteWithoutResponse) characteristicForWrite = characteristic;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if(error) NSLog(@"didUpdateValueForCharacteristic error: %@", [error localizedDescription]);
    else {
        NSData *value = [characteristic value];
        if(value) {
            NSLog(@"");
            NSLog(@"discovered characteristic with UUID = %@ has value with length = %lu", [characteristic UUID], [value length]);
            
            // convert NSdata *value to a character string and a hex string
            // first convert data into unsigned chars
            NSUInteger length = [value length], n, lineLength = 0;
            unsigned char *buffer = malloc(length), *line = malloc(length), thisChar;
            [value getBytes:buffer length:length];
            
            // now convert unsigned chars into strings
            NSString *hexString = @"0x";
            for(n = 0; n < length; n++) {
                thisChar = buffer[n];
                hexString = [hexString stringByAppendingFormat:@"%02X", thisChar]; // look at format specifiers
                if([hdSystem isPrintable:thisChar] || (thisChar == 10) || (thisChar == 13)) line[lineLength++] = thisChar;
                else line[lineLength++] = '.';
            }
            NSString *lineString = [[NSString alloc] initWithBytes:line length:lineLength encoding:NSUTF8StringEncoding];
            
            // destroy character buffers
            free(buffer);
            free(line);
            
            // display results
            if(lineLength) NSLog(@"  in characters: %@", lineString);
            NSLog(@"  in hex: %@", hexString);
            responseString = [responseString stringByAppendingString:lineString];
            [messageTextView setText:responseString];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if(error) NSLog(@"didUpdateNotificationStateForCharacteristic error: %@", [error localizedDescription]);
    else NSLog(@"didUpdateNotificationStateForCharacteristic");
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if(error) NSLog(@"didWriteValueForCharacteristic error: %@", [error localizedDescription]);
    else NSLog(@"didWriteValueForCharacteristic");
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(nonnull NSNumber *)RSSI error:(nullable NSError *)error
{
    if(error) NSLog(@"didReadRSSI error: %@", [error localizedDescription]);
    else NSLog(@"RSSI = %d dB", [RSSI intValue]);
}

- (void)gotoLastScreen
{
    [[self presentingViewController] dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)previousButtonPressed:(id)sender
{
    [self gotoLastScreen];
}

- (IBAction)sendTextFieldEditingDidEnd:(id)sender
{
    responseString = @"";
    [messageTextView setText:responseString];
    if(characteristicForWrite) {
        NSString *messageString = [sendTextField text];
        NSLog(@"send message string: '%@'", messageString);
        NSData *message = [messageString dataUsingEncoding:NSUTF8StringEncoding];
        [peripheral writeValue:message forCharacteristic:characteristicForWrite type:CBCharacteristicWriteWithoutResponse];
    }
}

- (void)calculateSpeeds
{
    CGFloat scaledSpeed = sliderSpeed * ItsMaxSpeed_, scaledLeftSpeed = scaledSpeed, scaledRightSpeed = scaledSpeed;
    
    if(sliderAngle < 0) scaledLeftSpeed = (1.0 + sliderAngle) * scaledSpeed;
    else scaledRightSpeed = (1.0 - sliderAngle) * scaledSpeed;
    
    leftSpeed = (int)(scaledLeftSpeed + 0.5);
    rightSpeed = (int)(scaledRightSpeed + 0.5);
}

- (IBAction)speedSliderValueChanged:(id)sender
{
    sliderSpeed = [speedSlider value];
    [self calculateSpeeds];
}

- (IBAction)angleSliderValueChanged:(id)sender {
    sliderAngle = [angleSlider value];
    [self calculateSpeeds];
}

- (IBAction)stopButtonPressed:(id)sender
{
    sliderSpeed = 0.0;
    [speedSlider setValue:sliderSpeed];
    
    sliderAngle = 0.0;
    [angleSlider setValue:sliderAngle];
    
    [self calculateSpeeds];
}

- (IBAction)resetResponsesButtonPressed:(id)sender
{
    responseString = @"";
    [messageTextView setText:responseString];
}

#pragma mark - Text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

@end
