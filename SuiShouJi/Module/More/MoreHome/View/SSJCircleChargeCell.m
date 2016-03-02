//
//  SSJCircleChargeCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCircleChargeCell.h"
@interface SSJCircleChargeCell()
@property (nonatomic,strong) UIImageView *categoryImage;
@property (nonatomic,strong) UILabel *categoryLabel;
@property (nonatomic,strong) UIImageView *circleImage;
@property (nonatomic,strong) UILabel *moneyLabel;
@property (nonatomic,strong) UILabel *circleLabel;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UISwitch *switchButton;
@property (nonatomic,strong) UIView *seperatorView;
@end
@implementation SSJCircleChargeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.categoryImage];
        [self.contentView addSubview:self.seperatorView];
        [self.contentView addSubview:self.categoryLabel];
        [self.contentView addSubview:self.moneyLabel];
        [self.contentView addSubview:self.circleImage];
        [self.contentView addSubview:self.circleLabel];
        [self.contentView addSubview:self.switchButton];
        [self.contentView addSubview:self.timeLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.categoryImage.size = CGSizeMake(46, 46);
    self.categoryImage.bottom = self.contentView.height / 2;
    self.categoryImage.left = 10;
    self.seperatorView.size = CGSizeMake(self.contentView.width - self.categoryImage.width - 20, 1 / [UIScreen mainScreen].scale);
    self.seperatorView.center = self.contentView.center;
    self.seperatorView.left = self.categoryImage.right + 5;
    self.categoryLabel.left = self.seperatorView.left;
    self.categoryLabel.centerY= self.categoryImage.centerY;
    self.moneyLabel.left = self.categoryLabel.right + 10;
    self.moneyLabel.centerY = self.categoryLabel.centerY;
    self.circleImage.size = CGSizeMake(20, 20);
    self.circleImage.left = self.seperatorView.left;
    self.circleImage.top = self.seperatorView.bottom + 15;
    self.circleLabel.centerY = self.circleImage.centerY;
    self.circleLabel.left = self.circleImage.right + 10;
    self.timeLabel.right = self.seperatorView.right;
    self.timeLabel.centerY = self.circleImage.centerY;
    self.switchButton.right = self.seperatorView.right;
    self.switchButton.bottom = self.seperatorView.top - 10;
}

-(UIImageView *)categoryImage{
    if (!_categoryImage) {
        _categoryImage = [[UIImageView alloc]init];
        _categoryImage.tintColor = [UIColor whiteColor];
        _categoryImage.layer.cornerRadius = 23;
        _categoryImage.contentMode = UIViewContentModeCenter;
    }
    return _categoryImage;
}

-(UIImageView *)circleImage{
    if (!_circleImage) {
        _circleImage = [[UIImageView alloc]init];
        _circleImage.image = [UIImage imageNamed:@"xuhuan_sel"];
        
    }
    return _circleImage;
}

-(UILabel *)categoryLabel{
    if (!_categoryLabel) {
        _categoryLabel = [[UILabel alloc]init];
        _categoryLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _categoryLabel.font = [UIFont systemFontOfSize:18];
    }
    return _categoryLabel;
}

-(UILabel *)moneyLabel{
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc]init];
        _moneyLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _moneyLabel.font = [UIFont systemFontOfSize:18];

    }
    return _moneyLabel;
}

-(UILabel *)circleLabel{
    if (!_circleLabel) {
        _circleLabel = [[UILabel alloc]init];
        _circleLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _circleLabel.font = [UIFont systemFontOfSize:15];
        
    }
    return _circleLabel;
}

-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _timeLabel.font = [UIFont systemFontOfSize:15];
    }
    return _timeLabel;
}

-(UISwitch *)switchButton{
    if (!_switchButton) {
        _switchButton = [[UISwitch alloc]init];
        _switchButton.onTintColor = [UIColor ssj_colorWithHex:@"47cfbe"];
        [_switchButton addTarget:self action:@selector(switchButtonClicked:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchButton;
}

-(UIView *)seperatorView{
    if (!_seperatorView) {
        _seperatorView = [[UIView alloc]init];
        _seperatorView.backgroundColor = [UIColor ssj_colorWithHex:@"cccccc"];
    }
    return _seperatorView;
}

-(void)setItem:(SSJBillingChargeCellItem *)item{
    _item = item;
    self.switchButton.on = _item.isOnOrNot;
    self.categoryImage.image = [[UIImage imageNamed:_item.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.categoryImage.backgroundColor = [UIColor ssj_colorWithHex:_item.colorValue];
    self.categoryLabel.text = _item.typeName;
    [self.categoryLabel sizeToFit];
    if (_item.incomeOrExpence) {
        self.moneyLabel.text = [NSString stringWithFormat:@"-%.2f",[_item.money doubleValue]];
    }else{
        self.moneyLabel.text = [NSString stringWithFormat:@"+%.2f",[_item.money doubleValue]];
    }
    [self.moneyLabel sizeToFit];
    self.timeLabel.text = _item.billDate;
    [self.timeLabel sizeToFit];
    switch (_item.chargeCircleType) {
        case 0:
            self.circleLabel.text = @"每天";
            break;
        case 1:
            self.circleLabel.text = @"每个工作日";
            break;
        case 2:
            self.circleLabel.text = @"每个周末";
            break;
        case 3:
            self.circleLabel.text = @"每周";
            break;
        case 4:
            self.circleLabel.text = @"每月";
            break;
        case 5:
            self.circleLabel.text = @"每年";
            break;
        case 6:
            self.circleLabel.text = @"每月最后一天";
            break;
        default:
            break;
    }
    [self.circleLabel sizeToFit];
}


-(void)switchButtonClicked:(id)sender{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
