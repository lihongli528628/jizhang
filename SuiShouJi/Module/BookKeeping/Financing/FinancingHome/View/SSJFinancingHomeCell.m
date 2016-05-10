//
//  SSJFinancingHomeCollectionViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomeCell.h"

@interface SSJFinancingHomeCell()
@property(nonatomic, strong) UILabel *fundingNameLabel;
@property(nonatomic, strong) UILabel *fundingMemoLabel;
@property(nonatomic, strong) UIView *backView;
@property(nonatomic, strong) UIButton *deleteButton;
@end

@implementation SSJFinancingHomeCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 8.f;
        [self.contentView addSubview:self.deleteButton];
        [self.contentView addSubview:self.fundingBalanceLabel];
        [self.contentView addSubview:self.fundingNameLabel];
        [self.contentView addSubview:self.fundingMemoLabel];
    }
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    self.deleteButton.size = CGSizeMake(30, 30);
    self.deleteButton.center = CGPointMake(self.width - 10, 5 );
    if (!_item.fundingMemo.length) {
        self.fundingNameLabel.left = 25;
        self.fundingNameLabel.centerY = self.contentView.height / 2;
    }else{
        self.fundingNameLabel.bottom = self.contentView.height / 2 - 3;
        self.fundingNameLabel.left = 25;
        self.fundingMemoLabel.top = self.contentView.height / 2 + 3;
        self.fundingMemoLabel.left = 25;
    }
    self.fundingBalanceLabel.centerY = self.contentView.height / 2;
    self.fundingBalanceLabel.right = self.contentView.width - 10;
}

-(UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]init];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.layer.borderWidth = 1;
        _backView.layer.cornerRadius = 2;
    }
    return _backView;
}

-(UILabel *)fundingNameLabel{
    if (!_fundingNameLabel) {
        _fundingNameLabel = [[UILabel alloc]init];
        _fundingNameLabel.textColor = [UIColor whiteColor];
        _fundingNameLabel.font = [UIFont systemFontOfSize:18];
    }
    return _fundingNameLabel;
}

-(UILabel *)fundingBalanceLabel{
    if (!_fundingBalanceLabel) {
        _fundingBalanceLabel = [[UILabel alloc]init];
        _fundingBalanceLabel.textColor = [UIColor whiteColor];
        _fundingBalanceLabel.font = [UIFont systemFontOfSize:22];
    }
    return _fundingBalanceLabel;
}

-(UILabel *)fundingMemoLabel{
    if (!_fundingMemoLabel) {
        _fundingMemoLabel = [[UILabel alloc]init];
        _fundingMemoLabel.textColor = [UIColor whiteColor];
        _fundingMemoLabel.font = [UIFont systemFontOfSize:13];
    }
    return _fundingMemoLabel;
}

-(UIButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc]init];
        [_deleteButton setImage:[UIImage imageNamed:@"ft_delete"] forState:UIControlStateNormal];
    }
    return _deleteButton;
}

-(void)setItem:(SSJFinancingHomeitem *)item{
    _item = item;
    self.backgroundColor = [UIColor ssj_colorWithHex:_item.fundingColor];
    self.fundingNameLabel.text = _item.fundingName;
    [self.fundingNameLabel sizeToFit];
    if (item.isAddOrNot == NO) {
        self.fundingBalanceLabel.hidden = NO;
        self.fundingBalanceLabel.text = [NSString stringWithFormat:@"%.2f",_item.fundingAmount];
        [self.fundingBalanceLabel sizeToFit];
    }else{
        self.fundingBalanceLabel.hidden = YES;
    }
    self.fundingMemoLabel.text = _item.fundingMemo;
    [self.fundingMemoLabel sizeToFit];
    [self setNeedsLayout];
}

@end
