//
//  CentralViewController.m
//  TankBlue
//
//  Created by Henk Meewis on 2/15/18.
//  Copyright © 2018 Henk Meewis. All rights reserved.
//

#import "PeripheralItem.h"
#import "CentralViewController.h"

HDHexConversion *hdHexConversion;
HD_System *hdSystem;

@interface CentralViewController ()
@end

@implementation CentralViewController

- (id)init
{
    self = [super init];
    if(self) {
        // create new different objects
        hdHexConversion = [[HDHexConversion alloc] init];
        hdSystem = [[HD_System alloc] init];
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        // peripheralsArray = [[NSMutableArray alloc] initWithCapacity:0];
        peripheralItemsArray = [[NSMutableArray alloc] initWithCapacity:0];
        pvc = nil;
        NSLog(@"init central view controller");
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    buttonColor = [restartButton currentTitleColor];
    [self restart];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"did connect with peripheral '%@'", [peripheral name]);
    [self gotoPeripheralView:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"did disconnect peripheral ...");
    [pvc gotoLastScreen];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"failed to connect peripheral ...");
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    bool alreadyDiscovered = false;
    NSString *discoveredName = [peripheral name], *existingName;
    NSUUID *discoveredUUID = [peripheral identifier], *existingUUID;
    PeripheralItem *newPeripheralItem;
    
    // check if the discovered peripheral is not yet in the list
    CBPeripheral *existingPeripheral;
    for(PeripheralItem *peripheralItem in peripheralItemsArray) {
        existingPeripheral = [peripheralItem peripheral];
        existingName = [existingPeripheral name];
        existingUUID = [existingPeripheral identifier];
        if([existingName isEqualToString:discoveredName] && [existingUUID isEqual:discoveredUUID]) alreadyDiscovered = true;
    }
    
    // be sure that this peripheral is new and valid and connectable
    if(!alreadyDiscovered) {
        NSNumber *isConnectableNumber = [advertisementData objectForKey:@"kCBAdvDataIsConnectable"];
        if(isConnectableNumber && [isConnectableNumber boolValue]) {
            discoveredName = @"<no name>";
            if([peripheral name]) discoveredName = [NSString stringWithFormat:@"'%@'", [peripheral name]];
            newPeripheralItem = [[PeripheralItem alloc] initWithPeripheral:peripheral withName:discoveredName andRSSI:RSSI];
            [peripheralItemsArray addObject:newPeripheralItem];
            NSLog(@"======================================================");
            // NSLog(@"array count: %u", (uint)[peripheralsArray count]);
            NSLog(@"discovered connectable peripheral with name: %@", discoveredName);
            NSLog(@"  and UUID: %@", [peripheral identifier]);
            NSLog(@"  and RSSI: %d dB", [RSSI intValue]);
            for(NSString *key in advertisementData) NSLog(@"%@: %@", key, advertisementData[key]);
            NSLog(@"");
            [peripheralsTableView reloadData];
        }
    }
}

- (NSString *)getManagerStateString:(CBManagerState)managerState
{
    NSString *managerStateString;
    switch(managerState) {
        case CBManagerStateUnknown: managerStateString = @"CBManagerStateUnknown"; break;
        case CBManagerStateResetting: managerStateString = @"CBManagerStateResetting"; break;
        case CBManagerStateUnsupported: managerStateString = @"CBManagerStateUnsupported"; break;
        case CBManagerStateUnauthorized: managerStateString = @"CBManagerStateUnauthorized"; break;
        case CBManagerStatePoweredOff: managerStateString = @"CBManagerStatePoweredOff"; break;
        case CBManagerStatePoweredOn: managerStateString = @"CBManagerStatePoweredOn"; break;
        default: managerStateString = @"inValid";
    }
    return managerStateString;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self startScanningForPeripherals];
}

- (void)startScanningForPeripherals
{
    CBManagerState managerState = [centralManager state];
    NSLog(@"central manager's state updated to '%@'", [self getManagerStateString:managerState]);
    if(managerState == CBManagerStatePoweredOn) {
        [centralManager scanForPeripheralsWithServices:nil options:nil];
        [self performSelector:@selector(stopScanningForPeripherals)
                   withObject:self
                   afterDelay:10.0];
    }
}

- (void)stopScanningForPeripherals
{
    if([centralManager isScanning]) {
        [centralManager stopScan];
        NSLog(@"central manager stopped scanning");
    }
}

- (void)gotoPeripheralView:(CBPeripheral *)connectedPeripheral
{
    pvc = [[PeripheralViewController alloc] init];
    
    id delegate = pvc;
    [connectedPeripheral setDelegate:delegate]; // in two steps to avoid warning
    [pvc setCentralManager:centralManager];
    [pvc setPeripheral:connectedPeripheral];
    [self presentViewController:pvc animated:true completion:nil];
}

/* not supported
 - (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict
 {
 }
 */

#pragma mark - UITableView data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // DLog(@"view for header in section");
    NSUInteger count = [peripheralItemsArray count];
    NSString *title;
    
    NSString *countString = [hdSystem getValueStringFor:count startingWithCapital:YES];
    NSString *body = @"peripheral";
    NSString *plural;
    switch(count) {
        case 0: plural = @"s"; break;
        case 1: plural = @":"; break;
        default: plural = @"s:";
    }
    
    title = [NSString stringWithFormat:@"%@ %@%@", countString, body, plural];
    
    return [hdSystem makeHeaderViewWithText:title
                               andTextColor:[UIColor redColor]
                                andTextSize:20
                                  andOffset:15
                             withBackground:true];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [peripheralItemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                            reuseIdentifier:@"Cell"];
    
    NSUInteger row = [indexPath row];
    PeripheralItem *thisPeripheralItem = [peripheralItemsArray objectAtIndex:row];
    CBPeripheral *thisPeripheral = [thisPeripheralItem peripheral];
    NSString *text;
    NSInteger rssi = [[thisPeripheralItem RSSI] integerValue];
    if(rssi < 0) text = [NSString stringWithFormat:@"%@ (RSSI = %ld dB)", [thisPeripheralItem name], rssi];
    else text = [NSString stringWithFormat:@"%@", [thisPeripheralItem name]];
    
    [[cell textLabel] setText:text];
    [[cell textLabel] setTextColor:buttonColor];
    [[cell detailTextLabel] setText:[[thisPeripheral identifier] UUIDString]];
    
    return cell;
}

#pragma mark - UITableView delegate
- (void)deselectLastUsedCell
{
    NSIndexPath *lastIndexPath = [peripheralsTableView indexPathForSelectedRow];
    [peripheralsTableView deselectRowAtIndexPath:lastIndexPath animated:YES];
    [peripheralsTableView setAllowsSelection:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    PeripheralItem *thisPeripheralItem = [peripheralItemsArray objectAtIndex:row];
    CBPeripheral *thisPeripheral = [thisPeripheralItem peripheral];
    [centralManager connectPeripheral:thisPeripheral options:nil];
    
    [self performSelector:@selector(deselectLastUsedCell)
               withObject:self
               afterDelay:1.0];
}

/*
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 }
 
 - (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
 {
 }
 */

- (void)restart
{
    [self stopScanningForPeripherals];
    [peripheralItemsArray removeAllObjects];
    [peripheralsTableView reloadData];
    [self performSelector:@selector(startScanningForPeripherals) withObject:self afterDelay:0.25];
}

- (IBAction)restartButtonPressed:(id)sender
{
    [self restart];
}
@end
