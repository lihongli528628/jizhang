//
//  SSJMotionPasswordViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/3/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMotionPasswordViewController.h"
#import "SSJNavigationController.h"
#import "SSJLoginVerifyPhoneViewController.h"
#import "SSJBindMobileNoViewController.h"
#import "UIViewController+SSJPageFlow.h"
#import "SCYMotionEncryptionView.h"
#import "SSJUserTableManager.h"
#import "UIImageView+CornerRadius.h"
#import "SSJMotionPasswordLoginPasswordAlertView.h"
#import <LocalAuthentication/LocalAuthentication.h>
//#import "SSJLoginNavigator.h"

static NSString *const kErrorRemindTextColor = @"ff7139";

//  验证密码最多错误次数
static const int kVerifyFailureTimesLimit = 5;

@interface SSJMotionPasswordViewController () <SCYMotionEncryptionViewDelegate>

@property (nonatomic, strong) UIView *portraitContainer;

@property (nonatomic, strong) UIImageView *portraitView;

@property (nonatomic, strong) UILabel *remindLab;

@property (nonatomic, strong) UILabel *bottomRemindLab;

@property (nonatomic, strong) UIButton *strokeToggle;

@property (nonatomic, strong) UIButton *forgetPwdBtn;

@property (nonatomic, strong) UIButton *changeAccountBtn;

@property (nonatomic, strong) UIButton *verifyLoginPwdBtn;

@property (nonatomic, strong) SCYMotionEncryptionView *motionView;

@property (nonatomic, strong) SSJMotionPasswordLoginPasswordAlertView *passwordAlertView;

@property (nonatomic, copy) NSString *password;

@property (nonatomic) int verifyFailureTimes;

@property (nonatomic, strong) SSJUserItem *userItem;

@property (nonatomic, strong) LAContext *context;

/**
 指纹发生更改后新的数据
 */
@property (nonatomic, strong) NSData *evaluatedPolicyDomainState;

@end

@implementation SSJMotionPasswordViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
        self.verifyFailureTimes = kVerifyFailureTimesLimit;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    [self updateNavigationBar];
    [self.view setNeedsUpdateConstraints];
    
    [self.view ssj_showLoadingIndicator];
    [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
        self.userItem = userItem;
        [self loadUserIcon];
        [self setupBindings];
        [self verifyFingerPrintPwdIfNeeded];
        [self.view ssj_hideLoadingIndicator];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
        [self.view ssj_hideLoadingIndicator];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_context invalidate];
    _context = nil;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.portraitContainer.layer.cornerRadius = self.portraitContainer.width * 0.5;
    self.portraitView.layer.cornerRadius = self.portraitView.width * 0.5;
}

- (void)updateViewConstraints {
    [self.portraitContainer mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(76, 76));
        make.top.mas_equalTo(80);
        make.centerX.mas_equalTo(self.view);
    }];
    [self.portraitView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.portraitContainer).insets(UIEdgeInsetsMake(5, 5, 5, 5));
    }];
    [self.remindLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.portraitContainer.mas_bottom).offset(15);
        make.height.mas_equalTo(22);
        make.centerX.mas_equalTo(self.view);
    }];
    [self.bottomRemindLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.remindLab.mas_bottom).offset(10);
        make.height.mas_equalTo(18);
        make.centerX.mas_equalTo(self.view);
    }];
    [self.motionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(self.view.width * 0.8, self.view.width * 0.8));
        make.top.mas_equalTo(self.bottomRemindLab.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.view);
    }];
    [self.strokeToggle mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 40));
        make.left.mas_equalTo(self.view.mas_centerX).offset(110);
        make.centerY.mas_equalTo(self.remindLab);
    }];
    [self.forgetPwdBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(96, 22));
        make.left.mas_equalTo(self.view).offset(30);
        make.bottom.mas_equalTo(self.view).offset(-30);
    }];
    [self.changeAccountBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(96, 22));
        make.right.mas_equalTo(self.view).offset(-30);
        make.bottom.mas_equalTo(self.view).offset(-30);
    }];
    [self.verifyLoginPwdBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 22));
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-30);
    }];
    [super updateViewConstraints];
}

