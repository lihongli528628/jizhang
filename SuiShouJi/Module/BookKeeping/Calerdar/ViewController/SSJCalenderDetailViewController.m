
//
//  SSJCalenderDetailViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCalenderDetailViewController.h"
#import "SSJBillingChargeCell.h"
#import "SSJCalenderDetailCell.h"
#import "SSJRecordMakingViewController.h"
#import "SSJCalenderTableViewCell.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "FMDB.h"

@interface SSJCalenderDetailViewController ()
@property (nonatomic,strong) UIView *footerView;
@property (nonatomic, strong) NSString *cellImage;
@property (nonatomic,strong) NSString *cellTitle;
@property (nonatomic,strong) NSString *cellColor;
@property (nonatomic)BOOL incomeOrExpence;
@property (nonatomic,strong) UIBarButtonItem *rightBarButton;
@end

@implementation SSJCalenderDetailViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"详情";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:self.cellColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    [self.tableView registerClass:[SSJCalenderTableViewCell class] forCellReuseIdentifier:@"BillingChargeCell"];
    [self.tableView registerClass:[SSJCalenderDetailCell class] forCellReuseIdentifier:@"calenderDetailCellID"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getDataFromDb];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:self.item.colorValue] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:21],
                                                                    NSForegroundColorAttributeName:[UIColor whiteColor]};
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 55;
    }
    if (indexPath.row == 3) {
        return 100;
    }
    return 50;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 100;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return self.footerView;
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (![self.item.chargeMemo isEqualToString:@""] && self.item.chargeMemo != nil) {
        return 4;
    }
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        SSJCalenderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BillingChargeCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setCellItem:self.item];
        return cell;
    }else if (indexPath.row == 1){
        SSJCalenderDetailCell *detailcell = [tableView dequeueReusableCellWithIdentifier:@"calenderDetailCellID" forIndexPath:indexPath];
        detailcell.detailLabel.text = self.item.billDate;
        [detailcell.detailLabel sizeToFit];
        detailcell.cellLabel.text = @"时间";
        [detailcell.cellLabel sizeToFit];
        return detailcell;
    }else if(indexPath.row == 2){
        SSJCalenderDetailCell *detailcell = [tableView dequeueReusableCellWithIdentifier:@"calenderDetailCellID" forIndexPath:indexPath];
        detailcell.detailLabel.text = [self getParentFundingNameWithParentfundingID:self.item.fundId];
        [detailcell.detailLabel sizeToFit];
        detailcell.cellLabel.text = @"资金类型";
        [detailcell.cellLabel sizeToFit];
        return detailcell;
    }else{
        SSJCalenderDetailCell *detailcell = [tableView dequeueReusableCellWithIdentifier:@"calenderDetailCellID" forIndexPath:indexPath];
        detailcell.detailLabel.numberOfLines = 2;
        detailcell.detailLabel.text = self.item.chargeMemo;
        [detailcell.detailLabel sizeToFit];
        detailcell.cellLabel.text = @"备注";
        [detailcell.cellLabel sizeToFit];
        return detailcell;
    }
}

-(NSString*)getParentFundingNameWithParentfundingID:(NSString*)fundingID{
    NSString *fundingName;
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
        return nil;
    }
    FMResultSet *rs = [db executeQuery:@"SELECT CACCTNAME FROM BK_FUND_INFO WHERE CFUNDID = ?",fundingID];
    while ([rs next]) {
        fundingName = [rs stringForColumn:@"CACCTNAME"];
    }
    [db close];
    return fundingName;
}

#pragma mark - Getter
-(UIView *)footerView{
    if (!_footerView) {
        _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 100)];
        UIButton *editeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.width - 22, 40)];
        [editeButton setTitle:@"修改此记录" forState:UIControlStateNormal];
        [editeButton setTitleColor:[UIColor ssj_colorWithHex:@"47cfbe"] forState:UIControlStateNormal];
        editeButton.layer.borderWidth = 1.f;
        editeButton.layer.cornerRadius = 2.f;
        editeButton.layer.borderColor = [UIColor ssj_colorWithHex:@"47cfbe"].CGColor;
        editeButton.center = CGPointMake(_footerView.width / 2, _footerView.height / 2);
        [editeButton addTarget:self action:@selector(editeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:editeButton];
    }
    return _footerView;
}

