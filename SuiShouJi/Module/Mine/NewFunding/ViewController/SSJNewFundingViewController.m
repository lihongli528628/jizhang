//
//  SSJNewFundingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewFundingViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJNewFundingTypeCell.h"
#import "SSJColorSelectViewControllerViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "SSJFundingItem.h"
#import "SSJDataSynchronizer.h"

#import "FMDB.h"

#define NUM @"+-.0123456789"


@interface SSJNewFundingViewController ()
@property (nonatomic,strong) TPKeyboardAvoidingTableView *tableview;
@property (nonatomic,strong) UIBarButtonItem *rightButton;
@end

@implementation SSJNewFundingViewController{
    UITextField *_nameTextField;
    UITextField *_amountTextField;
    UITextField *_memoTextField;
    NSString *_selectParent;
    NSString *_selectColor;
    NSString *_selectIcoin;

}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"添加资金账户";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectParent = @"1";
    _selectColor = @"#fe8a65";
    _selectIcoin = @"ft_cash";
    [self.view addSubview:self.tableview];
    self.navigationItem.rightBarButtonItem = self.rightButton;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 4) {
        SSJColorSelectViewControllerViewController *colorSelectVC = [[SSJColorSelectViewControllerViewController alloc]init];
        colorSelectVC.fundingColor = _selectColor;
        colorSelectVC.fundingAmount = [_amountTextField.text doubleValue];
        colorSelectVC.fundingName = _nameTextField.text;
        __weak typeof(self) weakSelf = self;
        colorSelectVC.colorSelectedBlock = ^(NSString *selectColor){
            _selectColor = selectColor;
            [weakSelf.tableview reloadData];
        };
        [self.navigationController pushViewController:colorSelectVC animated:YES];
    }else if (indexPath.section == 3) {
        SSJFundingTypeSelectViewController *fundingTypeVC = [[SSJFundingTypeSelectViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
        __weak typeof(self) weakSelf = self;
        fundingTypeVC.selectFundID = _selectParent;
        fundingTypeVC.typeSelectedBlock = ^(NSString *selectParent , NSString *selectIcon){
            _selectParent = selectParent;
            _selectIcoin = selectIcon;
            [weakSelf.tableview reloadData];
        };
        [self.navigationController pushViewController:fundingTypeVC animated:YES];
    }
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
    SSJNewFundingTypeCell *NewFundingCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!NewFundingCell) {
        NewFundingCell = [[SSJNewFundingTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    switch (indexPath.section) {
        case 0:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.cellText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入账户名称" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
            _nameTextField = NewFundingCell.cellText;
            _nameTextField.delegate = self;
        }
            break;
        case 1:{
            _amountTextField = NewFundingCell.cellText;
            NewFundingCell.cellText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入账户余额" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
            NewFundingCell.cellText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            _amountTextField.delegate = self;
        }
            break;
        case 2:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.cellText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"备注说明" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
            _memoTextField = NewFundingCell.cellText;
            _memoTextField.delegate = self;

        }
            break;
        case 3:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.cellText.text = @"账户类型";
            NewFundingCell.typeLabel.text = [self getParentFundingNameWithParentfundingID:_selectParent];
            NewFundingCell.typeImage.image = [UIImage imageNamed:_selectIcoin];
            [NewFundingCell.typeLabel sizeToFit];
            NewFundingCell.cellText.enabled = NO;
            NewFundingCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 4:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.colorView.backgroundColor = [UIColor ssj_colorWithHex:_selectColor];
            NewFundingCell.cellText.text = @"选择颜色";
            NewFundingCell.cellText.enabled = NO;
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
-(TPKeyboardAvoidingTableView *)tableview{
    if (!_tableview) {
        _tableview = [[TPKeyboardAvoidingTableView alloc]initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableview.backgroundColor = [UIColor clearColor];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    }
    return _tableview;
}

-(UIBarButtonItem *)rightButton{
    if (!_rightButton) {
        _rightButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"checkmark"] style:UIBarButtonItemStyleBordered target:self action:@selector(rightButtonClicked)];
    }
    return _rightButton;
}

#pragma mark - Private
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

-(void)rightButtonClicked{
    NSString* number=@"^(\\-)?\\d+(\\.\\d{1,2})?$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    if (![numberPre evaluateWithObject:_amountTextField.text]) {
        [CDAutoHideMessageHUD showMessage:@"请输入正确金额"];
        return;
    }
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
    }
    if ([_nameTextField.text isEqualToString:@""]) {
        [CDAutoHideMessageHUD showMessage:@"请输入资金账户名称"];
        return;
    }
    NSString *fundId = SSJUUID();
    NSString *fundName = _nameTextField.text;
    double fundAmount = [_amountTextField.text doubleValue];
    NSString *fundMemo = _memoTextField.text;
    NSString *userId = SSJUSERID();

    if([db intForQuery:@"SELECT COUNT(1) FROM BK_FUND_INFO WHERE CACCTNAME = ? AND CFUNDID <> ? AND CUSERID = ? AND OPERATORTYPE <> 2",_nameTextField.text,fundId,SSJUSERID()] > 0){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"已有同名称账户，请换个名称吧。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSInteger maxOrder = [db intForQuery:@"select max(IORDER) from bk_fund_info where cuserid = ? and operatortype != 2",userId];
    BOOL success = [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID,CACCTNAME,CPARENT,CCOLOR,CWRITEDATE,OPERATORTYPE,IVERSION,CMEMO,CUSERID,CADDDATE,IORDER) VALUES (?,?,?,?,?,?,?,?,?,?,?)",fundId,fundName,_selectParent,_selectColor,[[NSDate date] ssj_systemCurrentDateWithFormat:@"YYYY-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithInt:0],@(SSJSyncVersion()),fundMemo,userId,[[NSDate date] ssj_systemCurrentDateWithFormat:@"YYYY-MM-dd HH:mm:ss.SSS"],@(maxOrder + 1)];
    [db executeUpdate:@"UPDATE BK_FUND_INFO SET CICOIN = (SELECT CICOIN FROM BK_FUND_INFO WHERE CFUNDID = ?) WHERE CFUNDID = ?",_selectParent,fundId];
    if (success) {
        [db executeUpdate:@"INSERT INTO BK_FUNS_ACCT (CUSERID,CFUNDID,IBALANCE) VALUES (?,?,?)",SSJUSERID(),fundId,[NSNumber numberWithDouble:fundAmount]];
        if ([_amountTextField.text doubleValue] > 0) {
            [db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFUNSID , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE  , CBILLDATE ) VALUES (?,?,?,?,?,?,?,?,?,?,?)",SSJUUID(),userId,[NSString stringWithFormat:@"%.2f",[_amountTextField.text doubleValue]],@"1",fundId,[NSNumber numberWithDouble:0],[NSNumber numberWithDouble:[_amountTextField.text doubleValue]],[[NSDate date] ssj_systemCurrentDateWithFormat:@"YYYY-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),[NSNumber numberWithInt:0],[[NSDate date] ssj_systemCurrentDateWithFormat:@"YYYY-MM-dd"]];
        }else if([_amountTextField.text doubleValue] < 0){
            [db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFUNSID , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE  , CBILLDATE ) VALUES (?,?,?,?,?,?,?,?,?,?,?)",SSJUUID(),userId,[NSString stringWithFormat:@"%.2f",[_amountTextField.text doubleValue]],@"2",fundId,[NSNumber numberWithDouble:0],[NSNumber numberWithDouble:[_amountTextField.text doubleValue]],[[NSDate date] ssj_systemCurrentDateWithFormat:@"YYYY-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),[NSNumber numberWithInt:0],[[NSDate date] ssj_systemCurrentDateWithFormat:@"YYYY-MM-dd"]];
        }
        SSJFundingItem *item = [[SSJFundingItem alloc]init];
        item.fundingID = fundId;
        item.fundingName = fundName;
        item.fundingIcon = _selectIcoin;
        item.fundingColor = _selectColor;
        item.fundingBalance = fundAmount;
        item.fundingMemo = fundMemo;
        item.fundingParent = _selectParent;
        if (self.finishBlock) {
            self.finishBlock(item);
        }
    }
    
    [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    [db close];
    [self.navigationController popViewControllerAnimated:YES];
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
