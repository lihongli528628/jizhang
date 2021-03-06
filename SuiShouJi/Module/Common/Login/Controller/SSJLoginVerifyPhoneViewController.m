//
//  SSJLoginVerifyPhoneViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/6/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLoginVerifyPhoneViewController.h"
#import "SSJNormalWebViewController.h"
#import "SSRegisterAndLoginViewController.h"
#import "SSJLoginPhoneViewController.h"
#import "SSJMotionPasswordViewController.h"
#import "SSJBindMobileNoViewController.h"
#import "UIViewController+SSJPageFlow.h"

#import "SSJLoginVerifyPhoneNumViewModel.h"

#import "SSJUserTableManager.h"
#import "SSJDatabaseQueue.h"

#import "WXApi.h"



@interface SSJLoginVerifyPhoneViewController ()<UITextFieldDelegate>


/**手机号输入框*/
@property (nonatomic, strong) UITextField *numTextF;

@property (nonatomic, strong) UILabel *phonePreL;

@property (nonatomic, strong) UIButton *verifyPhoneBtn;

@property (nonatomic, strong) UIButton *agreeButton;

@property (nonatomic, strong) UIButton *protocolButton;

@property (nonatomic,strong)UIButton *tencentLoginButton;

@property (nonatomic,strong)UIButton *weixinLoginButton;

@property (nonatomic, strong) SSJLoginVerifyPhoneNumViewModel *verifyPhoneViewModel;
@end

@implementation SSJLoginVerifyPhoneViewController

#pragma mark - System

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialUI];
    [self updateViewConstraint];
    [self initData];
    [self initialBind];
}

- (void)initData {
    NSData *lastUserData = [[NSUserDefaults standardUserDefaults] objectForKey:SSJLastLoggedUserItemKey];
    SSJUserItem *lastUserItem = [NSKeyedUnarchiver unarchiveObjectWithData:lastUserData];
    NSString *userName = lastUserItem.mobileNo;
    self.numTextF.text = userName;
    self.titleL.text = @"登录  |  注册";
}

- (void)dealloc {
    [self.verifyPhoneViewModel.netWorkService cancel];
}

- (void)goBackAction {
    [super goBackAction];
    if (self.cancelHandle) {
        self.cancelHandle(self);
    }
}

#pragma mark - Layout
- (void)updateViewConstraint {
    [self.phonePreL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom).offset(50);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(self.scrollView.mas_left).offset(20);
        make.width.mas_equalTo(50);
    }];
    
    [self.numTextF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.phonePreL.mas_right);
        make.top.height.mas_equalTo(self.phonePreL);
        make.right.mas_equalTo(self.view).offset(-20);
    }];
    
    [self.verifyPhoneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.mas_equalTo(self.phonePreL);
        make.top.mas_equalTo(self.numTextF.mas_bottom).offset(44);
        make.right.mas_equalTo(self.numTextF);
    }];
    
    [self.agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.phonePreL);
        make.width.height.mas_equalTo(10);
        make.top.mas_equalTo(self.verifyPhoneBtn.mas_bottom).offset(20);
    }];
    
    [self.protocolButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.agreeButton.mas_right).offset(10);
        make.width.greaterThanOrEqualTo(0);
        make.height.top.mas_equalTo(self.agreeButton);
    }];
    
    if (([SSJDefaultSource() isEqualToString:@"11501"]
        || [SSJDefaultSource() isEqualToString:@"11502"]
        || [SSJDefaultSource() isEqualToString:@"11512"]
        || [SSJDefaultSource() isEqualToString:@"11513"]) && [WXApi isWXAppInstalled]) {
        [self.weixinLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(SSJSCREENHEIGHT - 85);
            make.size.mas_equalTo(CGSizeMake(50, 50));
            make.right.mas_equalTo(self.scrollView.mas_centerX).offset(-10);
        }];
        
        [self.tencentLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.top.mas_equalTo(self.weixinLoginButton);
            make.left.mas_equalTo(self.scrollView.mas_centerX).offset(10);
        }];
    } else {
        [self.tencentLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(SSJSCREENHEIGHT - 85);
            make.size.mas_equalTo(CGSizeMake(50, 50));
            make.centerX.mas_equalTo(self.scrollView.mas_centerX);
        }];
    }
    [super updateViewConstraints];
}

#pragma mark - Private
- (void)initialUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.topView];
    [self.topView addSubview:self.titleL];
    [self.scrollView addSubview:self.numTextF];
    [self.scrollView addSubview:self.phonePreL];
    [self.scrollView addSubview:self.verifyPhoneBtn];
    [self.scrollView addSubview:self.agreeButton];
    [self.scrollView addSubview:self.protocolButton];
    [self.scrollView addSubview:self.tencentLoginButton];
