
//
//  SSJFundingMergeSelectView.m
//  SuiShouJi
//
//  Created by 赵天立 on 2017/7/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFundingMergeSelectView.h"
#import "SSJFundingSelectView.h"
#import "SSJFinancingHomeitem.h"
#import "SSJCreditCardItem.h"

@interface SSJFundingMergeSelectView()

@property (nonatomic,strong) SSJFundingSelectView *fundSelectView;

@property (nonatomic,strong) UILabel *fundingTypeLab;

@property (nonatomic, strong) UIImageView *arrowImage;

@property (nonatomic) SSJFundTransferViewType type;

@end

@implementation SSJFundingMergeSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.fundSelectView];
        [self addSubview:self.fundingTypeLab];
        [self addSubview:self.arrowImage];
    }
    return self;
}

- (void)updateConstraints {
    
    [self.fundSelectView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(200, 80));
        make.top.mas_equalTo(25);
    }];
    
    [self.fundingTypeLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self.fundSelectView.mas_bottom).offset(14);
    }];
    
    [self.arrowImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self.fundSelectView.mas_right).offset(69);
    }];
    
    [super updateConstraints];
}

- (SSJFundingSelectView *)fundSelectView {
    if (!_fundSelectView) {
        _fundSelectView = [[SSJFundingSelectView alloc] init];
    }
    return _fundSelectView;
}

- (UILabel *)fundingTypeLab {
    if (!_fundingTypeLab) {
        _fundingTypeLab = [[UILabel alloc] init];
    }
    return _fundingTypeLab;
}

- (void)setFundingItem:(SSJFinancingHomeitem *)fundingItem {
    _fundingItem = fundingItem;
    self.fundSelectView.fundingItem = fundingItem;
    if (fundingItem) {
        SSJFinancingHomeitem *fundItem = (SSJFinancingHomeitem *)_fundingItem;
        
        NSString *str = [NSString stringWithFormat:@"资金账户类型: %@",fundItem.fundingParentName];
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:str];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4] range:NSMakeRange(0, attributeStr.length)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] range:NSMakeRange(0, 7)];
        
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:[str rangeOfString:fundItem.fundingParentName]];
        
        self.fundingTypeLab.attributedText = attributeStr;
        
    } else {
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:@"请选择资金账户类型"];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4] range:NSMakeRange(0, attributeStr.length)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] range:NSMakeRange(0, attributeStr.length)];
        self.fundingTypeLab.attributedText = attributeStr;
    }
    
    [self updateConstraintsIfNeeded];
}

- (UIImageView *)arrowImage {
    if (!_arrowImage) {
        _arrowImage = [[UIImageView alloc] init];
        _arrowImage.image = [[UIImage imageNamed:@"book_transfer_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _arrowImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor];
    }
    return _arrowImage;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.selectable) {
        if (self.fundSelectBlock) {
            self.fundSelectBlock();
        }
    }
}

- (void)setSelectable:(BOOL)selectable {
    _selectable = selectable;
    self.arrowImage.hidden = !_selectable;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
