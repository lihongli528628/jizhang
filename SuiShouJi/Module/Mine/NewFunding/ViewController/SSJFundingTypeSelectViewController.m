
//
//  SSJFundingTypeSelectViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingTypeSelectViewController.h"
#import "SSJFundingTypeTableViewCell.h"
#import "SSJFundingItem.h"
#import "SSJDatabaseQueue.h"
#import "FMDB.h"

@interface SSJFundingTypeSelectViewController ()

@end

@implementation SSJFundingTypeSelectViewController{
    NSMutableArray *_items;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"选择账户类型";
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _items = [[NSMutableArray alloc]init];
    [self getDateFromDb];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.typeSelectedBlock) {
        self.typeSelectedBlock(((SSJFundingItem*)[_items ssj_safeObjectAtIndex:indexPath.section]).fundingID , ((SSJFundingItem*)[_items ssj_safeObjectAtIndex:indexPath.section]).fundingIcon);
    };
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJFundingTypeCell";
    SSJFundingTypeTableViewCell *FundingTypeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!FundingTypeCell) {
        FundingTypeCell = [[SSJFundingTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    FundingTypeCell.item = [_items objectAtIndex:indexPath.section];
    if (!self.selectFundID || self.selectFundID.length == 0) {
        if (indexPath.section == 0) {
            FundingTypeCell.selectedOrNot = YES;
        }else{
            FundingTypeCell.selectedOrNot = NO;
            
        }
    }else{
        if ([FundingTypeCell.item.fundingID isEqualToString:self.selectFundID]) {
            FundingTypeCell.selectedOrNot = YES;
        }else{
            FundingTypeCell.selectedOrNot = NO;
        }
    }
    FundingTypeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return FundingTypeCell;
}

#pragma mark - Private
-(void)getDateFromDb{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM BK_FUND_INFO WHERE CPARENT = 'root' ORDER BY CFUNDID ASC"];
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        while ([rs next]) {
            SSJFundingItem *item = [[SSJFundingItem alloc]init];
            item.fundingID = [rs stringForColumn:@"CFUNDID"];
            item.fundingName = [rs stringForColumn:@"CACCTNAME"];
            item.fundingIcon = [rs stringForColumn:@"CICOIN"];
            item.fundingMemo = [rs stringForColumn:@"CMEMO"];
            item.fundingParent = [rs stringForColumn:@"CPARENT"];
            [tempArray addObject:item];
        }
        SSJDispatch_main_async_safe(^(){
            _items = tempArray;
            [weakSelf.tableView reloadData];
        });
    }];
}

-(void)reloadSelectedStatusexceptIndexPath:(NSIndexPath*)selectedIndexpath{
    for (int i = 0; i < [self.tableView numberOfSections]; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        if ([indexPath compare:selectedIndexpath] == NSOrderedSame) {
            ((SSJFundingTypeTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath]).selectedOrNot = YES;
        }else{
            ((SSJFundingTypeTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath]).selectedOrNot = NO;
        }
    }
}

-(void)closeButtonClicked:(id)sender{
    [self ssj_backOffAction];
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
