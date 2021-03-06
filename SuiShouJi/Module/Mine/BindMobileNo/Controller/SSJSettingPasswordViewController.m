//
//  SSJSettingPasswordViewController.m
//  SuiShouJi
//
//  Created by old lang on 2017/6/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJSettingPasswordViewController.h"
#import "SSJSettingViewController.h"
#import "UIViewController+SSJPageFlow.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SSJVerifCodeField.h"
#import "SSJPasswordField.h"
#import "SSJInviteCodeJoinSuccessView.h"
#import "SSJBindMobileNoNetworkService.h"
#import "SSJForgetAndResetPasswordNetworkService.h"
#import "SSJUserTableManager.h"

@interface SSJSettingPasswordViewController ()

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *descLab;

@property (nonatomic, strong) SSJVerifCodeField *authCodeField;

@property (nonatomic, strong) SSJPasswordField *passwordField;

@property (nonatomic, strong) UIButton *bindingBtn;

@property (nonatomic, strong) SSJInviteCodeJoinSuccessView *successAlertView;

@property (nonatomic, strong) SSJLoginVerifyPhoneNumViewModel *viewModel;

@property (nonatomic, strong) SSJBindMobileNoNetworkService *bindMobileNoService;

@property (nonatomic, strong) SSJForgetAndResetPasswordNetworkService *resetPasswordService;

@end

@implementation SSJSettingPasswordViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.appliesTheme = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle];
    [self setUpViews];
    [self setUpBindings];
    [self updateAppearance];
    [self.authCodeField getVerifCode];
    [self.view setNeedsUpdateConstraints];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)updateViewConstraints {
    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(SSJ_NAVIBAR_BOTTOM, 0, 0, 0));
    }];
    [self.icon mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView).offset(30);
        make.centerX.mas_equalTo(self.scrollView);
        make.size.mas_equalTo(CGSizeMake(74, 94));
    }];
    [self.descLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon.mas_bottom).offset(30);
        make.centerX.mas_equalTo(self.scrollView);
        make.height.mas_equalTo(30);
    }];
    [self.authCodeField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descLab.mas_bottom).offset(18);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.right.mas_equalTo(self.scrollView).offset(-15);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    [self.passwordField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.authCodeField.mas_bottom).offset(18);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.right.mas_equalTo(self.scrollView).offset(-15);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    [self.bindingBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.passwordField.mas_bottom).offset(34);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.bottom.mas_equalTo(self.scrollView).offset(-40);
        make.right.mas_equalTo(self.scrollView).offset(-15);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    [super updateViewConstraints];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

#pragma mark - Private
- (void)updateAppearance {
    [self.authCodeField defaultAppearanceTheme];
    [self.passwordField updateAppearanceAccordingToDefaultTheme];
    
    UIColor *mainColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].mainColor];
    self.descLab.textColor = mainColor;
    
    UIColor *normalColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].buttonColor];
    [self.bindingBtn ssj_setBackgroundColor:normalColor forState:UIControlStateNormal];
    
    UIColor *disableColor = [normalColor colorWithAlphaComponent:SSJButtonDisableAlpha];
    [self.bindingBtn ssj_setBackgroundColor:disableColor forState:UIControlStateDisabled];
}

- (void)setTitle {
    switch (self.type) {
        case SSJSettingPasswordTypeMobileNoBinding:
            self.title = @"绑定手机号";
            break;
            
        case SSJSettingPasswordTypeResettingPassword:
            self.title = @"重设密码";
            break;
    }
}

- (void)setUpViews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.icon];
    [self.scrollView addSubview:self.descLab];
    [self.scrollView addSubview:self.authCodeField];
    [self.scrollView addSubview:self.passwordField];
    [self.scrollView addSubview:self.bindingBtn];
    if (self.isLoginFlow) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"跳过", nil) style:UIBarButtonItemStylePlain target:self action:@selector(finishLoginFlow)];
    }
}

- (void)setUpBindings {
    @weakify(self);
    RAC(self.descLab,text) = [RACObserve(self.authCodeField, getAuthCodeState) map:^id(NSNumber *value) {
        @strongify(self);
        SSJGetVerifCodeState state = [value integerValue];
        NSString *ciphertext = self.mobileNo;
        if (self.mobileNo.length >= 7) {
            ciphertext = [self.mobileNo stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        }
        if (state == SSJGetVerifCodeStateSent) {
            return [NSString stringWithFormat:@"验证码已发送至：%@", ciphertext];
        } else if (state == SSJGetVerifCodeStateReady) {
            return [NSString stringWithFormat:@"将验证码发送至：%@", ciphertext];
        } else {
            return nil;
        }
    }];
    
    [[self.bindingBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        switch (self.type) {
            case SSJSettingPasswordTypeMobileNoBinding:
                [self executeBindMobileNoProcess];
                break;
                
            case SSJSettingPasswordTypeResettingPassword:
                [self executeResetPasswordProcess];
                break;
        }
    }];
    
    self.viewModel.phoneNum = self.mobileNo;
    self.authCodeField.viewModel = self.viewModel;
    RAC(self.viewModel, verificationCode) = self.authCodeField.rac_textSignal;
    RAC(self.viewModel, passwardNum) = self.passwordField.rac_textSignal;
    RAC(self.bindingBtn, enabled) = self.viewModel.enableRegAndLoginSignal;
}

- (void)executeBindMobileNoProcess {
    [[[[[self verifyPassword] then:^RACSignal *{
        return [self bindMobileNo];
    }] then:^RACSignal *{
        return [self queryUserItem];
    }] flattenMap:^RACStream *(SSJUserItem *userItem) {
        return [self saveMobildNo:userItem];
    }] subscribeError:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    } completed:^{
        if (self.isLoginFlow) {
            [self finishLoginFlow];
        } else {
            [self goBackToSettingPage];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.successAlertView showWithDesc:@"绑定手机号成功"];
            [SSJAnaliyticsManager event:@"bind_phone"];
        });
    }];
}

