//
//  SSJMultiFunctionButton.m
//  SuiShouJi
//
//  Created by ricky on 16/9/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMultiFunctionButtonView.h"

static const CGFloat kButtonWidth = 36.0;

static const CGFloat kButtonGap = 15.0;

@interface SSJMultiFunctionButtonView()

@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation SSJMultiFunctionButtonView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _buttons = [[NSMutableArray alloc] init];
        self.mainButtonIndex = 0;
        self.buttonStatus = NO;
        [self sizeToFit];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (CGSize)sizeThatFits:(CGSize)size{
    if (!self.buttonStatus) {
        return CGSizeMake(kButtonWidth, kButtonWidth);
    }else{
        return CGSizeMake(kButtonWidth, _buttons.count*kButtonWidth + (_buttons.count - 1)*kButtonGap);
    }
}

- (void)showOnView:(UIView *)view{
    
    if (self.superview) {
        return;
    }
    
    [view addSubview:self];
    self.leftBottom = CGPointMake(20, view.height - 84);
    self.alpha = 0;
    self.size = CGSizeMake(kButtonWidth, kButtonWidth);
    self.buttonStatus = YES;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.alpha = 1;
                     }
                     completion:^(BOOL complation) {
                         if (_showBlock) {
                             _showBlock();
                         }
                         [self sizeToFit];
                     }];
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    self.buttonStatus = NO;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.alpha = 0;
                     }
                     completion:^(BOOL complation) {
                         [self removeFromSuperview];
                         if (_dismissBlock) {
                             _dismissBlock();
                         }
                     }];
}

- (void)setButtonStatus:(BOOL)buttonStatus{
    _buttonStatus = buttonStatus;
    if (_buttonStatus) {
        [self sizeToFit];
        self.leftBottom = CGPointMake(20, SSJSCREENHEIGHT - 84);
        for (UIButton *button in _buttons) {
            button.leftBottom = CGPointMake(0, self.height);
        }
        for (int i = 0; i < _buttons.count; i ++) {
            UIButton *button = [_buttons ssj_safeObjectAtIndex:i];
            if (i == _mainButtonIndex) {
                button.selected = NO;
            }else{
                button.hidden = NO;
            }
            [UIView animateWithDuration:0.3
                             animations:^{
                                 if (i == _mainButtonIndex) {
                                     button.layer.transform = CATransform3DMakeRotation(-M_PI_4, 0, 0, 1);
                                     button.backgroundColor = self.mainButtonSelectedColor;
                                 }else{
                                     button.bottom = self.height - (i - _mainButtonIndex)*(kButtonWidth + kButtonGap);
                                 }
                             }
                             completion:^(BOOL complation) {
                             }];
        }
    }else{
        for (int i = 0; i < _buttons.count; i ++) {
            UIButton *button = [_buttons ssj_safeObjectAtIndex:i];
            if (i == _mainButtonIndex) {
                [self bringSubviewToFront:button];
            }
            [UIView animateWithDuration:0.3
                             animations:^{
                                 if (i == _mainButtonIndex) {
                                     button.layer.transform = CATransform3DIdentity;
                                     button.backgroundColor = self.mainButtonNormalColor;
                                 }else{
                                     button.bottom = self.height;
                                 }
                             }
                             completion:^(BOOL complation) {
                                 self.leftBottom = CGPointMake(20, SSJSCREENHEIGHT - 84);
                                 [self sizeToFit];
                                 button.frame = CGRectMake(0, 0, kButtonWidth, kButtonWidth);
                                 if (i != _mainButtonIndex) {
                                     button.hidden = YES;
                                 }else{
                                     button.hidden = NO;
                                 }
                             }];
        }
    }
}

- (void)setButtonBackColor:(UIColor *)color forControlState:(UIControlState)state atIndex:(NSInteger)index{
    UIButton *button = [_buttons ssj_safeObjectAtIndex:index];
    
    if (state == UIControlStateNormal) {
        [button ssj_setBackgroundColor:color forState:UIControlStateNormal];
    } else if (state == UIControlStateSelected) {
        [button ssj_setBackgroundColor:color forState:UIControlStateSelected];
        [button ssj_setBackgroundColor:color forState:(UIControlStateHighlighted | UIControlStateSelected)];
    }
}

- (void)setMainButtonIndex:(NSInteger)mainButtonIndex{
    if (_mainButtonIndex != mainButtonIndex) {
        _mainButtonIndex = mainButtonIndex;
        [self reload];
        [self setNeedsLayout];
    }
}

- (void)setMainButtonNormalColor:(UIColor *)mainButtonNormalColor{
    _mainButtonNormalColor = mainButtonNormalColor;
    for (UIButton *button in _buttons) {
        if (![button isKindOfClass:[UIButton class]]) {
            continue;
        }
        NSInteger buttonIndex = [_buttons indexOfObject:button];
        if (buttonIndex == _mainButtonIndex) {
            button.backgroundColor = _mainButtonNormalColor;
        }
    }
}

- (void)setSecondaryButtonNormalColor:(UIColor *)secondaryButtonNormalColor{
    _secondaryButtonNormalColor = secondaryButtonNormalColor;
    for (UIButton *button in _buttons) {
        if (![button isKindOfClass:[UIButton class]]) {
            continue;
        }
        NSInteger buttonIndex = [_buttons indexOfObject:button];
        if (buttonIndex != _mainButtonIndex) {
            button.backgroundColor = _secondaryButtonNormalColor;
        }
    }
}

- (void)setImages:(NSArray *)images{
    if (![_images isEqualToArray:images]) {
        _images = images;
        [self reload];
        [self setNeedsLayout];
    }
}

- (void)reload {
    [_buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_buttons removeAllObjects];
    
    for (int idx = 0; idx < _images.count; idx ++) {
        NSString *image = _images[idx];
        if (![image isKindOfClass:[NSString class]]) {
            continue;
        }
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.size = CGSizeMake(kButtonWidth, kButtonWidth);
        if (idx == _mainButtonIndex) {
            button.backgroundColor = self.mainButtonNormalColor;
            button.hidden = NO;
        }else{
            button.backgroundColor = self.secondaryButtonNormalColor;
            button.hidden = YES;
        }
        button.layer.shadowColor = [UIColor ssj_colorWithHex:@"#6c6c6c"].CGColor;
        button.layer.shadowOpacity = 0.5;
        button.layer.cornerRadius = kButtonWidth / 2;
        button.layer.shadowOffset = CGSizeMake(0, 5);
        [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(p_titleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_buttons addObject:button];
        [self addSubview:button];
    }
}


- (void)p_titleButtonAction:(UIButton *)button {
    if ([_buttons containsObject:button]) {
        NSUInteger selectedIndex = [_buttons indexOfObject:button];
        if (selectedIndex == _mainButtonIndex) {
            self.buttonStatus = !self.buttonStatus;
            if (self.buttonStatus) {
                [SSJAnaliyticsManager event:@"main_float_collapsed"];
            }else{
                [SSJAnaliyticsManager event:@"main_float_expand"];
            }
        }
        if (_customDelegate && [_customDelegate respondsToSelector:@selector(multiFunctionButtonView:willSelectButtonAtIndex:)]) {
            [_customDelegate multiFunctionButtonView:self willSelectButtonAtIndex:selectedIndex];
        }
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
