//
//  AnalyzePeripheralViewController.m
//  TankBlue
//
//  Created by Henk Meewis on 7/3/18.
//  Copyright © 2018 Henk Meewis. All rights reserved.
//

#import "MenuTestViewController.h"
#import "TableViewSectionData.h"
#import "TableViewData.h"
#import "HD_System.h"

#import "AnalyzePeripheralViewController.h"

extern HD_System *hdSystem;

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
    // [self populateMenuTableViewController];
}

- (IBAction)backButtonPressed:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)rediscoverServicesButtonPressed:(id)sender
{
    [peripheralArray removeAllObjects];
    [peripheral discoverServices:nil];
}

- (IBAction)menuTestScreenButtonPressed:(id)sender
{
    MenuTestViewController *mtvc = [[MenuTestViewController alloc] init];
    [self presentViewController:mtvc animated:true completion:nil];
}

#pragma mark - CBPeripheral delegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
    if(error) NSLog(@"didDiscoverServices error: %@", [error localizedDescription]);
    else {
        for(CBService *service in [peripheral services]) {
            [peripheral discoverCharacteristics:nil forService:service];
            
            NSMutableDictionary *serviceDict = [NSMutableDictionary dictionaryWithCapacity:0];
            [serviceDict setObject:service forKey:servicePtrKey];
            [peripheralArray addObject:serviceDict];
        }
        [self logData];
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

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error
{
    if(error) NSLog(@"didDiscoverCharacteristics error: %@", [error localizedDescription]);
    else {
        NSData *value;
        CBCharacteristicProperties properties;
        
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
                
                // check for value
                value = [characteristic value];
                if(value) [characteristicDict setObject:value forKey:characteristicValueKey];
                else {
                    properties = [characteristic properties];
                    if(properties & CBCharacteristicPropertyRead) [peripheral readValueForCharacteristic:characteristic];
                }
            }
        }
        [self logData];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error) NSLog(@"didUpdateValueForCharacteristic error: %@", [error localizedDescription]);
    else {
        NSLog(@"received update for value of characteristic with UUID: '%@'", [characteristic UUID]);
        
        NSData *value = [characteristic value];
        if(value) [self addValue:value toCharacteristic:characteristic];
        [self logData];
    }
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
    NSString *spaceString = @"", *result, *textString;
    for(NSUInteger n = 0; n < spaceCount; n++) spaceString = [spaceString stringByAppendingString:@" "];
    result = [NSString stringWithFormat:@"%@%@", spaceString, logString];
    // NSLog(@"%@", result);
    textString = [NSString stringWithFormat:@"%@\n%@", [dataTextView text], result];
    [dataTextView setText:textString];
}

- (void)logCharacteristicData:(NSDictionary *)characteristicDict
{
    NSString *log, *log1;
    CBCharacteristic *characteristic = [characteristicDict objectForKey:characteristicPtrKey];
    
    [self logString:@"" afterSpaces:0];
    [self logString:@"characteristic with UUID:" afterSpaces:4];
    log = [NSString stringWithFormat:@"'%@'", [characteristic UUID]];
    [self logString:log afterSpaces:10];

    // descriptors
    NSUInteger count = [[characteristic descriptors] count];
    log = (count == 1) ? @"descriptor" : @"descriptors";
    log1 = [NSString stringWithFormat:@"%lu %@ found", count, log];
    [self logString:log1 afterSpaces:8];
    
    // checkout properties
    NSMutableArray *propertyStrings = [self getPropertyStrings:[characteristic properties]];
    [self logString:@"properties:" afterSpaces:8];
    for(NSString *property in propertyStrings) [self logString:property afterSpaces:12];

    // value
    // if([characteristic properties] & CBCharacteristicPropertyRead) {
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
    // }
    
    // check is notifying
    log = [characteristic isNotifying] ? @"" : @"NOT ";
    log1 = [NSString stringWithFormat:@"%@notifying", log];
    [self logString:log1 afterSpaces:8];
}

- (void)logData
{
    CBService *service;
    NSMutableArray *characteristics;
    NSString *log;
    
    [dataTextView setText:@""];
    
    log = [NSString stringWithFormat:@"peripheral with name: '%@'", [peripheral name]];
    [self logString:log afterSpaces:0];
    [self logString:@"peripheral UUID =" afterSpaces:0];
    log = [NSString stringWithFormat:@"'%@'", [peripheral identifier]];
    [self logString:log afterSpaces:10];
    
    for(NSMutableDictionary *serviceDict in peripheralArray) {
        service = [serviceDict objectForKey:servicePtrKey];
        [self logString:@"\nservice with UUID:" afterSpaces:0];
        log = [NSString stringWithFormat:@"'%@'", [service UUID]];
        [self logString:log afterSpaces:10];
        characteristics = [serviceDict objectForKey:characteristicsArrayKey];
        for(NSMutableDictionary *characteristicDict in characteristics) [self logCharacteristicData:characteristicDict];
    }
    [self populateMenuTableViewController];
}

