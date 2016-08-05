//
//  SSJBudgetEditViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetEditViewController.h"
#import "SSJBudgetListViewController.h"
#import "SSJBookKeepingHomeViewController.h"
#import "SSJBudgetEditPeriodSelectionView.h"
#import "SSJBudgetEditAccountDaySelectionView.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJBudgetEditLabelCell.h"
#import "SSJBudgetEditTextFieldCell.h"
#import "SSJBudgetEditSwitchCtrlCell.h"
#import "SSJBudgetDatabaseHelper.h"
#import "SSJCustomKeyboard.h"
#import "SSJDatePeriod.h"
#import "SSJDataSynchronizer.h"
#import "SSJUserTableManager.h"

static NSString *const kBudgetEditLabelCellId = @"kBudgetEditLabelCellId";
static NSString *const kBudgetEditTextFieldCellId = @"kBudgetEditTextFieldCellId";
static NSString *const kBudgetEditSwitchCtrlCellId = @"kBudgetEditSwitchCtrlCellId";

static NSString *const kBudgetTypeTitle = @"预算类别";
static NSString *const kBooksTypeTitle = @"账本类型";
static NSString *const kAutoContinueTitle = @"自动续用";
static NSString *const kBudgetMoneyTitle = @"金额";
static NSString *const kBudgetRemindTitle = @"预算提醒";
static NSString *const kBudgetRemindScaleTitle = @"预算占比提醒";
static NSString *const kBudgetPeriodTitle = @"周期";
static NSString *const kAccountDayTitle = @"结算日";

//  预算金额输入框
static const NSInteger kBudgetMoneyTextFieldTag = 1000;

//  预算提醒百分比输入框
static const NSInteger kBudgetRemindScaleTextFieldTag = 1001;

@interface SSJBudgetEditViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) UIButton *saveBtn;

@property (nonatomic, strong) SSJBudgetEditPeriodSelectionView *periodSelectionView;

@property (nonatomic, strong) SSJBudgetEditAccountDaySelectionView *accountDaySelectionView;

@property (nonatomic, strong) NSArray *cellTitles;

@property (nonatomic, strong) NSArray *budgetTypeList;

@property (nonatomic, strong) NSArray *budgetList;

@property (nonatomic, strong) NSDictionary *budgetTypeMap;

@property (nonatomic, copy) NSString *bookName;

//  提醒百分比
@property (nonatomic) double remindPercent;

@end

@implementation SSJBudgetEditViewController

#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
        self.remindPercent = 0.1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.model) {
        self.navigationItem.title = @"编辑预算";
        UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"budget_delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteBudgetAction)];
        self.navigationItem.rightBarButtonItem = deleteItem;
    } else {
        self.navigationItem.title = @"添加预算";
    }
    
    [self queryData];
    [self.view addSubview:self.tableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cellTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.cellTitles ssj_safeObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self reuseCellIdForIndexPath:indexPath] forIndexPath:indexPath];
    [self updateCell:cell forIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellTitle = [self.cellTitles ssj_objectAtIndexPath:indexPath];
    if ([cellTitle isEqualToString:kBudgetTypeTitle]) {
        //  预算类别
        return 54;
    } else if ([cellTitle isEqualToString:kBooksTypeTitle]) {
        //  账本类型
        return 54;
    } else if ([cellTitle isEqualToString:kAutoContinueTitle]) {
        //  自动续用
        return 66;
    } else if ([cellTitle isEqualToString:kBudgetMoneyTitle]) {
        //  预算金额
        return 54;
    } else if ([cellTitle isEqualToString:kBudgetRemindTitle]) {
        //  预算提醒
        return 49;
    } else if ([cellTitle isEqualToString:kBudgetRemindScaleTitle]) {
        //  预算占比提醒
        return 62;
    } else if ([cellTitle isEqualToString:kBudgetPeriodTitle]
               || [cellTitle isEqualToString:kAccountDayTitle]) {
        //  周期、结算日
        return 54;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *title = [self.cellTitles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kBudgetPeriodTitle]) {
        [self.periodSelectionView show];
    } else if ([title isEqualToString:kAccountDayTitle]) {
        [self.accountDaySelectionView show];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == kBudgetMoneyTextFieldTag) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        text = [text stringByReplacingOccurrencesOfString:@"￥" withString:@""];
        text = [text ssj_reserveDecimalDigits:2 intDigits:0];
        textField.text = [NSString stringWithFormat:@"￥%@", text];
        
        self.model.budgetMoney = [text doubleValue];
        self.model.remindMoney = self.remindPercent * self.model.budgetMoney;
        
        SSJBudgetEditTextFieldCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:4]];
        if (cell) {
            [self updateRemindMoneyScaleWithCell:cell];
            [self updateRemindMoneyWithCell:cell];
        }
        return NO;
        
    } else if (textField.tag == kBudgetRemindScaleTextFieldTag) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = [text ssj_reserveDecimalDigits:1 intDigits:0];

        self.remindPercent = MIN([textField.text doubleValue], 100) / 100;
        self.model.remindMoney = self.remindPercent * self.model.budgetMoney;
        
        SSJBudgetEditTextFieldCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:4]];
        if (cell) {
            [self updateRemindMoneyWithCell:cell];
        }
        
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == kBudgetMoneyTextFieldTag) {
        SSJBudgetEditTextFieldCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
        cell.textField.text = [NSString stringWithFormat:@"￥%.2f", self.model.budgetMoney];
    } else if (textField.tag == kBudgetRemindScaleTextFieldTag) {
        SSJBudgetEditTextFieldCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:4]];
        if (cell) {
            [self updateRemindMoneyScaleWithCell:cell];
        }
    }
}

