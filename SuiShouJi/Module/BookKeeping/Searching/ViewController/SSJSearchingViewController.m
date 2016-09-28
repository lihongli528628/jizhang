//
//  SSJSearchingViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/9/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSearchingViewController.h"
#import "SSJChargeSearchingStore.h"
#import "SSJSearchBar.h"
#import "SSJSearchHistoryItem.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJSearchResultItem.h"

@interface SSJSearchingViewController ()

@property(nonatomic, strong) SSJSearchBar *searchBar;

@property(nonatomic, strong) NSArray *items;

@end

@implementation SSJSearchingViewController{
#warning test
    CFAbsoluteTime _startTime;
    CFAbsoluteTime _endTime;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.searchBar];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.model = SSJSearchHistoryModel;
#warning test
    _startTime = CFAbsoluteTimeGetCurrent();
    [SSJChargeSearchingStore searchForChargeListWithSearchContent:@"餐饮" ListOrder:SSJChargeListOrderMoneyAscending Success:^(NSArray<SSJSearchResultItem *> *result) {
        _endTime = CFAbsoluteTimeGetCurrent();
        NSLog(@"查询%ld条数据耗时%f",result.count,_endTime - _startTime);
    } failure:^(NSError *error) {
        
    }];
}

//- (void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
//}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.tableView.size = CGSizeMake(self.view.width, self.view.height - self.searchBar.bottom);
    self.tableView.top = self.searchBar.bottom + 10;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.model == SSJSearchResultModel) {
        return 75;
    }else{
        return 55;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.model == SSJSearchResultModel) {
        return 37;
    }else{
        return 55;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.model == SSJSearchResultModel) {
        return self.items.count;
    }else{
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.model == SSJSearchResultModel) {
        SSJSearchResultItem *item = [self.items ssj_safeObjectAtIndex:section];
        return item.chargeList.count;
    }else{
        return self.items.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.model == SSJSearchResultModel) {

    }else{

    }
}

#pragma mark - Getter
- (SSJSearchBar *)searchBar{
    if (!_searchBar) {
        __weak typeof(self) weakSelf = self;
        _searchBar = [[SSJSearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 70)];
        _searchBar.cancelAction = ^(){
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
    }
    return _searchBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
