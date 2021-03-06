//
//  SSJFixedFinanceProductViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceProductListViewController.h"
#import "SSJAddOrEditFixedFinanceProductViewController.h"
#import "SSJFixedFinanceProductDetailViewController.h"

#import "SCYSlidePagingHeaderView.h"
#import "SSJBudgetNodataRemindView.h"
#import "SSJLoanListSectionHeaderAmountView.h"
#import "SSJRecycleDataDeletionAlertView.h"

#import "SSJFixedFinProductListCell.h"

#import "SSJFixedFinanceProductStore.h"
#import "SSJFixedFinanceProductItem.h"
#import "SSJLoanListCellItem.h"
#import "SSJFinancingHomeitem.h"
#import "SSJFixedFinanceProductChargeItem.h"
#import "SSJDataSynchronizer.h"

static NSString *const kFixedFinanceProductListCellId = @"kFixedFinanceProductListCellId";

@interface SSJFixedFinanceProductListViewController ()<UITableViewDataSource, UITableViewDelegate,SCYSlidePagingHeaderViewDelegate>

@property (nonatomic, strong) SCYSlidePagingHeaderView *headerSegmentView;

@property (nonatomic, strong) SSJBudgetNodataRemindView *noDataRemindView;

@property (nonatomic, strong) SSJLoanListSectionHeaderAmountView *amountView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *addBtn;

@property (nonatomic, strong) UIBarButtonItem *deleteItem;

@property (nonatomic, strong) NSArray<SSJFixedFinanceProductItem *> *dataItems;
@end

@implementation SSJFixedFinanceProductListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.headerSegmentView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.addBtn];
    [self setUpNav];
    [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadDataAccordingToHeaderViewIndex];
}

#pragma mark - Private
- (void)setUpNav {
    self.title = self.item.fundingName;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(showDeletionAlertView)];
}

