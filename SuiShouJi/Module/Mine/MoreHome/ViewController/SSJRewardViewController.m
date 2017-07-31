//
//  SSJRewardViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRewardViewController.h"
#import "SSJRewardRankViewController.h"

#import "TPKeyboardAvoidingScrollView.h"
#import "SSJMakeWishMoneyCollectionViewCell.h"

#import "NSString+MoneyDisplayFormat.h"

static NSString *wishMoneyCellId = @"SSJMakeWishMoneyCollectionViewCellId";
@interface SSJRewardViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, strong) UICollectionView *moneyCollectionView;

@property (nonatomic, strong) UIImageView *topImg;

@property (nonatomic, strong) UILabel *slognL;

@property (nonatomic, strong) UIView *topBg;

@property (nonatomic, strong) UILabel *rewarkAmountTextL;

@property (nonatomic, strong) UITextField *rewarkAmountTextF;

@property (nonatomic, strong) UIView *bottomBg;

@property (nonatomic, strong) UILabel *rewarkNoteTextL;

@property (nonatomic, strong) UITextField *rewarkNotetTextF;

@property (nonatomic, strong) UIButton *goRewarkBtn;

@property (nonatomic, strong) UIButton *changePayMethodBtn;

@property (nonatomic, strong) UIButton *bottomView;

@property (nonatomic, strong) UIImageView *closeImgView;

/**心愿列表数据源*/
@property (nonatomic, strong) NSArray *rewarkMoneyDataArray;

/**支付方式*/
@property (nonatomic, assign) SSJMethodOfPayment payMethod;

@end

@implementation SSJRewardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"打赏支持";
    [self setUpUI];
    [self initNormalData];
    [self.view setNeedsUpdateConstraints];
    [self signalBind];
    [self appearanceWithTheme];
}
- (void)setUpUI {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.topImg];
    [self.scrollView addSubview:self.slognL];
    
    [self.scrollView addSubview:self.topBg];
    [self.topBg addSubview:self.rewarkAmountTextL];
    [self.topBg addSubview:self.rewarkAmountTextF];
    [self.topBg addSubview:self.moneyCollectionView];
    
    [self.scrollView addSubview:self.bottomBg];
    [self.bottomBg addSubview:self.rewarkNoteTextL];
    [self.bottomBg addSubview:self.rewarkNotetTextF];
    
    [self.scrollView addSubview:self.goRewarkBtn];
    [self.scrollView addSubview:self.changePayMethodBtn];
    
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.closeImgView];
}
#pragma mark - Layout
- (void)updateViewConstraints {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(SSJ_NAVIBAR_BOTTOM);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
    }];
    
    [self.topImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(18);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    
    [self.slognL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topImg.mas_bottom).offset(19);
        make.width.height.greaterThanOrEqualTo(0);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    
    [self.topBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(self.view).offset(-15);
        make.top.mas_equalTo(self.slognL.mas_bottom).offset(31);
        make.height.mas_equalTo(115);
    }];
    
    [self.rewarkAmountTextL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(0);
        make.width.lessThanOrEqualTo(@40);
        make.height.mas_equalTo(60);
    }];
    
    [self.rewarkAmountTextF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.rewarkAmountTextL.mas_right);
        make.top.height.mas_equalTo(self.rewarkAmountTextL);
        make.right.mas_equalTo(-15);
    }];
    
    [self.moneyCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.rewarkAmountTextL.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.topBg);
    }];
    
    [self.bottomBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topBg.mas_bottom).offset(10);
        make.left.right.mas_equalTo(self.topBg);
        make.bottom.mas_equalTo(self.rewarkNotetTextF).offset(28);
    }];
    
    [self.rewarkNoteTextL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(15);
        make.width.greaterThanOrEqualTo(0);
    }];
    
    [self.rewarkNotetTextF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.rewarkNoteTextL);
        make.top.mas_equalTo(self.rewarkNoteTextL.mas_bottom).offset(10);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(44);
    }];
    
    [self.goRewarkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomBg.mas_bottom).offset(20);
        make.left.right.mas_equalTo(self.bottomBg);
        make.height.mas_equalTo(44);
    }];
    
    [self.changePayMethodBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.goRewarkBtn.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self.scrollView);
        make.width.greaterThanOrEqualTo(0);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
    [self.closeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self.bottomView);
    }];
    
    [super updateViewConstraints];
}

