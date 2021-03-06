//
//  SSJCreditCardDetailHeader.m
//  SuiShouJi
//
//  Created by ricky on 16/8/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCreditCardDetailHeader.h"

@interface SSJCreditCardDetailHeader()

@property (nonatomic,strong) CAGradientLayer *backLayer;

@property(nonatomic, strong) UILabel *balanceTitleLab;

@property(nonatomic, strong) UILabel *balanceLab;

@property(nonatomic, strong) UILabel *limitTitleLab;

@property(nonatomic, strong) UILabel *limitLab;

@property(nonatomic, strong) UILabel *repaymentDayTitleLab;

@property(nonatomic, strong) UILabel *repaymentDayLab;

@property(nonatomic, strong) UILabel *billingDayTitleLab;

@property(nonatomic, strong) UILabel *billingDayLab;

@property(nonatomic, strong) UIView *horizontalSeperatorLine;

@end

@implementation SSJCreditCardDetailHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self.layer addSublayer:self.backLayer];
        [self addSubview:self.backGroundView];
        [self addSubview:self.balanceLab];
        [self addSubview:self.balanceTitleLab];
        [self addSubview:self.horizontalSeperatorLine];
        [self addSubview:self.billingDayTitleLab];
        [self addSubview:self.billingDayLab];
        [self addSubview:self.limitLab];
        [self addSubview:self.limitTitleLab];
        [self addSubview:self.repaymentDayLab];
        [self addSubview:self.repaymentDayTitleLab];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.backGroundView.size = CGSizeMake(self.width, 150);
    self.backGroundView.top = 10;
    self.backGroundView.centerX = self.width / 2;
    self.balanceLab.top = self.backGroundView.top + 20;
    self.balanceLab.centerX = self.width / 2;
    self.balanceTitleLab.top = self.balanceLab.bottom + 10;
    self.balanceTitleLab.centerX = self.width / 2;
    self.horizontalSeperatorLine.top = 90;
    self.horizontalSeperatorLine.centerX = self.width / 2;
    self.billingDayLab.width = self.backLayer.width / 3;
    self.billingDayLab.top = self.horizontalSeperatorLine.top + 12;
    self.billingDayLab.centerX = self.width / 2;
    self.billingDayTitleLab.top = self.billingDayLab.bottom + 10;
    self.billingDayTitleLab.centerX = self.billingDayLab.centerX;
    self.limitLab.width = self.backLayer.width / 3;
    self.limitLab.top = self.horizontalSeperatorLine.bottom + 12;
    self.limitLab.left = self.backLayer.left;
    self.limitTitleLab.top = self.limitLab.bottom + 10;
    self.limitTitleLab.centerX = self.limitLab.centerX;
    self.repaymentDayLab.width = self.backLayer.width / 3;
    self.repaymentDayLab.top = self.horizontalSeperatorLine.bottom + 12;
    self.repaymentDayLab.right = self.backLayer.right;
    self.repaymentDayTitleLab.top = self.repaymentDayLab.bottom + 10;
    self.repaymentDayTitleLab.centerX = self.repaymentDayLab.centerX;
}

-(UILabel *)balanceTitleLab{
    if (!_balanceTitleLab) {
        _balanceTitleLab = [[UILabel alloc]init];
        if (SSJ_CURRENT_THEME.financingDetailSecondaryColor.length) {
            _balanceTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailSecondaryColor alpha:SSJ_CURRENT_THEME.financingDetailSecondaryAlpha];
        } else {
            _balanceTitleLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.5];
        }
        _balanceTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6];
        [_balanceTitleLab sizeToFit];
    }
    return _balanceTitleLab;
}

-(UILabel *)balanceLab{
    if (!_balanceLab) {
        _balanceLab = [[UILabel alloc]init];
        if (SSJ_CURRENT_THEME.financingDetailMainColor.length) {
            _balanceLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailMainColor alpha:SSJ_CURRENT_THEME.financingDetailMainAlpha];
        } else {
            _balanceLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff"];
        }
        _balanceLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
    }
    return _balanceLab;
}

