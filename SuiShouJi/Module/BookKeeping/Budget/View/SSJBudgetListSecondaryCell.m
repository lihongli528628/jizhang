//
//  SSJBudgetListSecondaryCell.m
//  SuiShouJi
//
//  Created by old lang on 16/9/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetListSecondaryCell.h"
#import "SSJBudgetProgressView.h"

@interface SSJBudgetListSecondaryCell ()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UILabel *billTypeLab;

@property (nonatomic, strong) UILabel *periodLab;

@property (nonatomic, strong) UILabel *expendLab;

@property (nonatomic, strong) UILabel *budgetLab;

@property (nonatomic, strong) SSJBudgetProgressView *progressView;

@end

@implementation SSJBudgetListSecondaryCell

+ (CGFloat)rowHeight {
    return 206;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLab];
        [self.contentView addSubview:self.billTypeLab];
        [self.contentView addSubview:self.periodLab];
        [self.contentView addSubview:self.expendLab];
        [self.contentView addSubview:self.budgetLab];
        [self.contentView addSubview:self.progressView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.titleLab sizeToFit];
    [self.billTypeLab sizeToFit];
    [self.periodLab sizeToFit];
    [self.expendLab sizeToFit];
    [self.budgetLab sizeToFit];
    self.progressView.frame = CGRectMake(20, 0, self.contentView.width - 40, 35);
    
    CGFloat verticalGap = (self.contentView.height - self.titleLab.height - self.billTypeLab.height - self.periodLab.height - self.expendLab.height - self.budgetLab.height - self.progressView.height) / 6;
    
    self.titleLab.top = verticalGap;
    self.titleLab.centerX = self.contentView.width * 0.5;
    
    self.billTypeLab.leftTop = CGPointMake(20, self.titleLab.bottom + verticalGap);
    self.periodLab.leftTop = CGPointMake(20, self.billTypeLab.bottom + verticalGap);
    self.progressView.leftTop = CGPointMake(20, self.periodLab.bottom + verticalGap);
    self.expendLab.leftTop = CGPointMake(20, self.progressView.bottom + verticalGap);
    self.budgetLab.rightTop = CGPointMake(self.contentView.width - 20, self.progressView.bottom + verticalGap);
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    
    self.titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.billTypeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.periodLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.expendLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.budgetLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    [self setNeedsLayout];
    
    SSJBudgetListSecondaryCellItem *item = (SSJBudgetListSecondaryCellItem *)cellItem;
    self.titleLab.text = item.title;
    self.billTypeLab.text = item.billTypeName;
    self.periodLab.text = item.period;
    self.expendLab.attributedText = item.expend;
    self.budgetLab.attributedText = item.budget;
    self.progressView.expend = item.expendValue;
    self.progressView.budget = item.budgetValue;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:18];
    }
    return _titleLab;
}

- (UILabel *)billTypeLab {
    if (!_billTypeLab) {
        _billTypeLab = [[UILabel alloc] init];
        _billTypeLab.font = [UIFont systemFontOfSize:18];
    }
    return _billTypeLab;
}

- (UILabel *)periodLab {
    if (!_periodLab) {
        _periodLab = [[UILabel alloc] init];
        _periodLab.font = [UIFont systemFontOfSize:13];
    }
    return _periodLab;
}

- (UILabel *)expendLab {
    if (!_expendLab) {
        _expendLab = [[UILabel alloc] init];
        _expendLab.font = [UIFont systemFontOfSize:13];
    }
    return _expendLab;
}

- (UILabel *)budgetLab {
    if (!_budgetLab) {
        _budgetLab = [[UILabel alloc] init];
        _budgetLab.font = [UIFont systemFontOfSize:13];
    }
    return _budgetLab;
}

@end