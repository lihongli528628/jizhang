//
//  SSJLoginVerifyPhoneNumViewModel.m
//  SuiShouJi
//
//  Created by yi cai on 2017/6/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLoginVerifyPhoneNumViewModel.h"

#import "SSJThirdPartLoginItem.h"
#import "SSJUserItem.h"
#import "SSJBookkeepingTreeCheckInModel.h"
#import "SSJCustomCategoryItem.h"

#import "SSJStringAddition.h"
#import "SSJWeiXinLoginHelper.h"
#import "SSJLoginHelper.h"
#import "SSJBookkeepingTreeHelper.h"
#import "SSJLocalNotificationHelper.h"

#import "SSJUserTableManager.h"
#import "SSJUserDefaultDataCreater.h"
#import <GTSDK/GeTuiSdk.h>
#import "SSJDatabaseQueue.h"
#import "SSJBookkeepingTreeStore.h"
#import "SSJDataSynchronizer.h"
#import "SSJThirdPartyLoginManger.h"

#import "SSJHomeLoadingView.h"

#import "SSJNavigationController.h"
#import "SSJFingerprintPWDViewController.h"
#import "SSJMotionPasswordViewController.h"
#import "MMDrawerController.h"
#import "UIViewController+SSJPageFlow.h"

#import <LocalAuthentication/LocalAuthentication.h>
#import <AdSupport/ASIdentifierManager.h>
#import "SimulateIDFA.h"

@interface SSJLoginVerifyPhoneNumViewModel ()

//  登录方式
@property (assign, nonatomic) SSJLoginType loginType;

//登录用户的appid
@property (nonatomic,strong) NSString *appid;

@property (nonatomic,strong) SSJUserItem *userItem;

@property (nonatomic, strong) SSJBookkeepingTreeCheckInModel *checkInModel;

/**openId*/
@property (nonatomic, copy) NSString *openId;

@property(nonatomic, strong) SSJHomeLoadingView *loadingView;


@end

@implementation SSJLoginVerifyPhoneNumViewModel
- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

#pragma mark - Private

/**
 验证手机号请求

 @param phoneNum 手机号
 @param subscriber 订阅者
 */
- (void)verityPhoneNumWithPhone:(NSString *)phoneNum subscriber:(id<RACSubscriber>) subscriber {
    self.netWorkService.showLodingIndicator = YES;
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:phoneNum forKey:@"cmobileNo"];
    [self.netWorkService request:@"/chargebook/user/check_cphoneExist.go" params:paramDic success:^(SSJBaseNetworkService * _Nonnull service) {
        if ([service.returnCode isEqualToString:@"0"]
            || [service.returnCode isEqualToString:@"1"]) {
            [subscriber sendNext:service.rootElement];
            [subscriber sendCompleted];
        } else {
            NSError *error = [NSError errorWithDomain:SSJErrorDomain code:[service.returnCode integerValue] userInfo:@{NSLocalizedDescriptionKey:service.desc}];
            [subscriber sendError:error];
        }
    } failure:^(SSJBaseNetworkService * _Nonnull service) {
        [subscriber sendError:service.error];
    }];
}

/**
 第三方登录
 */