- (void)executeResetPasswordProcess {
    [[[[[self verifyPassword] then:^RACSignal *{
        return [self resetPassword];
    }] then:^RACSignal *{
        return [self queryUserItem];
    }] flattenMap:^RACStream *(SSJUserItem *userItem) {
        return [self savePassword:userItem];
    }] subscribeError:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    } completed:^{
        [SSJAnaliyticsManager event:@"modify_pwd"];
        [CDAutoHideMessageHUD showMessage:@"修改密码成功"];
        [self goBackToSettingPage];
    }];
}

- (void)finishLoginFlow {
    if (self.finishHandle) {
        self.finishHandle(self);
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (RACSignal *)verifyPassword {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (SSJVerifyPassword(self.passwordField.text)) {
            [subscriber sendCompleted];
        } else {
            [subscriber sendError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeLoginPasswordIllegal userInfo:@{NSLocalizedDescriptionKey:@"密法格式不正确，请输入字母和数字的组合"}]];
        }
        return nil;
    }];
}

- (RACSignal *)bindMobileNo {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.bindMobileNoService bindMobileNoWithMobileNo:self.mobileNo authCode:self.authCodeField.text password:self.passwordField.text success:^(__kindof SSJBaseNetworkService * _Nonnull service) {
            [subscriber sendCompleted];
        } failure:^(__kindof SSJBaseNetworkService * _Nonnull service) {
            [subscriber sendError:service.error];
        }];
        return nil;
    }];
}

- (RACSignal *)resetPassword {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.resetPasswordService requestWithType:SSJResetPasswordType mobileNo:self.mobileNo authCode:self.authCodeField.text password:self.passwordField.text success:^(SSJBaseNetworkService * _Nonnull service) {
            [subscriber sendCompleted];
        } failure:^(SSJBaseNetworkService * _Nonnull service) {
            [subscriber sendError:service.error];
        }];
        return nil;
    }];
}

- (RACSignal *)queryUserItem {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
            [subscriber sendNext:userItem];
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (RACSignal *)saveMobildNo:(SSJUserItem *)userItem {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        userItem.mobileNo = self.bindMobileNoService.mobileNo;
        [SSJUserTableManager saveUserItem:userItem success:^{
            //解决第三方登录后绑定手机号后再次登录手机号输入框默认显示
            NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:userItem];
            [[NSUserDefaults standardUserDefaults] setObject:userData forKey:SSJLastLoggedUserItemKey];
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (RACSignal *)savePassword:(SSJUserItem *)userItem {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        userItem.loginPWD = self.bindMobileNoService.password.ssj_md5HexDigest;
        [SSJUserTableManager saveUserItem:userItem success:^{
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (void)goBackToSettingPage {
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[SSJSettingViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

#pragma mark - Lazyloading
- (TPKeyboardAvoidingScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.view.bounds];
    }
    return _scrollView;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bind_No_SMS"]];
    }
    return _icon;
}

- (UILabel *)descLab {
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        _descLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _descLab;
}

- (SSJVerifCodeField *)authCodeField {
    if (!_authCodeField) {
        _authCodeField = [[SSJVerifCodeField alloc] initWithGetCodeType:SSJRegistAndForgetPasswordTypeForgetPassword];
    }
    return _authCodeField;
}

- (SSJPasswordField *)passwordField {
    if (!_passwordField) {
        _passwordField = [[SSJPasswordField alloc] init];
    }
    return _passwordField;
}

- (UIButton *)bindingBtn {
    if (!_bindingBtn) {
        _bindingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _bindingBtn.clipsToBounds = YES;
        _bindingBtn.layer.cornerRadius = 6;
        _bindingBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_bindingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        switch (self.type) {
            case SSJSettingPasswordTypeMobileNoBinding:
                [_bindingBtn setTitle:@"绑定" forState:UIControlStateNormal];
                break;
                
            case SSJSettingPasswordTypeResettingPassword:
                [_bindingBtn setTitle:@"确定" forState:UIControlStateNormal];
                break;
        }
    }
    return _bindingBtn;
}

- (SSJInviteCodeJoinSuccessView *)successAlertView {
    if (!_successAlertView) {
        _successAlertView = [[SSJInviteCodeJoinSuccessView alloc] init];
    }
    return _successAlertView;
}

- (SSJLoginVerifyPhoneNumViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[SSJLoginVerifyPhoneNumViewModel alloc] init];
    }
    return _viewModel;
}

- (SSJBindMobileNoNetworkService *)bindMobileNoService {
    if (!_bindMobileNoService) {
        _bindMobileNoService = [[SSJBindMobileNoNetworkService alloc] init];
        _bindMobileNoService.showLodingIndicator = YES;
    }
    return _bindMobileNoService;
}

- (SSJForgetAndResetPasswordNetworkService *)resetPasswordService {
    if (!_resetPasswordService) {
        _resetPasswordService = [[SSJForgetAndResetPasswordNetworkService alloc] init];
        _resetPasswordService.showLodingIndicator = YES;
    }
    return _resetPasswordService;
}

@end
