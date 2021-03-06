//
//  SSJLoginPopView.m
//  SuiShouJi
//
//  Created by yi cai on 2016/12/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoginPopView.h"
#import "SSJLoginVerifyPhoneViewController.h"
#import "SSJBookKeepingHomePopView.h"
#import "UIViewController+SSJPageFlow.h"
#import "SSJNavigationController.h"

BOOL kHomeNeedLoginPop = YES;
@implementation SSJLoginPopView

+ (BOOL)popIfNeededWithNav:(UINavigationController *)nav backController:(UIViewController *)backVC {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:SSJLastLoggedUserItemKey] && !SSJIsUserLogined() && kHomeNeedLoginPop) {
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:@"当前未登录，请登录后再去记账吧~" action:[SSJAlertViewAction actionWithTitle:@"关闭" handler:NULL], [SSJAlertViewAction actionWithTitle:@"立即登录" handler:^(SSJAlertViewAction * _Nonnull action) {
            SSJLoginVerifyPhoneViewController *loginVc = [[SSJLoginVerifyPhoneViewController alloc] init];
            SSJNavigationController *loginNav = [[SSJNavigationController alloc] initWithRootViewController:loginVc];
            [SSJVisibalController().navigationController presentViewController:loginNav animated:NO completion:NULL];
        }], nil];
        kHomeNeedLoginPop = NO;
        return YES;
    }
    return NO;
}
@end