//    [self.scrollView addSubview:self.weixinLoginButton];
    // 只有9188、有鱼并且没有审核的情况下，显示第三方登录
    if (([SSJDefaultSource() isEqualToString:@"11501"]
        || [SSJDefaultSource() isEqualToString:@"11502"]
        || [SSJDefaultSource() isEqualToString:@"11512"]
        || [SSJDefaultSource() isEqualToString:@"11513"]) && [WXApi isWXAppInstalled]) {
            [self.scrollView addSubview:self.weixinLoginButton];
    }
    
    [self updateViewConstraints];
}

/**
 信号绑定
 */
- (void)initialBind {
    RAC(self.verifyPhoneViewModel,phoneNum) = self.numTextF.rac_textSignal;
    RAC(self.verifyPhoneViewModel, agreeProtocol) = RACObserve(self.agreeButton,selected);
}

- (void)setMobileNo:(NSString *)mobileNo {
    _mobileNo = mobileNo;
    if (mobileNo.length) {
        self.numTextF.text = mobileNo;
    }
}

- (void)handleThirdPartLoginPageFlow {
    [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
        if ([userItem.motionPWDState boolValue] && !userItem.motionPWD.length) {
            SSJMotionPasswordViewController *motionVC = [[SSJMotionPasswordViewController alloc] init];
            motionVC.type = SSJMotionPasswordViewControllerTypeSetting;
            motionVC.finishHandle = self.finishHandle;
            motionVC.isLoginFlow = YES;
            [self.navigationController pushViewController:motionVC animated:YES];
        } else if (!userItem.mobileNo.length) {
            SSJBindMobileNoViewController *bindNoVC = [[SSJBindMobileNoViewController alloc] init];
            bindNoVC.isLoginFlow = YES;
            bindNoVC.finishHandle = self.finishHandle;
            [self.navigationController setViewControllers:@[bindNoVC] animated:YES];
        } else {
            if (self.finishHandle) {
                self.finishHandle(self);
            }
            [self dismissViewControllerAnimated:NO completion:NULL];
        }
    } failure:^(NSError * _Nonnull error) {
        [CDAutoHideMessageHUD showError:error];
    }];
}

#pragma mark - Lazy

- (UITextField *)numTextF {
    if (!_numTextF) {
        _numTextF = [[UITextField alloc] init];
        _numTextF.placeholder = @"手机号";
        _numTextF.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _numTextF.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _numTextF.keyboardType = UIKeyboardTypeNumberPad;
        _numTextF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _numTextF.delegate = self;
        [_numTextF ssj_setBorderWidth:2];
        [_numTextF ssj_setBorderStyle:SSJBorderStyleBottom];
        [_numTextF ssj_setBorderColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].cellSeparatorColor alpha:[SSJThemeSetting defaultThemeModel].cellSeparatorAlpha]];
    }
    return _numTextF;
}

- (UILabel *)phonePreL {
    if (!_phonePreL) {
        _phonePreL = [[UILabel alloc] init];
        _phonePreL.text = @"+86";
        _phonePreL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _phonePreL.textColor = [UIColor ssj_colorWithHex:@"333333"];
        [_phonePreL ssj_setBorderWidth:2];
        [_phonePreL ssj_setBorderStyle:SSJBorderStyleBottom];
        [_phonePreL ssj_setBorderColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].cellSeparatorColor alpha:[SSJThemeSetting defaultThemeModel].cellSeparatorAlpha]];
    }
    return _phonePreL;
}

- (UIButton *)verifyPhoneBtn {
    if (!_verifyPhoneBtn) {
        _verifyPhoneBtn = [[UIButton alloc] init];
        [_verifyPhoneBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [_verifyPhoneBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"f9cbd0"] forState:UIControlStateDisabled];
        [_verifyPhoneBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"ea4a64"] forState:UIControlStateNormal];
        _verifyPhoneBtn.titleLabel.textColor = [UIColor whiteColor];
        _verifyPhoneBtn.layer.cornerRadius = 6;
        _verifyPhoneBtn.layer.masksToBounds = YES;
        RAC(_verifyPhoneBtn,enabled) = self.verifyPhoneViewModel.enableVerifySignal;
        
        __weak __typeof(self)weakSelf = self;
        [[_verifyPhoneBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [weakSelf.view endEditing:YES];
            [[[weakSelf.verifyPhoneViewModel.verifyPhoneNumRequestCommand execute:nil] takeUntil:weakSelf.rac_willDeallocSignal] subscribeNext:^(NSNumber *result) {
//                1 密码登录(已注册)，0 验证码注册（未注册）
//                请求返回处理好的数据
                if ([result boolValue]) {
                    SSJLoginPhoneViewController *vc = [[SSJLoginPhoneViewController alloc] init];
                    vc.phoneNum = weakSelf.verifyPhoneViewModel.phoneNum;
                    vc.finishHandle = weakSelf.finishHandle;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                } else {
                    SSRegisterAndLoginViewController *loginVC = [[SSRegisterAndLoginViewController alloc] init];
                    loginVC.phoneNum = weakSelf.verifyPhoneViewModel.phoneNum;
                    loginVC.regOrForgetType = SSJRegistAndForgetPasswordTypeRegist;//注册
                    loginVC.finishHandle = weakSelf.finishHandle;
                    [weakSelf.navigationController pushViewController:loginVC animated:YES];
                }
            } error:^(NSError *error) {
                [CDAutoHideMessageHUD showError:error];
            }];
        }];
        
        [[[weakSelf.verifyPhoneViewModel.verifyPhoneNumRequestCommand.executing skip:1] distinctUntilChanged]
         subscribeNext:^(id x) {
             if ([x boolValue]) {
                 weakSelf.numTextF.userInteractionEnabled = NO;
             } else {
                 weakSelf.numTextF.userInteractionEnabled = YES;
             }
         }];
    }
    return _verifyPhoneBtn;
}

