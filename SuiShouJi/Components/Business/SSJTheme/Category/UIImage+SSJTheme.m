//
//  UIImage+SSJTheme.m
//  SuiShouJi
//
//  Created by old lang on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "UIImage+SSJTheme.h"
#import "NSString+SSJTheme.h"
#import "SSJThemeConst.h"

@implementation UIImage (SSJTheme)

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCache) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

+ (void)clearCache {
    [[self memoCache] removeAllObjects];
}

+ (NSCache *)memoCache {
    static NSCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!cache) {
            cache = [[NSCache alloc] init];
        }
    });
    return cache;
}

+ (instancetype)ssj_themeImageWithName:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name];
    if (image) {
        return image;
    }
    
    // 按照屏幕分辨率拼接图片名称，例如：320x640 imgName.png；640x960 imgName@2x.png；1242x2208 imgName@3x.png
    NSString *imgName = name;
    if ([UIScreen mainScreen].scale == 2 || [UIScreen mainScreen].scale == 3) {
        imgName = [NSString stringWithFormat:@"%@@%d", name, (int)[UIScreen mainScreen].scale];
    }
    
    NSString *themeID = [[NSUserDefaults standardUserDefaults] objectForKey:SSJCurrentThemeIDKey];
    NSString *imagePath = [[NSString ssj_themeDirectory] stringByAppendingPathComponent:themeID];
    imagePath = [imagePath stringByAppendingPathComponent:imgName];
    
    image = [[self memoCache] objectForKey:imagePath];
    if (image) {
        return image;
    }
    
    image = [UIImage imageWithContentsOfFile:imagePath];
    [[self memoCache] setObject:image forKey:imagePath];
    
    return image;
}

+ (instancetype)ssj_compatibleThemeImageNamed:(NSString *)name {
    NSString *imageName = [name stringByDeletingPathExtension];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        if (CGSizeEqualToSize(screenSize, CGSizeMake(320.0, 568.0))) {
            imageName = [NSString stringWithFormat:@"%@-568",imageName];
        } else if (CGSizeEqualToSize(screenSize, CGSizeMake(375.0, 667.0))) {
            imageName = [NSString stringWithFormat:@"%@-667",imageName];
        }
    }
    
    return [self ssj_themeImageWithName:imageName];
}

@end