-(UILabel *)limitTitleLab{
    if (!_limitTitleLab) {
        _limitTitleLab = [[UILabel alloc]init];
        if (SSJ_CURRENT_THEME.financingDetailSecondaryColor.length) {
            _limitTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailSecondaryColor alpha:SSJ_CURRENT_THEME.financingDetailSecondaryAlpha];
        } else {
            _limitTitleLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.5];
        }
        _limitTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6];
        _limitTitleLab.text = @"信用额度";
        [_limitTitleLab sizeToFit];
    }
    return _limitTitleLab;
}

-(UILabel *)limitLab{
    if (!_limitLab) {
        _limitLab = [[UILabel alloc]init];
        _limitLab.textAlignment = NSTextAlignmentCenter;
        if (SSJ_CURRENT_THEME.financingDetailMainColor.length) {
            _limitLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailMainColor alpha:SSJ_CURRENT_THEME.financingDetailMainAlpha];
        } else {
            _limitLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff"];
        }
        _limitLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _limitLab;
}

-(UILabel *)repaymentDayTitleLab{
    if (!_repaymentDayTitleLab) {
        _repaymentDayTitleLab = [[UILabel alloc]init];
        if (SSJ_CURRENT_THEME.financingDetailSecondaryColor.length) {
            _repaymentDayTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailSecondaryColor alpha:SSJ_CURRENT_THEME.financingDetailSecondaryAlpha];
        } else {
            _repaymentDayTitleLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.5];
        }
        _repaymentDayTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6];
        _repaymentDayTitleLab.text = @"还款日";
        [_repaymentDayTitleLab sizeToFit];
    }
    return _repaymentDayTitleLab;
}

-(UILabel *)repaymentDayLab{
    if (!_repaymentDayLab) {
        _repaymentDayLab = [[UILabel alloc]init];
        _repaymentDayLab.textAlignment = NSTextAlignmentCenter;
        if (SSJ_CURRENT_THEME.financingDetailMainColor.length) {
            _repaymentDayLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailMainColor alpha:SSJ_CURRENT_THEME.financingDetailMainAlpha];
        } else {
            _repaymentDayLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff"];
        }
        _repaymentDayLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _repaymentDayLab;
}

-(UILabel *)billingDayTitleLab{
    if (!_billingDayTitleLab) {
        _billingDayTitleLab = [[UILabel alloc]init];
        if (SSJ_CURRENT_THEME.financingDetailSecondaryColor.length) {
            _billingDayTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailSecondaryColor alpha:SSJ_CURRENT_THEME.financingDetailSecondaryAlpha];
        } else {
            _billingDayTitleLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.5];
        }
        _billingDayTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6];
        _billingDayTitleLab.text = @"账单日";
        [_billingDayTitleLab sizeToFit];
    }
    return _billingDayTitleLab;
}

-(UILabel *)billingDayLab{
    if (!_billingDayLab) {
        _billingDayLab = [[UILabel alloc]init];
        _billingDayLab.textAlignment = NSTextAlignmentCenter;

        if (SSJ_CURRENT_THEME.financingDetailMainColor.length) {
            _billingDayLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailMainColor alpha:SSJ_CURRENT_THEME.financingDetailMainAlpha];
        } else {
            _billingDayLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff"];
        }
        _billingDayLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _billingDayLab;
}

-(UIView *)horizontalSeperatorLine{
    if (!_horizontalSeperatorLine) {
        _horizontalSeperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 290, 1 / [UIScreen mainScreen].scale)];
        if (SSJ_CURRENT_THEME.financingDetailSecondaryColor.length) {
            _horizontalSeperatorLine.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailSecondaryColor alpha:SSJ_CURRENT_THEME.financingDetailSecondaryAlpha];
        } else {
            _horizontalSeperatorLine.backgroundColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.5];
        }
    }
    return _horizontalSeperatorLine;
}