#pragma mark - SCYMotionEncryptionViewDelegate
- (SCYMotionEncryptionCircleLayerStatus)motionView:(SCYMotionEncryptionView *)motionView didFinishSelectKeypads:(NSArray *)keypads {
    switch (self.type) {
        // 设置手势密码
        case SSJMotionPasswordViewControllerTypeSetting: {
            if (!self.password) {
                // 第一次绘制
                if (keypads.count < 3) {
                    return SCYMotionEncryptionCircleLayerStatusError;
                } else {
                    self.remindLab.text = @"再次绘制解锁图案";
                    self.remindLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordNormalColor];
                    self.password = [keypads componentsJoinedByString:@","];
                    return SCYMotionEncryptionCircleLayerStatusCorrect;
                }
            } else {
                // 第二次绘制
                if ([self.password isEqualToString:[keypads componentsJoinedByString:@","]]) {
                    // 设置成功，保存手势密码
                    _userItem.motionPWD = self.password;
                    _userItem.motionPWDState = @"1";
                    [SSJUserTableManager saveUserItem:_userItem success:^{
                        if (self.isLoginFlow) {
                            if (_userItem.mobileNo.length) {
                                if (self.finishHandle) {
                                    self.finishHandle(self);
                                }
                                [self dismissViewControllerAnimated:NO completion:NULL];
                            } else {
                                SSJBindMobileNoViewController *bindNoVC = [[SSJBindMobileNoViewController alloc] init];
                                bindNoVC.isLoginFlow = YES;
                                bindNoVC.finishHandle = self.finishHandle;
                                [self.navigationController setViewControllers:@[bindNoVC] animated:YES];
                            }
                        } else {
                            [self goBackAction];
                        }
                    } failure:^(NSError * _Nonnull error) {
                        [SSJAlertViewAdapter showError:error];
                    }];
                    return SCYMotionEncryptionCircleLayerStatusCorrect;
                } else {
                    // 设置失败，重新绘制
                    self.remindLab.text = @"与上次绘制不一致，请重新绘制";
                    self.remindLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordErrorColor];
                    self.password = nil;
                    return SCYMotionEncryptionCircleLayerStatusError;
                }
            }
        }
            break;
            
        // 验证手势密码
        case SSJMotionPasswordViewControllerTypeVerification: {
            if ([self.userItem.motionPWD isEqualToString:[keypads componentsJoinedByString:@","]]) {
                // 验证陈功
                if (self.evaluatedPolicyDomainState) {
                    // 指纹发生过更改就保存最新的数据
                    SSJUpdateEvaluatedPolicyDomainState(self.evaluatedPolicyDomainState);
                }
                if (self.finishHandle) {
                    self.finishHandle(self);
                }
                [self dismissViewControllerAnimated:YES completion:NULL];
                return SCYMotionEncryptionCircleLayerStatusCorrect;
            } else {
                // 验证失败
                self.verifyFailureTimes --;
                self.remindLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordErrorColor];
                self.remindLab.text = [NSString stringWithFormat:@"密码错误，您还可以输入%d次", self.verifyFailureTimes];
                
                // 验证失败次数达到最大限制
                if (self.verifyFailureTimes == 0) {
                    [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"手势密码已失效，请重新登录" action:[SSJAlertViewAction actionWithTitle:@"密码登录" handler:^(SSJAlertViewAction * _Nonnull action) {
                        [self relogin];
                    }], nil];
                }
                
                return SCYMotionEncryptionCircleLayerStatusError;
            }
        }
            break;
            
            //  关闭手势密码
        case SSJMotionPasswordViewControllerTypeTurnoff: {
            if ([_userItem.motionPWD isEqualToString:[keypads componentsJoinedByString:@","]]) {
                //  验证成功
                _userItem.motionPWD = @"";
                _userItem.motionPWDState = @"0";
                [SSJUserTableManager saveUserItem:_userItem success:^{
                    [self goBackAction];
                } failure:^(NSError * _Nonnull error) {
                    [SSJAlertViewAdapter showError:error];
                }];
                return SCYMotionEncryptionCircleLayerStatusCorrect;
            } else {
                //  验证失败
                self.verifyFailureTimes --;
                self.remindLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordErrorColor];
                self.remindLab.text = [NSString stringWithFormat:@"密码错误，您还可以输入%d次", self.verifyFailureTimes];
                
                //  验证失败次数达到最大限制
                if (self.verifyFailureTimes == 0) {
                    [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"手势密码已失效，请重新登录" action:[SSJAlertViewAction actionWithTitle:@"密码登录" handler:^(SSJAlertViewAction * _Nonnull action) {
                        [self relogin];
                    }], nil];
                }
                return SCYMotionEncryptionCircleLayerStatusError;
            }
        }
            break;
    }
}