- (void)thirdLoginWithLoginItem:(SSJThirdPartLoginItem *)item subscriber:(id<RACSubscriber>) subscriber {
    self.netWorkService.showLodingIndicator = YES;
    NSString *strAcctID = @"130313003";
    NSString *strSignType = @"1";
    NSString *strKey = @"iwannapie?!";
    NSString *type = @"";
    self.openId = item.openID;
    if (item.loginType == SSJLoginTypeQQ) {
        type = @"qq";
    }else if (item.loginType == SSJLoginTypeWeiXin){
        type = @"wechat";
    }
    NSString *strSign=[NSString stringWithFormat:@"signType=%@&merchantacctId=%@&auth_token=%@&key=%@",strSignType,strAcctID,item.openID,strKey];
    NSString *strmd5Sign=[[strSign ssj_md5HexDigest]uppercaseString];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    //imei
    NSString *imei = [UIDevice currentDevice].identifierForVendor.UUIDString;
    
    //手机型号
    NSString* phoneModel = SSJPhoneModel();
    
    //手机系统版本
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    
    //个推id
    NSString *getuiId = [GeTuiSdk clientId];
    
    [dict setObject:strAcctID forKey:@"merchantacctId"];
    [dict setObject:strSignType forKey:@"signType"];
    [dict setObject:strmd5Sign forKey:@"signMsg"];
    [dict setObject:SSJUSERID() forKey:@"cuserid"];
    [dict setObject:item.openID forKey:@"auth_token"];
    [dict setObject:item.portraitURL forKey:@"cicon"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:[item.nickName ssj_emojiFilter] forKey:@"crealname"];
    [dict setObject:imei forKey:@"cimei"];
    [dict setObject:phoneModel forKey:@"cmodel"];
    [dict setObject:phoneVersion forKey:@"cphoneos"];
    [dict setObject:item.userGender forKey:@"cgender"];
    [dict setObject:item.unionId forKey:@"cunionid"];
    [dict setObject:getuiId ?: @"" forKey:@"cgetuiid"];
    [self.netWorkService request:SSJURLWithAPI(@"/oauth/oauthlogin.go") params:dict success:^(SSJBaseNetworkService * _Nonnull service) {
        if ([service.returnCode isEqualToString:@"1"]) {
            [subscriber sendNext:service.rootElement];
            [subscriber sendCompleted];
        }else {
            [subscriber sendError:[NSError errorWithDomain:SSJErrorDomain code:[service.returnCode integerValue] userInfo:@{NSLocalizedDescriptionKey:service.desc}]];
        }
    } failure:^(SSJBaseNetworkService * _Nonnull service) {
        [subscriber sendError:service.error];
    }];
}

- (void)loginNormalWithPassWord:(NSString*)password AndUserAccount:(NSString*)useraccount subscriber:(id<RACSubscriber>) subscriber {
    if (!password.length) return;
    if (!useraccount.length) return;
    self.loginType = SSJLoginTypeNormal;
    self.netWorkService.showLodingIndicator = YES;
    self.openId = @"";
    NSString *strAcctID=@"130313003";
    NSString *strSignType=@"1";
    NSString *strKey=@"A9FK25RHT487ULMI";
    
    //imei
    NSString *imei = nil;
    if ([ASIdentifierManager sharedManager].advertisingTrackingEnabled) {
        imei = [NSString stringWithFormat:@"%@",[ASIdentifierManager sharedManager].advertisingIdentifier];
    } else {
        imei = [SimulateIDFA createSimulateIDFA];
    }
//    NSString *imei = [UIDevice currentDevice].identifierForVendor.UUIDString;
    
    //手机型号
    NSString *phoneModel = SSJPhoneModel();
    
    //个推id
    NSString *getuiId = [GeTuiSdk clientId];
    
    //手机系统版本
    NSString *phoneVersion = [[UIDevice currentDevice] systemVersion];
    
    NSString *encryptPassword = [password stringByAppendingString:SSJLoginPWDEncryptionKey];
    encryptPassword = [[encryptPassword ssj_md5HexDigest] lowercaseString];
    
    NSString *strSign=[NSString stringWithFormat:@"signType=%@&merchantacctId=%@&mobileNo=%@&pwd=%@&key=%@",strSignType,strAcctID,useraccount,encryptPassword,strKey];
    
    NSString *strmd5Sign=[[strSign ssj_md5HexDigest]uppercaseString];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:useraccount forKey:@"mobileNo"];
    [dict setObject:strAcctID forKey:@"merchantacctId"];
    [dict setObject:strSignType forKey:@"signType"];
    [dict setObject:encryptPassword forKey:@"pwd"];
    [dict setObject:strmd5Sign forKey:@"signMsg"];
    [dict setObject:SSJUSERID() forKey:@"cuserid"];
    [dict setObject:imei forKey:@"cimei"];
    [dict setObject:phoneModel forKey:@"cmodel"];
    [dict setObject:phoneVersion forKey:@"cphoneos"];
    [dict setObject:getuiId ?: @"" forKey:@"cgetuiid"];

    [self.netWorkService request:SSJURLWithAPI(@"/user/login.go") params:dict success:^(SSJBaseNetworkService * _Nonnull service) {
        if ([service.returnCode isEqualToString:@"1"]) {
            [subscriber sendNext:service.rootElement];
            [subscriber sendCompleted];
        } else {
            [subscriber sendError:[NSError errorWithDomain:SSJErrorDomain code:[service.returnCode integerValue] userInfo:@{NSLocalizedDescriptionKey:service.desc}]];
        }
    } failure:^(SSJBaseNetworkService * _Nonnull service) {
        [subscriber sendError:service.error];
    }];
}