#pragma mark - UITableViewController data source

- (void)populateMenuTableViewController
{
    NSLog(@"*** populate menu table view controller ***");
    NSString *tableHeaderText = [peripheral name];
    UIView *tableHeaderView = [hdSystem makeHeaderViewWithText:tableHeaderText
                                                  andTextColor:[UIColor redColor]
                                                   andTextSize:25
                                                     andOffset:15
                                                withBackground:true];
    [peripheralTableView setTableHeaderView:tableHeaderView];
    
    [peripheralTableView setRowHeight:40.0];
    menuTableViewSectionsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self generateServicesMenu];
    menuTablePopulated = true;
    
    // TableViewData *menuItemData = [self getCellDataFromSection:1 andRow:2];
    // [menuItemData changeValueTextTo:@"Oops"];
    
    // [self setAllButtonTitles];
    [peripheralTableView reloadData];
}

- (void)generateServicesMenu
{
    CBService *service;
    TableViewSectionData *serviceSection;
    NSString *serviceTitle, *characteristicTitle, *firstPart, *secondPart;
    NSMutableArray *characteristicsArray;
    CBCharacteristic *characteristic;
    
    // for all services
    for(NSMutableDictionary *serviceDict in peripheralArray) {
        service = [serviceDict objectForKey:servicePtrKey];
        serviceTitle = [NSString stringWithFormat:@"service with UUID: '%@'", [service UUID]];
        if([serviceTitle length] > 37) {
            firstPart = [serviceTitle substringToIndex:34];
            secondPart = [serviceTitle substringFromIndex:34];
            serviceTitle = [NSString stringWithFormat:@"%@ %@", firstPart, secondPart];     // space to create folding point
        }
        serviceSection = [[TableViewSectionData alloc] initSectionWithTitle:serviceTitle];
        [menuTableViewSectionsArray addObject:serviceSection];
        
        // for all characteristics
        characteristicsArray = [serviceDict objectForKey:characteristicsArrayKey];
        for(NSMutableDictionary *characteristicDict in characteristicsArray) {
            characteristic = [characteristicDict objectForKey:characteristicPtrKey];
            characteristicTitle = [NSString stringWithFormat:@"'%@'", [characteristic UUID]];
            [serviceSection addDefaultSelectableCellWithText:characteristicTitle
                                                     andName:@""
                                   andResponseMethodSelector:@selector(dummy)
                                                   isEnabled:true];
        }
    }
}

- (void)deselectLastUsedCell
{
    NSIndexPath *lastIndexPath = [peripheralTableView indexPathForSelectedRow];
    [peripheralTableView deselectRowAtIndexPath:lastIndexPath animated:YES];
    [peripheralTableView setAllowsSelection:YES];
}

- (TableViewData *)getCellDataFromSection:(NSUInteger)section andRow:(NSUInteger)row
{
    NSMutableArray *cellData = [[menuTableViewSectionsArray objectAtIndex:section] cellData];
    return [cellData objectAtIndex:row];
}

- (TableViewData *)getCellDataFromIndexPath:(NSIndexPath *)indexPath
{
    return [self getCellDataFromSection:[indexPath section]
                                 andRow:[indexPath row]];
}

- (void)dummy
{
    NSLog(@"*** dummy ***");
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = [[menuTableViewSectionsArray objectAtIndex:section] title];
    return [hdSystem makeHeaderViewWithText:title
                               andTextColor:[UIColor redColor]
                                andTextSize:17
                                  andOffset:15
                             withBackground:true];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [menuTableViewSectionsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *cellData = [[menuTableViewSectionsArray objectAtIndex:section] cellData];
    return [cellData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewData *thisCellData = [self getCellDataFromIndexPath:indexPath];
    return [thisCellData getCellForTableView:tableView andDelegate:self];
}

#pragma mark - UITableViewController delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewData *thisCellData = [self getCellDataFromIndexPath:indexPath];
    [thisCellData handleSelection];
    
    [self performSelector:@selector(deselectLastUsedCell)
               withObject:self
               afterDelay:1.0];
}

@end
