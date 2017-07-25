//
//  SSJWishFinishedViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishFinishedViewController.h"
#import "SSJWishProgressViewController.h"

#import "SSJWishListTableViewCell.h"

#import "SSJWishModel.h"

#import "SSJWishHelper.h"

@interface SSJWishFinishedViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation SSJWishFinishedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self updateViewConstraints];
    [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    @weakify(self);
    [SSJWishHelper queryIngWishWithState:SSJWishStateFinish success:^(NSMutableArray<SSJWishModel *> *resultArr) {
        @strongify(self);
        self.dataArray = resultArr;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

- (void)updateViewConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
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
    SSJWishListTableViewCell *cell = [SSJWishListTableViewCell cellWithTableView:tableView];
    cell.cellItem = [self.dataArray ssj_safeObjectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - Lazy
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.estimatedRowHeight = 170;
        _tableView.rowHeight = UITableViewAutomaticDimension;
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


@end