#pragma mark - Event
- (void)goBackAction {
    // 如果没有预算直接返回首页
    if (_budgetList.count == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [super goBackAction];
    }
}

- (void)deleteBudgetAction {
    __weak typeof(self) weakSelf = self;
    SSJAlertViewAction *cancel = [SSJAlertViewAction actionWithTitle:@"取消" handler:NULL];
    SSJAlertViewAction *sure = [SSJAlertViewAction actionWithTitle:@"确认" handler:^(SSJAlertViewAction *action) {
        [weakSelf deleteBudget];
    }];
    [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"您确认删除该预算" action:cancel, sure, nil];
}

- (void)autoContinueSwitchCtrlAction:(UISwitch *)switchCtrl {
    self.model.isAutoContinued = switchCtrl.isOn;
}

- (void)remindSwitchCtrlAction:(UISwitch *)switchCtrl {
    self.model.isRemind = switchCtrl.isOn;
    [self updateCellTitles];
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)periodSelectionViewAction {
    SSJDatePeriodType periodType = SSJDatePeriodTypeUnknown;
    switch (self.periodSelectionView.periodType) {
        case SSJBudgetPeriodTypeWeek:
            periodType = SSJDatePeriodTypeWeek;
            break;
            
        case SSJBudgetPeriodTypeMonth:
            periodType = SSJDatePeriodTypeMonth;
            break;
            
        case SSJBudgetPeriodTypeYear:
            periodType = SSJDatePeriodTypeYear;
            
            break;
    }
    
    SSJDatePeriod *period = [SSJDatePeriod datePeriodWithPeriodType:periodType date:[NSDate date]];
    
    self.model.beginDate = [period.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
    self.model.endDate = [period.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    self.model.type = self.periodSelectionView.periodType;
    self.accountDaySelectionView.periodType = self.periodSelectionView.periodType;
    
    [self.tableView reloadData];
}

- (void)saveButtonAction {
    [self updateSaveButtonState:YES];
    
    //  检测是否有预算类别、开始时间、预算周期和当前保存的预算冲突的配置
    [SSJBudgetDatabaseHelper checkIfConflictBudgetModel:self.model success:^(BOOL isConficted) {
        if (isConficted) {
            [self updateSaveButtonState:NO];
            SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
            [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:[self alertMessageForConflictedBudget] action:action, nil];
        } else {
            [SSJBudgetDatabaseHelper saveBudgetModel:self.model success:^{
                //  保存成功后自动同步
                [self syncIfNeeded];
                [self updateSaveButtonState:NO];
                [self ssj_backOffAction];
            } failure:^(NSError * _Nonnull error) {
                [self updateSaveButtonState:NO];
                SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
                [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:SSJ_ERROR_MESSAGE action:action, nil];
            }];
        }
    } failure:^(NSError * _Nonnull error) {
        [self updateSaveButtonState:NO];
        SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:SSJ_ERROR_MESSAGE action:action, nil];
    }];
}

#pragma mark - Private
- (void)queryData {
    [SSJBudgetDatabaseHelper queryForCurrentBudgetListWithSuccess:^(NSArray<SSJBudgetModel *> * _Nonnull result) {
        _budgetList = result;
        [self queryBillTypeList];
    } failure:^(NSError * _Nullable error) {
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
}

- (void)queryBillTypeList {
    [self.view ssj_showLoadingIndicator];
    [SSJBudgetDatabaseHelper queryBillTypeMapWithSuccess:^(NSDictionary * _Nonnull billTypeMap) {
        [self.view ssj_hideLoadingIndicator];
        self.budgetTypeMap = billTypeMap;
        
        //  如果是新建预算，需要重新创建个预算模型
        if (!self.model) {
            [self initBudgetModel];
        }
        
        [self updateCellTitles];
        _bookName = [SSJBudgetDatabaseHelper queryBookNameForBookId:self.model.booksId];
        [self.tableView reloadData];
        if (self.tableView.tableFooterView != self.footerView) {
            self.tableView.tableFooterView = self.footerView;
        }
        
        self.periodSelectionView.periodType = self.model.type;
        
        self.accountDaySelectionView.periodType = self.model.type;
        self.accountDaySelectionView.endDate = [NSDate dateWithString:self.model.endDate formatString:@"yyyy-MM-dd"];
        self.accountDaySelectionView.endOfMonth = self.model.isLastDay;
        
    } failure:^(NSError * _Nonnull error) {
        [self.view ssj_hideLoadingIndicator];
        SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:SSJ_ERROR_MESSAGE action:action, nil];
    }];
}

- (void)initBudgetModel {
    SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"currentBooksId"] forUserId:SSJUSERID()];
    SSJDatePeriod *period = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:[NSDate date]];
    self.model = [[SSJBudgetModel alloc] init];
    self.model.ID = SSJUUID();
    self.model.userId = SSJUSERID();
    self.model.booksId = userItem.currentBooksId ? : SSJUSERID();
    self.model.billIds = [self.budgetTypeMap allKeys];
    self.model.type = 1;
    self.model.budgetMoney = 3000;
    self.model.remindMoney = self.model.budgetMoney * self.remindPercent;
    self.model.beginDate = [period.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
    self.model.endDate = [period.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    self.model.isAutoContinued = YES;
    self.model.isRemind = YES;
    self.model.isAlreadyReminded = NO;
    self.model.isLastDay = YES;
}

- (NSString *)reuseCellIdForIndexPath:(NSIndexPath *)indexPath {
    NSString *cellTitle = [self.cellTitles ssj_objectAtIndexPath:indexPath];
    if ([cellTitle isEqualToString:kBudgetTypeTitle]
        || [cellTitle isEqualToString:kBudgetPeriodTitle]
        || [cellTitle isEqualToString:kBooksTypeTitle]
        || [cellTitle isEqualToString:kAccountDayTitle]) {
        return kBudgetEditLabelCellId;
    } else if ([cellTitle isEqualToString:kBudgetMoneyTitle]
               || [cellTitle isEqualToString:kBudgetRemindScaleTitle]) {
        return kBudgetEditTextFieldCellId;
    } else if ([cellTitle isEqualToString:kAutoContinueTitle]
               || [cellTitle isEqualToString:kBudgetRemindTitle]) {
        return kBudgetEditSwitchCtrlCellId;
    } else {
        return @"";
    }
}

- (void)updateRemindMoneyWithCell:(SSJBudgetEditTextFieldCell *)cell {
    NSString *remindMoney = [NSString stringWithFormat:@"%.2f", self.model.remindMoney];
    NSMutableAttributedString *detailText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"当预算金额剩余%@元时，即会提醒您哦！", remindMoney]];
    [detailText setAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"eb4a64"]} range:NSMakeRange(7, remindMoney.length)];
    cell.detailTextLabel.attributedText = detailText;
    [cell.detailTextLabel sizeToFit];
    [cell setNeedsLayout];
}