// 登录成功后保存当前账本类型：共享or个人
- (void )queryCurrentCategoryForUserId:(NSString *)userId {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSString *currentBookId = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userId];
        BOOL iShareBook = [db boolForQuery:@"select count(*) from bk_books_type where cbooksid = ? and operatortype <> 2 and cuserid = ?",currentBookId,userId];
        if (iShareBook) {//是个人账本
            SSJSaveBooksCategory(SSJBooksCategoryPersional);
        } else { //共享账本
            SSJSaveBooksCategory(SSJBooksCategoryPublic);
        }
    }] ;
}


/**
 获取验证码

 @param type 注册or忘记密码
 @param channelType 短信or语音
 @param subscriber <#subscriber description#>
 */
- (void)verCode:(SSJRegistAndForgetPasswordType)type channelType:(SSJLoginAndRegisterPasswordChannelType)channelType subscriber:(id<RACSubscriber>) subscriber {
    self.netWorkService.showLodingIndicator = YES;
    //                (mobileNo+timeStamp+key) MD5加密
    //发送验证码请求
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    u_long time = [[NSDate date] timeIntervalSince1970];
    NSString *strKey = @"iwannapie?!";
    NSString *strSign = [NSString stringWithFormat:@"%@%@%@",self.phoneNum,@(time),strKey];
    strSign = [[strSign ssj_md5HexDigest] uppercaseString];
    
    [param setObject:(type==SSJRegistAndForgetPasswordTypeForgetPassword)?@"14":@"13" forKey:@"yzmType"];//验证码业务类型，13注册 14找回密码
//
    [param setObject:[NSString stringWithFormat:@"%@",self.phoneNum] forKey:@"cmobileNo"];
    [param setObject:(channelType == SSJLoginAndRegisterPasswordChannelTypeSMS) ? @"0" : @"1" forKey:@"channelType"];//验证码类型： 0短信 1语音 , 默认为0；
    
    [param setObject:@(time) forKey:@"timeStamp"];
    [param setObject:strSign forKey:@"signMsg"];
    [param setObject:self.graphNum?:@"" forKey:@"imgYzm"];
    [self.netWorkService request:@"/chargebook/user/send_sms.go" params:param success:^(SSJBaseNetworkService * _Nonnull service) {
        [subscriber sendNext:service.rootElement];
        [subscriber sendCompleted];
    } failure:^(SSJBaseNetworkService * _Nonnull service) {
        [subscriber sendError:service.error];
    }];
}

/**
 重新获取图形验证码
 */
- (void)reVerCodeWithSubscriber:(id<RACSubscriber>) subscriber {
    self.netWorkService.showLodingIndicator = YES;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:self.phoneNum forKey:@"cmobileNo"];
    [self.netWorkService request:@"/chargebook/user/get_imgYzm.go" params:param success:^(SSJBaseNetworkService * _Nonnull service) {
        if ([service.returnCode isEqualToString:@"1"]) {
            [subscriber sendNext:service.rootElement];
            [subscriber sendCompleted];
        } else {
            [subscriber sendError:[NSError errorWithDomain:SSJErrorDomain code:[service.returnCode integerValue] userInfo:@{NSLocalizedDescriptionKey:service.desc}]];
        }
    } failure:^(SSJBaseNetworkService * _Nonnull service) {
        [subscriber sendError:service.error];
    }];
}


/**
 注册

 @param password <#password description#>
 @param useraccount <#useraccount description#>
 @param subscriber <#subscriber description#>
 */
