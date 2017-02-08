//
//  SSJFundingTransferViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/12.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingTransferViewController.h"
#import "SSJFundingItem.h"
#import "SSJFundingTypeSelectView.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJChargeCircleTimeSelectView.h"
#import "SSJFundingTransferPeriodSelectionView.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "SSJCreditCardItem.h"
#import "SSJChargeCircleModifyCell.h"
#import "SSJFundingTransferDetailViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "FMDB.h"

static NSString *const kTitle1 = @"转出账户";
static NSString *const kTitle2 = @"转入账户";
static NSString *const kTitle3 = @"转账金额";
static NSString *const kTitle4 = @"备注";
static NSString *const kTitle5 = @"转账日期";
static NSString *const kTitle6 = @"循环周期";
static NSString *const kTitle7 = @"周期起始日";
static NSString *const kTitle8 = @"周期结束日";

static NSString * SSJFundingTransferEditeCellIdentifier = @"SSJFundingTransferEditeCellIdentifier";

@interface SSJFundingTransferViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property (nonatomic,strong) UIBarButtonItem *rightButton;

@property (nonatomic,strong) SSJFundingTypeSelectView *transferInFundingTypeSelect;

@property (nonatomic,strong) SSJFundingTypeSelectView *transferOutFundingTypeSelect;

@property(nonatomic, strong) SSJChargeCircleTimeSelectView *chargeCircleTimeView;

@property (nonatomic, strong) SSJFundingTransferPeriodSelectionView *periodSelectionView;

@property(nonatomic, strong) UIView *saveFooterView;

@property(nonatomic, strong) NSArray *titles;

@property(nonatomic, strong) NSArray *images;

@end

@implementation SSJFundingTransferViewController{
    SSJBaseItem *_transferInItem;
    SSJBaseItem *_transferOutItem;
    UITextField *_moneyInput;
    UITextField *_memoInput;
}

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"转账";
        self.hideKeyboradWhenTouch = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
    self.titles = @[@[kTitle1, kTitle2], @[kTitle3, kTitle4, kTitle5, kTitle6]];
    self.images = @[@[@"founds_zhuanchuzhanghu", @"founds_zhuanruzhanghu"], @[@"loan_money", @"loan_memo", @"loan_calendar", @"xuhuan_xuhuan"]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transferTextDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    [self.view addSubview:self.tableView];
    if (self.item != nil) {
        _transferOutItem = [[SSJFundingItem alloc]init];
        _transferInItem = [[SSJFundingItem alloc]init];
        ((SSJFundingItem *)_transferInItem).fundingID = self.item.transferInId;
        ((SSJFundingItem *)_transferInItem).fundingIcon = self.item.transferInImage;
        ((SSJFundingItem *)_transferInItem).fundingName = self.item.transferInName;
        ((SSJFundingItem *)_transferOutItem).fundingID = self.item.transferOutId;
        ((SSJFundingItem *)_transferOutItem).fundingIcon = self.item.transferOutImage;
        ((SSJFundingItem *)_transferOutItem).fundingName = self.item.transferOutName;
        self.navigationItem.rightBarButtonItem = nil;
        self.title = @"编辑转账";
    }else{
        self.item = [[SSJFundingTransferDetailItem alloc]init];
        self.item.transferDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"];
        self.navigationItem.rightBarButtonItem = self.rightButton;
    }
    [self.tableView registerClass:[SSJChargeCircleModifyCell class] forCellReuseIdentifier:SSJFundingTransferEditeCellIdentifier];

}

- (void)updateTitlesAndImages {
    if (_item.cycleType == SSJCyclePeriodTypeOnce) {
        self.titles = @[@[kTitle1, kTitle2], @[kTitle3, kTitle4, kTitle5, kTitle6]];
        self.images = @[@[@"founds_zhuanchuzhanghu", @"founds_zhuanruzhanghu"], @[@"loan_money", @"loan_memo", @"loan_calendar", @"xuhuan_xuhuan"]];
    } else {
        self.titles = @[@[kTitle1, kTitle2], @[kTitle3, kTitle4, kTitle5, kTitle6]];
        self.images = @[@[@"founds_zhuanchuzhanghu", @"founds_zhuanruzhanghu"], @[@"loan_money", @"loan_memo", @"loan_calendar", @"xuhuan_xuhuan"]];
    }
}

