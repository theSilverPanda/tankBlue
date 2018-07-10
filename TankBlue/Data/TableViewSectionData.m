//
//  TableViewSectionData.m
//  HubExplorer
//
//  Created by Henk Meewis on 11/14/17.
//  Copyright © 2017 Hunter Douglas, Inc. All rights reserved.
//

#import "TableViewData.h"
#import "TableViewSectionData.h"

@implementation TableViewSectionData
@synthesize title, cellData;

- (id)initSectionWithTitle:(NSString *)text
{
    self = [super init];
    if(self) {
        title = text;
        cellData = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)addDefaultSelectableCellWithText:(NSString *)text
                                andName:(NSString *)name
              andResponseMethodSelector:(SEL)thisSelector
                               isEnabled:(bool)enabled
{
    TableViewData *data = [[TableViewData alloc] initDefaultSelectableCellWithText:text
                                                                           andName:name
                                                         andResponseMethodSelector:thisSelector
                                                                         isEnabled:enabled];
    [cellData addObject:data];
}

- (void)addCharacteristicCellWithUUID:(CBUUID *)thisUUID
                             andValue:(NSData *)value
{
    TableViewData *data = [[TableViewData alloc] initCharacteristicCellWithUUID:(CBUUID *)thisUUID
                                                                       andValue:(NSData *)value];
    [cellData addObject:data];
}

@end
