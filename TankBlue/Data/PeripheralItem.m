//
//  PeripheralItem.m
//  TankBlue
//
//  Created by Henk Meewis on 2/2/18.
//  Copyright © 2018 Henk Meewis. All rights reserved.
//

#import "PeripheralItem.h"

@implementation PeripheralItem

@synthesize name, peripheral, RSSI;

- (id)initWithPeripheral:(CBPeripheral *)thisPeripheral
                withName:(NSString *)thisName
                 andRSSI:(NSNumber *)thisRSSI
{
    self = [super init];
    if(self) {
        peripheral = thisPeripheral;
        name = thisName;
        RSSI = thisRSSI;
    }
    return self;
}

@end
