//
//  SSJWishIngViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishIngViewController.h"
#import "SSJWishProgressViewController.h"
#import "SSJWishWithdrawMoneyViewController.h"
#import "SSJMakeWishViewController.h"

#import "SSJWishListTableViewCell.h"

#import "SSJBudgetNodataRemindView.h"

#import "SSJWishHelper.h"

#import "SSJWishModel.h"

@interface SSJWishIngViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray <SSJWishModel *> *dataArray;

@property (nonatomic, strong) SSJBudgetNodataRemindView *noDataRemindView;

/**stateL 许下心愿，努力实现～*/
@property (nonatomic, strong) UILabel *stateL;

@end

@implementation SSJWishIngViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.stateL];
    [self.view addSubview:self.tableView];
    
    [self.tableView addSubview:self.noDataRemindView];
    [self updateViewConstraints];
    [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    @weakify(self);
    [SSJWishHelper queryIngWishWithState:SSJWishStateNormalIng success:^(NSMutableArray<SSJWishModel *> *resultArr) {
        @strongify(self);
        self.dataArray = resultArr;
        if (self.dataArray.count == 0) {
            self.noDataRemindView.hidden = NO;
        } else {
            self.noDataRemindView.hidden = YES;
        }
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.showAnimation = YES;
}

- (void)updateViewConstraints {
    [self.stateL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(30);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.top.mas_equalTo(44);
    }];
    
    [super updateViewConstraints];
}

#pragma mark - Theme
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        self.view.backgroundColor =[UIColor whiteColor];
    }
    self.stateL.textColor = SSJ_SECONDARY_COLOR;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SSJWishModel *model = [self.dataArray ssj_safeObjectAtIndex:indexPath.row];
    SSJWishProgressViewController *wishProgressVC = [[SSJWishProgressViewController alloc] init];
    wishProgressVC.wishId = model.wishId;
    
    [SSJVisibalController().navigationController pushViewController:wishProgressVC animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJWishListTableViewCell *cell = [SSJWishListTableViewCell cellWithTableView:tableView animation:self.showAnimation];
    cell.cellItem = [self.dataArray ssj_safeObjectAtIndex:indexPath.row];
    cell.wishSaveMoneyBlock = ^(SSJWishModel *item) {
        if (item.status == SSJWishStateTermination) {//终止
            //重新开始
        } else if (item.status == SSJWishStateNormalIng) {//进行中
            //去存钱
            SSJWishWithdrawMoneyViewController *saveVC = [[SSJWishWithdrawMoneyViewController alloc] init];
            saveVC.wishModel = [item copy];
            saveVC.saveMoneyType = SSJSaveMoneyTypeList;
            [SSJVisibalController().navigationController pushViewController:saveVC animated:YES];
        }
    };

    return cell;
}

#pragma mark - Lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
//        _tableView.estimatedRowHeight = 170;
//        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.rowHeight = kFinalImgHeight(SSJSCREENWITH) + 10;
    }
    return _tableView;
}

- (NSMutableArray<SSJWishModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UILabel *)stateL {
    if (!_stateL) {
        _stateL = [[UILabel alloc] init];
        _stateL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _stateL.textAlignment = NSTextAlignmentCenter;
        _stateL.backgroundColor = [UIColor clearColor];
        _stateL.text = @"许下心愿，努力实现～";
    }
    return _stateL;
}

- (SSJBudgetNodataRemindView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[SSJBudgetNodataRemindView alloc] init];
        _noDataRemindView.image = @"wish_list_has_no_finish";
        _noDataRemindView.title = @"暂无心愿清单";
        _noDataRemindView.subTitle = @"不如和一百万人一起\n为心愿存钱\n一步步实现自己的小心愿吧";
        _noDataRemindView.actionTitle = @"许下心愿";
        _noDataRemindView.centerX = SSJSCREENWITH * 0.5;
        _noDataRemindView.centerY = (SSJSCREENHEIGHT - 60) * 0.5;
        _noDataRemindView.actionBlock = ^{
            SSJMakeWishViewController *makeWish = [[SSJMakeWishViewController alloc] init];
            [SSJVisibalController().navigationController pushViewController:makeWish animated:YES];
        };
    }
    return _noDataRemindView;
}
@end