//
//  OMHomeTableViewCell.m
//  OfficeMate
//
//  Created by Ravindra Shetty on 23/05/15.
//  Copyright (c) 2015 Ravindra Shetty. All rights reserved.
//

#import "OMHomeTableViewCell.h"
#import "OMAppearance.h"

@implementation OMHomeTableViewCell

- (void)awakeFromNib {
    self.locationInfoLabel.textColor = [OMAppearance appThemeColorWithAlpha:1.0f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