- (RACSignal *)registerWithPassWord:(NSString*)password AndUserAccount:(NSString*)useraccount {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        self.netWorkService.showLodingIndicator = YES;
        self.openId = @"";
        //imei
        NSString *imei = [UIDevice currentDevice].identifierForVendor.UUIDString;
        
        //手机型号
        NSString *phoneModel = SSJPhoneModel();
        
        //个推id
        NSString *getuiId = [GeTuiSdk clientId];
        
        //手机系统版本
        NSString *phoneVersion = [[UIDevice currentDevice] systemVersion];
        
        NSString *encryptPassword = [password stringByAppendingString:SSJLoginPWDEncryptionKey];
        encryptPassword = [[encryptPassword ssj_md5HexDigest] lowercaseString];
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        [dict setObject:useraccount forKey:@"cmobileno"];
        [dict setObject:self.verificationCode forKey:@"yzm"];
        [dict setObject:encryptPassword forKey:@"pwd"];
        [dict setObject:phoneModel forKey:@"cmodel"];
        [dict setObject:phoneVersion forKey:@"cphoneos"];
        [dict setObject:phoneModel forKey:@"cphonebrand"];
        [dict setObject:imei forKey:@"cimei"];
        [dict setObject:getuiId ?: @"" forKey:@"cgetuiid"];
        [self.netWorkService request:SSJURLWithAPI(@"/chargebook/user/mobile_register.go") params:dict success:^(SSJBaseNetworkService * _Nonnull service) {
            if ([service.returnCode isEqualToString:@"1"]) {
                [subscriber sendNext:service.rootElement];
                [subscriber sendCompleted];
            }else {
                [subscriber sendError:[NSError errorWithDomain:SSJErrorDomain code:[service.returnCode integerValue] userInfo:@{NSLocalizedDescriptionKey:service.desc}]];
            }
        } failure:^(SSJBaseNetworkService * _Nonnull service) {
            [subscriber sendError:service.error];
        }];
        return nil;
    }];
}


/**
 忘记密码

 @param password <#password description#>
 @param useraccount <#useraccount description#>
 @param subscriber <#subscriber description#>
 */
- (RACSignal *)forgetWithPassWord:(NSString*)password AndUserAccount:(NSString*)mobileNo authCode:(NSString *)authCode {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        self.netWorkService.showLodingIndicator = YES;
        NSString *encryptPassword = [password stringByAppendingString:SSJLoginPWDEncryptionKey];
        encryptPassword = [[encryptPassword ssj_md5HexDigest] lowercaseString];
        [self.netWorkService request:@"/chargebook/user/forget_pwd.go" params:@{@"cmobileNo":mobileNo ?: @"",@"yzm":authCode ?: @"",@"newPwd":encryptPassword ?: @""} success:^(SSJBaseNetworkService * _Nonnull service) {
            if ([service.returnCode isEqualToString:@"1"]) {
                [subscriber sendNext:service.rootElement];
                [subscriber sendCompleted];
            }else {
                [subscriber sendError:[NSError errorWithDomain:SSJErrorDomain code:[service.returnCode integerValue] userInfo:@{NSLocalizedDescriptionKey:service.desc}]];
            }
        } failure:^(SSJBaseNetworkService * _Nonnull service) {
            [subscriber sendError:service.error];
        }];
        return nil;
    }];
}

