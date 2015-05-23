//
//  OMAppearance.h
//  OfficeMate
//
//  Created by Ravindra Shetty on 23/05/15.
//  Copyright (c) 2015 Ravindra Shetty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OMAppearance : NSObject

+(UIColor *)appThemeColorWithAlpha:(CGFloat)alpha;
+(UIColor *)appTextColorWithAlpha:(CGFloat)alpha;
+(UIColor *)appBgColorWithAlpha:(CGFloat)alpha;

+(UIFont *)appFontWithSize:(CGFloat)size shouldBold:(BOOL)bold;

@end
