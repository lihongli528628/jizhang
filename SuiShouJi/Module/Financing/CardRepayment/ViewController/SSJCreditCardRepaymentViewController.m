//
//  SSJCreditCardRepaymentViewController.m
//  SuiShouJi
//
//  Created by ricky on 2016/12/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCreditCardRepaymentViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "SSJMonthSelectView.h"

#import "TPKeyboardAvoidingTableView.h"
#import "SSJChargeCircleModifyCell.h"
#import "SSJFundingTypeSelectView.h"
#import "SSJReminderDateSelectView.h"

#import "SSJFinancingHomeHelper.h"
#import "SSJRepaymentStore.h"

#import "SSJFundingItem.h"
#import "SSJCreditCardItem.h"

static NSString *const SSJRepaymentEditeCellIdentifier = @"SSJRepaymentEditeCellIdentifier";

static NSString *const kTitle1 = @"待还款账户";
static NSString *const kTitle2 = @"还款金额";
static NSString *const kTitle3 = @"备注";
static NSString *const kTitle4 = @"付款账户";
static NSString *const kTitle5 = @"还款日期";
static NSString *const kTitle6 = @"还款账单月份";


@interface SSJCreditCardRepaymentViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property(nonatomic, strong) UIView *saveFooterView;

@property(nonatomic, strong) NSArray *titles;

@property(nonatomic, strong) NSArray *images;

@property(nonatomic, strong) SSJFundingTypeSelectView *fundSelectView;

@property(nonatomic, strong) SSJReminderDateSelectView *repaymentTimeView;

@property(nonatomic, strong) SSJMonthSelectView *repaymentMonthSelectView;

@end

@implementation SSJCreditCardRepaymentViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[@[kTitle1,kTitle2,kTitle3],@[kTitle4,kTitle6,kTitle5]];
    self.images = @[@[@"loan_person",@"loan_money",@"loan_memo"],@[@"card_zhanghu",@"",@"loan_expires"]];
    [self.tableView registerClass:[SSJChargeCircleModifyCell class] forCellReuseIdentifier:SSJRepaymentEditeCellIdentifier];
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.repaymentModel.repaymentId.length || self.chargeItem) {
        self.repaymentModel = [SSJRepaymentStore queryRepaymentModelWithChargeItem:self.chargeItem];
    }else {
        self.repaymentModel.applyDate = [NSDate date];
        self.repaymentModel.repaymentSourceFoundId = [SSJFinancingHomeHelper queryfirstFundItem].fundingID;
        self.repaymentModel.repaymentSourceFoundName = [SSJFinancingHomeHelper queryfirstFundItem].fundingName;
        self.repaymentModel.repaymentSourceFoundImage = [SSJFinancingHomeHelper queryfirstFundItem].fundingIcon;
        NSDate *repaymentDate = [NSDate date];
        if (repaymentDate.day < self.repaymentModel.cardBillingDay) {
            repaymentDate = [repaymentDate dateBySubtractingMonths:1];
        }else {
            repaymentDate = repaymentDate;
        }
        self.repaymentModel.repaymentMonth = repaymentDate;
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClicked)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return self.saveFooterView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 80 ;
    }
    return 0.1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle4]) {
        self.fundSelectView.selectFundID = self.repaymentModel.repaymentSourceFoundId;
        [self.fundSelectView show];
    }else if ([title isEqualToString:kTitle5]) {
        self.repaymentTimeView.currentDate = self.repaymentModel.applyDate;
        [self.repaymentTimeView show];
    }else if ([title isEqualToString:kTitle6]) {
        self.repaymentMonthSelectView.currentDate = self.repaymentModel.repaymentMonth;
        [self.repaymentMonthSelectView show];
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.titles[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    NSString *image = [self.images ssj_objectAtIndexPath:indexPath];
    SSJChargeCircleModifyCell *repaymentModifyCell = [tableView dequeueReusableCellWithIdentifier:SSJRepaymentEditeCellIdentifier];
    repaymentModifyCell.cellTitle = title;
    repaymentModifyCell.cellImageName = image;
    if ([title isEqualToString:kTitle2] || [title isEqualToString:kTitle3]) {
        repaymentModifyCell.cellInput.hidden = NO;
    }else {
        repaymentModifyCell.cellInput.hidden = YES;
    }
    if (indexPath.section == 1) {
        repaymentModifyCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        repaymentModifyCell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([title isEqualToString:kTitle1]) {
        repaymentModifyCell.cellDetail = self.repaymentModel.cardName;
    }else if ([title isEqualToString:kTitle2]) {
        if (self.repaymentModel.repaymentMoney != 0) {
            repaymentModifyCell.cellInput.text = [[NSString stringWithFormat:@"%@",self.repaymentModel.repaymentMoney] ssj_moneyDecimalDisplayWithDigits:2];
        }
        repaymentModifyCell.cellInput.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        repaymentModifyCell.cellInput.tag = 100;
        repaymentModifyCell.cellInput.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }else if ([title isEqualToString:kTitle3]) {
        repaymentModifyCell.cellInput.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"选填" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        repaymentModifyCell.cellInput.tag = 101;
        repaymentModifyCell.cellInput.text = self.repaymentModel.memo;
    }else if ([title isEqualToString:kTitle4]) {
        repaymentModifyCell.cellDetail = self.repaymentModel.repaymentSourceFoundName;
        repaymentModifyCell.cellTypeImageName = self.repaymentModel.repaymentSourceFoundImage;
    }else if ([title isEqualToString:kTitle5]) {
        repaymentModifyCell.cellDetail = [self.repaymentModel.applyDate formattedDateWithFormat:@"yyyy-MM-dd"];
    }else if ([title isEqualToString:kTitle6]) {
        repaymentModifyCell.cellDetail = [self.repaymentModel.repaymentMonth formattedDateWithFormat:@"yyyy年MM月"];
    }
    return repaymentModifyCell;
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 100) {
        self.repaymentModel.repaymentMoney = [NSDecimalNumber decimalNumberWithString:textField.text];
    }else if (textField.tag == 101){
        self.repaymentModel.memo = textField.text;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Event
- (void)textDidChange:(NSNotification *)notification {
    UITextField *textField = notification.object;
    if ([textField isKindOfClass:[UITextField class]]) {
        if (textField.tag == 100) {
            [self setupTextFiledNum:textField num:2];
            self.repaymentModel.repaymentMoney = [NSDecimalNumber decimalNumberWithString:textField.text];
        }else if (textField.tag == 101){
            self.repaymentModel.memo = textField.text;
        }
    }
}


- (void)saveButtonClicked:(id)sender{
    if (self.repaymentModel.repaymentMoney == 0) {
        [CDAutoHideMessageHUD showMessage:@"请输入还款金额"];
        return;
    }
    if ([[NSDate dateWithYear:self.repaymentModel.repaymentMonth.year month:self.repaymentModel.repaymentMonth.month day:self.repaymentModel.cardBillingDay] isLaterThan:self.repaymentModel.applyDate]) {
        [CDAutoHideMessageHUD showMessage:@"本期账单还没有出不能还款哦"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [SSJRepaymentStore saveRepaymentWithRepaymentModel:self.repaymentModel Success:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {

    }];
}

- (void)deleteButtonClicked{
    __weak typeof(self) weakSelf = self;
    [SSJRepaymentStore deleteRepaymentWithRepaymentModel:self.repaymentModel Success:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - Getter
- (TPKeyboardAvoidingTableView *)tableView{
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc]initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    }
    return _tableView;
}

- (UIView *)saveFooterView{
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

-(SSJFundingTypeSelectView *)fundSelectView{
    if (!_fundSelectView) {
        _fundSelectView = [[SSJFundingTypeSelectView alloc]init];
        __weak typeof(self) weakSelf = self;
        _fundSelectView.fundingTypeSelectBlock = ^(SSJFundingItem *item){
            if (item.fundingID.length) {
                weakSelf.repaymentModel.repaymentSourceFoundId = item.fundingID;
                weakSelf.repaymentModel.repaymentSourceFoundName = item.fundingName;
                weakSelf.repaymentModel.repaymentSourceFoundImage = item.fundingIcon;
                [weakSelf.tableView reloadData];
                [weakSelf.fundSelectView dismiss];
            }else{
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]init];
                NewFundingVC.needLoanOrNot = NO;
                NewFundingVC.addNewFundingBlock = ^(SSJBaseItem *item){
                    if ([item isKindOfClass:[SSJFundingItem class]]) {
                        SSJFundingItem *fundItem = (SSJFundingItem *)item;
                        weakSelf.repaymentModel.repaymentSourceFoundId = fundItem.fundingID;
                        weakSelf.repaymentModel.repaymentSourceFoundName = fundItem.fundingName;
                        weakSelf.repaymentModel.repaymentSourceFoundImage = fundItem.fundingIcon;
                        [weakSelf.tableView reloadData];
                    }else if ([item isKindOfClass:[SSJCreditCardItem class]]){
                        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
                        weakSelf.repaymentModel.repaymentSourceFoundId = cardItem.cardId;
                        weakSelf.repaymentModel.repaymentSourceFoundName = cardItem.cardName;
                        weakSelf.repaymentModel.repaymentSourceFoundImage = @"ft_creditcard";
                        [weakSelf.tableView reloadData];
                    }
                    
                };
                [weakSelf.fundSelectView dismiss];
                [weakSelf.navigationController pushViewController:NewFundingVC animated:YES];
            }
        };
    }
    return _fundSelectView;
}

- (SSJReminderDateSelectView *)repaymentTimeView{
    if (!_repaymentTimeView) {
        _repaymentTimeView = [[SSJReminderDateSelectView alloc]initWithFrame:self.view.bounds];
        __weak typeof(self) weakSelf = self;
        _repaymentTimeView.dateSetBlock = ^(NSDate *date){
            weakSelf.repaymentModel.applyDate = date;
            [weakSelf.tableView reloadData];
        };
    }
    return _repaymentTimeView;
}

- (SSJMonthSelectView *)repaymentMonthSelectView{
    if (!_repaymentMonthSelectView) {
        _repaymentMonthSelectView = [[SSJMonthSelectView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        __weak typeof(self) weakSelf = self;
        _repaymentMonthSelectView.timerSetBlock = ^(NSDate *date){
            weakSelf.repaymentModel.repaymentMonth = date;
            [weakSelf.tableView reloadData];
        };
    }
    return _repaymentMonthSelectView;
}

#pragma mark - Private
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
