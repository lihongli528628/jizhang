//
//  SSJDataImportViewController.m
//  SuiShouJi
//
//  Created by old lang on 2017/9/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDataImportViewController.h"

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJDataImportTopView
#pragma mark -
@interface _SSJDataImportTopView : UIView

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIImageView *icon_1;

@property (nonatomic, strong) UILabel *nameLab_1;

@property (nonatomic, strong) UIImageView *icon_2;

@property (nonatomic, strong) UILabel *nameLab_2;

@property (nonatomic, strong) UIView *container;

@end

@implementation _SSJDataImportTopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLab];
        [self addSubview:self.container];
        [self.container addSubview:self.icon_1];
        [self.container addSubview:self.nameLab_1];
        [self.container addSubview:self.icon_2];
        [self.container addSubview:self.nameLab_2];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)updateConstraints {
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30);
        make.centerX.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(249, 16));
    }];
    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLab.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-17);
    }];
    [self.icon_1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.icon_1.size);
        make.top.left.mas_equalTo(self.container);
    }];
    [self.nameLab_1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon_1.mas_bottom).offset(10);
        make.bottom.mas_equalTo(self.container);
        make.centerX.mas_equalTo(self.icon_1);
    }];
    [self.icon_2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.icon_2.size);
        make.top.mas_equalTo(self.icon_1);
        make.left.mas_equalTo(self.icon_1.mas_right).offset(90);
        make.right.mas_equalTo(self.container);
    }];
    [self.nameLab_2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon_2.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self.icon_2);
    }];
    [super updateConstraints];
}

- (void)updateAppearance {
    self.titleLab.textColor = SSJ_MAIN_COLOR;
    self.nameLab_1.textColor = SSJ_MAIN_COLOR;
    self.nameLab_2.textColor = SSJ_MAIN_COLOR;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"导入其它记账app数据，开启新的记账之旅";
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _titleLab;
}

- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] init];
        [_container addSubview:self.icon_1];
        [_container addSubview:self.nameLab_1];
        [_container addSubview:self.icon_2];
        [_container addSubview:self.nameLab_2];
    }
    return _container;
}

- (UIImageView *)icon_1 {
    if (!_icon_1) {
        _icon_1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"suishouji_logo"]];
    }
    return _icon_1;
}

- (UILabel *)nameLab_1 {
    if (!_nameLab_1) {
        _nameLab_1 = [[UILabel alloc] init];
        _nameLab_1.text = @"随手记";
        _nameLab_1.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _nameLab_1;
}

- (UIImageView *)icon_2 {
    if (!_icon_2) {
        _icon_2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"custom_logo"]];
    }
    return _icon_2;
}

- (UILabel *)nameLab_2 {
    if (!_nameLab_2) {
        _nameLab_2 = [[UILabel alloc] init];
        _nameLab_2.text = @"自定义";
        _nameLab_2.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _nameLab_2;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJDataImportBottomCell
#pragma mark -

#import "SSJDashLine.h"

@interface _SSJDataImportBottomCell : UIView

@property (nonatomic, copy) void(^clickTitleLabBlock)(_SSJDataImportBottomCell *);

@property (nonatomic, strong) UILabel *numberLab;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) SSJDashLine *dashLine;

@end

@implementation _SSJDataImportBottomCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.numberLab];
        [self addSubview:self.titleLab];
        [self addSubview:self.imageView];
        [self addSubview:self.dashLine];
        [self updateAppearance];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.dashLine.startPoint = CGPointMake(self.numberLab.centerX, self.numberLab.bottom + 20);
    self.dashLine.endPoint = CGPointMake(self.numberLab.centerX, self.height - 20);
}

- (void)updateConstraints {
    [self.numberLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(18, 18));
        make.left.and.top.mas_equalTo(self);
    }];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self.numberLab.mas_right).offset(10);
        make.right.mas_equalTo(self);
    }];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLab.mas_bottom).offset(14);
        make.left.mas_equalTo(self.titleLab);
        make.right.and.bottom.mas_equalTo(self);
        make.size.mas_equalTo(self.imageView.image.size);
    }];
    [super updateConstraints];
}

- (void)updateAppearance {
    _numberLab.textColor = [UIColor whiteColor];
    _numberLab.backgroundColor = RGBCOLOR(255, 164, 140);
    _dashLine.lineColor = RGBCOLOR(255, 164, 140);
    _titleLab.textColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].mainColor];
}

- (void)clickTitleAction {
    if (self.clickTitleLabBlock) {
        self.clickTitleLabBlock(self);
    }
}

