//
//  SSJNewFundingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJModifyFundingViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "SSJColorSelectViewControllerViewController.h"
#import "SSJModifyFundingTableViewCell.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "SSJCustomKeyboard.h"

#import "FMDB.h"

#define NUM @"+-.0123456789"

@interface SSJModifyFundingViewController ()
@property (nonatomic,strong) UIView *footerView;
@property (nonatomic,strong) TPKeyboardAvoidingTableView *tableView;
@property (nonatomic,strong) UIBarButtonItem *rightBarButton;
@end

@implementation SSJModifyFundingViewController{
    NSArray *_cellTitleArray;
    UITextField *_amountTextField;
    UITextField *_memoTextField;
    UITextField *_nameTextField;
    NSString *_selectParent;
    NSString *_selectColor;
    NSString *_selectIcoin;
    double _amountValue;
}

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {\
        self.statisticsTitle = @"编辑资金账户";
//        self.hideKeyboradWhenTouch = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.item.fundingName;
    _cellTitleArray = @[@"账户名称",@"账户余额",@"备注",@"账户类型",@"选择颜色"];
    _selectColor = self.item.fundingColor;
    _selectParent = self.item.fundingParent;
    _selectIcoin = self.item.fundingIcon;
    _amountValue = self.item.fundingAmount;
    [self.view addSubview:self.tableView];
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _amountValue = [_amountTextField.text doubleValue];
    self.item.fundingMemo = _memoTextField.text;
    self.item.fundingName = _nameTextField.text;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 4) {
        return 80;
    }
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 4) {
        SSJColorSelectViewControllerViewController *colorSelectVC = [[SSJColorSelectViewControllerViewController alloc]init];
        colorSelectVC.fundingColor = _selectColor;
        colorSelectVC.fundingAmount = _amountValue;
        colorSelectVC.fundingName = self.item.fundingName;
        __weak typeof(self) weakSelf = self;
        colorSelectVC.colorSelectedBlock = ^(NSString *selectColor){
            _selectColor = selectColor;
            [weakSelf.tableView reloadData];
        };
        [self.navigationController pushViewController:colorSelectVC animated:YES];
    }else if (indexPath.section == 3) {
        SSJFundingTypeSelectViewController *fundingTypeVC = [[SSJFundingTypeSelectViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
        fundingTypeVC.selectFundID = _selectParent;
        __weak typeof(self) weakSelf = self;
        fundingTypeVC.typeSelectedBlock = ^(NSString *selectParent,NSString *selectIcon){
            _selectParent = selectParent;
            _selectIcoin = selectIcon;
            [weakSelf.tableView reloadData];
        };
        [self.navigationController pushViewController:fundingTypeVC animated:YES];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 4) {
        return self.footerView;
    }
    return nil;
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJModifyFundingCell";
    SSJModifyFundingTableViewCell *NewFundingCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!NewFundingCell) {
        NewFundingCell = [[SSJModifyFundingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NewFundingCell.cellTitle.text = _cellTitleArray[indexPath.section];
    [NewFundingCell.cellTitle sizeToFit];
    switch (indexPath.section) {
        case 0:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.cellDetail.text = self.item.fundingName;
            _nameTextField = NewFundingCell.cellDetail;
            _nameTextField.delegate = self;
        }
            break;
        case 1:{
            _amountTextField = NewFundingCell.cellDetail;
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.cellDetail.text = [NSString stringWithFormat:@"%.2f",_amountValue];
            _amountTextField.delegate = self;

        }
            break;
        case 2:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.cellDetail.text = self.item.fundingMemo;
            _memoTextField = NewFundingCell.cellDetail;
            _memoTextField.delegate = self;
        }
            break;
        case 3:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.typeTitle.text = [self getParentFundingNameWithParentfundingID:_selectParent];
            [NewFundingCell.typeTitle sizeToFit];
            NewFundingCell.typeImage.image = [UIImage imageNamed:_selectIcoin];
            NewFundingCell.cellDetail.enabled = NO;
            NewFundingCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 4:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.colorView.backgroundColor = [UIColor ssj_colorWithHex:_selectColor];
            NewFundingCell.cellDetail.hidden = YES;
            NewFundingCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        default:
            break;
    }
    return NewFundingCell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSInteger existedLength = textField.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = string.length;
    if (textField == _nameTextField || textField == _memoTextField) {
        if (string.length == 0) return YES;
        if (existedLength - selectedLength + replaceLength > 13) {
            if (textField == _nameTextField) {
                [CDAutoHideMessageHUD showMessage:@"账户名称不能超过13个字"];
            }else{
                [CDAutoHideMessageHUD showMessage:@"备注不能超过13个字"];
            }
            return NO;
        }
    }else if (textField == _amountTextField){
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUM] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        if (![string isEqualToString:filtered] || (existedLength - selectedLength + replaceLength > 13)) {
            return NO;
        }
    }
    return YES;
}


#pragma mark - Getter
-(UIView *)footerView{
    if (!_footerView) {
        _footerView = [[UIView alloc]init];
        _footerView.size = CGSizeMake(self.view.width, 80);
        UIButton *comfirmButton = [[UIButton alloc]init];
        comfirmButton.size = CGSizeMake(self.view.width - 40, 40);
        comfirmButton.center = CGPointMake(_footerView.width / 2, _footerView.height / 2);
        comfirmButton.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor];
        comfirmButton.layer.cornerRadius = 4.0f;
        [comfirmButton setTitle:@"保存" forState:UIControlStateNormal];
        [comfirmButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:comfirmButton];
    }
    return _footerView;
}