- (void)reloadDataAccordingToHeaderViewIndex {
    [self.view ssj_showLoadingIndicator];
    [SSJFixedFinanceProductStore queryFixedFinanceProductWithFundID:self.item.fundingID Type:(int)_headerSegmentView.selectedIndex success:^(NSArray<SSJFixedFinanceProductItem *> * _Nonnull resultList) {
        [self.view ssj_hideLoadingIndicator];
        self.dataItems = resultList;
        [self.tableView reloadData];
        [self updateAmount];
        if (self.dataItems.count == 0) {
            [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
        } else {
            [self.view ssj_hideWatermark:YES];
        }

    } failure:^(NSError * _Nonnull error) {
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}

- (void)updateAmount {
    double money = 0;
    for (SSJFixedFinanceProductItem *productItem in self.dataItems) {
        NSArray *array = [SSJFixedFinanceProductStore queryFixedFinanceProductAddAndRedemChargeListWithModel:productItem error:nil];
        for (SSJFixedFinanceProductChargeItem *tempItem in array) {
            money += tempItem.money;
        }
        if (!productItem.isend) {
            money += [SSJFixedFinanceProductStore queryForFixedFinanceProduceInterestiothWithProductID:productItem.productid];
        } else {
            money += [SSJFixedFinanceProductStore queryForFixedFinanceProduceJieSuanInterestiothWithProductID:productItem.productid];
        }
    }
    self.amountView.amount = [NSString stringWithFormat:@"+%.2f", money];
}

#pragma mark - Action
- (void)showDeletionAlertView {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"确定要删除该资金账户吗?" preferredStyle:UIAlertControllerStyleAlert];
    @weakify(self);
    [alert addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self deleteAction];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:NULL]];
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)deleteAction {
    [self.view ssj_showLoadingIndicator];
    MJWeakSelf;
    [SSJFixedFinanceProductStore queryFixedFinanceProductWithFundID:self.item.fundingID Type:SSJFixedFinanceStateAll success:^(NSArray<SSJFixedFinanceProductItem *> * _Nonnull resultList) {
        [weakSelf.view ssj_hideLoadingIndicator];
        [SSJFixedFinanceProductStore deleteFixedFinanceProductAccountWithModel:resultList success:^{
            [weakSelf.view ssj_hideLoadingIndicator];
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            [SSJRecycleDataDeletionAlertor showAlert:SSJRecycleDataDeletionTypeFund];
        } failure:^(NSError * _Nonnull error) {
            [weakSelf.view ssj_hideLoadingIndicator];
            [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
        }];
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}

- (void)addAction {
    SSJAddOrEditFixedFinanceProductViewController *addOrEditVC = [[SSJAddOrEditFixedFinanceProductViewController alloc] init];
    [self.navigationController pushViewController:addOrEditVC animated:YES];
}

#pragma mark - Theme
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    _headerSegmentView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    _headerSegmentView.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _headerSegmentView.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    [_headerSegmentView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    [_amountView updateAppearance];
    _addBtn.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
    [_addBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
    [_addBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];

}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJFixedFinProductListCell *cell = [SSJFixedFinProductListCell cellWithTableView:tableView];
    cell.cellItem = [SSJLoanListCellItem itemForFixedFinanceProductModel:[self.dataItems ssj_safeObjectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 40;
    } else {
        return 10;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 && self.dataItems.count) {
        return self.amountView;
    } else {
        return [[UIView alloc] init];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SSJFixedFinanceProductItem *model = [self.dataItems ssj_safeObjectAtIndex:indexPath.row];
    SSJFixedFinanceProductDetailViewController *detailVC = [[SSJFixedFinanceProductDetailViewController alloc] init];
    detailVC.productID = model.productid;
    detailVC.fundColor = [NSString stringWithFormat:@"%@,%@",self.item.startColor,self.item.endColor];
    [self.navigationController pushViewController:detailVC animated:YES];
//    [SSJLoanHelper queryForFundColorWithID:model.fundID completion:^(NSString * _Nonnull color) {
//        SSJLoanDetailViewController *loanDetailVC = [[SSJLoanDetailViewController alloc] init];
//        loanDetailVC.loanID = model.ID;
//        loanDetailVC.fundColor = color;
//        [self.navigationController pushViewController:loanDetailVC animated:YES];
//    }];
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    [self reloadDataAccordingToHeaderViewIndex];
    
    if (index == 0) {
        
    } else if (index == 1) {
        
    } else if (index == 2) {
    }

}


#pragma mark - Lazy
- (SCYSlidePagingHeaderView *)headerSegmentView {
    if (!_headerSegmentView) {
        _headerSegmentView = [[SCYSlidePagingHeaderView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, 36)];
        _headerSegmentView.customDelegate = self;
        _headerSegmentView.buttonClickAnimated = YES;
        _headerSegmentView.titles = @[@"未结算", @"已结算", @"全部"];
        [_headerSegmentView setTabSize:CGSizeMake(_headerSegmentView.width / _headerSegmentView.titles.count, 3)];
        [_headerSegmentView ssj_setBorderWidth:1];
        [_headerSegmentView ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleBottom)];
    }
    return _headerSegmentView;
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerSegmentView.frame), self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM-self.headerSegmentView.height - self.addBtn.height) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        _tableView.sectionFooterHeight = 0;
        _tableView.rowHeight = 120;
    }
    return _tableView;
}

- (SSJLoanListSectionHeaderAmountView *)amountView {
    if (!_amountView) {
        _amountView = [[SSJLoanListSectionHeaderAmountView alloc] initWithFrame:CGRectMake(0, self.headerSegmentView.bottom, self.view.width, 40)];
            _amountView.title = @"累计理财";
    }
    return _amountView;
}

- (SSJBudgetNodataRemindView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[SSJBudgetNodataRemindView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 260)];
        _noDataRemindView.image = @"loan_noDataRemind";
        _noDataRemindView.title = @"暂无记录哦";
    }
    return _noDataRemindView;
}

- (NSArray<SSJFixedFinanceProductItem *> *)dataItems {
    if (!_dataItems) {
        _dataItems = [NSArray array];
    }
    return _dataItems;
}

- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn.frame = CGRectMake(0, self.view.height - 50, self.view.width, 50);
        _addBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_addBtn setTitle:@"添加" forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
        [_addBtn ssj_setBorderStyle:SSJBorderStyleTop];
    }
    return _addBtn;
}
@end