#pragma mark - Private
// 注销登录状态、清空用户的手势密码，并跳转至登录页面
- (void)relogin {
    @weakify(self);
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        self.userItem.motionPWD = @"";
        self.userItem.motionPWDState = @"1";
        [SSJUserTableManager saveUserItem:self.userItem success:^{
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [SSJUserTableManager reloadUserIdWithSuccess:^{
                [subscriber sendCompleted];
            } failure:^(NSError * _Nonnull error) {
                [subscriber sendError:error];
            }];
            return nil;
        }];
    }] subscribeError:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    } completed:^{
        @strongify(self);
        if (self.type == SSJMotionPasswordViewControllerTypeVerification) {
            SSJLoginVerifyPhoneViewController *loginVC = [[SSJLoginVerifyPhoneViewController alloc] init];
            loginVC.finishHandle = self.finishHandle;
            loginVC.mobileNo = self.userItem.mobileNo;
            [self.navigationController setViewControllers:@[loginVC] animated:YES];
        } else if (self.type == SSJMotionPasswordViewControllerTypeTurnoff) {
            SSJLoginVerifyPhoneViewController *loginVC = [[SSJLoginVerifyPhoneViewController alloc] init];
            loginVC.mobileNo = self.userItem.mobileNo;
            loginVC.finishHandle = ^(UIViewController *controller) {
                [self.navigationController popViewControllerAnimated:NO];
            };
            SSJNavigationController *naviVC = [[SSJNavigationController alloc] initWithRootViewController:loginVC];
            [self presentViewController:naviVC animated:YES completion:NULL];
        }
    }];
}

// 切换账号
- (void)changeAccountAction {
    [SSJUserTableManager reloadUserIdWithSuccess:^{
        SSJLoginVerifyPhoneViewController *loginVC = [[SSJLoginVerifyPhoneViewController alloc] init];
        loginVC.finishHandle = self.finishHandle;
        [self.navigationController setViewControllers:@[loginVC] animated:YES];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

// 验证登录密码
- (void)verifyLoginPassword {
    NSString *inputPwd = [_passwordAlertView.passwordInput.text ssj_md5HexDigest];
    if ([inputPwd isEqualToString:_userItem.loginPWD]) {
        // 验证登录密码正确
        if (_type == SSJMotionPasswordViewControllerTypeSetting) {
            self.remindLab.text = @"请绘制解锁图案";
            self.remindLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordNormalColor];
            [_passwordAlertView dismiss:NULL];
        } else if (_type == SSJMotionPasswordViewControllerTypeTurnoff) {
            _userItem.motionPWD = @"";
            _userItem.motionPWDState = @"0";
            [SSJUserTableManager saveUserItem:_userItem success:^{
                [_passwordAlertView dismiss:^(BOOL finished) {
                    [self goBackAction];
                }];
            } failure:^(NSError * _Nonnull error) {
                [SSJAlertViewAdapter showError:error];
            }];
        }
    } else {
        [_passwordAlertView shake];
        _passwordAlertView.passwordInput.text = nil;
        [CDAutoHideMessageHUD showMessage:@"密码输入错误，请重新输入"];
    }
}

- (void)verifyFingerPrintPwdIfNeeded {
    if (self.type != SSJMotionPasswordViewControllerTypeVerification
        || ![self.userItem.fingerPrintState boolValue]
        || ![self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        return;
    }
    
    BOOL touchIDChanged = NO;
    if (self.context.evaluatedPolicyDomainState && SSJEvaluatedPolicyDomainState()) {
        touchIDChanged = ![self.context.evaluatedPolicyDomainState isEqualToData:SSJEvaluatedPolicyDomainState()];
    }
    
    if (touchIDChanged) {
        self.evaluatedPolicyDomainState = self.context.evaluatedPolicyDomainState;
        return;
    }
    
    [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"请按住Home键进行解锁" reply:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            SSJDispatchMainSync(^{
                if (self.finishHandle) {
                    self.finishHandle(self);
                }
                [self dismissViewControllerAnimated:YES completion:NULL];
            });
        }
    }];
}

- (void)loadUserIcon {
    NSString *iconUrlStr = [_userItem.icon hasPrefix:@"http"] ? _userItem.icon : SSJImageURLWithAPI(_userItem.icon);
    UIImage *placeholder = [UIImage imageNamed:@"defualt_portrait"];
    [self.portraitView sd_setImageWithURL:[NSURL URLWithString:iconUrlStr] placeholderImage:placeholder options:(SDWebImageAvoidAutoSetImage | SDWebImageAllowInvalidSSLCertificates) completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            [UIView animateWithDuration:0.25 animations:^{
                self.portraitView.image = image;
            }];
        }
    }];
}