- (void)datawithDic:(NSDictionary *)dict {
    NSDictionary *result = [dict objectForKey:@"results"];
    self.accesstoken = [result objectForKey:@"accessToken"];
    [SSJUserItem mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"userId":@"cuserid",
                 @"nickName":@"crealname",  // 第三方登录时，服务器返回的crealname就是用户昵称
                 @"mobileNo":@"cmobileno",
                 @"icon":@"cicon",
                 @"openid":@"oauthid"};
    }];
    _userItem = [SSJUserItem mj_objectWithKeyValues:result[@"user"]];
    self.userItem.loginType = [NSString stringWithFormat:@"%d", (int)self.loginType];
    self.userItem.openId = self.openId;
    
    self.bookBillsArray = [result objectForKey:@"bookBills"];
    self.userBillTypeArray = [result objectForKey:@"userBillType"];
    self.fundInfoArray = [result objectForKey:@"fundInfo"];
    self.booksTypeArray = [result objectForKey:@"bookType"];
    self.membersArray = [result objectForKey:@"bk_member"];
    
    NSArray *billType = [result objectForKey:@"billType"];
    NSMutableDictionary *tmpBillTypeInfo = [NSMutableDictionary dictionaryWithCapacity:billType.count];
    for (NSDictionary *record in billType) {
        tmpBillTypeInfo[record[@"id"]] = record;
    }
    self.billTypeInfo = tmpBillTypeInfo;
    
    NSArray *userBill = [result objectForKey:@"userBill"];
    NSMutableDictionary *tmpUserBillInfo = [NSMutableDictionary dictionaryWithCapacity:userBill.count];
    for (NSDictionary *record in userBill) {
        tmpUserBillInfo[[NSString stringWithFormat:@"%@_%@", record[@"cbillid"], record[@"cbooksid"]]] = record;
    }
    self.userBillInfo = tmpUserBillInfo;
    
    self.checkInModel = [SSJBookkeepingTreeCheckInModel mj_objectWithKeyValues:[result objectForKey:@"userTree"]];
    self.customCategoryArray = [SSJCustomCategoryItem mj_objectArrayWithKeyValuesArray:[result objectForKey:@"bookBillArray"]];
}

- (void)showConfirmToLoginAlertView:(void(^)(BOOL confirm))completion {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:SSJLastLoggedUserItemKey]) {
        completion(YES);
        return;
    }
    
    NSData *lastUserData = [[NSUserDefaults standardUserDefaults] objectForKey:SSJLastLoggedUserItemKey];
    SSJUserItem *lastUserItem = [NSKeyedUnarchiver unarchiveObjectWithData:lastUserData];
    BOOL isSameUser = ([self.userItem.mobileNo isEqualToString:lastUserItem.mobileNo] && lastUserItem.mobileNo.length) || ([self.userItem.openId isEqualToString:lastUserItem.openId] && lastUserItem.openId.length);
    if (isSameUser) {
        completion(YES);
        return;
    }
    
    NSString *userName;
    SSJLoginType loginType = [lastUserItem.loginType intValue];
    if (loginType == SSJLoginTypeNormal) {
        userName = [lastUserItem.mobileNo stringByReplacingCharactersInRange:NSMakeRange(4, 4) withString:@"****"];
    }else{
        userName = lastUserItem.nickName;
    }
    
    NSString *message = nil;
    switch (loginType) {
        case SSJLoginTypeNormal:
            message = [NSString stringWithFormat:@"您已使用过手机号%@登陆过,确定使用新账户登录",userName];
            break;
            
        case SSJLoginTypeQQ:
            message = [NSString stringWithFormat:@"您已使用过QQ:%@登陆过,确定使用新账户登录",userName];
            break;
            
        case SSJLoginTypeWeiXin:
            message = [NSString stringWithFormat:@"您已使用过微信:%@登陆过,确定使用新账户登录",userName];
            break;
    }
    
    [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:message action:[SSJAlertViewAction actionWithTitle:@"取消" handler:^(SSJAlertViewAction * _Nonnull action) {
        completion(NO);
    }], [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
        completion(YES);
    }], nil];
}

