//
//  AppDelegate.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/11.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "AppDelegate.h"

#import "SSJDatabaseQueue.h"
#import "SSJUserDefaultDataCreater.h"
#import "SSJUserTableManager.h"
#import "SSJDataSynchronizer.h"
#import "SSJDataSynchronizeTask.h"
#import "SSJDatabaseUpgrader.h"
#import "SSJRegularManager.h"
#import "SSJThirdPartyLoginManger.h"
#import "SSJNavigationController.h"
#import "SSJBookKeepingHomeViewController.h"
#import "SSJNewMineHomeViewController.h"
#import "SSJFinancingHomeViewController.h"
#import "SSJReportFormsViewController.h"
#import "MMDrawerController.h"
#import "SSJFundingDetailsViewController.h"
#import "SSJLoanDetailViewController.h"
#import "SSJWishProgressViewController.h"
#import "SSJFixedFinanceProductDetailViewController.h"
#import "SSJNewUserFirstStartViewController.h"
#import "SSJGuideViewController.h"
#import "SSJStartLauncherViewController.h"

#import "UIViewController+SSJMotionPassword.h"

//#import "SSJAPPEvaluatePopView.h"
#import "SSJGradientMaskView.h"
#import "SSJCreditCardItem.h"

#import "SSJLocalNotificationHelper.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "SSJStartViewManager.h"
#import <UShareUI/UMSocialUIManager.h>
#import "SSJShareBooksUrlHandle.h"

//#import "SSJPatchUpdateService.h"
//#import "SSJJspatchAnalyze.h"
//#import "SSJJsPatchItem.h"
#import "SSJBooksTypeSelectViewController.h"
//#import "JPEngine.h"
#import "SSJUmengManager.h"
#import "SSJLocalNotificationHelper.h"
#import "SSJLocalNotificationStore.h"
#import "SSJDomainManager.h"
#import "SSJLoanHelper.h"
#import "SSJAnaliyticsManager.h"
#import "SSJCustomThemeManager.h"
#import "SSJWishHelper.h"
#import "SSJFixedFinanceProductStore.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

//  进入后台超过的时限后进入锁屏
static const NSTimeInterval kLockScreenDelay = 60;

static NSString *const kEnterBackgroundTimeKey = @"kEnterBackgroundTimeKey";

//微信desc
static NSString *const kWeiXinDescription = @"weixinLogin";

void SCYSaveEnterBackgroundTime() {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kEnterBackgroundTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSDate *SCYEnterBackgroundTime() {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kEnterBackgroundTimeKey];
}

@interface AppDelegate ()

@property (nonatomic, strong) SSJStartViewManager *startViewManager;

@property(nonatomic, strong) SSJGradientMaskView *maskView;

@end

@implementation AppDelegate

#pragma mark - Lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 此方法最好第一个调用
    SSJMigrateLaunchTimesInfo();
    SSJAddLaunchTimesForCurrentVersion();

#ifdef DEBUG
//    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"patch1" ofType:@"js"];
//    NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
//    [JPEngine evaluateScript:script];
#endif
    
    [SSJUmengManager umengShare];
    [SSJAnaliyticsManager SSJAnaliytics];
    [[SSJGeTuiManager shareManager] SSJGeTuiManagerWithDelegate:self];
    
    [MQManager setScheduledAgentWithAgentId:@"" agentGroupId:SSJMQDefualtGroupId scheduleRule:MQScheduleRulesRedirectGroup];
    
    [self initUserDataWithFinishHandler:^(BOOL successfull){
#ifdef DEBUG
        // 如果要模拟用户登录，就开启此开关，并在simulateUserSync方法传入用户的id；如果用户还有未同步到server端的数据，将用户同步失败的json文件放到bundle中，并以“sync_data.json”命名
        BOOL simulateUserSync = NO;
#else
        BOOL simulateUserSync = NO;
#endif
        if (simulateUserSync) {
            [SSJDataSynchronizeTask simulateUserSync:@"ec0fd0d4-f2c1-4903-abd9-acabb6a48805"];
        } else {
            [[SSJDataSynchronizer shareInstance] startTimingSync];
            if (SSJIsUserLogined()) {
                [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:NULL failure:NULL];
            }
        }
        
        UILocalNotification *notifcation = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
        if (notifcation) {
            SSJDispatchMainAsync(^{
                [self pushToControllerWithNotification:notifcation];
            });
        }
    }];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self setRootViewController];
    
    //如果第一次打开记录当前时间
    if (SSJLaunchTimesForCurrentVersion() == 1) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSDate date]forKey:SSJLastPopTimeKey];
