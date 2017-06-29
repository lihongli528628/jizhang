//
//  SSJFirstBindMobileNoViewController.m
//  SuiShouJi
//
//  Created by old lang on 2017/6/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBindMobileNoViewController.h"
#import "SSJSettingPasswordViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SSJMobileNoField.h"
#import "SSJLoginVerifyPhoneNumViewModel.h"

@interface SSJBindMobileNoViewController ()

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *descLab;

@property (nonatomic, strong) SSJMobileNoField *phoneNoField;

@property (nonatomic, strong) UIButton *nextBtn;

@property (nonatomic, strong) SSJLoginVerifyPhoneNumViewModel *viewModel;

@end

@implementation SSJBindMobileNoViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"绑定手机号";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpViews];
    [self setUpBindings];
    [self updateAppearance];
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints {
    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(SSJ_NAVIBAR_BOTTOM, 0, 0, 0));
    }];
    [self.icon mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView).offset(30);
        make.centerX.mas_equalTo(self.scrollView);
        make.size.mas_equalTo(CGSizeMake(74, 88));
    }];
    [self.descLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon.mas_bottom).offset(30);
        make.centerX.mas_equalTo(self.scrollView);
        make.height.mas_equalTo(30);
    }];
    [self.phoneNoField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descLab.mas_bottom).offset(48);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.right.mas_equalTo(self.scrollView).offset(-15);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    [self.nextBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneNoField.mas_bottom).offset(38);
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
    self.descLab.textColor = SSJ_MAIN_COLOR;
    [self.phoneNoField updateAppearanceAccordingToTheme];
    [self.nextBtn ssj_setBackgroundColor:SSJ_BUTTON_NORMAL_COLOR forState:UIControlStateNormal];
    [self.nextBtn ssj_setBackgroundColor:SSJ_BUTTON_DISABLE_COLOR forState:UIControlStateDisabled];
}

- (void)setUpViews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.icon];
    [self.scrollView addSubview:self.descLab];
    [self.scrollView addSubview:self.phoneNoField];
    [self.scrollView addSubview:self.nextBtn];
}

- (void)setUpBindings {
    @weakify(self);
    [[self.nextBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.phoneNoField resignFirstResponder];
    }];

    RAC(self.viewModel, phoneNum) = self.phoneNoField.rac_textSignal;
    self.nextBtn.rac_command = self.viewModel.verifyPhoneNumRequestCommand;
    [self.viewModel.verifyPhoneNumRequestCommand.executionSignals.switchToLatest subscribeNext:^(NSNumber *result) {
        @strongify(self);
        if ([result boolValue]) {
            NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"此手机号已经注册过了，换一个吧"}];
            [SSJAlertViewAdapter showError:error completion:^{
                [self.phoneNoField becomeFirstResponder];
            }];
        } else {
            SSJSettingPasswordViewController *pwdSetttingVC = [[SSJSettingPasswordViewController alloc] init];
            pwdSetttingVC.type = SSJSettingPasswordTypeMobileNoBinding;
            pwdSetttingVC.mobileNo = self.phoneNoField.text;
            [self.navigationController pushViewController:pwdSetttingVC animated:YES];
        }
    } error:NULL];
    
    RAC(self.nextBtn, enabled) = self.viewModel.enableVerifySignal;
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
        _icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bind_No_shield"]];
    }
    return _icon;
}

- (UILabel *)descLab {
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        _descLab.text = @"绑定手机，提高账号安全等级";
        _descLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _descLab;
}

- (SSJMobileNoField *)phoneNoField {
    if (!_phoneNoField) {
        _phoneNoField = [[SSJMobileNoField alloc] init];
    }
    return _phoneNoField;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextBtn.clipsToBounds = YES;
        _nextBtn.layer.cornerRadius = 6;
        _nextBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _nextBtn;
}

- (SSJLoginVerifyPhoneNumViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[SSJLoginVerifyPhoneNumViewModel alloc] init];
        _viewModel.agreeProtocol = YES;
    }
    return _viewModel;
}

@end
