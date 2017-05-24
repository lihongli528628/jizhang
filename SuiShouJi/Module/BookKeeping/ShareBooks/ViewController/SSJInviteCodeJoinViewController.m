
//
//  SSJInviteCodeJoinViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJInviteCodeJoinViewController.h"
#import "UIViewController+MMDrawerController.h"

@interface SSJInviteCodeJoinViewController ()

@property(nonatomic, strong) UIView *backView;

@property(nonatomic, strong) UITextField *codeInput;

@property(nonatomic, strong) UILabel *customCodeLab;

@property(nonatomic, strong) UIButton *sendButton;


@end

@implementation SSJInviteCodeJoinViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"暗号加入";
        self.appliesTheme = NO;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundView.image = [UIImage ssj_compatibleImageNamed:@"sharebk_backgroud"];
    [self.view addSubview:self.backView];
    [self.backView addSubview:self.codeInput];
    [self.backView addSubview:self.customCodeLab];
    [self.view addSubview:self.sendButton];
    [self.mm_drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
    
    [self.view setNeedsUpdateConstraints];

    // Do any additional setup after loading the view.
}

- (void)updateViewConstraints {
    
    [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(200);
        make.width.mas_equalTo(self.view.mas_width).offset(-35);
        make.top.mas_equalTo(SSJ_NAVIBAR_BOTTOM + 30);
        make.centerX.mas_equalTo(self.view);
    }];
    
    [self.codeInput mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.backView.mas_width).offset(-44);
        make.height.mas_equalTo(57);
        make.centerX.mas_equalTo(self.backView.mas_centerX);
        make.top.mas_equalTo(self.backView).offset(36);
    }];
    
    [self.customCodeLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.codeInput.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.codeInput);
    }];
    
    [self.sendButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(224, 46));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.backView.mas_bottom);
    }];
    

    [super updateViewConstraints];
}

#pragma mark - Getter
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.layer.cornerRadius = 16.f;
        _backView.layer.shadowOffset = CGSizeMake(0, 2);
        _backView.layer.shadowColor = [UIColor ssj_colorWithHex:@"#000000"].CGColor;
        _backView.layer.shadowOpacity = 0.15;
    }
    return _backView;
}

- (UITextField *)codeInput {
    if (!_codeInput) {
        _codeInput = [[UITextField alloc] init];
        _codeInput.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _codeInput.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _codeInput.textAlignment = NSTextAlignmentCenter;
        [_codeInput ssj_setBorderColor:[UIColor ssj_colorWithHex:@"#DDDDDD"]];
        [_codeInput ssj_setBorderStyle:SSJBorderStyleBottom];
        [_codeInput ssj_setBorderWidth:1.f];
        _codeInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入六位暗号" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"#CCCCCC"]}];
        _codeInput.rightViewMode = UITextFieldViewModeAlways;
        _codeInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        _codeInput.tintColor = [UIColor ssj_colorWithHex:@"#333333"];
        @weakify(self);
        [_codeInput.rac_textSignal subscribeNext:^(id x) {
            @strongify(self);
            if (self.codeInput.text.length == 0) {
                self.sendButton.backgroundColor = [UIColor ssj_colorWithHex:@"#CCCCCC"];
                self.sendButton.layer.shadowColor = [UIColor blackColor].CGColor;
                self.sendButton.layer.shadowOpacity = 0.15;
                
            } else {
                self.sendButton.backgroundColor = [UIColor ssj_colorWithHex:@"#EB4A64"];
                self.sendButton.layer.shadowColor = [UIColor ssj_colorWithHex:@"#EB4A64"].CGColor;
                self.sendButton.layer.shadowOpacity = 0.39;
            }
        }];
    }
    return _codeInput;
}

- (UILabel *)customCodeLab {
    if (!_customCodeLab) {
        _customCodeLab = [[UILabel alloc] init];
        _customCodeLab.textColor = [UIColor ssj_colorWithHex:@"#999999"];
        _customCodeLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _customCodeLab.text = @"对上暗号，即可加入";
        [_customCodeLab sizeToFit];
    }
    return _customCodeLab;
}

- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _sendButton.layer.cornerRadius = 23.f;
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendButton setTitle:@"发送暗号" forState:UIControlStateNormal];
        _sendButton.backgroundColor = [UIColor ssj_colorWithHex:@"#EB4A64"];
        _sendButton.layer.shadowOffset = CGSizeMake(0, 4);
        [_sendButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

#pragma mark - Event
- (void)sendButtonClicked:(id)sender {

    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
