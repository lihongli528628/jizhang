//
//  SSJCreditCardRepaymentViewController.m
//  SuiShouJi
//
//  Created by ricky on 2016/12/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCreditCardRepaymentViewController.h"

#import "TPKeyboardAvoidingTableView.h"
#import "SSJChargeCircleModifyCell.h"

#import "SSJFinancingHomeHelper.h"

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

@end

@implementation SSJCreditCardRepaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[@[kTitle1,kTitle2,kTitle3],@[kTitle4,kTitle6,kTitle5]];
    self.images = @[@[@"loan_person",@"loan_money",@"loan_memo"],@[@"card_zhanghu",@"",@"loan_expires"]];
    [self.tableView registerClass:[SSJChargeCircleModifyCell class] forCellReuseIdentifier:SSJRepaymentEditeCellIdentifier];
    if (!self.repaymentModel.repaymentId.length) {
        self.repaymentModel.applyDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"];
        self.repaymentModel.repaymentSourceFoundId = [SSJFinancingHomeHelper queryfirstFundItem].fundingID;
        self.repaymentModel.repaymentSourceFoundName = [SSJFinancingHomeHelper queryfirstFundItem].fundingName;
        self.repaymentModel.repaymentSourceFoundImage = [SSJFinancingHomeHelper queryfirstFundItem].fundingIcon;
        NSDate *repaymentDate = [NSDate date];
        if (repaymentDate.day < self.repaymentModel.cardBillingDay) {
            repaymentDate = [repaymentDate dateBySubtractingMonths:2];
        }else {
            repaymentDate = [repaymentDate dateBySubtractingMonths:1];
        }
        self.repaymentModel.repaymentMonth = [repaymentDate formattedDateWithFormat:@"yyyy年MM月"];
    }
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1) {
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
            repaymentModifyCell.cellInput.text = [NSString stringWithFormat:@"%@",self.repaymentModel.repaymentMoney];
        }
        repaymentModifyCell.cellInput.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        repaymentModifyCell.cellInput.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }else if ([title isEqualToString:kTitle3]) {
        repaymentModifyCell.cellInput.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"选填" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        repaymentModifyCell.cellInput.text = self.repaymentModel.memo;
    }else if ([title isEqualToString:kTitle4]) {
        repaymentModifyCell.cellDetail = self.repaymentModel.repaymentSourceFoundName;
        repaymentModifyCell.cellTypeImageName = self.repaymentModel.repaymentSourceFoundImage;
    }else if ([title isEqualToString:kTitle5]) {
        repaymentModifyCell.cellDetail = self.repaymentModel.applyDate;
    }else if ([title isEqualToString:kTitle6]) {
        repaymentModifyCell.cellDetail = self.repaymentModel.repaymentMonth;
    }
    return repaymentModifyCell;
}

#pragma mark - Event
- (void)saveButtonClicked:(id)sender{
    
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
