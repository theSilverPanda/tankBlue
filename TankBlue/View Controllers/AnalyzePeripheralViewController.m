//
//  AnalyzePeripheralViewController.m
//  TankBlue
//
//  Created by Henk Meewis on 7/3/18.
//  Copyright © 2018 Henk Meewis. All rights reserved.
//

#import "MenuTestViewController.h"
#import "AnalyzePeripheralViewController.h"

#define servicePtrKey @"servicePtr"
#define characteristicsArrayKey @"characteristicsArray"
#define characteristicPtrKey @"characteristicPtr"
#define characteristicValueKey @"characteristicValue"

@interface AnalyzePeripheralViewController ()
@end

@implementation AnalyzePeripheralViewController
@synthesize centralManager, peripheral;

- (id)init
{
    self = [super init];
    if(self) {
        NSLog(@"analyze peripheral view controller initiated");
        peripheralArray = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [peripheral discoverServices:nil];
}

- (IBAction)backButtonPressed:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)rediscoverServicesButtonPressed:(id)sender
{
    [peripheral discoverServices:nil];
}

- (IBAction)menuTestScreenButtonPressed:(id)sender
{
    MenuTestViewController *mtvc = [[MenuTestViewController alloc] init];
    [self presentViewController:mtvc animated:true completion:nil];
}

- (IBAction)revisitDataButtonPressed:(id)sender
{
    [self logData];
}

#pragma mark - CBPeripheral delegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
    if(error) NSLog(@"didDiscoverServices error: %@", [error localizedDescription]);
    else {
        NSUInteger count = [[peripheral services] count];
        NSString *message = (count == 1) ? @"service discovered" : @"services discovered";
        NSLog(@"%d %@", (int)count, message);
        for(CBService *service in [peripheral services]) {
            CBUUID *uuid = [service UUID];
            NSLog(@"  with UUID: '%@'", uuid);
            [peripheral discoverCharacteristics:nil forService:service];
            
            NSMutableDictionary *serviceDict = [NSMutableDictionary dictionaryWithCapacity:0];
            [serviceDict setObject:service forKey:servicePtrKey];
            [peripheralArray addObject:serviceDict];
        }
    }
}

- (NSMutableArray *)getPropertyStrings:(CBCharacteristicProperties)properties
{
    NSMutableArray *propertyStrings = [NSMutableArray arrayWithCapacity:0];
    if(properties & CBCharacteristicPropertyBroadcast) [propertyStrings addObject:@"CBCharacteristicPropertyBroadcast"];
    if(properties & CBCharacteristicPropertyRead) [propertyStrings addObject:@"CBCharacteristicPropertyRead"];
    if(properties & CBCharacteristicPropertyWriteWithoutResponse) [propertyStrings addObject:@"CBCharacteristicPropertyWriteWithoutResponse"];
    if(properties & CBCharacteristicPropertyWrite) [propertyStrings addObject:@"CBCharacteristicPropertyWrite"];
    if(properties & CBCharacteristicPropertyNotify) [propertyStrings addObject:@"CBCharacteristicPropertyNotify"];
    if(properties & CBCharacteristicPropertyIndicate) [propertyStrings addObject:@"CBCharacteristicPropertyIndicate"];
    if(properties & CBCharacteristicPropertyAuthenticatedSignedWrites) [propertyStrings addObject:@"CBCharacteristicPropertyAuthenticatedSignedWrites"];
    if(properties & CBCharacteristicPropertyExtendedProperties) [propertyStrings addObject:@"CBCharacteristicPropertyExtendedProperties"];
    if(properties & CBCharacteristicPropertyNotifyEncryptionRequired) [propertyStrings addObject:@"CBCharacteristicPropertyNotifyEncryptionRequired"];
    if(properties & CBCharacteristicPropertyIndicateEncryptionRequired) [propertyStrings addObject:@"CBCharacteristicPropertyIndicateEncryptionRequired"];
    return propertyStrings;
}

- (void)logProperties:(CBCharacteristicProperties)properties
{
    NSLog(@"    with properties(%lu):", properties);
    NSMutableArray *propertyStrings = [self getPropertyStrings:properties];
    for(NSString *propertyString in propertyStrings) NSLog(@"      %@", propertyString);
}