- (void)updateCell:(__kindof UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    NSString *cellTitle = [self.cellTitles ssj_objectAtIndexPath:indexPath];
    cell.textLabel.text = cellTitle;
    [cell.textLabel sizeToFit];
    [cell setNeedsLayout];
    
    if ([cellTitle isEqualToString:kBudgetTypeTitle]) {
        //  预算类别
        SSJBudgetEditLabelCell *budgetTypeCell = cell;
        budgetTypeCell.subtitleLab.text = [self budgetTypeNames];
        budgetTypeCell.detailTextLabel.text = nil;
        [budgetTypeCell.detailTextLabel sizeToFit];
        budgetTypeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        budgetTypeCell.customAccessoryType = UITableViewCellAccessoryNone;

    } else if ([cellTitle isEqualToString:kBooksTypeTitle]) {
        //  账本类型
        SSJBudgetEditLabelCell *bookTypeCell = cell;
        bookTypeCell.subtitleLab.text = _bookName;
        bookTypeCell.detailTextLabel.text = nil;
        [bookTypeCell.detailTextLabel sizeToFit];
        bookTypeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        bookTypeCell.customAccessoryType = UITableViewCellAccessoryNone;
        
    } else if ([cellTitle isEqualToString:kAutoContinueTitle]) {
        //  自动续用
        SSJBudgetEditSwitchCtrlCell *autoContinueCell = cell;
        [autoContinueCell.switchCtrl removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
        [autoContinueCell.switchCtrl addTarget:self action:@selector(autoContinueSwitchCtrlAction:) forControlEvents:UIControlEventValueChanged];
        [autoContinueCell.switchCtrl setOn:self.model.isAutoContinued];
        autoContinueCell.detailTextLabel.text = @"系统会自动为您自动续用您设置的预算内容";
        [autoContinueCell.detailTextLabel sizeToFit];
        
    } else if ([cellTitle isEqualToString:kBudgetMoneyTitle]) {
        //  预算金额
        SSJBudgetEditTextFieldCell *budgetMoneyCell = cell;
        budgetMoneyCell.textField.tag = kBudgetMoneyTextFieldTag;
        budgetMoneyCell.textField.text = [NSString stringWithFormat:@"￥%.2f", self.model.budgetMoney];
        budgetMoneyCell.textField.inputView = [SSJCustomKeyboard sharedInstance];
        budgetMoneyCell.textField.delegate = self;
        budgetMoneyCell.textField.rightView = nil;
        budgetMoneyCell.detailTextLabel.text = nil;
        budgetMoneyCell.detailTextLabel.attributedText = nil;
        [budgetMoneyCell.detailTextLabel sizeToFit];
        
    } else if ([cellTitle isEqualToString:kBudgetRemindTitle]) {
        //  预算提醒
        SSJBudgetEditSwitchCtrlCell *budgetRemindCell = cell;
        [budgetRemindCell.switchCtrl removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
        [budgetRemindCell.switchCtrl addTarget:self action:@selector(remindSwitchCtrlAction:) forControlEvents:UIControlEventValueChanged];
        [budgetRemindCell.switchCtrl setOn:self.model.isRemind];
        budgetRemindCell.detailTextLabel.text = nil;
        [budgetRemindCell.detailTextLabel sizeToFit];
        
    } else if ([cellTitle isEqualToString:kBudgetRemindScaleTitle]) {
        //  刷新预算占比提醒
        SSJBudgetEditTextFieldCell *budgetScaleCell = cell;
        budgetScaleCell.textField.tag = kBudgetRemindScaleTextFieldTag;
        budgetScaleCell.textField.inputView = [SSJCustomKeyboard sharedInstance];
        budgetScaleCell.textField.delegate = self;
        
        [self updateRemindMoneyScaleWithCell:budgetScaleCell];
        [self updateRemindMoneyWithCell:budgetScaleCell];
        
        UILabel *percentLab = [[UILabel alloc] init];
        percentLab.font = [UIFont systemFontOfSize:18];
        percentLab.text = @"％";
        percentLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [percentLab sizeToFit];
        
        budgetScaleCell.textField.rightView = percentLab;
        budgetScaleCell.textField.rightViewMode = UITextFieldViewModeAlways;
        
    } else if ([cellTitle isEqualToString:kBudgetPeriodTitle]) {
        //  周期
        SSJBudgetEditLabelCell *budgetPeriodCell = cell;
        budgetPeriodCell.subtitleLab.text = [self budgetPeriod];
        budgetPeriodCell.detailTextLabel.text = nil;
        [budgetPeriodCell.detailTextLabel sizeToFit];
        budgetPeriodCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        budgetPeriodCell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
        
    } else if ([cellTitle isEqualToString:kAccountDayTitle]) {
        //  结算日
        SSJBudgetEditLabelCell *budgetPeriodCell = cell;
        budgetPeriodCell.subtitleLab.text = [self accountday];
        budgetPeriodCell.detailTextLabel.text = nil;
        [budgetPeriodCell.detailTextLabel sizeToFit];
        budgetPeriodCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        budgetPeriodCell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
    }
}

- (NSString *)accountday {
    // 这里没有判断一种情况，如果是2月份，并且只有28天，选择的截止日是28日的话，如何区分是每月28号还是每月最后一天
    NSString *accountday = nil;
    NSDate *endDate = [NSDate dateWithString:_model.endDate formatString:@"yyyy-MM-dd"];
    
    switch (_model.type) {
        case SSJBudgetPeriodTypeWeek:
            accountday = [self stringForWeekday:endDate.weekday];
            break;
            
        case SSJBudgetPeriodTypeMonth:
            if (_model.isLastDay || endDate.day > 28) {
                accountday = @"每月最后一天";
            } else {
                accountday = [NSString stringWithFormat:@"每月%d日", (int)endDate.day];
            }
            break;
            
        case SSJBudgetPeriodTypeYear:
            if (endDate.month == 2) {
                if (_model.isLastDay || endDate.day > 28) {
                    accountday = @"每年2月末";
                } else {
                    accountday = [NSString stringWithFormat:@"每年2月%d日", (int)endDate.day];
                }
            } else {
                accountday = [NSString stringWithFormat:@"每年%@", [endDate formattedDateWithFormat:@"M月d日"]];
            }
            break;
    }
    
    return accountday;
}

- (NSString *)stringForWeekday:(NSInteger)weekday {
    switch (weekday) {
        case 1:     return @"每周日";
        case 2:     return @"每周一";
        case 3:     return @"每周二";
        case 4:     return @"每周三";
        case 5:     return @"每周四";
        case 6:     return @"每周五";
        case 7:     return @"每周六";
        default:    return @"";
    }
}

- (void)updateCellTitles {
    if (self.model.isRemind) {
        self.cellTitles = @[@[kBudgetTypeTitle], @[kBooksTypeTitle], @[kAutoContinueTitle], @[kBudgetMoneyTitle], @[kBudgetRemindTitle, kBudgetRemindScaleTitle], @[kBudgetPeriodTitle, kAccountDayTitle]];
    } else {
        self.cellTitles = @[@[kBudgetTypeTitle], @[kBooksTypeTitle], @[kAutoContinueTitle], @[kBudgetMoneyTitle], @[kBudgetRemindTitle], @[kBudgetPeriodTitle, kAccountDayTitle]];
    }
}

- (void)updateRemindMoneyScaleWithCell:(SSJBudgetEditTextFieldCell *)cell {
    if (self.model.budgetMoney <= 0) {
        cell.textField.text = @"0.0";
    } else {
        cell.textField.text = [NSString stringWithFormat:@"%.1f", (self.model.remindMoney / self.model.budgetMoney) * 100];
    }
}

- (NSString *)budgetPeriod {
    switch (self.model.type) {
        case 0:
            return @"每周";
        case 1:
            return @"每月";
        case 2:
            return @"每年";
        default:
            return nil;
    }
}

- (NSString *)budgetTypeNames {
    // 目前只显示所有支出类别，以后增加用户自选类别时再加上
//    if (self.model.billIds.count < self.budgetTypeMap.count) {
//        NSMutableArray *typeNameArr = [NSMutableArray arrayWithCapacity:5];
//        for (NSString *typeId in self.model.billIds) {
//            [typeNameArr addObject:self.budgetTypeMap[typeId]];
//            if (typeNameArr.count == 5) {
//                break;
//            }
//        }
//        return [typeNameArr componentsJoinedByString:@","];
//    }
    
    return @"所有支出类目";
}

//  已有冲突预算配置的提示信息
- (NSString *)alertMessageForConflictedBudget {
    switch (self.model.type) {
        case 0:
            return @"亲爱的用户，您已设置过相同支出类别的周预算了，请选其它周期或在原有周预算上编辑吧！";
        case 1:
            return @"亲爱的用户，您已设置过相同支出类别的月预算了，请选其它周期或在原有月预算上编辑吧！";
        case 2:
            return @"亲爱的用户，您已设置过相同支出类别的年预算了，请选其它周期或在原有年预算上编辑吧！";
    }
}

- (void)updateSaveButtonState:(BOOL)isSaving {
    if (isSaving) {
        self.saveBtn.enabled = NO;
        [self.saveBtn ssj_showLoadingIndicator];
        [self.saveBtn setTitle:nil forState:UIControlStateNormal];
    } else {
        self.saveBtn.enabled = YES;
        [self.saveBtn ssj_hideLoadingIndicator];
        [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    }
}

- (void)deleteBudget {
    [self.view ssj_showLoadingIndicator];
    [SSJBudgetDatabaseHelper deleteBudgetWithID:self.model.ID success:^{
        [self.view ssj_hideLoadingIndicator];
        
        [self syncIfNeeded];
        
        // 如果删除后没有预算直接返回首页
        if (_budgetList.count == 1) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            SSJBudgetListViewController *budgetListVC = [self ssj_previousViewControllerBySubtractingIndex:2];
            if ([budgetListVC isKindOfClass:[SSJBudgetListViewController class]]) {
                [self.navigationController popToViewController:budgetListVC animated:YES];
            }
        }
    } failure:^(NSError * _Nullable error) {
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showAlertViewWithTitle:nil message:SSJ_ERROR_MESSAGE action:[SSJAlertViewAction actionWithTitle:@"确认" handler:NULL], nil];
    }];
}

- (void)syncIfNeeded {
    [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
}

#pragma mark - Getter
- (TPKeyboardAvoidingTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:0.1];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView registerClass:[SSJBudgetEditLabelCell class] forCellReuseIdentifier:kBudgetEditLabelCellId];
        [_tableView registerClass:[SSJBudgetEditTextFieldCell class] forCellReuseIdentifier:kBudgetEditTextFieldCellId];
        [_tableView registerClass:[SSJBudgetEditSwitchCtrlCell class] forCellReuseIdentifier:kBudgetEditSwitchCtrlCellId];
    }
    return _tableView;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 116)];
        _footerView.backgroundColor = [UIColor clearColor];
        [_footerView addSubview:self.saveBtn];
    }
    return _footerView;
}

