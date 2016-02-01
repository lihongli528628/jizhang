//
//  SSJConstant.m
//  SuiShouJi
//
//  Created by old lang on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJConstant.h"

const int64_t SSJDefaultSyncVersion = -1;

//  接口域名
#ifdef DEBUG
//NSString *const SSJBaseURLString = @"http://192.168.2.47:8080";  // 东亚
//NSString *const SSJBaseURLString = @"http://192.168.1.155:8091";
NSString *const SSJBaseURLString = @"http://jz.9188.com/user/mobregisterchk.go";   // 测试环境
//NSString *const SSJBaseURLString = @"http://1.9188.com";
#else
NSString *const SSJBaseURLString = @"http://jz.9188.com/user/mobregisterchk.go";
#endif

NSString *const SSJErrorDomain = @"com.9188.jizhang";

NSString *const SSJLastSelectFundItemKey = @"lastSelectFundKey";

NSString *const SSJLastPopTimeKey = @"lastPopTimeKey";

NSString *const SSJHaveLoginOrRegistKey = @"haveLoginOrRegistKey";

NSString *const SSJHaveEnterFundingHomeKey = @"haveEnterFundingHomeKey";

NSString *const SSJSyncDataSuccessNotification = @"SSJSyncDataSuccessNotification";

NSString *const SSJLoginOrRegisterNotification = @"SSJLoginOrRegisterNotification";


