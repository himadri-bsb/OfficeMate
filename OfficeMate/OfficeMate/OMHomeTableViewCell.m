//
//  OMHomeTableViewCell.m
//  OfficeMate
//
//  Created by Ravindra Shetty on 23/05/15.
//  Copyright (c) 2015 Ravindra Shetty. All rights reserved.
//

#import "OMHomeTableViewCell.h"
#import "OMAppearance.h"
#import "OMCommonDefs.h"

#define COLOR_BACKGROUND_SELECTED [UIColor colorWithRed:231.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1]

@implementation OMHomeTableViewCell


- (void)awakeFromNib {
    self.locationInfoLabel.textColor = [OMAppearance appThemeColorWithAlpha:1.0f];
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.observingIndicator.hidden = YES;
        [self addLongPressGestureRecogniser];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.observingIndicator.hidden = YES;
}

- (void)addLongPressGestureRecogniser
{
    UILongPressGestureRecognizer *lpg = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap:)];
    [self addGestureRecognizer:lpg];
}


- (void)handleLongTap:(UILongPressGestureRecognizer *)logTapGesture {
    if (logTapGesture.state == UIGestureRecognizerStateBegan) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_LongPressTableCell object:self];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        [self.contentView setBackgroundColor:COLOR_BACKGROUND_SELECTED];
    }
    else {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [self.contentView setBackgroundColor:COLOR_BACKGROUND_SELECTED];
    }
    else {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
    }
}

@end