#pragma mark - Private
- (void)initNormalData {
    self.rewarkMoneyDataArray = @[@"5.20",@"13.14",@"52.0"];
}

- (void)signalBind {
    RACSignal *signal = [RACSignal combineLatest:@[RACObserve(self, rewarkAmountTextF.text)] reduce:^id(NSString *money) {
        return @(money.length && [money doubleValue] > 0);
    }];
    RAC(self.goRewarkBtn,enabled) = signal;
}

#pragma mark - Theme
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self appearanceWithTheme];
}

- (void)appearanceWithTheme {
    self.rewarkAmountTextF.textColor = self.rewarkNoteTextL.textColor = self.rewarkNotetTextF.textColor = self.rewarkAmountTextF.textColor = self.rewarkAmountTextL.textColor = SSJ_MAIN_COLOR;

    [self.moneyCollectionView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];

    self.closeImgView.tintColor = self.bottomView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor];
    
    self.rewarkAmountTextF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入打赏金额" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    
    [self.goRewarkBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
    [self.goRewarkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.goRewarkBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor alpha:SSJButtonDisableAlpha] forState:UIControlStateSelected];
    
    [self.bottomView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        self.bottomBg.backgroundColor = self.topBg.backgroundColor =SSJ_DEFAULT_BACKGROUND_COLOR;
        self.view.backgroundColor = [UIColor whiteColor];
    } else {
        self.bottomBg.backgroundColor = self.topBg.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailHeaderColor alpha:SSJ_CURRENT_THEME.financingDetailHeaderAlpha];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((collectionView.width - 120)/self.rewarkMoneyDataArray.count, 25);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *amount = [self.rewarkMoneyDataArray ssj_safeObjectAtIndex:indexPath.row];
    self.rewarkAmountTextF.text = amount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.rewarkMoneyDataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SSJMakeWishMoneyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:wishMoneyCellId forIndexPath:indexPath];
    cell.layer.cornerRadius = 6;
    cell.layer.masksToBounds = YES;
    cell.amontStr = [self.rewarkMoneyDataArray ssj_safeObjectAtIndex:indexPath.row];
    return cell;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.rewarkAmountTextF == textField) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = [text ssj_reserveDecimalDigits:2 intDigits:9];
        return NO;
    }
    return YES;
}


#pragma mark - Lazy
- (TPKeyboardAvoidingScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] init];
    }
    return _scrollView;
}

- (UIImageView *)topImg {
    if (!_topImg) {
        _topImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rewark_top_img"]];
    }
    return _topImg;
}

- (UIView *)topBg {
    if (!_topBg) {
        _topBg = [[UIView alloc] init];
        _topBg.layer.cornerRadius = 6;
        _topBg.layer.masksToBounds = YES;
    }
    return _topBg;
}

- (UILabel *)slognL {
    if (!_slognL) {
        _slognL = [[UILabel alloc] init];
        _slognL.text = @"谢谢你的爱，小鱼会继续努力哒~";
        _slognL.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_4];
        _slognL.textColor = [UIColor whiteColor];
    }
    return _slognL;
}

- (UILabel *)rewarkAmountTextL {
    if (!_rewarkAmountTextL) {
        _rewarkAmountTextL = [[UILabel alloc] init];
        _rewarkAmountTextL.text = @"金额";
        _rewarkAmountTextL.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_2];
    }
    return _rewarkAmountTextL;
}

- (UITextField *)rewarkAmountTextF {
    if (!_rewarkAmountTextF) {
        _rewarkAmountTextF = [[UITextField alloc] init];
        _rewarkAmountTextF.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _rewarkAmountTextF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _rewarkAmountTextF.keyboardType = UIKeyboardTypeDecimalPad;
        _rewarkAmountTextF.textAlignment = NSTextAlignmentRight;
        _rewarkAmountTextF.delegate = self;
    }
    return _rewarkAmountTextF;
}

