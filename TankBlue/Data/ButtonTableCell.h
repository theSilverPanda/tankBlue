//
//  ButtonTableCell.h
//  HubExplorer
//
//  Created by Henk Meewis on 11/3/17.
//  Copyright © 2017 Hunter Douglas, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonTableCell : UITableViewCell
{
}

@property (nonatomic, weak) IBOutlet UIButton *button;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@end