-(TPKeyboardAvoidingTableView *)tableView{
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc]initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];

        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    }
    return _tableView;
}

-(UIBarButtonItem*)rightBarButton{
    if (!_rightBarButton) {
        _rightBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonClicked:)];
//        _rightBarButton.tintColor = [UIColor ssj_colorWithHex:@"cccccc"];
    }
    return _rightBarButton;
}

#pragma mark - Private
-(void)saveButtonClicked:(id)sender{
    NSString* number=@"^(\\-)?\\d+(\\.\\d{1,2})?$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    if (![numberPre evaluateWithObject:_amountTextField.text]) {
        [CDAutoHideMessageHUD showMessage:@"请输入正确金额"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __block NSString *currentDateStr = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"];
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db,BOOL *rollback){
        if ([db intForQuery:@"SELECT OPERATORTYPE FROM BK_FUND_INFO WHERE CFUNDID = ? AND CUSERID = ?",weakSelf.item.fundingID,SSJUSERID()] == 2) {
            return ;
        }
        if([db intForQuery:@"SELECT COUNT(1) FROM BK_FUND_INFO WHERE CACCTNAME = ? AND CFUNDID <> ? AND CUSERID = ? AND OPERATORTYPE <> 2",_nameTextField.text,weakSelf.item.fundingID,SSJUSERID()] > 0){
            dispatch_async(dispatch_get_main_queue(), ^(){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"已有同名称账户，请换个名称吧。" delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                return;
            });
        }
        if ([_amountTextField.text doubleValue] < self.item.fundingAmount) {
            if (![db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFUNSID , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE  , CBILLDATE ) VALUES (?,?,?,?,?,?,?,?,?,?,?)",SSJUUID(),SSJUSERID(),[NSString stringWithFormat:@"%.2f",weakSelf.item.fundingAmount - [_amountTextField.text doubleValue]],[NSNumber numberWithInt:2],weakSelf.item.fundingID,[NSNumber numberWithDouble:[_amountTextField.text doubleValue]],[NSNumber numberWithDouble:[_amountTextField.text doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),[NSNumber numberWithInt:0],currentDateStr]) {
                *rollback = YES;
            }
            
        }else if ([_amountTextField.text doubleValue] > self.item.fundingAmount) {
            if (![db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFUNSID , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE  , CBILLDATE ) VALUES (?,?,?,?,?,?,?,?,?,?,?)",SSJUUID(),SSJUSERID(),[NSString stringWithFormat:@"%.2f",[_amountTextField.text doubleValue] - weakSelf.item.fundingAmount],@"1",weakSelf.item.fundingID,[NSNumber numberWithDouble:[_amountTextField.text doubleValue]],[NSNumber numberWithDouble:[_amountTextField.text doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),[NSNumber numberWithInt:0],currentDateStr]) {
                *rollback = YES;
            }
        }
        [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = ? WHERE CFUNDID = ? AND CUSERID = ? ",[NSNumber numberWithDouble:[_amountTextField.text doubleValue]] , weakSelf.item.fundingID,SSJUSERID()];
        [db executeUpdate:@"UPDATE BK_FUND_INFO SET CACCTNAME = ? , CPARENT = ? , CCOLOR = ? , CICOIN = (SELECT CICOIN FROM BK_FUND_INFO WHERE CFUNDID = ?) , CMEMO = ? , IVERSION = ? , CWRITEDATE = ? , OPERATORTYPE = ? WHERE CFUNDID = ? AND CUSERID = ? ",_nameTextField.text,_selectParent,_selectColor, _selectParent , _memoTextField.text , @(SSJSyncVersion()), [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] , [NSNumber numberWithInt:1] ,weakSelf.item.fundingID,SSJUSERID()];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }];
    
    [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
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

-(void)closeButtonClicked:(id)sender{
    [self ssj_backOffAction];
}

-(void)rightBarButtonClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        BOOL haveConfigOrNot;
        if ([db intForQuery:@"select * from bk_charge_period_config where ifunsid = ? and cuserid = ? and operatortype != 2",weakSelf.item.fundingID,userid] > 0) {
            haveConfigOrNot = YES;
        }else{
            haveConfigOrNot = NO;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (haveConfigOrNot) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"删除此资金账户，关联的周期记账将会被暂停哦，如需续用请至“更多”进行编辑。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alert.tag = 100;
                [alert show];
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"你确定要删除该资金账户吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alert.tag = 101;
                [alert show];
            }
        });
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    __weak typeof(self) weakSelf = self;
    if (buttonIndex == 1 && alertView.tag == 101) {
        [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db){
            [db executeUpdate:@"UPDATE BK_FUND_INFO SET OPERATORTYPE = 2 , IVERSION = ? , CWRITEDATE = ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithLongLong:SSJSyncVersion()],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],weakSelf.item.fundingID,SSJUSERID()];
            SSJDispatch_main_async_safe(^(){
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            });
        }];
    }else if (buttonIndex == 1 && alertView.tag == 100){
        [[SSJDatabaseQueue sharedInstance]inDatabase:^(FMDatabase *db) {
            if ([db executeUpdate:@"UPDATE BK_FUND_INFO SET OPERATORTYPE = 2 , IVERSION = ? , CWRITEDATE = ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithLongLong:SSJSyncVersion()],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],weakSelf.item.fundingID,SSJUSERID()]) {
                [db executeUpdate:@"update BK_CHARGE_PERIOD_CONFIG set ISTATE = 0 where IFUNSID = ?",weakSelf.item.fundingID];
            }
            SSJDispatch_main_async_safe(^(){
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            });
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
