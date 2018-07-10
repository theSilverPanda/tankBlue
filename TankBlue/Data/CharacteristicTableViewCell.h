//
//  CharacteristicTableViewCell.h
//  TankBlue
//
//  Created by Henk Meewis on 7/10/18.
//  Copyright © 2018 Henk Meewis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CharacteristicTableViewCell : UITableViewCell
{
//    __weak IBOutlet UILabel *uuidLabel;
//    __weak IBOutlet UILabel *valueLabel;
}
@property (nonatomic, weak) IBOutlet UILabel *uuidLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;

@end
