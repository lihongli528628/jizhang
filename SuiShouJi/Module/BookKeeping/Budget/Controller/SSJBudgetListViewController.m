//
//  SSJBudgetListViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetListViewController.h"
#import "SSJBudgetEditViewController.h"
#import "SSJBudgetDetailViewController.h"
#import "SSJBudgetListCell.h"
#import "SSJBudgetListSecondaryCell.h"
#import "SSJBudgetCategorySelectionControl.h"
#import "SSJBudgetDatabaseHelper.h"
#import "SSJBudgetBillTypeSelectionViewController.h"

static NSString *const kBudgetListCellId = @"kBudgetListCellId";
static NSString *const kBudgetListSecondaryCellId = @"kBudgetListSecondaryCellId";

@interface SSJBudgetListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) SSJBudgetCategorySelectionControl *rightBarControl;

@property (nonatomic, strong) NSArray *dataList;

/**
 新建的预算id
 */
@property (nonatomic, copy) NSString *addBudgetId;

@end

@implementation SSJBudgetListViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.navigationItem.title = @"预算";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAddBarButtonItem];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view ssj_showLoadingIndicator];
    [SSJBudgetDatabaseHelper queryForBudgetCellItemListWithSuccess:^(NSArray<SSJBudgetListCellItem *> * _Nonnull result) {
        [self.view ssj_hideLoadingIndicator];
        self.dataList = result;
        [self.tableView reloadData];
        
        // 如果是新建预算返回后，滑动到新建预算的位置
        if (self.addBudgetId) {
            for (int section = 0; section < self.dataList.count; section ++) {
                NSArray *sectionArr = self.dataList[section];
                for (int row = 0; row < sectionArr.count; row ++) {
                    SSJBudgetListCellItem *item = sectionArr[row];
                    if ([item.budgetID isEqualToString:self.addBudgetId]) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                        break;
                    }
                }
            }
        }
        
    } failure:^(NSError * _Nullable error) {
        [self.view ssj_hideLoadingIndicator];
        SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:[error localizedDescription] action:action, nil];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.addBudgetId = nil;
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rowArr = [self.dataList ssj_safeObjectAtIndex:section];
    return rowArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBudgetListCellItem *item = [self.dataList ssj_objectAtIndexPath:indexPath];
    if (item.isMajor) {
        SSJBudgetListCell *cell = [tableView dequeueReusableCellWithIdentifier:kBudgetListCellId forIndexPath:indexPath];
        cell.cellItem = item;
        return cell;
    } else {
        SSJBudgetListSecondaryCell *cell = [tableView dequeueReusableCellWithIdentifier:kBudgetListSecondaryCellId forIndexPath:indexPath];
        [cell layoutIfNeeded];
        cell.cellItem = item;
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBudgetListCellItem *item = [self.dataList ssj_objectAtIndexPath:indexPath];
    return item.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SSJBudgetListCellItem *item = [self.dataList ssj_objectAtIndexPath:indexPath];
    SSJBudgetDetailViewController *detailVC = [[SSJBudgetDetailViewController alloc] init];
    detailVC.budgetId = item.budgetID;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - Event
- (void)categorySelectionControlAction {
    switch (self.rightBarControl.option) {
        case SSJBudgetCategorySelectionControlOptionMajor: {
            __weak typeof(self) wself = self;
            SSJBudgetEditViewController *newBudgetVC = [[SSJBudgetEditViewController alloc] init];
            newBudgetVC.addNewBudgetBlock = ^(NSString *budgetId) {
                wself.addBudgetId = budgetId;
            };
            [self.navigationController pushViewController:newBudgetVC animated:YES];
        }
            break;
            
        case SSJBudgetCategorySelectionControlOptionSecondary: {
            SSJBudgetBillTypeSelectionViewController *billTypeSelectionController = [[SSJBudgetBillTypeSelectionViewController alloc] init];
            billTypeSelectionController.enterFromBudgetList = YES;
            [self.navigationController pushViewController:billTypeSelectionController animated:YES];
        }
            break;
    }
}

#pragma mark - Private
- (void)setupAddBarButtonItem {
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBarControl];
    self.navigationItem.rightBarButtonItem = addItem;
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
//        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView setTableFooterView:[[UIView alloc] init]];
        [_tableView registerClass:[SSJBudgetListCell class] forCellReuseIdentifier:kBudgetListCellId];
        [_tableView registerClass:[SSJBudgetListSecondaryCell class] forCellReuseIdentifier:kBudgetListSecondaryCellId];
    }
    return _tableView;
}

- (SSJBudgetCategorySelectionControl *)rightBarControl {
    if (!_rightBarControl) {
        _rightBarControl = [[SSJBudgetCategorySelectionControl alloc] init];
        [_rightBarControl addTarget:self action:@selector(categorySelectionControlAction) forControlEvents:UIControlEventValueChanged];
    }
    return _rightBarControl;
}

@end
