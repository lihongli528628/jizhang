//
//  SSJNewMineHomeTabelviewCell.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJNewMineHomeTabelviewCell.h"

@interface SSJNewMineHomeTabelviewCell()

@property (nonatomic,strong) UILabel *titleLab;

@property(nonatomic, strong) UIImageView *cellImageView;

@end

@implementation SSJNewMineHomeTabelviewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.cellImageView];
        
        [self.contentView addSubview:self.titleLab];

        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)updateConstraints {
    
    [self.cellImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(44);
        make.centerY.mas_equalTo(self.cellImageView);
    }];
    
    [super updateConstraints];
}

-(UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc]init];
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _titleLab;
}

-(UIImageView *)cellImageView{
    if (!_cellImageView) {
        _cellImageView = [[UIImageView alloc]init];
    }
    return _cellImageView;
}


- (void)setItem:(SSJMineHomeTableViewItem *)item {
    
    _item = item;
    
    self.titleLab.text = item.title;
    
    if ([item.image hasPrefix:@"http"]) {
//        [self.cellImageView sd_setImageWithURL:[NSURL URLWithString:item.image]];
    } else {
        self.cellImageView.image = [UIImage imageNamed:item.image];
    }
    
    
    [self updateConstraintsIfNeeded];
}

- (void)updateCellAppearanceAfterThemeChanged{
    [super updateCellAppearanceAfterThemeChanged];
    self.titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
}


@end