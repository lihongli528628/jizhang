//
//  SSJAccountMergeViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/8/4.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAccountMergeViewController.h"
#import "SSJAccountMergeManager.h"

@interface SSJAccountMergeViewController ()

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UILabel *startLab;

@property (nonatomic, strong) UILabel *endLab;

@property (nonatomic, strong) UIButton *startButton;

@property (nonatomic, strong) UIButton *endButton;

@property (nonatomic, strong) UILabel *mergeTitleLab;

@property (nonatomic, strong) UILabel *hintLab;

@property (nonatomic, strong) UIImageView *warningImage;

@property (nonatomic,strong) UIButton *mergeButton;

@property (nonatomic,strong) SSJAccountMergeManager *manager;

@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, strong) NSDate *endDate;

@end

@implementation SSJAccountMergeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"数据合并";
    [self.view addSubview:self.backView];
    [self.view addSubview:self.startLab];
    [self.view addSubview:self.endLab];
    [self.view addSubview:self.startButton];
    [self.view addSubview:self.endButton];
    [self.view addSubview:self.mergeTitleLab];
    [self.view addSubview:self.warningImage];
    [self.view addSubview:self.mergeButton];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getStartAndEndDate];
}

- (void)updateViewConstraints {
    [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(SSJ_NAVIBAR_BOTTOM);
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(180);
    }];
    
    [self.startLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view).dividedBy(2);
        make.top.mas_equalTo(self.mergeTitleLab.mas_bottom).offset(30);
    }];
    
    [self.endLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view).multipliedBy(1.5);
        make.top.mas_equalTo(self.mergeTitleLab.mas_bottom).offset(30);
    }];
    
    [self.startButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.startLab);
        make.top.mas_equalTo(self.startLab.mas_bottom).offset(15);
    }];
    
    [self.endButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.endLab);
        make.top.mas_equalTo(self.endLab.mas_bottom).offset(15);
    }];
    
    [self.mergeTitleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.backView.mas_top).offset(30);
    }];
    
    [self.warningImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.backView.mas_bottom).offset(11);
        make.left.mas_equalTo(15);
    }];
    
    [self.mergeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.backView.mas_bottom).offset(136);
        make.width.mas_equalTo(self.view).offset(-30);
        make.height.mas_equalTo(44);
    }];
    
    [super updateViewConstraints];
}


#pragma mark - Getter
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return _backView;
}

- (UILabel *)startLab {
    if (!_startLab) {
        _startLab = [[UILabel alloc] init];
        _startLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _startLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _startLab.text = @"起始时间";
    }
    return _startLab;
}

- (UILabel *)endLab {
    if (!_endLab) {
        _endLab = [[UILabel alloc] init];
        _endLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _endLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _endLab.text = @"截止时间";
    }
    return _endLab;
}

- (UIButton *)startButton {
    if (!_startButton) {
        _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _startButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        [_startButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
        [_startButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor]];
        [_startButton ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return _startButton;
}

- (UIButton *)endButton {
    if (!_endButton) {
        _endButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _endButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        [_endButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
        [_endButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor]];
        [_endButton ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return _endButton;
}

- (UILabel *)mergeTitleLab {
    if (!_mergeTitleLab) {
        _mergeTitleLab = [[UILabel alloc] init];
        _mergeTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _mergeTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _mergeTitleLab.text = @"将未登录账户上的数据合并到当前账户上";
    }
    return _mergeTitleLab;
}

- (UIButton *)mergeButton {
    if (!_mergeButton) {
        _mergeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _mergeButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_mergeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _mergeButton.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        [_mergeButton setTitle:@"合并数据" forState:UIControlStateNormal];
        _mergeButton.layer.cornerRadius = 6.f;
    }
    return _mergeButton;
}


- (UIImageView *)warningImage {
    if (!_warningImage) {
        _warningImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
    }
    return _warningImage;
}

- (SSJAccountMergeManager *)manager {
    if (!_manager) {
        _manager = [[SSJAccountMergeManager alloc] init];
    }
    return _manager;
}

#pragma mark - Private
- (void)getStartAndEndDate {
    NSDictionary *dateDic = [self.manager getStartAndEndChargeDataForUnloggedUser];
    
    if (![dateDic objectForKey:@"maxDate"] && ![dateDic objectForKey:@"minDate"]) {
        [CDAutoHideMessageHUD showMessage:@"未登录账户上还没有流水,不用合并啦"];
    }
    
    NSString *startDateStr = [dateDic objectForKey:@"minDate"];
    
    NSString *endDateStr = [dateDic objectForKey:@"maxDate"];
    
    NSDate *startDate = [NSDate dateWithString:startDateStr formatString:@"yyyy-MM-dd"];
    
    NSDate *endDate = [NSDate dateWithString:endDateStr formatString:@"yyyy-MM-dd"];
    
    self.startDate = startDate;
    self.endDate = endDate;
    
    [self.startButton setTitle:startDateStr forState:UIControlStateNormal];
    [self.endButton setTitle:endDateStr forState:UIControlStateNormal];
    
    [self.view setNeedsUpdateConstraints];
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