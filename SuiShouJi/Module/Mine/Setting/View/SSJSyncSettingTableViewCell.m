//
//  SSJSyncSettingTableViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSyncSettingTableViewCell.h"

@implementation SSJSyncSettingTableViewCellItem

+ (instancetype)itemWithTitle:(NSString *)title accessoryType:(UITableViewCellAccessoryType)accessoryType {
    SSJSyncSettingTableViewCellItem *item = [[SSJSyncSettingTableViewCellItem alloc] init];
    item.title = title;
    item.accessoryType = accessoryType;
    return item;
}

@end

@interface SSJSyncSettingTableViewCell()
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIImageView *checkMarkImage;
@end

@implementation SSJSyncSettingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.checkMarkImage];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(17);
        make.left.mas_equalTo(15);
//        make.right.mas_lessThanOrEqualTo(-15);
        make.bottom.mas_equalTo(-17);
    }];
    [self.checkMarkImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self.contentView);
        make.size.mas_equalTo(self.checkMarkImage.image.size);
    }];
    [super updateConstraints];
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _titleLabel;
}

-(UIImageView *)checkMarkImage{
    if (!_checkMarkImage) {
        _checkMarkImage = [[UIImageView alloc]init];
        _checkMarkImage.image = [[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _checkMarkImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    }
    return _checkMarkImage;
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJSyncSettingTableViewCellItem class]]) {
        return;
    }
    [super setCellItem:cellItem];
    
    SSJSyncSettingTableViewCellItem *item = cellItem;
    
    [[RACObserve(item, title) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSString *title) {
        self.titleLabel.text = title;
        [self setNeedsUpdateConstraints];
        [self setNeedsLayout];
    }];
    
    [[RACObserve(item, accessoryType) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        if (item.accessoryType == UITableViewCellAccessoryNone) {
            self.checkMarkImage.hidden = YES;
        } else if (item.accessoryType == UITableViewCellAccessoryCheckmark) {
            self.checkMarkImage.hidden = NO;
        } else if (item.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
            self.checkMarkImage.hidden = YES;
            self.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }];
}

@end
