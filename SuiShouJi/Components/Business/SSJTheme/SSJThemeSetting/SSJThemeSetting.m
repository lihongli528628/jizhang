//
//  SSJThemeSetting.m
//  SuiShouJi
//
//  Created by old lang on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeSetting.h"
#import "NSString+SSJTheme.h"
#import "UIImage+SSJTheme.h"

#import "MMDrawerController.h"
#import "SSJBookKeepingHomeViewController.h"
#import "SSJReportFormsViewController.h"
#import "SSJFinancingHomeViewController.h"
#import "SSJMineHomeViewController.h"

@implementation SSJThemeSetting

+ (BOOL)addThemeModel:(SSJThemeModel *)model {
    NSDictionary *modelInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:[self settingFilePath]];
    NSMutableDictionary *newModelInfo = [NSMutableDictionary dictionaryWithCapacity:modelInfo.count + 1];
    [newModelInfo addEntriesFromDictionary:modelInfo];
    [newModelInfo setObject:model forKey:model.ID];
    
    return [NSKeyedArchiver archiveRootObject:newModelInfo toFile:[self settingFilePath]];
}

+ (BOOL)switchToThemeID:(NSString *)ID {
    if (!ID.length) {
        return NO;
    }
    
    SSJSetCurrentThemeID(ID);
    
    [self updateTabbar];
    
    return YES;
}

+ (SSJThemeModel *)currentThemeModel {
    NSDictionary *modelInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:[self settingFilePath]];
    SSJThemeModel *model = [modelInfo objectForKey:SSJCurrentThemeID()];
    if (model) {
        return model;
    } else {
        return [self defaultThemeModel];
    }
}

+ (NSArray *)allThemeModels {
    NSDictionary *modelInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:[self settingFilePath]];
    return [modelInfo allValues];
}

+ (NSString *)settingFilePath {
    NSString *settingPath = [[NSString ssj_themeDirectory] stringByAppendingPathComponent:@"settings"];
    return settingPath;
}

+ (SSJThemeModel *)defaultThemeModel {
    SSJThemeModel *model = [[SSJThemeModel alloc] init];
    model.ID = SSJDefaultThemeID;
    model.name = @"默认主题";
    model.backgroundAlpha = 1;
    model.mainColor = @"#393939";
    model.secondaryColor = @"#a7a7a7";
    model.marcatoColor = @"#eb4a64";
    model.borderColor = @"#cccccc";
    model.naviBarTitleColor = @"#000000";
    model.naviBarTintColor = @"#eb4a64";
    model.naviBarBackgroundColor = @"#FFFFFF";
    model.tabBarTitleColor = @"#a7a7a7";
    model.tabBarSelectedTitleColor = @"#eb4a64";
    model.tabBarBackgroundColor = @"#FFFFFF";
    model.cellSeparatorAlpha = 1;
    model.cellSeparatorColor = @"#e8e8e8";
    model.cellIndicatorColor = @"#cccccc";
    model.moreHomeTitleColor = @"#FFFFFF";
    model.moreHomeSubtitleColor = @"#fab9bf";
    model.recordHomeBorderColor = @"#eb4a64";
    return model;
}

+ (void)updateTabbar {
    MMDrawerController *drawerVC = (MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if (![drawerVC isKindOfClass:[MMDrawerController class]]) {
        return;
    }
    
    UITabBarController *tabBarVC = (UITabBarController *)drawerVC.centerViewController;
    if (![tabBarVC isKindOfClass:[UITabBarController class]]) {
        return;
    }
    
    SSJThemeModel *themeModel = [self currentThemeModel];
    
    UIViewController *recordHomeController = [tabBarVC.viewControllers ssj_safeObjectAtIndex:0];
    recordHomeController.tabBarItem.image = [UIImage ssj_themeImageWithName:@"tab_accounte_nor"];
    recordHomeController.tabBarItem.selectedImage = [UIImage ssj_themeImageWithName:@"tab_accounte_sel"];
    [recordHomeController.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:themeModel.tabBarTitleColor]} forState:UIControlStateNormal];
    [recordHomeController.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:themeModel.tabBarSelectedTitleColor]} forState:UIControlStateSelected];
    
    UIViewController *reportFormsController = [tabBarVC.viewControllers ssj_safeObjectAtIndex:1];
    reportFormsController.tabBarItem.image = [UIImage ssj_themeImageWithName:@"tab_form_nor"];
    reportFormsController.tabBarItem.selectedImage = [UIImage ssj_themeImageWithName:@"tab_form_sel"];
    [reportFormsController.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:themeModel.tabBarTitleColor]} forState:UIControlStateNormal];
    [reportFormsController.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:themeModel.tabBarSelectedTitleColor]} forState:UIControlStateSelected];
    
    UIViewController *financingController = [tabBarVC.viewControllers ssj_safeObjectAtIndex:2];
    financingController.tabBarItem.image = [UIImage ssj_themeImageWithName:@"tab_founds_nor"];
    financingController.tabBarItem.selectedImage = [UIImage ssj_themeImageWithName:@"tab_founds_sel"];
    [financingController.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:themeModel.tabBarTitleColor]} forState:UIControlStateNormal];
    [financingController.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:themeModel.tabBarSelectedTitleColor]} forState:UIControlStateSelected];
    
    UIViewController *moreController = [tabBarVC.viewControllers ssj_safeObjectAtIndex:3];
    moreController.tabBarItem.image = [UIImage ssj_themeImageWithName:@"tab_more_nor"];
    moreController.tabBarItem.selectedImage = [UIImage ssj_themeImageWithName:@"tab_more_sel"];
    [moreController.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:themeModel.tabBarTitleColor]} forState:UIControlStateNormal];
    [moreController.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:themeModel.tabBarSelectedTitleColor]} forState:UIControlStateSelected];
}

@end