//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    if (self.item != nil) {
//        self.navigationItem.rightBarButtonItem = nil;
//    }else{
//    }
//}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return self.saveFooterView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 80 ;
    }
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle1]) {
        if ([_transferOutItem isKindOfClass:[SSJFundingItem class]]) {
            self.transferOutFundingTypeSelect.selectFundID = ((SSJFundingItem *)_transferOutItem).fundingID;
        }else if ([_transferInItem isKindOfClass:[SSJCreditCardItem class]]) {
            self.transferOutFundingTypeSelect.selectFundID = ((SSJCreditCardItem *)_transferOutItem).cardId;
        }
        [self.transferOutFundingTypeSelect show];
    }else if ([title isEqualToString:kTitle2]){
        if ([_transferInItem isKindOfClass:[SSJFundingItem class]]) {
            self.transferInFundingTypeSelect.selectFundID = ((SSJFundingItem *)_transferInItem).fundingID;
        }else if ([_transferInItem isKindOfClass:[SSJCreditCardItem class]]) {
            self.transferInFundingTypeSelect.selectFundID = ((SSJCreditCardItem *)_transferInItem).cardId;
        }
        [self.transferInFundingTypeSelect show];
    }else if ([title isEqualToString:kTitle5]){
        [self.chargeCircleTimeView show];
    }
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.titles[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    NSString *image = [self.images ssj_objectAtIndexPath:indexPath];
    SSJChargeCircleModifyCell *circleModifyCell = [tableView dequeueReusableCellWithIdentifier:SSJFundingTransferEditeCellIdentifier];
    circleModifyCell.cellTitle = title;
    circleModifyCell.cellImageName = image;
    if ([title isEqualToString:kTitle1]) {
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        circleModifyCell.cellInput.hidden = YES;
        if (!_transferOutItem) {
            circleModifyCell.cellDetail = @"请选择转出账户";
        }else{
            if ([_transferOutItem isKindOfClass:[SSJFundingItem class]]) {
                circleModifyCell.cellDetail = ((SSJFundingItem *)_transferOutItem).fundingName;
                circleModifyCell.cellTypeImageName = ((SSJFundingItem *)_transferOutItem).fundingIcon;
            }else if ([_transferOutItem isKindOfClass:[SSJCreditCardItem class]]) {
                circleModifyCell.cellDetail = ((SSJCreditCardItem *)_transferOutItem).cardName;
                circleModifyCell.cellTypeImageName = @"ft_creditcard";
            }

        }
//        _moneyInput = circleModifyCell.cellInput;
    }else if ([title isEqualToString:kTitle2]) {
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        circleModifyCell.cellInput.hidden = YES;
        if (!_transferInItem) {
            circleModifyCell.cellDetail = @"请选择转入账户";
        }else{
            if ([_transferInItem isKindOfClass:[SSJFundingItem class]]) {
                circleModifyCell.cellDetail = ((SSJFundingItem *)_transferInItem).fundingName;
                circleModifyCell.cellTypeImageName = ((SSJFundingItem *)_transferInItem).fundingIcon;
            }else if ([_transferInItem isKindOfClass:[SSJCreditCardItem class]]) {
                circleModifyCell.cellDetail = ((SSJCreditCardItem *)_transferInItem).cardName;
                circleModifyCell.cellTypeImageName = @"ft_creditcard";
            }
        }
    }else if ([title isEqualToString:kTitle3]) {
        circleModifyCell.cellInput.hidden = NO;
        if (self.item.transferMoney.length) {
            circleModifyCell.cellInput.text = [NSString stringWithFormat:@"%.2f",[self.item.transferMoney doubleValue]];
        }
        circleModifyCell.cellInput.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        circleModifyCell.cellInput.keyboardType = UIKeyboardTypeDecimalPad;
        circleModifyCell.cellInput.delegate = self;
        circleModifyCell.cellInput.tag = 100;
        _moneyInput = circleModifyCell.cellInput;
    }else if ([title isEqualToString:kTitle4]) {
        circleModifyCell.cellInput.hidden = NO;
        circleModifyCell.cellInput.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"(选填)" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        circleModifyCell.cellInput.text = self.item.transferMemo;
        circleModifyCell.cellInput.tag = 101;
        circleModifyCell.cellInput.delegate = self;
        _memoInput = circleModifyCell.cellInput;
    }else if ([title isEqualToString:kTitle5]) {
        circleModifyCell.cellInput.hidden = YES;
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        circleModifyCell.cellDetail = self.item.transferDate;
    }else if ([title isEqualToString:kTitle6]) {
        circleModifyCell.cellInput.hidden = YES;
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        circleModifyCell.cellDetail = SSJTitleForCycleType(self.periodSelectionView.selectedType);
    }
    return circleModifyCell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    if (textField == self.transferIntext || textField == self.transferOuttext) {
//        NSInteger existedLength = textField.text.length;
//        NSInteger selectedLength = range.length;
//        NSInteger replaceLength = string.length;
//        if (existedLength - selectedLength + replaceLength > 10) {
//            [CDAutoHideMessageHUD showMessage:@"金额不能超过10位"];
//            return NO;
//        }
//    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 100) {
        self.item.transferMoney = textField.text;
    }else if (textField.tag == 101){
        self.item.transferMemo = textField.text;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Getter
-(UIBarButtonItem *)rightButton{
    if (!_rightButton) {
        _rightButton = [[UIBarButtonItem alloc]initWithTitle:@"转账记录" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
        _rightButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor];
    }
    return _rightButton;
}

-(SSJFundingTypeSelectView *)transferInFundingTypeSelect{
    if (!_transferInFundingTypeSelect) {
        __weak typeof(self) weakSelf = self;
        _transferInFundingTypeSelect = [[SSJFundingTypeSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        if (self.item != nil) {
            _transferOutFundingTypeSelect.selectFundID = self.item.transferInId;
        }
        _transferInFundingTypeSelect.fundingTypeSelectBlock = ^(SSJFundingItem *fundingItem){
            if (![fundingItem.fundingName isEqualToString:@"添加资金新的账户"])
            {
                _transferInItem = fundingItem;
            }else{
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]init];
                NewFundingVC.needLoanOrNot = NO;
                NewFundingVC.addNewFundingBlock = ^(SSJBaseItem *item){
                    if ([item isKindOfClass:[SSJFundingItem class]]) {
                        SSJFundingItem *fundItem = (SSJFundingItem *)item;
                        _transferInItem = fundItem;
                    }else if ([item isKindOfClass:[SSJCreditCardItem class]]){
                        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
                        _transferInItem = cardItem;
                    }
                };
                [weakSelf.navigationController pushViewController:NewFundingVC animated:YES];
            }
            [weakSelf.tableView reloadData];
            [weakSelf.transferInFundingTypeSelect dismiss];
        };
    }
    return _transferInFundingTypeSelect;
}

-(SSJFundingTypeSelectView *)transferOutFundingTypeSelect{
    if (!_transferOutFundingTypeSelect) {
        __weak typeof(self) weakSelf = self;
        _transferOutFundingTypeSelect = [[SSJFundingTypeSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        if (self.item != nil) {
            _transferOutFundingTypeSelect.selectFundID = self.item.transferOutId;
        }
        _transferOutFundingTypeSelect.fundingTypeSelectBlock = ^(SSJFundingItem *fundingItem){
            if (![fundingItem.fundingName isEqualToString:@"添加资金新的账户"])
            {
                _transferOutItem = fundingItem;
            }else{
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]init];
                NewFundingVC.needLoanOrNot = NO;
                NewFundingVC.addNewFundingBlock = ^(SSJBaseItem *item){
                    if ([item isKindOfClass:[SSJFundingItem class]]) {
                        SSJFundingItem *fundItem = (SSJFundingItem *)item;
                        _transferOutItem = fundItem;
                    }else if ([item isKindOfClass:[SSJCreditCardItem class]]){
                        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
                        _transferOutItem = cardItem;
                    }
                };
                [weakSelf.navigationController pushViewController:NewFundingVC animated:YES];
            }
            [weakSelf.tableView reloadData];
            [weakSelf.transferOutFundingTypeSelect dismiss];
        };
    }
    return _transferOutFundingTypeSelect;
}

-(TPKeyboardAvoidingTableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[TPKeyboardAvoidingTableView alloc]initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    }
    return _tableView;
}

-(UIView *)saveFooterView{
    if (_saveFooterView == nil) {
        _saveFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
        UIButton *saveButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _saveFooterView.width - 20, 40)];
        [saveButton setTitle:@"保存" forState:UIControlStateNormal];
        saveButton.layer.cornerRadius = 3.f;
        saveButton.layer.masksToBounds = YES;
        [saveButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        saveButton.center = CGPointMake(_saveFooterView.width / 2, _saveFooterView.height / 2);
        [_saveFooterView addSubview:saveButton];
    }
    return _saveFooterView;
}

