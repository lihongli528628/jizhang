//
//  SSJBookKeepingHomeBar.m
//  SuiShouJi
//
//  Created by ricky on 16/10/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeBar.h"
#import "FLAnimatedImage.h"

@interface SSJBookKeepingHomeBar()

@property (nonatomic,strong) UILabel *statusLab;

@end


@implementation SSJBookKeepingHomeBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.leftButton];
        [self addSubview:self.rightBarButton];
        [self addSubview:self.budgetButton];
        [self addSubview:self.loadingView];
        [self addSubview:self.statusLab];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.budgetButton.centerX = self.width / 2;
    self.budgetButton.bottom = self.height;
    self.leftButton.left = 10;
    self.leftButton.centerY = 10 + self.height / 2;
    self.rightBarButton.right = self.width - 10;
    self.rightBarButton.centerY = 10 + self.height / 2;
    self.loadingView.centerX = self.statusLab.centerX = self.width / 2;
    self.loadingView.top = self.budgetButton.bottom + 5;
    self.statusLab.top = self.loadingView.bottom + 5;
}

- (SSJHomeBudgetButton *)budgetButton{
    if (!_budgetButton) {
        _budgetButton = [[SSJHomeBudgetButton alloc]initWithFrame:CGRectMake(0, 0, 200, 46)];
    }
    return _budgetButton;
}

- (SSJBookKeepingHomeBooksButton *)leftButton{
    if (!_leftButton) {
        _leftButton = [[SSJBookKeepingHomeBooksButton alloc]initWithFrame:CGRectMake(0, 0, 30, 32)];
    }
    return _leftButton;
}

- (SSJHomeBarCalenderButton*)rightBarButton{
    if (!_rightBarButton) {
        _rightBarButton = [[SSJHomeBarCalenderButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
        //        buttonView.layer.borderColor = [UIColor redColor].CGColor;
        //        buttonView.layer.borderWidth = 1;
    }
    return _rightBarButton;
}
    
- (FLAnimatedImageView *)loadingView{
    if (!_loadingView) {
        _loadingView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, 57, 25)];
        NSData *gifData;
        if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
            gifData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"homeDefualtLoading" ofType:@"gif"]];
        } else {
            gifData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"homeLoading" ofType:@"gif"]];
            
        }
        _loadingView.hidden = YES;
        _loadingView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:gifData];
    }
    return _loadingView;
}

- (UILabel *)statusLab {
    if (!_statusLab) {
        _statusLab = [[UILabel alloc] init];
        _statusLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _statusLab.font = [UIFont systemFontOfSize:13];
        _statusLab.text  = @"数据加载中";
        [_statusLab sizeToFit];
        _statusLab.hidden = YES;
    }
    return _statusLab;
}

- (void)updateAfterThemeChange {
    [self.rightBarButton updateAfterThemeChange];
    [self.budgetButton updateAfterThemeChange];
    self.statusLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

- (void)setIsAnimating:(BOOL)isAnimating {
    _isAnimating = isAnimating;
    self.statusLab.hidden = self.loadingView.hidden = !_isAnimating;
    [self setNeedsLayout];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