- (void)setupViews {
    [self.view addSubview:self.portraitContainer];
    [self.view addSubview:self.remindLab];
    [self.view addSubview:self.bottomRemindLab];
    [self.view addSubview:self.motionView];
    [self.view addSubview:self.strokeToggle];
    
    switch (self.type) {
        case SSJMotionPasswordViewControllerTypeSetting:
            self.remindLab.text = @"请绘制解锁图案";
            break;
            
        case SSJMotionPasswordViewControllerTypeVerification:
            [self.view addSubview:self.forgetPwdBtn];
            [self.view addSubview:self.changeAccountBtn];
            self.remindLab.text = @"请绘制手势密码";
            break;
            
        case SSJMotionPasswordViewControllerTypeTurnoff:
            if (SSJUserLoginType() == SSJLoginTypeNormal) {
                [self.view addSubview:self.verifyLoginPwdBtn];
            }
            self.remindLab.text = @"请输入原手势密码";
    }
}

- (void)setupBindings {
    RAC(self.motionView, showStroke) = RACObserve(self.strokeToggle, selected);
}

- (void)updateNavigationBar {
    self.hidesNavigationBarWhenPushed = self.type == SSJMotionPasswordViewControllerTypeVerification;
    
    self.navigationBarBackgroundColor = [UIColor clearColor];
    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        self.navigationBarTintColor = [UIColor whiteColor];
        self.navigationBarTitleColor = [UIColor whiteColor];
        self.backgroundView.image = [UIImage ssj_compatibleImageNamed:@"motion_background"];
    }
    
    if (self.type == SSJMotionPasswordViewControllerTypeSetting) {
        self.title = @"设置手势密码";
        self.showNavigationBarBaseLine = NO;
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.leftBarButtonItem = nil;
        if (!self.isLoginFlow) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBackAction)];
        }
    } else if (self.type == SSJMotionPasswordViewControllerTypeTurnoff) {
        self.title = @"关闭手势密码";
        self.showNavigationBarBaseLine = NO;
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBackAction)];
    }
}

#pragma mark - Getter
- (UIView *)portraitContainer {
    if (!_portraitContainer) {
        _portraitContainer = [[UIView alloc] init];
        _portraitContainer.clipsToBounds = YES;
        _portraitContainer.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        [_portraitContainer addSubview:self.portraitView];
    }
    return _portraitContainer;
}

- (UIImageView *)portraitView {
    if (!_portraitView) {
        _portraitView = [[UIImageView alloc] init];
        _portraitView.clipsToBounds = YES;
    }
    return _portraitView;
}

- (UILabel *)remindLab {
    if (!_remindLab) {
        _remindLab = [[UILabel alloc] init];
        _remindLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordNormalColor];
        _remindLab.textAlignment = NSTextAlignmentCenter;
        _remindLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _remindLab;
}

- (UILabel *)bottomRemindLab {
    if (!_bottomRemindLab) {
        _bottomRemindLab = [[UILabel alloc] init];
        _bottomRemindLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordNormalColor];
        _bottomRemindLab.textAlignment = NSTextAlignmentCenter;
        _bottomRemindLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _bottomRemindLab.text = self.type == SSJMotionPasswordViewControllerTypeSetting ? @"至少连接3个点" : nil;
    }
    return _bottomRemindLab;
}