-(SSJChargeCircleTimeSelectView *)chargeCircleTimeView{
    if (!_chargeCircleTimeView) {
        _chargeCircleTimeView = [[SSJChargeCircleTimeSelectView alloc]initWithFrame:self.view.bounds];
        _chargeCircleTimeView.maxDate = [NSDate date];
        _chargeCircleTimeView.timeIsTooLateBlock = ^(){
            [CDAutoHideMessageHUD showMessage:@"转账时间不能大于当前时间哦"];
        };
        __weak typeof(self) weakSelf = self;
        _chargeCircleTimeView.timerSetBlock = ^(NSString *dateStr){
            weakSelf.item.transferDate = dateStr;
            [weakSelf.tableView reloadData];
        };
    }
    return _chargeCircleTimeView;
}

- (SSJFundingTransferPeriodSelectionView *)periodSelectionView {
    if (!_periodSelectionView) {
        _periodSelectionView = [[SSJFundingTransferPeriodSelectionView alloc] init];
        [_periodSelectionView addTarget:self action:@selector(periodSelectionViewAction) forControlEvents:UIControlEventValueChanged];
    }
    return _periodSelectionView;
}

#pragma mark - Event
-(void)rightButtonClicked:(id)sender{
    SSJFundingTransferDetailViewController *transferDetailVc = [[SSJFundingTransferDetailViewController alloc]init];
    [self.navigationController pushViewController:transferDetailVc animated:YES];
}

