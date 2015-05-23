//
//  OMHomeTableViewCell.h
//  OfficeMate
//
//  Created by Ravindra Shetty on 23/05/15.
//  Copyright (c) 2015 Ravindra Shetty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMHomeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLable;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;

@end