//        [SSJJspatchAnalyze removePatch];
    }
        
    
    //每次启动打一次补丁
//    [SSJJspatchAnalyze SSJJsPatchAnalyzePatch];
    
    //微信登录
    [WXApi registerApp:SSJDetailSettingForSource(@"WeiXinKey")];
    
//    _startViewManager = [[SSJStartViewManager alloc] init];
//    [_startViewManager showWithCompletion:^(SSJStartViewManager *manager){
//        [UIViewController verifyMotionPasswordIfNeeded:^(BOOL isVerified) {
//            UITabBarController *tabVC = (UITabBarController *)((MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController).centerViewController;
//            UINavigationController *navi = [tabVC.viewControllers firstObject];
//            UIViewController *vc = [navi.viewControllers firstObject];
//            if (![vc isKindOfClass:[SSJBookKeepingHomeViewController class]]) {
//                return;
//            }
//            SSJBookKeepingHomeViewController *homeVC = (SSJBookKeepingHomeViewController *)vc;
//            if (isVerified) {
//                homeVC.allowRefresh = YES;
//                homeVC.hasLoad = NO;
//            } else {
//                [homeVC reloadWithAnimation];
//            }
//        } animated:NO];
//        manager = nil;
//    }];
    
    [SSJDomainManager requestDomain];
    // 美恰sdk设置
    [MQManager initWithAppkey:SSJMQAppKey completion:NULL];
    //保存app启动时间，判断是否为新用户
//    [SSJAPPEvaluatePopView evaluatePopViewConfiguration];
    
    
    // 如果自定义主题有升级的话，会先移除之前的主题包，导致启动后4个tab图标消失，延迟执行会避免这个问题（令人费解的机制）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SSJCustomThemeManager initializeCustomTheme];
    });
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [GeTuiSdk setBadge:0];
    //每次从后台进入打一次补丁
//    [SSJJspatchAnalyze SSJJsPatchAnalyzePatch];
    
    // 当程序从后台进入前台，检测是否自动补周期数据
    [SSJRegularManager supplementCycleRecordsForUserId:SSJUSERID() success:^{
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError * _Nonnull error) {
        [CDAutoHideMessageHUD showError:error];
    }];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self pushToControllerWithNotification:notification];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //App 进入后台时，关闭美洽服务
    [MQManager closeMeiqiaService];
    SCYSaveEnterBackgroundTime();
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    NSDate *backgroundTime = SCYEnterBackgroundTime();
    NSTimeInterval interval = [backgroundTime timeIntervalSinceDate:[NSDate date]];
    interval = ABS(interval);
    if (interval >= kLockScreenDelay) {
        [UIViewController verifyMotionPasswordIfNeeded:NULL animated:NO];
    }
    // App 进入前台时，开启美洽服务
    [MQManager openMeiqiaService];
}

//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
//    [MQManager registerDeviceToken:deviceToken];
//}