- (UILabel *)numberLab {
    if (!_numberLab) {
        _numberLab = [[UILabel alloc] init];
        _numberLab.clipsToBounds = YES;
        _numberLab.layer.cornerRadius = 2;
        _numberLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        _numberLab.textAlignment = NSTextAlignmentCenter;
    }
    return _numberLab;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_4];
        _titleLab.numberOfLines = 0;
        _titleLab.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTitleAction)];
        [_titleLab addGestureRecognizer:tap];
    }
    return _titleLab;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (SSJDashLine *)dashLine {
    if (!_dashLine) {
        _dashLine = [[SSJDashLine alloc] init];
        _dashLine.lineWidth = 1;
    }
    return _dashLine;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJDataImportBottomView
#pragma mark -

#import "SSJDomainManager.h"

@interface _SSJDataImportBottomView : UIView

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) _SSJDataImportBottomCell *cell_1;

@property (nonatomic, strong) _SSJDataImportBottomCell *cell_2;

@property (nonatomic, strong) _SSJDataImportBottomCell *cell_3;

@end

@implementation _SSJDataImportBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLab];
        [self addSubview:self.cell_1];
        [self addSubview:self.cell_2];
        [self addSubview:self.cell_3];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)updateConstraints {
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(24);
        make.centerX.mas_equalTo(self);
    }];
    [self.cell_1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLab.mas_bottom).offset(22);
        make.centerX.mas_equalTo(self);
    }];
    [self.cell_2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.cell_1.mas_bottom).offset(12);
        make.centerX.mas_equalTo(self);
    }];
    [self.cell_3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.cell_2.mas_bottom).offset(12);
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-20);
    }];
    [super updateConstraints];
}

- (void)updateAppearance {
    _titleLab.textColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].mainColor];
    [_cell_1 updateAppearance];
    [_cell_2 updateAppearance];
    [_cell_3 updateAppearance];
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"如何进行数据导入？";
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _titleLab;
}

- (_SSJDataImportBottomCell *)cell_1 {
    if (!_cell_1) {
        _cell_1 = [[_SSJDataImportBottomCell alloc] init];
        _cell_1.numberLab.text = @"1";
        NSString *url = [NSString stringWithFormat:@"http://%@", [SSJDomainManager domain].host];
        _cell_1.titleLab.text = [NSString stringWithFormat:@"在有鱼记账手机客户端2.8.0以上版本登录后，电脑登录有鱼记账官网\n（%@ 一键复制）", url];
        _cell_1.imageView.image = [UIImage imageNamed:@"data_import_guide_1"];
        _cell_1.clickTitleLabBlock = ^(_SSJDataImportBottomCell *cell) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = url;
            [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"复制成功，您可粘贴发送至QQ或微信，然后在电脑上打开链接即可。" action:[SSJAlertViewAction actionWithTitle:@"知道了" handler:NULL], nil];
        };
    }
    return _cell_1;
}

- (_SSJDataImportBottomCell *)cell_2 {
    if (!_cell_2) {
        _cell_2 = [[_SSJDataImportBottomCell alloc] init];
        _cell_2.numberLab.text = @"2";
        _cell_2.titleLab.text = @"点击右上角的“数据迁移”，输入有鱼账号和密码";
        _cell_2.imageView.image = [UIImage imageNamed:@"data_import_guide_2"];
    }
    return _cell_2;
}

- (_SSJDataImportBottomCell *)cell_3 {
    if (!_cell_3) {
        _cell_3 = [[_SSJDataImportBottomCell alloc] init];
        _cell_3.numberLab.text = @"3";
        _cell_3.titleLab.text = @"选择好记账平台，导入记账数据文件，根据指示完成即可";
        _cell_3.imageView.image = [UIImage imageNamed:@"data_import_guide_3"];
    }
    return _cell_3;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJDataImportViewController
#pragma mark -
@interface SSJDataImportViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) _SSJDataImportTopView *topView;

@property (nonatomic, strong) _SSJDataImportBottomView *bottomView;

@end

@implementation SSJDataImportViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
        self.title = @"数据导入";
        self.appliesTheme = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.topView];
    [self.scrollView addSubview:self.bottomView];
    [self.view setNeedsUpdateConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController.viewControllers.count == 1) {
        self.tabBarController.tabBar.hidden = NO;
    }
}

- (void)updateViewConstraints {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(SSJ_NAVIBAR_BOTTOM, 0, 0, 0));
    }];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.scrollView);
        make.top.left.right.mas_equalTo(self.scrollView);
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.scrollView);
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.left.right.bottom.mas_equalTo(self.scrollView);
    }];
    [super updateViewConstraints];
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
    }
    return _scrollView;
}

- (_SSJDataImportTopView *)topView {
    if (!_topView) {
        _topView = [[_SSJDataImportTopView alloc] init];
        _topView.backgroundColor = [UIColor whiteColor];
        UIColor *borderColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].cellIndicatorColor alpha:[SSJThemeSetting defaultThemeModel].cellSeparatorAlpha];
        [_topView ssj_setBorderColor:borderColor];
        [_topView ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return _topView;
}

- (_SSJDataImportBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[_SSJDataImportBottomView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

@end