-(void)comfirmTologinWithSuccess:(void(^)())success failure:(void(^)(NSError *error))failure {
    //  只要登录就设置用户为已注册，因为9188账户、第三方登录没有注册就可以登录
    self.userItem.registerState = @"1";
    
    if (!self.userItem.currentBooksId) {
        self.userItem.currentBooksId = self.userItem.userId;
    }
    
    // 保存用户信息
    [[[[[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJUserTableManager saveUserItem:self.userItem success:^{
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }] then:^RACSignal *{
        // 保存用户登录信息
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            if (SSJSaveAppId(self.appid)
                && SSJSaveAccessToken(self.accesstoken)
                && SSJSetUserId(self.userItem.userId)
                && SSJSaveUserLogined(YES)) {
                //                //保存账本类型个人or共享
                //                [self queryCurrentCategoryForUserId:self.userItem.userId];
                [subscriber sendCompleted];
                
            } else {
                [subscriber sendError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"存储用户登录信息失败"}]];
            }
            return nil;
        }];
    }] then:^RACSignal *{
        // 合并用户数据，即使合并失败，之后还会进行同步，所以无论成功与否都正常走接下来的流程
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [SSJLoginHelper updateTableWhenLoginWithViewModel:self completion:^{
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }] then:^RACSignal *{
        // 检测用户的默认数据，哪些没有就创建哪些
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [SSJUserDefaultDataCreater asyncCreateAllDefaultDataWithUserId:SSJUSERID() success:^{
                [subscriber sendCompleted];
            } failure:^(NSError *error) {
                [subscriber sendError:error];
            }];
            return nil;
        }];
    }] then:^RACSignal *{
        // 更新用户签到数据
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() success:^(SSJBookkeepingTreeCheckInModel * _Nonnull checkInModel) {
                if (![checkInModel.lastCheckInDate isEqualToString:self.checkInModel.lastCheckInDate]) {
                    [SSJBookkeepingTreeStore saveCheckInModel:self.checkInModel success:NULL failure:NULL];
                    [SSJBookkeepingTreeHelper loadTreeImageWithUrlPath:self.checkInModel.treeImgUrl finish:NULL];
                    [SSJBookkeepingTreeHelper loadTreeGifImageDataWithUrlPath:self.checkInModel.treeGifUrl finish:NULL];
                }
                [subscriber sendCompleted];
            } failure:^(NSError * _Nonnull error) {
                [subscriber sendError:error];
            }];
            return nil;
        }];
    }] then:^RACSignal *{
        // 登录成功，做些额外的处理
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            //            [self.loadingView show];
            [self syncData];
            [self.loadingView show];
            [SSJAnaliyticsManager setUserId:SSJUSERID() userName:(self.userItem.nickName.length ? self.userItem.nickName : self.userItem.mobileNo)];
            [[NSNotificationCenter defaultCenter] postNotificationName:SSJLoginOrRegisterNotification object:nil];
            [SSJLocalNotificationHelper cancelLocalNotificationWithKey:SSJReminderNotificationKey];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SSJHaveLoginOrRegistKey];
            [[NSUserDefaults standardUserDefaults] setInteger:self.loginType forKey:SSJUserLoginTypeKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //保存账本类型个人or共享
            [self queryCurrentCategoryForUserId:self.userItem.userId];
            [subscriber sendCompleted];
            return nil;
        }];
    }] subscribeError:^(NSError *error) {
        failure(error);
    } completed:^{
        success();
    }];
}

- (RACSignal *)handleRegisterResult:(NSDictionary *)result {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        NSDictionary *resultInfo = [result objectForKey:@"results"];
        if (resultInfo) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SSJHaveLoginOrRegistKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            SSJUserItem *userItem = [[SSJUserItem alloc] init];
            userItem.userId = SSJUSERID();
            userItem.mobileNo = self.phoneNum;
            userItem.registerState = @"1";
            userItem.loginType = @"0";
            
            [SSJUserTableManager saveUserItem:userItem success:^{
                if (SSJSaveAppId(resultInfo[@"appId"] ?: @"")
                    && SSJSaveAccessToken(resultInfo[@"accessToken"] ?: @"")
                    && SSJSaveUserLogined(YES)) {
                    [self syncData];
                    [[NSNotificationCenter defaultCenter] postNotificationName:SSJLoginOrRegisterNotification object:self];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"保存appid／token／登录状态失败"}]];
                }
            } failure:^(NSError * _Nonnull error) {
                [subscriber sendError:error];
            }];
        } else {
            [subscriber sendCompleted];
        }
        return nil;
    }];
}


- (void)syncData {
    [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:^(SSJDataSynchronizeType type){
        [CDAutoHideMessageHUD showMessage:@"同步成功"];
    } failure:^(SSJDataSynchronizeType type, NSError *error) {
        [CDAutoHideMessageHUD showMessage:@"同步失败"];
    }];
}

