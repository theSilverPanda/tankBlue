//
//  ButtonTableCell.m
//  HubExplorer
//
//  Created by Henk Meewis on 11/3/17.
//  Copyright © 2017 Hunter Douglas, Inc. All rights reserved.
//

#import "ButtonTableCell.h"

@implementation ButtonTableCell
@synthesize button;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    // [nameLabel setHidden:true];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
