//
//  MenuTestViewController.m
//  TankBlue
//
//  Created by Henk Meewis on 7/4/18.
//  Copyright © 2018 Henk Meewis. All rights reserved.
//

#import "TableViewSectionData.h"
#import "TableViewData.h"
#import "HD_System.h"

#import "MenuTestViewController.h"

extern HD_System *hdSystem;

@interface MenuTestViewController ()
@end

@implementation MenuTestViewController

- (id)init
{
    self = [super init];
    if(self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self populateMenuTableViewController];
}

- (IBAction)backButtonPessed:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - UITableViewController data source

- (void)populateMenuTableViewController
{
    NSLog(@"*** populate menu table view controller ***");

    NSString *tableHeaderText = @"Table Header Text";
    UIView *tableHeaderView = [hdSystem makeHeaderViewWithText:tableHeaderText
                                                  andTextColor:[UIColor redColor]
                                                   andTextSize:18
                                                     andOffset:15
                                                withBackground:true];
    [peripheralTableView setTableHeaderView:tableHeaderView];

        [peripheralTableView setRowHeight:27.0];
    menuTableViewSectionsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self generateConnectToHubMenu];
    [self generateHomeDataMenuIsEnabled:true];
    [self generateAdvancedFunctionalityMenu];
    
    menuTablePopulated = true;
    
    // TableViewData *menuItemData = [self getCellDataFromSection:1 andRow:2];
    // [menuItemData changeValueTextTo:@"Oops"];
    
    // [self setAllButtonTitles];
    [peripheralTableView reloadData];
}

- (void)generateConnectToHubMenu
{
    // generate first menu section
    TableViewSectionData *findHubSection = [[TableViewSectionData alloc] initSectionWithTitle:@"Connect to hub:"];
    [menuTableViewSectionsArray addObject:findHubSection];
    
    // generate three selectable menu items
    [findHubSection addDefaultSelectableCellWithText:@"with preset"
                                             andName:@""
                           andResponseMethodSelector:@selector(dummy)
                                           isEnabled:true];
    [findHubSection addDefaultSelectableCellWithText:@"with NetBIOS"
                                             andName:@""
                           andResponseMethodSelector:@selector(dummy)
                                           isEnabled:true];
    [findHubSection addDefaultSelectableCellWithText:@"with Bonjour"
                                             andName:@""
                           andResponseMethodSelector:@selector(dummy)
                                           isEnabled:true];
}

- (void)generateHomeDataMenuIsEnabled:(bool)enabled
{
    // generate second menu section
    TableViewSectionData *homeDataSection = [[TableViewSectionData alloc] initSectionWithTitle:@"Home data:"];
    [menuTableViewSectionsArray addObject:homeDataSection];
    
    // generate seven selectable menu items
    [homeDataSection addDefaultSelectableCellWithText:@"rooms"
                                              andName:@""
                            andResponseMethodSelector:@selector(dummy)
                                            isEnabled:enabled];
    [homeDataSection addDefaultSelectableCellWithText:@"shades"
                                              andName:@""
                            andResponseMethodSelector:@selector(dummy)
                                            isEnabled:enabled];
    [homeDataSection addDefaultSelectableCellWithText:@"single room scenes"
                                              andName:@""
                            andResponseMethodSelector:@selector(dummy)
                                            isEnabled:enabled];
    [homeDataSection addDefaultSelectableCellWithText:@"multiple room scenes"
                                              andName:@""
                            andResponseMethodSelector:@selector(dummy)
                                            isEnabled:enabled];
    [homeDataSection addDefaultSelectableCellWithText:@"flat scenes"
                                              andName:@""
                            andResponseMethodSelector:@selector(dummy)
                                            isEnabled:enabled];
    [homeDataSection addDefaultSelectableCellWithText:@"scheduled events"
                                              andName:@""
                            andResponseMethodSelector:@selector(dummy)
                                            isEnabled:enabled];
    [homeDataSection addDefaultSelectableCellWithText:@"scene controllers"
                                              andName:@""
                            andResponseMethodSelector:@selector(dummy)
                                            isEnabled:enabled];
    [homeDataSection addDefaultSelectableCellWithText:@"integrations"
                                              andName:@""
                            andResponseMethodSelector:@selector(dummy)
                                            isEnabled:enabled];
}

- (void)generateAdvancedFunctionalityMenu
{
    // generate third menu section
    TableViewSectionData *advancedFunctionalitySection = [[TableViewSectionData alloc] initSectionWithTitle:@"Advanced features:"];
    [menuTableViewSectionsArray addObject:advancedFunctionalitySection];
    
    // generate six selectable menu items
    [advancedFunctionalitySection addDefaultSelectableCellWithText:@"RF network"
                                                           andName:@""
                                         andResponseMethodSelector:@selector(dummy)
                                                         isEnabled:true];
    [advancedFunctionalitySection addDefaultSelectableCellWithText:@"remote server"
                                                           andName:@""
                                         andResponseMethodSelector:@selector(dummy)
                                                         isEnabled:true];
    [advancedFunctionalitySection addDefaultSelectableCellWithText:@"HomeKit"
                                                           andName:@""
                                         andResponseMethodSelector:@selector(dummy)
                                                         isEnabled:true];
    [advancedFunctionalitySection addDefaultSelectableCellWithText:@"mDNS lookup"
                                                           andName:@""
                                         andResponseMethodSelector:@selector(dummy)
                                                         isEnabled:true];
    [advancedFunctionalitySection addDefaultSelectableCellWithText:@"disconnect from hub"
                                                           andName:@""
                                         andResponseMethodSelector:@selector(dummy)
                                                         isEnabled:true];
    [advancedFunctionalitySection addDefaultSelectableCellWithText:@"testing"
                                                           andName:@""
                                         andResponseMethodSelector:@selector(dummy)
                                                         isEnabled:true];
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
    return 35.0;
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
