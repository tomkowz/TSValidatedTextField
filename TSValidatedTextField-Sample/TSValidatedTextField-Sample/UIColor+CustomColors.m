//
//  UIColor+CustomColors.m
//  TSValidatedTextField-Sample
//
//  Created by Tomasz Szulc on 17.11.2013.
//  Copyright (c) 2013 Tomasz Szulc. All rights reserved.
//

#import "UIColor+CustomColors.h"

@implementation UIColor (CustomColors)

+ (UIColor *)validColor
{
    return [UIColor colorWithRed:98.0/255.0 green:178.0/255.0 blue:3.0/255.0 alpha:1.0];
}

+ (UIColor *)invalidColor
{
    return [UIColor colorWithRed:239.0/255.0 green:28.0/255.0 blue:28.0/255.0 alpha:1.0];
}

@end
