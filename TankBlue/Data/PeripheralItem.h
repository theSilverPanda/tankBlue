//
//  PeripheralItem.h
//  TankBlue
//
//  Created by Henk Meewis on 2/2/18.
//  Copyright © 2018 Henk Meewis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface PeripheralItem : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSNumber *RSSI;

- (id)initWithPeripheral:(CBPeripheral *)thisPeripheral
                withName:(NSString *)thisName
                 andRSSI:(NSNumber *)thisRSSI;

@end
