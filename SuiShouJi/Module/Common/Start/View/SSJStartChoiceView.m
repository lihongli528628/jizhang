//
//  SSJStartChoiceView.m
//  SuiShouJi
//
//  Created by 赵天立 on 2017/9/10.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJStartChoiceView.h"

@interface SSJStartChoiceView()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIImageView *olderImage;

@property (nonatomic, strong) UIImageView *newerImage;

@property (nonatomic, strong) UILabel *newerLab;

@property (nonatomic, strong) UILabel *olderLab;

@end

@implementation SSJStartChoiceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLab];
        [self addSubview:self.olderImage];
        [self addSubview:self.newerImage];
        [self addSubview:self.olderLab];
        [self addSubview:self.newerLab];
    }
    return self;
}

- (void)updateConstraints {
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self).offset(160);
    }];
    
    [self.newerImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLab).offset(85);
        make.right.mas_equalTo(self.mas_centerX).offset(-12.5);
    }];
    
    [self.olderImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLab).offset(85);
        make.right.mas_equalTo(self.mas_centerX).offset(12.5);
    }];
    
    [self.newerLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.newerImage).offset(25);
        make.centerX.mas_equalTo(self.newerImage.mas_centerX);
    }];
    
    [self.olderLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.olderImage).offset(25);
        make.centerX.mas_equalTo(self.olderImage.mas_centerX);
    }];
    
    [super updateConstraints];
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _titleLab.text = @"小鱼儿询问下,你属于哪类记账者?";
    }
    return _titleLab;
}

- (UILabel *)newerLab {
    if (!_newerLab) {
        _newerLab = [[UILabel alloc] init];
        _newerLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _newerLab.text = @"新手小白";
    }
    return _newerLab;
}

- (UILabel *)olderLab {
    if (!_olderLab) {
        _olderLab = [[UILabel alloc] init];
        _olderLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _olderLab.text = @"记账老司机";
    }
    return _olderLab;
}

- (UIImageView *)newerImage {
    if (!_newerImage) {
        _newerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"neweruserimage"]];
    }
    return _newerImage;
}

- (UIImageView *)olderImage {
    if (!_olderImage) {
        _olderImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"olderuserimage"]];
    }
    return _olderImage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