-(void)saveButtonClicked:(id)sender{
    if (_transferInItem == nil || _transferInItem == nil) {
        [CDAutoHideMessageHUD showMessage:@"请选择资金账户"];
        return;
    }
    __block NSString *transferInId;
    __block NSString *transferOutId;
    __block NSString *transferInName;
    __block NSString *transferOutName;
    if ([_transferInItem isKindOfClass:[SSJFundingItem class]]) {
        transferInId = ((SSJFundingItem *)_transferInItem).fundingID;
        transferInName = ((SSJFundingItem *)_transferInItem).fundingName;
    }else{
        transferInId = ((SSJCreditCardItem *)_transferInItem).cardId;
        transferInName = ((SSJCreditCardItem *)_transferInItem).cardName;
    }
    if ([_transferOutItem isKindOfClass:[SSJFundingItem class]]) {
        transferOutId = ((SSJFundingItem *)_transferOutItem).fundingID;
        transferOutName = ((SSJFundingItem *)_transferOutItem).fundingName
        ;
    }else{
        transferOutId = ((SSJCreditCardItem *)_transferOutItem).cardId;
        transferOutName = ((SSJCreditCardItem *)_transferOutItem).cardName;
    }
    if ([transferInId isEqualToString:transferOutId]) {
        [CDAutoHideMessageHUD showMessage:@"请选择不同账户"];
        return;
    }else if ([_moneyInput.text doubleValue] == 0 || [_moneyInput.text isEqualToString:@""]) {
        [CDAutoHideMessageHUD showMessage:@"请输入金额"];
        return;
    }else if (_memoInput.text.length > 15){
        [CDAutoHideMessageHUD showMessage:@"备注最多输入15个字哦"];
        return;
    }
    __block NSString *booksid = SSJGetCurrentBooksType();
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance]asyncInTransaction:^(FMDatabase *db , BOOL *rollback){
        NSString *userid = SSJUSERID();
        NSString *writedate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"YYYY-MM-dd HH:mm:ss.SSS"];
        if (!self.item.transferInChargeId.length && !self.item.transferOutChargeId.length) {
            if (![db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFUNSID , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE  , CBILLDATE , CBOOKSID , CMEMO) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",SSJUUID(),userid,_moneyInput.text,@"3",transferInId,@"",@"",writedate,@(SSJSyncVersion()),[NSNumber numberWithInt:0],weakSelf.item.transferDate,booksid,_memoInput.text])
            {
                *rollback = YES;
                return;
            }
            if (![db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFUNSID , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE  , CBILLDATE , CBOOKSID , CMEMO) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",SSJUUID(),userid,_moneyInput.text,@"4",transferOutId,@"",@"",writedate,@(SSJSyncVersion()),[NSNumber numberWithInt:0],weakSelf.item.transferDate,booksid,_memoInput.text]) {
                *rollback = YES;
                return;
            }
            SSJDispatch_main_async_safe(^(){
                [self.navigationController popViewControllerAnimated:YES];
            });
        }else{
            if (![db executeUpdate:@"update bk_user_charge set imoney = ? , ifunsid = ? , cwritedate = ? , iversion = ? , operatortype = 1 , cmemo = ? , cbilldate = ? where ichargeid = ? and cuserid = ?",[NSNumber numberWithDouble:[_moneyInput.text doubleValue]],transferInId,writedate,@(SSJSyncVersion()),_memoInput.text,weakSelf.item.transferDate,weakSelf.item.transferInChargeId,userid]) {
                *rollback = YES;
                return;
            }
            if (![db executeUpdate:@"update bk_user_charge set imoney = ? , ifunsid = ? , cwritedate = ? , iversion = ? , operatortype = 1 , cmemo = ? , cbilldate = ? where ichargeid = ? and cuserid = ?",[NSNumber numberWithDouble:[_moneyInput.text doubleValue]],transferOutId,writedate,@(SSJSyncVersion()),_memoInput.text,weakSelf.item.transferDate,weakSelf.item.transferOutChargeId,userid]) {
                *rollback = YES;
                return;
            }
            weakSelf.item.transferOutId = transferOutId ? : weakSelf.item.transferOutId;
            weakSelf.item.transferInId = transferInId ? : weakSelf.item.transferInId;
            weakSelf.item.transferOutName = transferOutName ? : weakSelf.item.transferOutName;
            weakSelf.item.transferInName = transferInName ? : weakSelf.item.transferInName;
            weakSelf.item.transferMoney = _moneyInput.text;
            weakSelf.item.transferMemo = _memoInput.text;
            SSJDispatch_main_async_safe(^(){
                if (weakSelf.editeCompleteBlock) {
                    weakSelf.editeCompleteBlock(weakSelf.item);
                }
                [self.navigationController popViewControllerAnimated:YES];
                
            });
        }
        
    }];
    
    [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
}

