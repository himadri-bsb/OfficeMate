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

- (void)changeToSelected:(BOOL)selected {
    if (selected) {
        [self.contentView setBackgroundColor:[UIColor lightGrayColor]];
    }
    else {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        [self.contentView setBackgroundColor:[UIColor lightGrayColor]];
    }
    else {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
    }
}

@end
