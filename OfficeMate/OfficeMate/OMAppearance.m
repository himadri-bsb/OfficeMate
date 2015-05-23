//
//  OMAppearance.m
//  OfficeMate
//
//  Created by Ravindra Shetty on 23/05/15.
//  Copyright (c) 2015 Ravindra Shetty. All rights reserved.
//

#import "OMAppearance.h"

#define APP_FONT_NAME_NORMAL @"Helvetica"
#define APP_FONT_NAME_BOLD @"HelveticaNeue-Bold"

@implementation OMAppearance

+(UIColor *)appThemeColorWithAlpha:(CGFloat)alpha {
    return [UIColor colorWithRed:15/255.f green:143/255.f blue:225/255.f alpha:alpha];
}

+(UIColor *)appTextColorWithAlpha:(CGFloat)alpha {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
}

+(UIColor *)appBgColorWithAlpha:(CGFloat)alpha {
    return [UIColor colorWithRed:1 green:1 blue:1 alpha:alpha];

}

+(UIFont *)appFontWithSize:(CGFloat)size shouldBold:(BOOL)bold {
    if (bold) {
        return [UIFont fontWithName:APP_FONT_NAME_BOLD size:size];
    }
    else {
        return [UIFont fontWithName:APP_FONT_NAME_NORMAL size:size];
    }
}

+(void)setUpNavigatioNBarAppearance {
    [[UINavigationBar appearance] setBarTintColor:[OMAppearance appThemeColorWithAlpha:1.0f]];
    [[UINavigationBar appearance]  setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
}

@end
