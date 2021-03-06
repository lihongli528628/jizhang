//
//  SSJRecordMakingBillTypeInputView.m
//  SuiShouJi
//
//  Created by old lang on 16/5/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingBillTypeInputView.h"
#import "SSJCustomKeyboard.h"

@interface SSJRecordMakingBillTypeInputView ()

@property (nonatomic, strong) UIView *fillColorView;

@property (nonatomic, strong) UILabel *billTypeNameLab;

@property (nonatomic, strong) UITextField *moneyInput;

@end

@implementation SSJRecordMakingBillTypeInputView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.fillColorView];
        [self addSubview:self.billTypeNameLab];
        [self addSubview:self.moneyInput];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    _fillColorView.frame = self.bounds;
    _billTypeNameLab.left = 30;
    _billTypeNameLab.centerY = self.height * 0.5;
    _moneyInput.right = self.width - 30;
    _moneyInput.centerY = self.height * 0.5;
}

- (void)setBillTypeName:(NSString *)billTypeName {
    if (![_billTypeName isEqualToString:billTypeName]) {
        _billTypeName = billTypeName;
        _billTypeNameLab.text = _billTypeName;
        [_billTypeNameLab sizeToFit];
        [self setNeedsLayout];
    }
}

- (void)setFillColor:(UIColor *)fillColor {
    if (!CGColorEqualToColor(_fillColor.CGColor, fillColor.CGColor)) {
        _fillColor = fillColor;
        _fillColorView.backgroundColor = _fillColor;
    }
}

- (UIView *)fillColorView {
    if (!_fillColorView) {
        _fillColorView = [[UIView alloc] init];
        _fillColorView.backgroundColor = [UIColor clearColor];
        _fillColorView.alpha = SSJ_CURRENT_THEME.recordMakingInputViewAlpha;
    }
    return _fillColorView;
}

- (UILabel *)billTypeNameLab {
    if (!_billTypeNameLab) {
        _billTypeNameLab = [[UILabel alloc] init];
        _billTypeNameLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        _billTypeNameLab.textColor = [UIColor whiteColor];
    }
    return _billTypeNameLab;
}

- (UITextField *)moneyInput {
    if (!_moneyInput) {
        _moneyInput = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
        _moneyInput.tintColor = [UIColor whiteColor];
        _moneyInput.inputView = [SSJCustomKeyboard sharedInstance];
//        _moneyInput.keyboardType = UIKeyboardTypeURL;
        _moneyInput.textColor = [UIColor whiteColor];
        _moneyInput.font = [UIFont ssj_pingFangRegularFontOfSize:30];
        _moneyInput.textAlignment = NSTextAlignmentRight;
        _moneyInput.placeholder = @"0.00";
        _moneyInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"0.00" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5]}];
    }
    return _moneyInput;
}

@end