- (UIButton *)agreeButton {
    if (!_agreeButton) {
        _agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _agreeButton.selected = YES;
        [_agreeButton setImage:nil forState:UIControlStateNormal];
        [_agreeButton setImage:[[UIImage imageNamed:@"register_agreement"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        _agreeButton.tintColor = [UIColor ssj_colorWithHex:@"ea4a64"];
        [[_agreeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
            btn.selected = !btn.selected;
        }];
        [_agreeButton ssj_setBorderWidth:2];
        [_agreeButton ssj_setBorderStyle:SSJBorderStyleAll];
        [_agreeButton ssj_setBorderColor:[UIColor ssj_colorWithHex:@"ea4a64"]];
    }
    return _agreeButton;
}

- (UIButton *)protocolButton {
    if (!_protocolButton) {
        _protocolButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _protocolButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        NSString *oldStr = @"我已阅读并同意用户协定";
        [_protocolButton setAttributedTitle:[oldStr attributeStrWithTargetStr:@"用户协定" range:NSMakeRange(0, 0) color:[UIColor ssj_colorWithHex:@"ea4a64"]] forState:UIControlStateNormal];
        [_protocolButton setTitleColor:[UIColor ssj_colorWithHex:@"666666"] forState:UIControlStateNormal];
        @weakify(self);
        [[_protocolButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self.view endEditing:YES];
            SSJNormalWebViewController *userAgreementVC = [SSJNormalWebViewController webViewVCWithURL:[NSURL URLWithString:SSJUserProtocolUrl]];
            userAgreementVC.title = @"用户协定";
            [self.navigationController pushViewController:userAgreementVC animated:YES];
        }];
    }
    return _protocolButton;
}

-(UIButton *)tencentLoginButton{
    if (!_tencentLoginButton) {
        _tencentLoginButton = [[UIButton alloc]init];
        [_tencentLoginButton setImage:[UIImage imageNamed:@"login_qq"] forState:UIControlStateNormal];
        _tencentLoginButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor];
        _tencentLoginButton.contentMode = UIViewContentModeCenter;
        @weakify(self);
        [[_tencentLoginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [SSJAnaliyticsManager event:@"login_qq"];
            [self.view endEditing:YES];
            [[self.verifyPhoneViewModel.qqLoginCommand execute:nil] subscribeError:^(NSError *error) {
                if (error.code != SSJErrorCodeLoginCanceled) {
                    [CDAutoHideMessageHUD showError:error];
                }
            } completed:^{
                [CDAutoHideMessageHUD showMessage:@"登录成功"];
                [self handleThirdPartLoginPageFlow];
            }];
        }];
    }
    return _tencentLoginButton;
}

-(UIButton *)weixinLoginButton{
    if (!_weixinLoginButton) {
        _weixinLoginButton = [[UIButton alloc]init];
        [_weixinLoginButton setImage:[UIImage imageNamed:@"login_weixin"] forState:UIControlStateNormal];
        [_weixinLoginButton sizeToFit];
//        _weixinLoginButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor];
        _weixinLoginButton.contentMode = UIViewContentModeCenter;
        @weakify(self);
        [[_weixinLoginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [SSJAnaliyticsManager event:@"login_weixin"];
            [self.view endEditing:YES];
            [[self.verifyPhoneViewModel.wxLoginCommand execute:nil] subscribeError:^(NSError *error) {
                if (error.code != SSJErrorCodeLoginCanceled) {
                    [CDAutoHideMessageHUD showError:error];
                }
            } completed:^{
                [CDAutoHideMessageHUD showMessage:@"登录成功"];
                [self handleThirdPartLoginPageFlow];
            }];
        }];
    }
    return _weixinLoginButton;
}

- (SSJLoginVerifyPhoneNumViewModel *)verifyPhoneViewModel {
    if (!_verifyPhoneViewModel) {
        _verifyPhoneViewModel = [[SSJLoginVerifyPhoneNumViewModel alloc] init];
    }
    return _verifyPhoneViewModel;
}

#pragma mark -  UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = textField.text ? : @"";
    text = [text stringByReplacingCharactersInRange:range withString:string];
        if (text.length > 11) {
            [CDAutoHideMessageHUD showMessage:@"最多只能输入11位手机号" inView:self.view.window duration:1];
            return NO;
        }
    return YES;
}

@end