- (void)periodSelectionViewAction {
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Private

- (void)transferTextDidChange{
    [self setupTextFiledNum:_moneyInput num:2];
}

//-(void)transferTextDidChange{
//    [self setupTextFiledNum:self.transferIntext num:2];
//    [self setupTextFiledNum:self.transferOuttext num:2];
//    if ([self.transferIntext isFirstResponder]) {
//        if (![self.transferIntext.text hasPrefix:@"¥"]&&![self.transferIntext.text isEqualToString:@""]) {
//            self.transferIntext.text = [NSString stringWithFormat:@"¥%@",self.transferIntext.text];
//        }else if ([self.transferIntext.text isEqualToString:@"¥"]){
//            self.transferIntext.text = @"";
//        }
//        self.transferOuttext.text = self.transferIntext.text;
//    }else{
//        if (![self.transferOuttext.text hasPrefix:@"¥"]&&![self.transferIntext.text isEqualToString:@""]) {
//            self.transferOuttext.text = [NSString stringWithFormat:@"¥%@",self.transferOuttext.text];
//        }else if ([self.transferOuttext.text isEqualToString:@"¥"]){
//            self.transferOuttext.text = @"";
//        }
//        self.transferIntext.text = self.transferOuttext.text;
//    }
//}

//-(void)transferOutButtonClicked:(id)sender{
//    [self.transferIntext resignFirstResponder];
//    [self.transferOuttext resignFirstResponder];
//    [self.transferOutFundingTypeSelect show];
//}
//
//-(void)transferInButtonClicked:(id)sender{
//    [self.transferIntext resignFirstResponder];
//    [self.transferOuttext resignFirstResponder];
//    [self.transferInFundingTypeSelect show];
//}


/**
 *   限制输入框小数点(输入框只改变时候调用valueChange)
 *
 *  @param TF  输入框
 *  @param num 小数点后限制位数
 */
-(void)setupTextFiledNum:(UITextField *)TF num:(int)num
{
    NSString *str = [TF.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
    NSArray *arr = [TF.text componentsSeparatedByString:@"."];
    if ([str isEqualToString:@"0."] || [str isEqualToString:@"."]) {
        TF.text = @"0.";
    }else if (str.length == 2) {
        if ([str floatValue] == 0) {
            TF.text = @"0";
        }else if(arr.count < 2){
            TF.text = [NSString stringWithFormat:@"%d",[str intValue]];
        }
    }
    
    if (arr.count > 2) {
        TF.text = [NSString stringWithFormat:@"%@.%@",arr[0],arr[1]];
    }
    
    if (arr.count == 2) {
        NSString * lastStr = arr.lastObject;
        if (lastStr.length > num) {
            TF.text = [NSString stringWithFormat:@"%@.%@",arr[0],[lastStr substringToIndex:num]];
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