-(UIView *)backGroundView{
    if (!_backGroundView) {
        _backGroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1 / [UIScreen mainScreen].scale, 40)];
    }
    return _backGroundView;
}

- (CAGradientLayer *)backLayer {
    if (!_backLayer) {
        _backLayer = [CAGradientLayer layer];
        _backLayer.cornerRadius = 8;
        _backLayer.size = CGSizeMake(self.width - 30, 150);
        _backLayer.position = CGPointMake(self.width / 2, 85);
        if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
            _backLayer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, _backLayer.width + 4, _backLayer.height + 4) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)].CGPath;
        }
        _backLayer.startPoint = CGPointMake(0, 0.5);
        _backLayer.endPoint = CGPointMake(1, 0.5);
        _backLayer.shadowRadius = 10;
        _backLayer.shadowOpacity = 0.3;
    }
    return _backLayer;
}

- (void)setItem:(SSJFinancingHomeitem *)item{
    _item = item;
    if (_item.fundingAmount > 0) {
        self.balanceTitleLab.text = @"当前余额";
    }else{
        self.balanceTitleLab.text = @"当前欠款";
    }
    [self.balanceTitleLab sizeToFit];

    self.limitLab.text = [[NSString stringWithFormat:@"%f",_item.cardItem.cardLimit] ssj_moneyDecimalDisplayWithDigits:2];
    [self.limitLab sizeToFit];

    if (_item.cardItem.cardRepaymentDay == 0) {
        self.repaymentDayLab.text = @"未设置";
    }else{
        self.repaymentDayLab.text = [NSString stringWithFormat:@"每月%ld日",(long)_item.cardItem.cardRepaymentDay];
    }

    [self.repaymentDayLab sizeToFit];

    if (_item.cardItem.cardBillingDay == 0) {
        self.billingDayLab.text = @"未设置";
    }else{
        self.billingDayLab.text = [NSString stringWithFormat:@"每月%ld日",(long)_item.cardItem.cardBillingDay];
    }
    [self.billingDayLab sizeToFit];

    self.balanceLab.text = [NSString stringWithFormat:@"%.2f",_item.fundingAmount];
    [self.balanceLab sizeToFit];
    
    if (_item.startColor.length && _item.endColor.length) {
        self.backLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:_item.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:_item.endColor].CGColor];
        self.backLayer.shadowColor = [UIColor ssj_colorWithHex:_item.startColor].CGColor;
    }
}

- (void)updateAfterThemeChange {
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    if (SSJ_CURRENT_THEME.financingDetailSecondaryColor.length) {
        _balanceTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailSecondaryColor alpha:SSJ_CURRENT_THEME.financingDetailSecondaryAlpha];
        _balanceLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailMainColor alpha:SSJ_CURRENT_THEME.financingDetailMainAlpha];
        _limitTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailSecondaryColor alpha:SSJ_CURRENT_THEME.financingDetailSecondaryAlpha];
        _limitLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailMainColor alpha:SSJ_CURRENT_THEME.financingDetailMainAlpha];
        _repaymentDayTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailSecondaryColor alpha:SSJ_CURRENT_THEME.financingDetailSecondaryAlpha];
        _repaymentDayLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailMainColor alpha:SSJ_CURRENT_THEME.financingDetailMainAlpha];
        _billingDayTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailSecondaryColor alpha:SSJ_CURRENT_THEME.financingDetailSecondaryAlpha];
        _billingDayLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailMainColor alpha:SSJ_CURRENT_THEME.financingDetailMainAlpha];
    } else {
        _balanceTitleLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.5];
        _balanceLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff"];
        _limitTitleLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.5];
        _limitLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff"];
        _repaymentDayTitleLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.5];
        _repaymentDayLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff"];
        _billingDayTitleLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.5];
        _billingDayLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff"];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