- (UICollectionView *)moneyCollectionView {
    if (!_moneyCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 15;
        flowLayout.minimumLineSpacing = 15;
        flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
        _moneyCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _moneyCollectionView.delegate = self;
        _moneyCollectionView.dataSource = self;
        _moneyCollectionView.backgroundColor = [UIColor clearColor];
        [_moneyCollectionView registerClass:[SSJMakeWishMoneyCollectionViewCell class] forCellWithReuseIdentifier:wishMoneyCellId];
        [_moneyCollectionView ssj_setBorderWidth:1];
        [_moneyCollectionView ssj_setBorderStyle:SSJBorderStyleTop];
    }
    return _moneyCollectionView;
}

- (UIView *)bottomBg {
    if (!_bottomBg) {
        _bottomBg = [[UIView alloc] init];
        _bottomBg.layer.cornerRadius = 6;
        _bottomBg.layer.masksToBounds = YES;
    }
    return _bottomBg;
}

- (UILabel *)rewarkNoteTextL {
    if (!_rewarkNoteTextL) {
        _rewarkNoteTextL = [[UILabel alloc] init];
        _rewarkNoteTextL.text = @"留言：";
        _rewarkNoteTextL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _rewarkNoteTextL;
}

- (UITextField *)rewarkNotetTextF {
    if (!_rewarkNotetTextF) {
        _rewarkNotetTextF = [[UITextField alloc] init];
        _rewarkNotetTextF.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _rewarkNotetTextF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _rewarkNotetTextF.keyboardType = UIKeyboardTypeDecimalPad;
        _rewarkNotetTextF.delegate = self;
    }
    return _rewarkNotetTextF;
}

- (UIButton *)goRewarkBtn {
    if (!_goRewarkBtn) {
        _goRewarkBtn = [[UIButton alloc] init];
        _goRewarkBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_goRewarkBtn setTitle:@"许下心愿" forState:UIControlStateNormal];
        _goRewarkBtn.layer.cornerRadius = 6;
        _goRewarkBtn.layer.masksToBounds = YES;
        @weakify(self);
        [[_goRewarkBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);

        }];
    }
    return _goRewarkBtn;
}

- (UIButton *)changePayMethodBtn {
    if (!_changePayMethodBtn) {
        _changePayMethodBtn = [[UIButton alloc] init];
        _changePayMethodBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        NSString *oldStr = @"使用微信付款，更换";
        NSString *tarStr = @"更换";
        NSMutableAttributedString *attStr = [oldStr attributeStrWithTargetStr:oldStr range:NSMakeRange(0, 0) color:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]];
        [attStr addAttribute:NSForegroundColorAttributeName value:SSJ_MAIN_COLOR range:[oldStr rangeOfString:tarStr]];
        [_changePayMethodBtn setAttributedTitle:attStr forState:UIControlStateNormal];
        _changePayMethodBtn.layer.cornerRadius = 6;
        _changePayMethodBtn.layer.masksToBounds = YES;
        @weakify(self);
        [[_changePayMethodBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [_changePayMethodBtn setTitle:@"使用支付宝付款，更换" forState:UIControlStateNormal];
        }];
    }
    return _changePayMethodBtn;
}

- (UIButton *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIButton alloc] init];
        _bottomView.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_bottomView setTitle:@"打赏榜" forState:UIControlStateNormal];
        [_bottomView setImage:[[UIImage imageNamed:@"founds_selectbutton"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        
        [_bottomView setTitleEdgeInsets:UIEdgeInsetsMake(0, -40, 0, 40)];
        [_bottomView setImageEdgeInsets:UIEdgeInsetsMake(0, 40, 0, -40)];
        [_bottomView ssj_setBorderWidth:1];
        [_bottomView ssj_setBorderStyle:SSJBorderStyleTop];
    }
    return _bottomView;
}

- (UIImageView *)closeImgView {
    if (!_closeImgView) {
        _closeImgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    }
    return _closeImgView;
}

@end
