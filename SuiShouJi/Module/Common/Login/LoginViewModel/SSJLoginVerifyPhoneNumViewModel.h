//
//  SSJLoginVerifyPhoneNumViewModel.h
//  SuiShouJi
//
//  Created by yi cai on 2017/6/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SSJBaseNetworkService;
@class SSJThirdPartLoginItem;

@interface SSJLoginVerifyPhoneNumViewModel : NSObject

/**
 请求验证手机号命令
 */
@property (nonatomic, strong) RACCommand *verifyPhoneNumRequestCommand;

/**微信登录命令*/
@property (nonatomic, strong) RACCommand *wxLoginCommand;

/**qq登录命令*/
@property (nonatomic, strong) RACCommand *qqLoginCommand;

/**是否允许点击验证手机号下一步信号*/
@property (nonatomic, strong) RACSignal *enableVerifySignal;

/**同意协议*/
@property (nonatomic, assign, getter=isAgreeProtocol) BOOL agreeProtocol;

/**手机号*/
@property (nonatomic, copy) NSString *phoneNum;

/**第三方登录model*/
@property (nonatomic, strong) SSJThirdPartLoginItem *thirdPartLoginItem;
@end
