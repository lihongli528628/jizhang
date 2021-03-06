//
//  SSJMotionPasswordViewController.h
//  SuiShouJi
//
//  Created by old lang on 16/3/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

@class SSJLoginNavigator;

typedef NS_ENUM(NSUInteger, SSJMotionPasswordViewControllerType) {
    SSJMotionPasswordViewControllerTypeSetting,      // 设置手势密码
    SSJMotionPasswordViewControllerTypeVerification, // 验证手势密码
    SSJMotionPasswordViewControllerTypeTurnoff
};

@interface SSJMotionPasswordViewController : SSJBaseViewController

//  手势密码类型，默认为设置手势密码(SSJMotionPasswordViewControllerTypeSetting)
@property (nonatomic) SSJMotionPasswordViewControllerType type;

/**
 是否属于登录流程
 */
@property (nonatomic) BOOL isLoginFlow;

@end