- (UIButton *)saveBtn {
    if (!_saveBtn) {
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveBtn.frame = CGRectMake(22, 22, self.view.width - 44, 44);
        _saveBtn.layer.cornerRadius = 3;
        _saveBtn.clipsToBounds = YES;
        _saveBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_saveBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
        [_saveBtn addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
}

- (SSJBudgetEditPeriodSelectionView *)periodSelectionView {
    if (!_periodSelectionView) {
        _periodSelectionView = [[SSJBudgetEditPeriodSelectionView alloc] init];
        [_periodSelectionView addTarget:self action:@selector(periodSelectionViewAction) forControlEvents:UIControlEventValueChanged];
    }
    return _periodSelectionView;
}

- (SSJBudgetEditAccountDaySelectionView *)accountDaySelectionView {
    if (!_accountDaySelectionView) {
        __weak typeof(self) wself = self;
        _accountDaySelectionView = [[SSJBudgetEditAccountDaySelectionView alloc] initWithFrame:CGRectMake(0, 0, self.viewIfLoaded.width, 200)];
        _accountDaySelectionView.periodType = self.model.type;
        _accountDaySelectionView.sureAction = ^(SSJBudgetEditAccountDaySelectionView *view) {
            wself.model.beginDate = [view.beginDate formattedDateWithFormat:@"yyyy-MM-dd"];
            wself.model.endDate = [view.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
            wself.model.isLastDay = view.endOfMonth;
            [wself.tableView reloadData];
        };
    }
    return _accountDaySelectionView;
}

@end