#pragma mark - Lazy
- (SSJBaseNetworkService *)netWorkService {
    if (!_netWorkService) {
        _netWorkService = [[SSJBaseNetworkService alloc] init];
        _netWorkService.httpMethod = SSJBaseNetworkServiceHttpMethodPOST;
        _netWorkService.showLodingIndicator = YES;
    }
    return _netWorkService;
}

- (RACCommand *)verifyPhoneNumRequestCommand {
    if (!_verifyPhoneNumRequestCommand) {
        _verifyPhoneNumRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @weakify(self);
            RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                //判断手机号格式
                if (![self.phoneNum ssj_validPhoneNum]) {
                    [subscriber sendError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeMobileNoIllegal userInfo:@{NSLocalizedDescriptionKey:@"请输入正确的手机号"}]];
                } else {
                    [self verityPhoneNumWithPhone:self.phoneNum subscriber:subscriber];
                }
                return nil;
            }];
            //返回的数据处理json->model
            //1 密码登录(已注册)，80 验证码注册（未注册）
            return [signal map:^id(NSDictionary *result) {
                return @([[result objectForKey:@"code"] boolValue]);
            }];
        }];
    }
    return _verifyPhoneNumRequestCommand;
}

- (RACSignal *)enableVerifySignal {
    if (!_enableVerifySignal) {
        //手机号位数，是否同意用户协议
        _enableVerifySignal = [RACSignal combineLatest:@[RACObserve(self, phoneNum),RACObserve(self, agreeProtocol)] reduce:^id(NSString *phoneNum,NSNumber *isAgree){
            return @(phoneNum.length >= SSJMobileNoLength && isAgree.boolValue);
        }];
    }
    return _enableVerifySignal;
}

- (RACSignal *)enableRegAndLoginSignal {
    if (!_enableRegAndLoginSignal) {
        _enableRegAndLoginSignal = [RACSignal combineLatest:@[RACObserve(self, verificationCode),RACObserve(self, passwardNum)] reduce:^id(NSString *code,NSString *passward){
            return @(code.length >= SSJAuthCodeLength && passward.length >= SSJMinPasswordLength);
        }];
    }
    return _enableRegAndLoginSignal;
}

- (RACSignal *)enableNormalLoginSignal {
    if (!_enableNormalLoginSignal) {
        _enableNormalLoginSignal = [[RACSignal combineLatest:@[RACObserve(self,passwardNum)] reduce:^id(NSString *passward){
            return @(passward.length >= SSJMinPasswordLength && passward.length <= SSJMaxPasswordLength);
        }] skip:1];
    }
    return _enableNormalLoginSignal;
}

/**
 获取验证码

 @return <#return value description#>
 */
- (RACCommand *)getVerificationCodeCommand {
    if (!_getVerificationCodeCommand) {
        _getVerificationCodeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @weakify(self);
            RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self verCode:self.regOrForType channelType:SSJLoginAndRegisterPasswordChannelTypeSMS subscriber:subscriber];
                return nil;
            }];
            return [signal map:^id(NSDictionary *value) {
                return value;
            }];
        }];
    }
    return _getVerificationCodeCommand;
}

/**
 重新获取图形验证码页面

 @return <#return value description#>
 */
- (RACCommand *)reGetVerificationCodeCommand {
    if (!_reGetVerificationCodeCommand) {
        _reGetVerificationCodeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @weakify(self);
            RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self reVerCodeWithSubscriber:subscriber];
                return nil;
            }];
            return [signal map:^id(NSDictionary *value) {
                    return [[[value objectForKey:@"results"] objectForKey:@"image"] base64ToImage];
            }];
        }];
    }
    return _reGetVerificationCodeCommand;
}

- (RACCommand *)forgetPwdCommand {
    if (!_forgetPwdCommand) {
        @weakify(self);
        _forgetPwdCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                //登录
                self.loginType = SSJLoginTypeNormal;
                //验证密码格式
                if ([self.passwardNum ssj_validPassWard]) {
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeLoginPasswordIllegal userInfo:@{NSLocalizedDescriptionKey:@"请输入6~15位数字、字母组合密码"}]];
                }
                return nil;
            }] then:^RACSignal *{
                return [self forgetWithPassWord:self.passwardNum AndUserAccount:self.phoneNum authCode:self.verificationCode];
            }] then:^RACSignal *{
                return [self normalLoginSignal];
            }];
        }];
    }
    return _forgetPwdCommand;
}