#pragma mark - Private
// 初始化用户数据
- (void)initUserDataWithFinishHandler:(void (^)(BOOL successfull))finishHandler {
    [[NSNotificationCenter defaultCenter] postNotificationName:SSJInitDatabaseDidBeginNotification object:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 迁移数据库文件
        NSString *dbDocumentPath = SSJSQLitePath();
        SSJPRINT(@"%@", dbDocumentPath);
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dbDocumentPath]) {
            NSError *error = nil;
            NSString *dbBundlePath = [[NSBundle mainBundle] pathForResource:@"mydatabase" ofType:@"db"];
            [[NSFileManager defaultManager] copyItemAtPath:dbBundlePath toPath:dbDocumentPath error:&error];
            if (error) {
                SSJDispatchMainAsync(^{
                    finishHandler(NO);
                });
                return;
            }
        }
        
        if (!SSJUSERID()) {
            NSError *error = nil;
            [SSJUserTableManager reloadUserIdWithError:&error];
            if (error) {
                SSJDispatchMainAsync(^{
                    finishHandler(NO);
                });
                return;
            }
        }
        
        NSError *error = [SSJDatabaseUpgrader upgradeDatabase];
        if (error) {
            SSJDispatchMainAsync(^{
                finishHandler(NO);
            });
            return;
        }
        
        [SSJUserDefaultDataCreater createAllDefaultDataWithUserId:SSJUSERID() error:nil];
        
        
        SSJDispatchMainAsync(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SSJInitDatabaseDidFinishNotification object:self];
            [[UIApplication sharedApplication] cancelAllLocalNotifications]; 
            // 1.7.0之前有每日提醒，此版本后提醒改变了，所以要取消之前所有提醒
            [SSJLocalNotificationStore queryForreminderListForUserId:SSJUSERID() WithSuccess:^(NSArray<SSJReminderItem *> *result) {
                for (SSJReminderItem *item in result) {
                    [SSJLocalNotificationHelper registerLocalNotificationWithremindItem:item];
                }
            } failure:^(NSError *error) {
                SSJPRINT(@"警告：同步后注册本地通知失败 error:%@", [error localizedDescription]);
            }];

            finishHandler(YES);
        });
    });
}

// 设置根控制器
- (void)setRootViewController {
    if (SSJLaunchTimesForAllVersion() == 1) {
        SSJNewUserFirstStartViewController *newUserVc = [[SSJNewUserFirstStartViewController alloc] initWithNibName:nil bundle:nil];
        SSJNavigationController *newUserNavi = [[SSJNavigationController alloc] initWithRootViewController:newUserVc];
        [UIApplication sharedApplication].keyWindow.rootViewController = newUserNavi;
    } else if (SSJLaunchTimesForCurrentVersion() == 1) {
        SSJGuideViewController *guideVc = [[SSJGuideViewController alloc] init];
        SSJNavigationController *guideNavi = [[SSJNavigationController alloc] initWithRootViewController:guideVc];
        [UIApplication sharedApplication].keyWindow.rootViewController = guideNavi;

    } else {
        SSJStartLauncherViewController *launcherVc = [[SSJStartLauncherViewController alloc] initWithNibName:nil bundle:nil];
        SSJNavigationController *launcherNavi = [[SSJNavigationController alloc] initWithRootViewController:launcherVc];
        [UIApplication sharedApplication].keyWindow.rootViewController = launcherNavi;
    }
}
    
#pragma mark - qq快登
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [WXApi handleOpenURL:url delegate:[SSJThirdPartyLoginManger shareInstance].weixinLogin];
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {  
        [SSJShareBooksUrlHandle handleOpenURL:url];
        // 其他如支付等SDK的回调
    }
    return result;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    return [TencentOAuth HandleOpenURL:url] ||
    [WXApi handleOpenURL:url delegate:[SSJThirdPartyLoginManger shareInstance].weixinLogin] || [SSJShareBooksUrlHandle handleOpenURL:url];
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [TencentOAuth HandleOpenURL:url] ||
    [WXApi handleOpenURL:url delegate:[SSJThirdPartyLoginManger shareInstance].weixinLogin] || [SSJShareBooksUrlHandle handleOpenURL:url];
}

