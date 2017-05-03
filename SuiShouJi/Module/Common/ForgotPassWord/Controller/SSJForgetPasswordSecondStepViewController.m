//
//  SSJForgetPasswordSecondStepViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/1/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJForgetPasswordSecondStepViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SSJBaselineTextField.h"
#import "SSJRegistNetworkService.h"
#import "SSJBorderButton.h"

@interface SSJForgetPasswordSecondStepViewController () <UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, strong) SSJBaselineTextField *passwordField;

@property (nonatomic, strong) SSJBorderButton *nextButton;

@property (nonatomic, strong) SSJRegistNetworkService *networkService;

@end

@implementation SSJForgetPasswordSecondStepViewController

#pragma mark - Lifecycle
- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"输入新密码";
        self.showNavigationBarBaseLine = NO;
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        self.backgroundView.image = [UIImage ssj_compatibleImageNamed:@"login_bg"];
    }
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.passwordField];
    [self.scrollView addSubview:self.nextButton];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor clearColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_1),
                                                                        NSForegroundColorAttributeName:[UIColor whiteColor]};
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.passwordField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = textField.text ? : @"";
    text = [text stringByReplacingCharactersInRange:range withString:string];
    if (text.length > 15) {
        [CDAutoHideMessageHUD showMessage:@"最多只能输入15位" inView:self.view.window duration:1];
        return NO;
    }
    return YES;
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    [super serverDidFinished:service];
    
    if ([self.networkService.returnCode isEqualToString:@"1"]) {
        
        [self.passwordField resignFirstResponder];
        
        __weak typeof(self) weakSelf = self;
        SSJAlertViewAction *sureAction = [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction *action) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:SCYUpdateUserInfoNotification object:self];
            if (weakSelf.finishHandle) {
                weakSelf.finishHandle(weakSelf);
            }
        }];
        
        
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:@"设置密码成功" action:sureAction, nil];
        
    } else {
        [self.passwordField becomeFirstResponder];
    }
}

#pragma mark - Notification
//- (void)textDidChange {
//    if ([self.passwordField isFirstResponder]) {
//        self.nextButton.enabled = self.passwordField.text.length >= 6;
//    }
//}

#pragma mark - Event
- (void)finishBtnAction {
    if (!self.passwordField.text.length) {
        [CDAutoHideMessageHUD showMessage:@"请收入您的新密码"];
        return;
    }
    
    NSString * regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,15}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:self.passwordField.text];
    if (isMatch) {
        [self.networkService setPasswordWithMobileNo:self.mobileNo authCode:self.authCode password:self.passwordField.text];
    } else {
        [CDAutoHideMessageHUD showMessage:@"只能输入6-15位字母、数字组合"];
    }
}

#pragma mark - Getter
- (SSJRegistNetworkService *)networkService {
    if (!_networkService) {
        _networkService = [[SSJRegistNetworkService alloc] initWithDelegate:self type:SSJRegistAndForgetPasswordTypeForgetPassword];
        _networkService.showLodingIndicator = YES;
    }
    return _networkService;
}

- (TPKeyboardAvoidingScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.view.bounds];
    }
    return _scrollView;
}

- (SSJBaselineTextField *)passwordField {
    if (!_passwordField) {
        _passwordField = [[SSJBaselineTextField alloc] initWithFrame:CGRectMake(25, 94, self.view.width - 50, 50) contentHeight:34];
        _passwordField.secureTextEntry = YES;
        _passwordField.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
        _passwordField.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor];
        _passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入新密码" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor]}];
        _passwordField.delegate = self;
        _passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 36)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"login_password"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        imageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor];
        imageView.center = CGPointMake(leftView.width * 0.5, leftView.height * 0.5);
        [leftView addSubview:imageView];
        _passwordField.leftViewMode = UITextFieldViewModeAlways;
        _passwordField.leftView = leftView;
    }
    return _passwordField;
}

- (SSJBorderButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [[SSJBorderButton alloc] initWithFrame:CGRectMake(25, self.passwordField.bottom + 40, self.view.width - 50, 40)];
        [_nextButton setFontSize:16];
        [_nextButton setTitle:@"确定" forState:SSJBorderButtonStateNormal];
        [_nextButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor] forState:SSJBorderButtonStateNormal];
        [_nextButton setBackgroundColor:[UIColor clearColor] forState:SSJBorderButtonStateNormal];
        [_nextButton setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor] forState:SSJBorderButtonStateNormal];
        [_nextButton addTarget:self action:@selector(finishBtnAction)];
    }
    return _nextButton;
}

@end