- (RACCommand *)registerCommand {
    if (!_registerCommand) {
        @weakify(self);
        _registerCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                //登录
                self.loginType = SSJLoginTypeNormal;
                //验证密码格式
                if (![self.passwardNum ssj_validPassWard]) {
                    [subscriber sendError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeLoginPasswordIllegal userInfo:@{NSLocalizedDescriptionKey:@"请输入6~15位数字、字母组合密码"}]];
                } else {
                    [subscriber sendCompleted];
                }
                return nil;
            }] then:^RACSignal *{
                return [self registerWithPassWord:self.passwardNum AndUserAccount:self.phoneNum];
            }] flattenMap:^RACStream *(NSDictionary *result) {
                return [self handleRegisterResult:result];
            }];
        }];
    }
    return _registerCommand;
}

- (RACCommand *)wxLoginCommand {
    if (!_wxLoginCommand) {
        _wxLoginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @weakify(self);
            return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                //发送微信登录请求
                [[SSJThirdPartyLoginManger shareInstance].weixinLogin weixinLoginWithSucessBlock:^(SSJThirdPartLoginItem *item) {
                    [SSJThirdPartyLoginManger shareInstance].qqLogin = nil;
                    [SSJThirdPartyLoginManger shareInstance].weixinLogin = nil;
                    self.loginType = SSJLoginTypeWeiXin;
                    [self thirdLoginWithLoginItem:item subscriber:subscriber];
                } failBlock:^(NSError *error){
                    [subscriber sendError:error];
                }];
                return nil;
            }] flattenMap:^RACStream *(NSDictionary *result) {
                return [self handleLoginResult:result];
            }];
        }];
    }
    return _wxLoginCommand;
}

- (RACCommand *)qqLoginCommand {
    if (!_qqLoginCommand) {
        _qqLoginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @weakify(self);
            RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                //发送qq登录请求
                [[SSJThirdPartyLoginManger shareInstance].qqLogin qqLoginWithSucessBlock:^(SSJThirdPartLoginItem *item) {
                    [SSJThirdPartyLoginManger shareInstance].qqLogin = nil;
                    [SSJThirdPartyLoginManger shareInstance].weixinLogin = nil;
                    self.loginType = SSJLoginTypeQQ;
                    [self thirdLoginWithLoginItem:item subscriber:subscriber];
                } failBlock:^(NSError *error){
                    [subscriber sendError:error];
                }];
                return nil;
            }] flattenMap:^RACStream *(NSDictionary *result) {
                return [self handleLoginResult:result];
            }];
            return signal;
        }];
    }
    return _qqLoginCommand;
}

- (RACCommand *)normalLoginCommand {
    if (!_normalLoginCommand) {
        _normalLoginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [self normalLoginSignal];
        }];
    }
    return _normalLoginCommand;
}

- (RACSignal *)normalLoginSignal {
    @weakify(self);
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [self loginNormalWithPassWord:self.passwardNum AndUserAccount:self.phoneNum subscriber:subscriber];
        return nil;
    }] flattenMap:^RACStream *(NSDictionary *result) {
        return [self handleLoginResult:result];
    }];
}

- (RACSignal *)handleLoginResult:(NSDictionary *)result {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self datawithDic:result];
        [self showConfirmToLoginAlertView:^(BOOL confirm) {
            if (confirm) {
                [self comfirmTologinWithSuccess:^{
                    [subscriber sendCompleted];
                } failure:^(NSError *error) {
                    [subscriber sendError:error];
                }];
            } else {
                [subscriber sendError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeLoginCanceled userInfo:@{NSLocalizedDescriptionKey:@"用户取消登录"}]];
            }
        }];
        return nil;
    }];
}


- (SSJHomeLoadingView *)loadingView{
    if (!_loadingView) {
        _loadingView = [[SSJHomeLoadingView alloc] init];
    }
    return _loadingView;
}

@end
