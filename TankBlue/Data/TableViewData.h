//
//  TableViewData.h
//  HubExplorer
//
//  Created by Henk Meewis on 11/13/17.
//  Copyright © 2017 Hunter Douglas, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef enum {ctDefault = 0, ctButton, ctDefaultSelectable, ctCharacteristic} eCellType;

@interface TableViewData : NSObject

@property (nonatomic) eCellType cellType;
@property (nonatomic, weak) NSString *buttonText, *nameText, *valueText;
@property (nonatomic, weak) id delegate;
@property (nonatomic) SEL responseMethod;
@property (nonatomic) bool enabled;
@property (nonatomic, weak) CBUUID *uuid;
@property (nonatomic, weak) NSData *value;

- (id)initDefaultCellWithText:(NSString *)text
                      andName:(NSString *)name;
- (id)initButtonCellWithText:(NSString *)text
                     andName:(NSString *)name;
- (id)initDefaultSelectableCellWithText:(NSString *)text
                                andName:(NSString *)name
              andResponseMethodSelector:(SEL)thisSelector
                              isEnabled:(bool)isEnabled;
- (id)initCharacteristicCellWithUUID:(CBUUID *)thisUUID
                            andValue:(NSData *)value;
- (UITableViewCell *)getCellForTableView:(UITableView *)tableView
                             andDelegate:(id)thisDelegate;
- (void)handleSelection;
- (void)changeValueTextTo:(NSString *)text;

@end
