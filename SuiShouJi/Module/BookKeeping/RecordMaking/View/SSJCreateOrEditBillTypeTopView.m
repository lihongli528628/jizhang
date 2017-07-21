//
//  SSJCreateOrEditBillTypeTopView.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCreateOrEditBillTypeTopView.h"

@interface _SSJCreateOrEditBillTypeTopViewColorControl : UIControl

@property (nonatomic, strong) UIView *colorView;

@property (nonatomic, strong) UIImageView *arrowView;

@property (nonatomic) BOOL isArrowDown;

@end

@implementation _SSJCreateOrEditBillTypeTopViewColorControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.colorView];
        [self addSubview:self.arrowView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    }
    return self;
}

- (void)updateConstraints {
    [self.colorView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(15);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(26, 13));
    }];
    [self.arrowView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.colorView.mas_right).offset(10);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(7, 7));
        make.right.mas_equalTo(self.mas_right).offset(-10);
    }];
    [super updateConstraints];
}

- (void)tapAction {
    _isArrowDown = !_isArrowDown;
    [UIView animateWithDuration:0.25 animations:^{
        self.arrowView.transform = CGAffineTransformMakeRotation(_isArrowDown ? M_PI : 0);
    }];
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (UIView *)colorView {
    if (!_colorView) {
        _colorView = [[UIView alloc] init];
        _colorView.clipsToBounds = YES;
        _colorView.layer.cornerRadius = 4;
    }
    return _colorView;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loan_arrow"]];
        _arrowView.transform = CGAffineTransformMakeRotation(M_PI);
    }
    return _arrowView;
}

@end

@interface SSJCreateOrEditBillTypeTopView ()

@property (nonatomic, strong) _SSJCreateOrEditBillTypeTopViewColorControl *colorControl;

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UITextField *nameField;

@end

@implementation SSJCreateOrEditBillTypeTopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.colorControl];
        [self addSubview:self.iconView];
        [self addSubview:self.nameField];
    }
    return self;
}

- (void)updateConstraints {
    [self.colorControl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.bottom.mas_equalTo(0);
    }];
    [self.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.colorControl.mas_right).offset(20);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(self.iconView.image.size);
    }];
    [self.nameField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconView.mas_right).offset(20);
        make.right.mas_equalTo(self).offset(-10);
        make.top.and.bottom.mas_equalTo(self);
    }];
    [super updateConstraints];
}

- (_SSJCreateOrEditBillTypeTopViewColorControl *)colorControl {
    if (!_colorControl) {
        _colorControl = [[_SSJCreateOrEditBillTypeTopViewColorControl alloc] init];
        [_colorControl ssj_setBorderStyle:SSJBorderStyleRight];
        [_colorControl ssj_setBorderInsets:UIEdgeInsetsMake(20, 0, 20, 0)];
        @weakify(self);
        [[_colorControl rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.tapColorAction) {
                self.tapColorAction();
            }
        }];
    }
    return _colorControl;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
    }
    return _iconView;
}

- (UITextField *)nameField {
    if (!_nameField) {
        _nameField = [[UITextField alloc] init];
        _nameField.textAlignment = NSTextAlignmentRight;
        _nameField.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _nameField;
}

- (void)updateAppearanceAccordingToTheme {
    [self.colorControl ssj_setBorderColor:SSJ_BORDER_COLOR];
}

@end
