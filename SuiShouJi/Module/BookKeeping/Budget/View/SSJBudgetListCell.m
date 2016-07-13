//
//  SSJBudgetListCell.m
//  SuiShouJi
//
//  Created by old lang on 16/2/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetListCell.h"
#import "SSJBudgetWaveWaterView.h"

@interface SSJBudgetListCell ()

//  预算周期类型
@property (nonatomic, strong) UILabel *typeLab;

//  开始时间
@property (nonatomic, strong) UILabel *beginDateLab;

//  已花金额
@property (nonatomic, strong) UILabel *paymentLab;

//  计划金额
@property (nonatomic, strong) UILabel *budgetLab;

//  百分比波浪进度
@property (nonatomic, strong) SSJBudgetWaveWaterView *waveView;

@end

@implementation SSJBudgetListCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
    return 165;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.typeLab];
        [self.contentView addSubview:self.beginDateLab];
        [self.contentView addSubview:self.paymentLab];
        [self.contentView addSubview:self.budgetLab];
        [self.contentView addSubview:self.waveView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.typeLab.leftTop = CGPointMake(10, 18);
    self.beginDateLab.rightTop = CGPointMake(self.contentView.width - 10, 18);
    self.paymentLab.leftBottom = CGPointMake(10, self.contentView.height - 15);
    self.budgetLab.rightBottom = CGPointMake(self.contentView.width - 10, self.contentView.height - 15);
    self.waveView.center = CGPointMake(self.contentView.width * 0.5, self.contentView.height * 0.56);
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJBudgetListCellItem class]]) {
        return;
    }
    
    SSJBudgetListCellItem *item = (SSJBudgetListCellItem *)cellItem;
    self.typeLab.text = item.typeName;
    [self.typeLab sizeToFit];
    
    self.beginDateLab.text = [NSString stringWithFormat:@"开始时间：%@",item.beginDate];
    [self.beginDateLab sizeToFit];
    
    UIColor *paymentColor = item.payment > item.budget ? [UIColor redColor] : [UIColor ssj_colorWithHex:@"eb4a64"];
    NSMutableAttributedString *paymentStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已花：%.2f", item.payment]];
    [paymentStr setAttributes:@{NSForegroundColorAttributeName:paymentColor} range:NSMakeRange(3, paymentStr.length - 3)];
    self.paymentLab.attributedText = paymentStr;
    [self.paymentLab sizeToFit];
    
    self.budgetLab.text = [NSString stringWithFormat:@"计划：%.2f", item.budget];
    [self.budgetLab sizeToFit];
    
    self.waveView.percent = (item.payment / item.budget);
    self.waveView.money = item.budget - item.payment;
}

- (UILabel *)typeLab {
    if (!_typeLab) {
        _typeLab = [[UILabel alloc] init];
        _typeLab.backgroundColor = [UIColor clearColor];
        _typeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _typeLab.font = [UIFont systemFontOfSize:14];
    }
    return _typeLab;
}

- (UILabel *)beginDateLab {
    if (!_beginDateLab) {
        _beginDateLab = [[UILabel alloc] init];
        _beginDateLab.backgroundColor = [UIColor clearColor];
        _beginDateLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _beginDateLab.font = [UIFont systemFontOfSize:12];
    }
    return _beginDateLab;
}

- (UILabel *)paymentLab {
    if (!_paymentLab) {
        _paymentLab = [[UILabel alloc] init];
        _paymentLab.backgroundColor = [UIColor clearColor];
        _paymentLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _paymentLab.font = [UIFont systemFontOfSize:14];
    }
    return _paymentLab;
}

- (UILabel *)budgetLab {
    if (!_budgetLab) {
        _budgetLab = [[UILabel alloc] init];
        _budgetLab.backgroundColor = [UIColor clearColor];
        _budgetLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _budgetLab.font = [UIFont systemFontOfSize:14];
    }
    return _budgetLab;
}

- (SSJBudgetWaveWaterView *)waveView {
    if (!_waveView) {
        _waveView = [[SSJBudgetWaveWaterView alloc] initWithRadius:90];
        _waveView.waveAmplitude = 6;
        _waveView.waveSpeed = 4;
        _waveView.waveCycle = 1;
        _waveView.waveGrowth = 2;
        _waveView.waveOffset = 40;
        _waveView.fullWaveAmplitude = 5;
        _waveView.fullWaveSpeed = 3;
        _waveView.fullWaveCycle = 4;
        _waveView.outerBorderWidth = 5;
        _waveView.showText = YES;
    }
    return _waveView;
}

@end