#pragma mark - 根据推送的内容跳转不同的页面
- (void)pushToControllerWithNotification:(UILocalNotification *)notification{
    if ([notification.userInfo[@"key"] isEqualToString:SSJReminderNotificationKey]) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:notification.alertBody action:[SSJAlertViewAction actionWithTitle:@"知道了" handler:NULL],nil];
        }else{
            UIViewController *currentVc = SSJVisibalController();
            NSDictionary *userinfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
            SSJReminderItem *remindItem = [SSJReminderItem mj_objectWithKeyValues:[userinfo objectForKey:@"remindItem"]];
            if (remindItem.remindType == SSJReminderTypeCreditCard) {
                SSJFinancingHomeitem *cardItem = [[SSJFinancingHomeitem alloc]init];
                if (!remindItem.fundId.length) {
                    [self getCreditCardIdForRemindId:remindItem.remindId Success:^(NSString *cardId) {
                        cardItem.fundingID = remindItem.fundId;
                        SSJFundingDetailsViewController *creditCardVc = [[SSJFundingDetailsViewController alloc] init];
                        creditCardVc.item = cardItem;
                        [currentVc.navigationController pushViewController:creditCardVc animated:YES];
                    } failure:NULL];
                }

            }else if(remindItem.remindType == SSJReminderTypeBorrowing){
                if (!remindItem.fundId.length) {
                    [self getLoanIdForRemindId:remindItem.remindId Success:^(NSString *cardId) {
                        [SSJLoanHelper queryForFundColorWithLoanId:remindItem.fundId completion:^(NSString * _Nonnull color) {
                            SSJLoanDetailViewController *loanVc = [[SSJLoanDetailViewController alloc]init];
                            loanVc.loanID = cardId;
                            loanVc.fundColor = color;
                            [currentVc.navigationController pushViewController:loanVc animated:YES];
                        }];
                    } failure:NULL];
                }

            } else if (remindItem.remindType == SSJReminderTypeWish) {//愿望
                if (remindItem.remindId.length) {
                    SSJWishProgressViewController *wishProgressVC = [[SSJWishProgressViewController alloc] init];
                    wishProgressVC.wishId = [SSJWishHelper queryWishIdWithRemindId:remindItem.remindId];
                    [currentVc.navigationController pushViewController:wishProgressVC animated:YES];
                }
            }else if (remindItem.remindType == SSJFixedFinaProduct) {
                
                SSJFixedFinanceProductDetailViewController *finDeVC = [[SSJFixedFinanceProductDetailViewController alloc] init];
                finDeVC.productID = [SSJFixedFinanceProductStore queryProductIdWithRemindId:remindItem.remindId];
                [currentVc.navigationController pushViewController:finDeVC animated:YES];
            }
        }
    }
}

#pragma mark - 获取当前推送的账户id
- (void)getCreditCardIdForRemindId:(NSString *)remindID Success:(void (^)(NSString *cardId))success failure:(void (^)())failure{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *cardId = [db stringForQuery:@"select cfundid from bk_user_credit where cremindid = ? and cuserid = ?",remindID,SSJUSERID()];
        if (success) {
            success(cardId);
        }
    }];
}

- (void)getLoanIdForRemindId:(NSString *)remindID Success:(void (^)(NSString *cardId))success failure:(void (^)())failure{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString * loanId = [db stringForQuery:@"select loanid from bk_loan where cremindid = ? and cuserid = ?",remindID,SSJUSERID()];
        if (success) {
            success(loanId);
        }
    }];
}

#pragma mark - 远程通知有关的
/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // [ GTSdk ]：向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token];
}

/** 远程通知注册失败委托 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    SSJPRINT(@"\n>>>[DeviceToken Error]:%@\n\n", error.description);
}

#pragma mark - APP运行中接收到通知(推送)处理 - iOS 10以下版本收到推送

/** APP已经接收到“远程”通知(推送) - 透传推送消息  */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        return;
    }
    
    // [ GTSdk ]：将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:userInfo];
    
    // 控制台打印接收APNs信息
    SSJPRINT(@"\n>>>[Receive RemoteNotification]:%@\n\n", userInfo);
    
    completionHandler(UIBackgroundFetchResultNewData);
    
    [[SSJGeTuiManager shareManager] pushToViewControllerWithUserInfo:userInfo];
    
}

//- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
//    
//}

#pragma mark - iOS 10中收到推送消息

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
//  iOS 10: App在前台获取到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    SSJPRINT(@"willPresentNotification：%@", notification.request.content.userInfo);
    
    // 根据APP需要，判断是否要提示用户Badge、Sound、Alert
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

//  iOS 10: 点击通知进入App时触发
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    SSJPRINT(@"didReceiveNotification：%@", response.notification.request.content.userInfo);
    
    // [ GTSdk ]：将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:response.notification.request.content.userInfo];
    
    completionHandler();
}
#endif

@end
