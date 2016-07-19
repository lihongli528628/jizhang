//
//  SSJThemeUtil.h
//  SuiShouJi
//
//  Created by old lang on 16/7/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SSJ_CURRENT_THEME [SSJThemeSetting currentThemeModel]

//  切换主题通知
extern NSString *const SSJThemeDidChangeNotification;

extern NSString *const SSJDefaultThemeID;

void SSJSetCurrentThemeID(NSString *ID);

NSString *SSJCurrentThemeID(void);
