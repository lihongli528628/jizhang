//
//  SSJRecycleListCell.m
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRecycleListCell.h"

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJRecycleListCellSeparatorView
#pragma mark -

@interface _SSJRecycleListCellSeparatorView : UIView

@property (nonatomic, strong) NSArray<NSString *> *titles;

@property (nonatomic, strong) NSMutableArray<UILabel *> *labels;

@end

static const CGFloat kSpace = 8;

@implementation _SSJRecycleListCellSeparatorView

- (void)dealloc {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.labels = [NSMutableArray array];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)updateConstraints {
    [self.labels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (idx == 0) { 
                make.left.mas_equalTo(self);
            } else {
                UILabel *preLab = self.labels[idx - 1];
                make.left.mas_equalTo(preLab.mas_right).offset(kSpace * 2);
            }
            make.top.and.bottom.mas_equalTo(self);
            CGFloat width = [obj.text sizeWithAttributes:@{NSFontAttributeName:obj.font}].width;
            CGFloat maxWidth = 100;
            if (idx == self.titles.count - 1) {
                make.width.mas_equalTo(MIN(width, maxWidth)).priorityLow();
                make.right.mas_lessThanOrEqualTo(self);
            } else {
                make.width.mas_equalTo(MIN(width, maxWidth));
            }
        }];
    }];
    [super updateConstraints];
}

- (void)setTitles:(NSArray<NSString *> *)titles {
    _titles = titles;
    
    if (self.labels.count < titles.count) {
        // 如果lab不够就继续创建新的
        for (int i = 0; titles.count - self.labels.count; i ++) {
            UILabel *lab = [[UILabel alloc] init];
            lab.textColor = SSJ_SECONDARY_COLOR;
            lab.textAlignment = NSTextAlignmentCenter;
            [lab ssj_setBorderWidth:1];
            [lab ssj_setBorderColor:SSJ_BORDER_COLOR];
            [lab ssj_setBorderInsets:UIEdgeInsetsMake(2, -kSpace, 2, -kSpace)];
            lab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
            [self.labels addObject:lab];
            [self addSubview:lab];
        }
    }
    
    [self.labels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < _titles.count - 1) {
            obj.text = _titles[idx];
            [obj ssj_setBorderStyle:SSJBorderStyleRight];
            obj.hidden = NO;
        } else if (idx == _titles.count - 1) {
            obj.text = _titles[idx];
            [obj ssj_setBorderStyle:SSJBorderStyleleNone];
            obj.hidden = NO;
        } else {
            obj.hidden = YES;
        }
    }];
    
    [self setNeedsUpdateConstraints];
}

- (void)updateAppearanceAccordingToTheme {
    [self.labels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.hidden) {
            *stop = YES;
        }
        obj.textColor = SSJ_SECONDARY_COLOR;
        [obj ssj_setBorderColor:SSJ_BORDER_COLOR];
    }];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJRecycleListCell
#pragma mark -

#import "SSJCheckMark.h"

@interface SSJRecycleListCell ()

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) _SSJRecycleListCellSeparatorView *subtitleView;

@property (nonatomic, strong) UIImageView *arrow;

@property (nonatomic, strong) SSJCheckMark *checkMark;

@end

@implementation SSJRecycleListCell

- (void)dealloc {
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.icon];
        [self.contentView addSubview:self.titleLab];
        [self.contentView addSubview:self.subtitleView];
        [self.contentView addSubview:self.arrow];
        [self.contentView addSubview:self.checkMark];
        [self.contentView ssj_setBorderStyle:SSJBorderStyleBottom];
        [self updateAppearance];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)updateConstraints {
    [_icon mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(15);
        make.top.mas_equalTo(self.contentView).offset(12);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [_titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_icon.mas_right).offset(10);
        make.centerY.mas_equalTo(_icon);
    }];
    
    [_arrow mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(_arrow.image.size);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.centerY.mas_equalTo(_icon);
    }];
    
    [_subtitleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_titleLab.mas_bottom).offset(8);
        make.left.mas_equalTo(_titleLab);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.height.mas_equalTo(13);
    }];
    [_checkMark mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(16, 16));
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).offset(-15);
    }];
    
    [super updateConstraints];
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJRecycleListCellItem class]]) {
        return;
    }
    [super setCellItem:cellItem];
    SSJRecycleListCellItem *item = cellItem;
    
    @weakify(self);
    
    RAC(self.icon, image) = [[RACObserve(item, icon) takeUntil:self.rac_prepareForReuseSignal] map:^id(UIImage *icon) {
        return [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }];
    RAC(self.icon, tintColor) = RACObserve(item, iconTintColor);
    RAC(self.titleLab, text) = RACObserve(item, title);
    RAC(self.subtitleView, titles) = RACObserve(item, subtitles);
    
    [[RACObserve(item, state) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *stateValue) {
        @strongify(self);
        
        switch ([stateValue integerValue]) {
            case SSJRecycleListCellStateNormal: {
                UIImage *img = [[UIImage imageNamed:@"recycle_arrow_down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                self.arrow.image = img;
                self.arrow.hidden = NO;
                self.checkMark.hidden = YES;
            }
                break;
                
            case SSJRecycleListCellStateExpanded: {
                UIImage *img = [[UIImage imageNamed:@"recycle_arrow_up"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                self.arrow.image = img;
                self.arrow.hidden = NO;
                self.checkMark.hidden = YES;
            }
                break;
                
            case SSJRecycleListCellStateSelected: {
                self.arrow.hidden = YES;
                self.checkMark.hidden = NO;
                self.checkMark.currentState = SSJCheckMarkSelected;
            }
                break;
                
            case SSJRecycleListCellStateUnselected: {
                self.arrow.hidden = YES;
                self.checkMark.hidden = NO;
                self.checkMark.currentState = SSJCheckMarkNormal;
            }
                break;
        }
        
        [self setNeedsUpdateConstraints];
    }];
}

- (SSJRecycleListCellItem *)item {
    return (SSJRecycleListCellItem *)self.cellItem;
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    _titleLab.textColor = SSJ_MAIN_COLOR;
    _arrow.tintColor = SSJ_CELL_SEPARATOR_COLOR;
    [_subtitleView updateAppearanceAccordingToTheme];
    [_checkMark updateAppearanceAccordingToTheme];
    [self.contentView ssj_setBorderColor:SSJ_CELL_SEPARATOR_COLOR];
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
    }
    return _icon;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _titleLab;
}

- (_SSJRecycleListCellSeparatorView *)subtitleView {
    if (!_subtitleView) {
        _subtitleView = [[_SSJRecycleListCellSeparatorView alloc] init];
    }
    return _subtitleView;
}

- (UIImageView *)arrow {
    if (!_arrow) {
        _arrow = [[UIImageView alloc] init];
    }
    return _arrow;
}

- (SSJCheckMark *)checkMark {
    if (!_checkMark) {
        _checkMark = [[SSJCheckMark alloc] init];
    }
    return _checkMark;
}

@end
