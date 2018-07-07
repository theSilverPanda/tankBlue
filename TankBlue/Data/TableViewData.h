//
//  TableViewData.h
//  HubExplorer
//
//  Created by Henk Meewis on 11/13/17.
//  Copyright © 2017 Hunter Douglas, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum {ctDefault = 0, ctButton, ctDefaultSelectable} eCellType;

@interface TableViewData : NSObject

@property (nonatomic) eCellType cellType;
@property (nonatomic, strong) NSString *buttonText, *nameText, *valueText;
@property (nonatomic, strong) id delegate;
@property (nonatomic) SEL responseMethod;
@property (nonatomic) bool enabled;

- (id)initDefaultCellWithText:(NSString *)text
                      andName:(NSString *)name;
- (id)initButtonCellWithText:(NSString *)text
                     andName:(NSString *)name;
- (id)initDefaultSelectableCellWithText:(NSString *)text
                                andName:(NSString *)name
              andResponseMethodSelector:(SEL)thisSelector
                              isEnabled:(bool)isEnabled;

- (UITableViewCell *)getCellForTableView:(UITableView *)tableView
                             andDelegate:(id)thisDelegate;
- (void)handleSelection;
- (void)changeValueTextTo:(NSString *)text;

@end