- (void)displayBoolWithName:(NSString *)name andValue:(BOOL)value
{
    NSString *valueString = value ? @"true" : @"false";
    NSLog(@"    BOOL %@ == %@", name, valueString);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error
{
    if(error) NSLog(@"didDiscoverCharacteristics error: %@", [error localizedDescription]);
    else {
        NSUInteger count = [[service characteristics] count];
        NSString *message = (count == 1) ? @"characteristic" : @"characteristics";
        NSString *description = [NSString stringWithFormat:@"for service with UUID: '%@'", [service UUID]];
        NSLog(@"%d %@ %@", (int)count, message, description);
        
        NSUInteger descriptorCount;
        
        // find the service
        for(NSMutableDictionary *serviceDict in peripheralArray) if([serviceDict objectForKey:servicePtrKey] == service) {
            
            // to this service, add characteristics array
            NSMutableArray *characteristicsArray = [NSMutableArray arrayWithCapacity:0];
            [serviceDict setObject:characteristicsArray forKey:characteristicsArrayKey];
            
            // for each characteristic in this service, add characteristic dictionaries for each characteristic, and add the characteristic pointer
            for(CBCharacteristic *characteristic in [service characteristics]) {
                
                // make dictionary, add to array, and add pointer
                NSMutableDictionary *characteristicDict = [NSMutableDictionary dictionaryWithCapacity:0];
                [characteristicsArray addObject:characteristicDict];
                [characteristicDict setObject:characteristic forKey:characteristicPtrKey];

                // UUID
                NSLog(@"  with UUID: '%@'", [characteristic UUID]);
                
                // descriptors
                descriptorCount = [[characteristic descriptors] count];
                message = (descriptorCount == 1) ? @"descriptor" : @"descriptors";
                NSLog(@"    %d %@ found", (int)descriptorCount, message);
                
                // properties
                [self logProperties:[characteristic properties]];
                
                // is notifying
                [self displayBoolWithName:@"isNotifying" andValue:[characteristic isNotifying]];
                
                // read value
                if([characteristic properties] & CBCharacteristicPropertyRead) {
                    NSData *value = [characteristic value];
                    if(value) {
                        NSLog(@"    value found!");
                        NSString *dataString = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
                        if(dataString) NSLog(@"    data string = '%@'", dataString);
                        else NSLog(@"    data is NOT a string");
                        [characteristicDict setObject:value forKey:characteristicValueKey];
                    }
                    else {
                        NSLog(@"    could NOT read a value");
                        [peripheral readValueForCharacteristic:characteristic];
                    }
                }
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"---------------------------------------------------------------------------------------------");
    if(error) {
        NSLog(@"received error from characteristic with UUID: '%@'", [characteristic UUID]);
        NSLog(@"didUpdateValueForCharacteristic error: %@", [error localizedDescription]);
    }
    else {
        
        NSLog(@"received update for value of characteristic with UUID: '%@'", [characteristic UUID]);
        NSData *value = [characteristic value];
        if(value) {
            NSLog(@"    value found!");
            NSString *dataString = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
            if(dataString) NSLog(@"    data string = '%@'", dataString);
            else NSLog(@"    data is NOT a string");
            [self addValue:value toCharacteristic:characteristic];
        }
        else NSLog(@"    could NOT read a value");
    }
    NSLog(@"---------------------------------------------------------------------------------------------");
}

- (bool)addValue:(NSData *)value toCharacteristic:(CBCharacteristic *)thisCharacteristic
{
    // first find the characteristic
    bool found = false;
    NSMutableArray *characteristicsArray;
    CBCharacteristic *foundCharacteristic;
    for(NSMutableDictionary *serviceDict in peripheralArray) {
        characteristicsArray = [serviceDict objectForKey:characteristicsArrayKey];
        for(NSMutableDictionary *characteristicDict in characteristicsArray) {
            foundCharacteristic = [characteristicDict objectForKey:characteristicPtrKey];
            if(foundCharacteristic == thisCharacteristic) {
                found = true;
                [characteristicDict setObject:value forKey:characteristicValueKey];
                break;
            }
        }
        if(found) break;
    }
    return found;
}

- (void)logString:(NSString *)logString afterSpaces:(NSUInteger)spaceCount
{
    NSString *spaceString = @"";
    for(NSUInteger n = 0; n < spaceCount; n++) spaceString = [spaceString stringByAppendingString:@" "];
    NSLog(@"%@%@", spaceString, logString);
}

- (void)logCharacteristicData:(NSDictionary *)characteristicDict
{
    NSString *log, *log1;
    CBCharacteristic *characteristic = [characteristicDict objectForKey:characteristicPtrKey];
    
    log = [NSString stringWithFormat:@"characteristic with UUID: '%@'", [characteristic UUID]];
    [self logString:log afterSpaces:4];
    
    // descriptors
    NSUInteger count = [[characteristic descriptors] count];
    log = (count == 1) ? @"descriptor" : @"descriptors";
    log1 = [NSString stringWithFormat:@"%lu %@ found", count, log];
    [self logString:log1 afterSpaces:8];
    
    // checkout properties
    NSMutableArray *propertyStrings = [self getPropertyStrings:[characteristic properties]];
    [self logString:@"properties:" afterSpaces:8];
    for(NSString *property in propertyStrings) [self logString:property afterSpaces:12];
    if([characteristic properties] & CBCharacteristicPropertyRead) {
        
        // value
        NSData *value = [characteristicDict objectForKey:characteristicValueKey];
        if(value) {
            [self logString:@"value:" afterSpaces:8];
            log = [NSString stringWithFormat:@"data length = %lu", [value length]];
            [self logString:log afterSpaces:12];
            NSString *dataString = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
            if(dataString) {
                log = [NSString stringWithFormat:@"value = '%@'", dataString];
                log1 = [NSString stringWithFormat:@"string length = %lu", [dataString length]];
                [self logString:log1 afterSpaces:12];
            }
            else log = @"value is NOT a string";
        }
        else log = @"NO value present";
        [self logString:log afterSpaces:12];
    }
    
    // check is notifying
    log = [characteristic isNotifying] ? @"" : @"NOT ";
    log1 = [NSString stringWithFormat:@"%@notifying", log];
    [self logString:log1 afterSpaces:8];
}

- (void)logData
{
    CBService *service;
    NSMutableArray *characteristics;
    
    NSLog(@"");
    NSLog(@"peripheral with name: '%@'", [peripheral name]);
    NSLog(@"peripheral UUID = '%@'", [peripheral identifier]);
    for(NSMutableDictionary *serviceDict in peripheralArray) {
        service = [serviceDict objectForKey:servicePtrKey];
        NSLog(@"service with UUID: '%@'", [service UUID]);
        characteristics = [serviceDict objectForKey:characteristicsArrayKey];
        for(NSMutableDictionary *characteristicDict in characteristics) {
            [self logCharacteristicData:characteristicDict];
            NSLog(@"");
        }
    }
}
@end
