//
//  SSJPersonalDetailUserSignatureCell.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/4.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJPersonalDetailUserSignatureCell.h"
#import "SSJCustomTextView.h"

@implementation SSJPersonalDetailUserSignatureCellItem

+ (instancetype)itemWithSignatureLimit:(NSUInteger)signatureLimit signature:(NSString *)signature {
    SSJPersonalDetailUserSignatureCellItem *item = [[SSJPersonalDetailUserSignatureCellItem alloc] init];
    item.signatureLimit = signatureLimit;
    item.signature = signature;
    return item;
}

@end

@interface SSJPersonalDetailUserSignatureCell ()

@property (nonatomic, strong) UILabel *leftLab;

@property (nonatomic, strong) UILabel *counter;

@property (nonatomic, strong) UITextField *signatureField;

@end

@implementation SSJPersonalDetailUserSignatureCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.leftLab];
        [self.contentView addSubview:self.counter];
        [self.contentView addSubview:self.signatureField];
        [self setNeedsUpdateConstraints];
        [self updateAppearance];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateConstraints {
    [self.leftLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(18);
        make.left.mas_equalTo(15);
    }];
    [self.signatureField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.leftLab.mas_bottom).offset(8);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(20);
    }];
    [self.counter mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-10);
        make.right.mas_equalTo(-15);
    }];
    [super updateConstraints];
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJPersonalDetailUserSignatureCellItem class]]) {
        return;
    }
    [super setCellItem:cellItem];
    
    SSJPersonalDetailUserSignatureCellItem *item = cellItem;
    RAC(self.signatureField, placeholder) = [[RACObserve(item, signatureLimit) takeUntil:self.rac_prepareForReuseSignal] map:^id(NSNumber *value) {
        return [NSString stringWithFormat:@"输入记账小目标，更有利于小目标实现%d字", [value intValue]];
    }];
    
    [[RACChannelTo(item, signature) takeUntil:self.rac_prepareForReuseSignal] subscribe:self.signatureField.rac_newTextChannel];
    [self.signatureField.rac_newTextChannel subscribe:RACChannelTo(item, signature)];
    
    RAC(self.counter, text) = [[RACSignal merge:@[[RACObserve(item, signature) takeUntil:self.rac_prepareForReuseSignal],
                      self.signatureField.rac_textSignal]] map:^id(NSString *text) {
        return [NSString stringWithFormat:@"%d", (int)text.length];
    }];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.leftLab.textColor = SSJ_MAIN_COLOR;
    self.counter.textColor = SSJ_SECONDARY_COLOR;
    self.signatureField.textColor = SSJ_SECONDARY_COLOR;
    
    SSJPersonalDetailUserSignatureCellItem *item = self.cellItem;
    NSString *placeholder = [NSString stringWithFormat:@"输入记账小目标，更有利于小目标实现%d字", (int)item.signatureLimit];
    self.signatureField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:SSJ_SECONDARY_COLOR}];
}

- (UILabel *)leftLab {
    if (!_leftLab) {
        _leftLab = [[UILabel alloc] init];
        _leftLab.text = @"记账小目标";
        _leftLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _leftLab;
}

- (UILabel *)counter {
    if (!_counter) {
        _counter = [[UILabel alloc] init];
        _counter.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _counter;
}

- (UITextField *)signatureField {
    if (!_signatureField) {
        _signatureField = [[UITextField alloc] init];
        _signatureField.adjustsFontSizeToFitWidth = YES;
        _signatureField.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _signatureField;
}

@end