- (UIButton *)strokeToggle {
    if (!_strokeToggle) {
        _strokeToggle = [UIButton buttonWithType:UIButtonTypeCustom];
        [_strokeToggle setImage:[[UIImage imageNamed:@"founds_yincang"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_strokeToggle setImage:[[UIImage imageNamed:@"founds_yincang"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal | UIControlStateHighlighted];
        [_strokeToggle setImage:[[UIImage imageNamed:@"founds_xianshi"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        [_strokeToggle setImage:[[UIImage imageNamed:@"founds_xianshi"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected | UIControlStateHighlighted];
        _strokeToggle.selected = YES;
        _strokeToggle.tintColor = [UIColor whiteColor];
        [[_strokeToggle rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
            btn.selected = !btn.selected;
        }];
    }
    return _strokeToggle;
}

- (UIButton *)forgetPwdBtn {
    if (!_forgetPwdBtn) {
        _forgetPwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _forgetPwdBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_forgetPwdBtn setTitle:@"忘记手势密码" forState:UIControlStateNormal];
        if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
            [_forgetPwdBtn setTitleColor:[[UIColor ssj_colorWithHex:@"#EE4F4F"] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
        } else {
            [_forgetPwdBtn setTitleColor:[[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordNormalColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
        }
        @weakify(self);
        [[_forgetPwdBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.userItem.loginPWD.length) {
                [self.passwordAlertView show];
            } else {
                [self relogin];
            }
        }];
    }
    return _forgetPwdBtn;
}

- (UIButton *)changeAccountBtn {
    if (!_changeAccountBtn) {
        _changeAccountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeAccountBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_changeAccountBtn setTitle:@"登录其它账号" forState:UIControlStateNormal];
        if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
            [_changeAccountBtn setTitleColor:[[UIColor ssj_colorWithHex:@"#EE4F4F"] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
        } else {
            [_changeAccountBtn setTitleColor:[[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordNormalColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
        }
        [_changeAccountBtn addTarget:self action:@selector(changeAccountAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeAccountBtn;
}

- (UIButton *)verifyLoginPwdBtn {
    if (!_verifyLoginPwdBtn) {
        _verifyLoginPwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _verifyLoginPwdBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_verifyLoginPwdBtn setTitle:@"忘记手势？可验证登录密码" forState:UIControlStateNormal];
        if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
            [_verifyLoginPwdBtn setTitleColor:[[UIColor ssj_colorWithHex:@"#EE4F4F"] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
        } else {
            [_verifyLoginPwdBtn setTitleColor:[[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordNormalColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
        }
        @weakify(self);
        [[_verifyLoginPwdBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self.passwordAlertView show];
        }];
    }
    return _verifyLoginPwdBtn;
}

- (SCYMotionEncryptionView *)motionView {
    if (!_motionView) {
        _motionView = [[SCYMotionEncryptionView alloc] init];
        _motionView.delegate = self;
        _motionView.strokeColorInfo = @{@(SCYMotionEncryptionCircleLayerStatusDefault):[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordHighlightedColor],
                                        @(SCYMotionEncryptionCircleLayerStatusCorrect):[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordHighlightedColor],
                                        @(SCYMotionEncryptionCircleLayerStatusError):[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordErrorColor]};

        _motionView.circleRadius = self.view.width * 0.1;
        _motionView.imageInfo = @{@(SCYMotionEncryptionCircleLayerStatusDefault):[UIImage ssj_themeImageWithName:@"motion_circle_default"],
                                  @(SCYMotionEncryptionCircleLayerStatusCorrect):[UIImage ssj_themeImageWithName:@"motion_circle_correct"],
                                  @(SCYMotionEncryptionCircleLayerStatusError):[UIImage ssj_themeImageWithName:@"motion_circle_error"]};
    }
    return _motionView;
}

- (SSJMotionPasswordLoginPasswordAlertView *)passwordAlertView {
    if (!_passwordAlertView) {
        _passwordAlertView = [SSJMotionPasswordLoginPasswordAlertView alertView];
        [_passwordAlertView.sureButton addTarget:self action:@selector(verifyLoginPassword) forControlEvents:UIControlEventTouchUpInside];
    }
    return _passwordAlertView;
}

- (LAContext *)context {
    if (!_context) {
        _context = [[LAContext alloc] init];
        _context.localizedFallbackTitle = @"";
    }
    return _context;
}

@end