-(UIBarButtonItem*)rightBarButton{
    if (!_rightBarButton) {
        _rightBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonClicked:)];
    }
    return _rightBarButton;
}


#pragma mark - Private

/**
 *  修改流水
 */
-(void)editeButtonClicked:(id)sender{
    SSJRecordMakingViewController *recordMakingVc = [[SSJRecordMakingViewController alloc]init];
    recordMakingVc.item = self.item;
    [self.navigationController pushViewController:recordMakingVc animated:YES];
}


/**
 *  每次进入页面之前获取一次最修改的数据
 */
-(void)getDataFromDb{
    __weak typeof(self) weakSelf = self;

    [[SSJDatabaseQueue sharedInstance]inDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery:@"SELECT A.* , B.* FROM BK_USER_CHARGE AS A , BK_BILL_TYPE AS B WHERE A.ICHARGEID = ? AND A.CUSERID = ?  AND A.IBILLID = B.ID",self.item.ID,SSJUSERID()];
        while ([rs next]) {
            weakSelf.item.money = [rs stringForColumn:@"IMONEY"];
            weakSelf.item.billId = [rs stringForColumn:@"IBILLID"];
            weakSelf.item.billDate = [rs stringForColumn:@"CBILLDATE"];
            weakSelf.item.fundId = [rs stringForColumn:@"IFUNSID"];
            weakSelf.item.typeName = [rs stringForColumn:@"CNAME"];
            weakSelf.item.imageName = [rs stringForColumn:@"CCOIN"];
            weakSelf.item.colorValue = [rs stringForColumn:@"CCOLOR"];
            weakSelf.item.incomeOrExpence = [rs boolForColumn:@"ITYPE"];
        }
        SSJDispatch_main_async_safe(^(){
            [weakSelf.tableView reloadData];
        })
    }];
}

-(void)rightBarButtonClicked:(id)sender{
    [self deleteCharge];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  数据库中删除流水
 */
-(void)deleteCharge{
    [[SSJDatabaseQueue sharedInstance]asyncInTransaction:^(FMDatabase *db , BOOL *rollback){
        [db executeUpdate:@"UPDATE BK_USER_CHARGE SET OPERATORTYPE = 2 , CWRITEDATE = ? , IVERSION = ? WHERE ICHARGEID = ?",[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),self.item.ID];
        if ([db intForQuery:@"SELECT ITYPE FROM BK_BILL_TYPE WHERE ID = ?",self.item.billId]) {
            if (![db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE + ? WHERE  CFUNDID = ?",[NSNumber numberWithDouble:[self.item.money doubleValue]],self.item.fundId] || ![db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET EXPENCEAMOUNT = EXPENCEAMOUNT - ? , SUMAMOUNT = SUMAMOUNT + ? , CWRITEDATE = ? WHERE CBILLDATE = ?",[NSNumber numberWithDouble:[self.item.money doubleValue]],[NSNumber numberWithDouble:[self.item.money doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],self.item.billDate]) {
                *rollback = YES;
            }
        }else{
            if (![db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE - ? WHERE  CFUNDID = ?",[NSNumber numberWithDouble:[self.item.money doubleValue]],self.item.fundId] || ![db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET INCOMEAMOUNT = INCOMEAMOUNT - ? , SUMAMOUnT = SUMAMOUNT - ? , CWRITEDATE = ? WHERE CBILLDATE = ?",[NSNumber numberWithDouble:[self.item.money doubleValue]],[NSNumber numberWithDouble:[self.item.money doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],self.item.billDate]) {
                *rollback = YES;
            }
        }
        [db executeUpdate:@"DELETE FROM BK_DAILYSUM_CHARGE WHERE SUMAMOUNT = 0 AND INCOMEAMOUNT = 0 AND EXPENCEAMOUNT = 0"];
    }];
    if (SSJSyncSetting() == SSJSyncSettingTypeWIFI) {
        [[SSJDataSynchronizer shareInstance]startSyncWithSuccess:^(){
            
        }failure:^(NSError *error) {
            
        }];
    }
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
