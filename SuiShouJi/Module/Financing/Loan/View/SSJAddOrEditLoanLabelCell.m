//
//  SSJAddOrEditLoanCell.m
//  SuiShouJi
//
//  Created by old lang on 16/8/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAddOrEditLoanLabelCell.h"

@interface SSJAddOrEditLoanLabelCell ()

//@property (nonatomic, strong) UISwitch *switchControl;

@end

@implementation SSJAddOrEditLoanLabelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
        self.textLabel.font = [UIFont systemFontOfSize:18];
        
        _additionalIcon = [[UIImageView alloc] init];
        [self.contentView addSubview:_additionalIcon];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont systemFontOfSize:18];
        [self.contentView addSubview:_subtitleLabel];
        
        _switchControl = [[UISwitch alloc] init];
        [self.contentView addSubview:_switchControl];
        
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.imageView sizeToFit];
    self.imageView.left = 16;
    self.imageView.centerY = self.contentView.height * 0.5;
    
    [self.textLabel sizeToFit];
    self.textLabel.left = 48;
    self.textLabel.centerY = self.contentView.height * 0.5;
    
    if (_switchControl.hidden) {
        [_subtitleLabel sizeToFit];
        _subtitleLabel.rightTop = CGPointMake(self.contentView.width, (self.contentView.height - _subtitleLabel.height) * 0.5);
    } else {
        _switchControl.rightTop = CGPointMake(self.contentView.width, (self.contentView.height - _switchControl.height) * 0.5);
        
        [_subtitleLabel sizeToFit];
        _subtitleLabel.rightTop = CGPointMake(_switchControl.left - 16, (self.contentView.height - _subtitleLabel.height) * 0.5);
    }
    
    [_additionalIcon sizeToFit];
    _additionalIcon.rightTop = CGPointMake(_subtitleLabel.left - 8, (self.contentView.height - _additionalIcon.height) * 0.5);
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)setShowSwitch:(BOOL)showSwitch {
    _switchControl.hidden = !showSwitch;
}

- (void)updateAppearance {
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _subtitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
}

@end