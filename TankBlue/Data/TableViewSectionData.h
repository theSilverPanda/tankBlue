//
//  TableViewSectionData.h
//  HubExplorer
//
//  Created by Henk Meewis on 11/14/17.
//  Copyright © 2017 Hunter Douglas, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableViewSectionData : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray *cellData;

- (id)initSectionWithTitle:(NSString *)text;
- (void)addDefaultSelectableCellWithText:(NSString *)text
                                 andName:(NSString *)name
               andResponseMethodSelector:(SEL)thisSelector
                               isEnabled:(bool)enabled;
@end
