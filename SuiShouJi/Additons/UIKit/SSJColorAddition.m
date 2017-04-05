//
//  SSJColorAddition.m
//  SuiShouJi
//
//  Created by old lang on 15/10/26.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJColorAddition.h"

@implementation UIColor (SSJCategory)

+ (UIColor *)ssj_colorWithHex:(NSString *)hexColor {
    NSString *cString = [[hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if (cString.length > 6) {
        return [self ssj_colorWithAlphaHex:hexColor];
    } else {
        return [self ssj_colorWithHex:hexColor alpha:1];
    }
}

+ (UIColor *)ssj_colorWithHex:(NSString *)hexColor alpha:(CGFloat)alpha {
    if (hexColor.length) {
        NSString *cString = [[hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
        // String should be 6 or 8 characters
        
        if ([cString length] < 6) return [UIColor blackColor];
        // strip 0X if it appears
        if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
        if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
        if ([cString length] != 6) return [UIColor blackColor];
        
        // Separate into r, g, b substrings
        
        NSRange range;
        range.location = 0;
        range.length = 2;
        NSString *rString = [cString substringWithRange:range];
        range.location = 2;
        NSString *gString = [cString substringWithRange:range];
        range.location = 4;
        NSString *bString = [cString substringWithRange:range];
        // Scan values
        unsigned int r, g, b;
        
        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];
        
        return [UIColor colorWithRed:((float) r / 255.0f)
                               green:((float) g / 255.0f)
                                blue:((float) b / 255.0f)
                               alpha:alpha];
    }else {
        return nil;
    }
}

+ (UIColor *)ssj_colorWithAlphaHex:(NSString *)hexColor {
    if (hexColor.length) {
        NSString *cString = [[hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
        // String should be 6 or 8 characters
        
        if ([cString length] < 6) return [UIColor blackColor];
        // strip 0X if it appears
        if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
        if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
        if ([cString length] != 8) return [UIColor blackColor];
        
        // Separate into r, g, b substrings
        
        NSRange range;
        range.location = 0;
        range.length = 2;
        NSString *rString = [cString substringWithRange:range];
        range.location = 2;
        NSString *gString = [cString substringWithRange:range];
        range.location = 4;
        NSString *bString = [cString substringWithRange:range];
        range.location = 4;
        NSString *aString = [cString substringWithRange:range];
        // Scan values
        unsigned int r, g, b ,a;
        
        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];
        [[NSScanner scannerWithString:aString] scanHexInt:&a];
        
        return [UIColor colorWithRed:((float) r / 255.0f)
                               green:((float) g / 255.0f)
                                blue:((float) b / 255.0f)
                               alpha:((float) a / 255.0f)];
    }else {
        return nil;
    }
}


@end
