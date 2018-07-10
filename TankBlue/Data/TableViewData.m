//
//  TableViewData.m
//  HubExplorer
//
//  Created by Henk Meewis on 11/13/17.
//  Copyright © 2017 Hunter Douglas, Inc. All rights reserved.
//

#import "ButtonTableCell.h"
#import "CharacteristicTableViewCell.h"
#import "HD_System.h"

#import "TableViewData.h"

extern HD_System *hdSystem;
// extern DataStore *dataStore;

@implementation TableViewData
@synthesize cellType, buttonText, nameText, valueText, delegate, responseMethod, enabled, uuid, value;

- (id)initDefaultCellWithText:(NSString *)text
                      andName:(NSString *)name
{
    self = [super init];
    if(self) {
        cellType = ctDefault;
        valueText = text;
        nameText = name;
        enabled = true;
    }
    return self;
}

- (id)initButtonCellWithText:(NSString *)text
                     andName:(NSString *)name
{
    self = [super init];
    if(self) {
        cellType = ctButton;
        buttonText = text;
        nameText = name;
        enabled = true;
    }
    return self;
}

- (id)initDefaultSelectableCellWithText:(NSString *)text
                                andName:(NSString *)name
              andResponseMethodSelector:(SEL)thisSelector
                              isEnabled:(bool)isEnabled
{
    self = [super init];
    if(self) {
        cellType = ctDefaultSelectable;
        valueText = text;
        nameText = name;
        responseMethod = thisSelector;
        enabled = isEnabled;
    }
    return self;
}

- (id)initCharacteristicCellWithUUID:(CBUUID *)thisUUID
                            andValue:(NSData *)thisValue
{
    self = [super init];
    if(self) {
        cellType = ctCharacteristic;
        uuid = thisUUID;
        value = thisValue;
    }
    return self;
}

- (UITableViewCell *)getCellForTableView:(UITableView *)tableView
              andDelegate:(id)thisDelegate
{
    // DLog(@"get cell with type '%@' for table view", [self getCellTypeString]);
    
    delegate = thisDelegate;
    
    UITableViewCell *cell;
    switch(cellType) {
        case ctDefault:
            cell = [self getDefaultCellForTableView:tableView];
            break;
        case ctButton:
            cell = [self getButtonCellForTableView:tableView];
            break;
        case ctDefaultSelectable:
            cell = [self getDefaultSelectableCellForTableView:tableView];
            break;
        case ctCharacteristic:
            cell = [self getCharacteristicCellForTableView:tableView];
            break;
        default: cell = nil;
    }
    return cell;
}

- (UITableViewCell *)getDefaultCellForTableView:(UITableView *)tableView
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                            reuseIdentifier:@"Cell"];
    
    [[cell textLabel] setText:valueText];
    [[cell detailTextLabel] setTextColor:[UIColor redColor]];
    [[cell detailTextLabel] setText:nameText];
    
    return cell;
}

- (UITableViewCell *)getButtonCellForTableView:(UITableView *)tableView
{
    static NSString *buttonTableIdentifier = @"ButtonTableCell";
    ButtonTableCell *cell = (ButtonTableCell *)[tableView dequeueReusableCellWithIdentifier:buttonTableIdentifier];
    
    // Configure the cell...
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ButtonTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [[cell button] setTitle:buttonText forState:0];
    [[cell button] addTarget:self
                      action:@selector(identityButtonWasPressed)
            forControlEvents:UIControlEventTouchUpInside];
    [[cell nameLabel] setText:nameText];
    
    return cell;
}

- (UITableViewCell *)getDefaultSelectableCellForTableView:(UITableView *)tableView
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                            reuseIdentifier:@"Cell"];
    
    UIColor *textColor = enabled ? [UIColor blueColor] : [UIColor lightGrayColor];
    [[cell textLabel] setTextColor:textColor];
    [[cell textLabel] setText:valueText];
    [[cell detailTextLabel] setTextColor:[UIColor redColor]];
    [[cell detailTextLabel] setText:nameText];
    
    return cell;
}

- (UITableViewCell *)getCharacteristicCellForTableView:(UITableView *)tableView
{
    static NSString *characteristicTableIdentifier = @"CharacteristicTableViewCell";
    CharacteristicTableViewCell *cell = (CharacteristicTableViewCell *)[tableView dequeueReusableCellWithIdentifier:characteristicTableIdentifier];
    
    // Configure the cell...
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CharacteristicTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSString *uuidString = [NSString stringWithFormat:@"'%@'", uuid];
    [[cell uuidLabel] setText:uuidString];
    
    NSString *valueString = @"No data available";
    if(value) {
        NSString *tempString = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
        if([value length] > [tempString length]) valueString = @"data geen string";
        else valueString = [NSString stringWithFormat:@"'%@'", tempString];
    }
    [[cell valueLabel] setText:valueString];
    
    return cell;
}

- (void)identityButtonWasPressed
{
    [hdSystem sendMethod:@"identityButtonWasPressed" toDelegate:delegate];
}

- (void)openViewButtonWasPressed
{
    NSLog(@"open view button was pressed");
}

- (void)handleSelection
{
    if(enabled) [hdSystem sendSelector:responseMethod toDelegate:delegate];
}

- (void)changeValueTextTo:(NSString *)text
{
    valueText = text;
}

- (NSString *)getCellTypeString
{
    NSString *cellTypeString;
    switch(cellType) {
        case ctDefault: cellTypeString = @"default"; break;
        case ctButton: cellTypeString = @"button"; break;
        case ctDefaultSelectable: cellTypeString = @"defaultSelectable"; break;
        case ctCharacteristic: cellTypeString = @"characteristic"; break;
        default: cellTypeString = @"unknown";
    }
    return cellTypeString;
}

@end
