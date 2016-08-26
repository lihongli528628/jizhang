//
//  SSJAddOrEditLoanViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAddOrEditLoanViewController.h"
#import "SSJNewFundingViewController.h"
#import "SSJReminderEditeViewController.h"
#import "SSJLoanListViewController.h"
#import "SSJAddOrEditLoanLabelCell.h"
#import "SSJAddOrEditLoanTextFieldCell.h"
#import "SSJAddOrEditLoanMultiLabelCell.h"
#import "SSJLoanFundAccountSelectionView.h"
#import "SSJLoanDateSelectionView.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJLoanHelper.h"
#import "SSJLocalNotificationStore.h"

static NSString *const kAddOrEditLoanLabelCellId = @"SSJAddOrEditLoanLabelCell";
static NSString *const kAddOrEditLoanTextFieldCellId = @"SSJAddOrEditLoanTextFieldCell";
static NSString *const kAddOrEditLoanMultiLabelCellId = @"SSJAddOrEditLoanMultiLabelCell";

const NSInteger kLenderTag = 1001;
const NSInteger kMoneyTag = 1002;
const NSInteger kMemoTag = 1003;
const NSInteger kRateTag = 1004;

const int kLenderMaxLength = 7;
const int kMemoMaxLength = 13;

@interface SSJAddOrEditLoanViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) UIButton *sureButton;

// 借贷账户
@property (nonatomic, strong) SSJLoanFundAccountSelectionView *fundingSelectionView;

// 借贷日
@property (nonatomic, strong) SSJLoanDateSelectionView *borrowDateSelectionView;

// 期限日
@property (nonatomic, strong) SSJLoanDateSelectionView *repaymentDateSelectionView;

@property (nonatomic, strong) SSJReminderItem *reminderItem;

@property (nonatomic, strong) UILabel *interestLab;

@end

@implementation SSJAddOrEditLoanViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_loanModel.ID.length) {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClicked)];
        self.navigationItem.rightBarButtonItem = rightItem;
        
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                self.title = @"编辑借出款";
                break;
                
            case SSJLoanTypeBorrow:
                self.title = @"编辑欠款";
                break;
        }
    } else {
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                self.title = @"新建借出款";
                break;
                
            case SSJLoanTypeBorrow:
                self.title = @"新建欠款";
                break;
        }
    }
    
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = self.footerView;
    self.tableView.hidden = YES;
    
    [self updateAppearance];
    
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 3;
    } else if (section == 2) {
        return _loanModel.interest ? 2 : 1;
    } else if (section == 3) {
        return 1;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:0]] == NSOrderedSame) {
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"被谁借款";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"欠谁钱款";
                break;
        }
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"必填" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.textField.text = _loanModel.lender;
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.delegate = self;
        cell.textField.clearsOnBeginEditing = YES;
        cell.textField.tag = kLenderTag;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:0]] == NSOrderedSame) {
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"借出金额";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"欠款金额";
                break;
        }
        
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"¥0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.textField.text = [NSString stringWithFormat:@"¥%.2f", _loanModel.jMoney];
        cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        cell.textField.clearsOnBeginEditing = YES;
        cell.textField.delegate = self;
        cell.textField.tag = kMoneyTag;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:2 inSection:0]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"借出账户";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"借入账户";
                break;
        }
        
        SSJLoanFundAccountSelectionViewItem *selectedFundItem = [self.fundingSelectionView.items ssj_safeObjectAtIndex:_fundingSelectionView.selectedIndex];
        cell.additionalIcon.image = [UIImage imageNamed:selectedFundItem.image];
        cell.subtitleLabel.text = selectedFundItem.title;
        cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.switchControl.hidden = YES;
        cell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:1]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"借款日";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"欠款日";
                break;
        }
        
        cell.additionalIcon.image = nil;
        cell.subtitleLabel.text = [_loanModel.borrowDate formattedDateWithFormat:@"yyyy.MM.dd"];
        cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.switchControl.hidden = YES;
        cell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:1]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        cell.textLabel.text = @"还款日";
        
        cell.additionalIcon.image = nil;
        cell.subtitleLabel.text = [_loanModel.repaymentDate formattedDateWithFormat:@"yyyy.MM.dd"];
        cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.switchControl.hidden = YES;
        cell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:2 inSection:1]] == NSOrderedSame) {
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        cell.textLabel.text = @"备注";
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"选填" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.textField.text = _loanModel.memo;
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.clearsOnBeginEditing = NO;
        cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        cell.textField.delegate = self;
        cell.textField.tag = kMemoTag;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:2]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        cell.textLabel.text = @"计息";
        cell.additionalIcon.image = nil;
        cell.subtitleLabel.text = nil;
        cell.switchControl.hidden = NO;
        [cell.switchControl setOn:_loanModel.interest animated:YES];
        [cell.switchControl addTarget:self action:@selector(interestSwitchAction:) forControlEvents:UIControlEventValueChanged];
        cell.customAccessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:2]] == NSOrderedSame) {
        SSJAddOrEditLoanMultiLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanMultiLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        cell.textLabel.text = @"年收益率";
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"0.0" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        if (_loanModel.rate) {
            cell.textField.text = [NSString stringWithFormat:@"%.1f", _loanModel.rate * 100];
        }
        cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        cell.textField.delegate = self;
        cell.textField.tag = kRateTag;
        [cell setNeedsLayout];
        
        _interestLab = cell.subtitleLabel;
        [self updateInterest];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:3]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        cell.textLabel.text = @"到期日提醒";
        cell.subtitleLabel.text = [_reminderItem.remindDate formattedDateWithFormat:@"yyyy.MM.dd"];
        cell.additionalIcon.image = nil;
        cell.customAccessoryType = UITableViewCellAccessoryNone;
        cell.switchControl.hidden = NO;
        cell.switchControl.on = _reminderItem.remindState;
        [cell.switchControl addTarget:self action:@selector(remindSwitchAction:) forControlEvents:UIControlEventValueChanged];
        cell.selectionStyle = _reminderItem ? SSJ_CURRENT_THEME.cellSelectionStyle : UITableViewCellSelectionStyleNone;
        [cell setNeedsLayout];
        
        return cell;
        
    } else {
        return [[UITableViewCell alloc] init];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:2]] == NSOrderedSame) {
        return 74;
    } else {
        return 54;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([indexPath compare:[NSIndexPath indexPathForRow:2 inSection:0]] == NSOrderedSame) {
        [self.view endEditing:YES];
        [self.fundingSelectionView show];
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:1]] == NSOrderedSame) {
        [self.view endEditing:YES];
        [self.borrowDateSelectionView show];
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:1]] == NSOrderedSame) {
        [self.view endEditing:YES];
        [self.repaymentDateSelectionView show];
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:3]] == NSOrderedSame) {
        if (_reminderItem) {
            [self enterReminderVC];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField.tag == kLenderTag) {
        if (textField.text.length > kLenderMaxLength) {
            switch (_loanModel.type) {
                case SSJLoanTypeLend:
                    [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"借款人不能超过%d个字", kLenderMaxLength]];
                    break;
                    
                case SSJLoanTypeBorrow:
                    [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"欠款人不能超过%d个字", kLenderMaxLength]];
                    break;
            }
            return NO;
        }
        
        return YES;
        
    } else if (textField.tag == kMemoTag) {
        if (textField.text.length > kMemoMaxLength) {
            [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"备注不能超过%d个字", kMemoMaxLength]];
            return NO;
        }
    } else if (textField.tag == kRateTag) {
        if ([textField.text doubleValue] < 0) {
            [CDAutoHideMessageHUD showMessage:@"收益率不能小于0"];
            return NO;
        }
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == kMoneyTag) {
        NSString *money = [textField.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
        textField.text = [NSString stringWithFormat:@"¥%.2f", [money doubleValue]];
    } else if (textField.tag == kRateTag) {
        textField.text = [NSString stringWithFormat:@"%.1f", [textField.text doubleValue]];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField.tag == kLenderTag) {
        
        _loanModel.lender = newStr;
        [self updateRemindName];
        
        return YES;
        
    } else if (textField.tag == kMoneyTag) {
        
        BOOL shouldChange = YES;
        
        if (newStr.length) {
            newStr = [newStr stringByReplacingOccurrencesOfString:@"¥" withString:@""];
            if (newStr.length) {
                newStr = [NSString stringWithFormat:@"¥%@", newStr];
            }
            
            NSArray *components = [newStr componentsSeparatedByString:@"."];
            if (components.count >= 2) {
                NSString *integer = [components objectAtIndex:0];
                NSString *digit = [components objectAtIndex:1];
                if (digit.length > 2) {
                    digit = [digit substringToIndex:2];
                }
                newStr = [NSString stringWithFormat:@"%@.%@", integer, digit];
            }
            textField.text = newStr;
            
            shouldChange =  NO;
        }
        
        _loanModel.jMoney = [[newStr stringByReplacingOccurrencesOfString:@"¥" withString:@""] doubleValue];
        [self updateRemindName];
        
        return shouldChange;
        
    } else if (textField.tag == kMemoTag) {
        
        _loanModel.memo = newStr;
        
        return YES;
        
    } else if (textField.tag == kRateTag) {
        
        BOOL shouldChange = YES;
        
        if (newStr.length) {
            NSArray *components = [newStr componentsSeparatedByString:@"."];
            if (components.count >= 2) {
                NSString *integer = [components objectAtIndex:0];
                NSString *digit = [components objectAtIndex:1];
                if (digit.length > 1) {
                    digit = [digit substringToIndex:1];
                }
                newStr = [NSString stringWithFormat:@"%@.%@", integer, digit];
            }
            textField.text = newStr;
            
            shouldChange =  NO;
        }
        
        _loanModel.rate = [newStr doubleValue] * 0.01;
        [self updateInterest];
        
        return shouldChange;
        
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField.tag == kLenderTag) {
        _loanModel.lender = @"";
    } else if (textField.tag == kMoneyTag) {
        _loanModel.jMoney = 0;
    } else if (textField.tag == kMemoTag) {
        _loanModel.memo = @"";
    } else if (textField.tag == kRateTag) {
        _loanModel.rate = 0;
    }
    
    return YES;
}

#pragma mark - Event
- (void)deleteButtonClicked {
    __weak typeof(self) wself = self;
    [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"确认要删除此项目么？" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:NULL], [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction *action) {
        [wself deleteLoanModel];
    }], nil];
}

- (void)sureButtonAction {
    if ([self checkLoanModelIsValid]) {
        _sureButton.enabled = NO;
        [_sureButton ssj_showLoadingIndicator];
        [SSJLoanHelper saveLoanModel:_loanModel remindModel:_reminderItem success:^{
            _sureButton.enabled = YES;
            [_sureButton ssj_hideLoadingIndicator];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError * _Nonnull error) {
            _sureButton.enabled = YES;
            [_sureButton ssj_hideLoadingIndicator];
            [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
        }];
    }
}

- (void)interestSwitchAction:(UISwitch *)switchCtrl {
    _loanModel.interest = switchCtrl.on;
    [_tableView beginUpdates];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
}

- (void)remindSwitchAction:(UISwitch *)switchCtrl {
    if (_reminderItem) {
        _reminderItem.remindState = switchCtrl.on;
    } else {
        [self enterReminderVC];
    }
}

#pragma mark - Private
- (void)updateAppearance {
    [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
    [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor alpha:0.5] forState:UIControlStateDisabled];
    
    CGFloat alpha = [[SSJThemeSetting currentThemeModel].ID isEqualToString:SSJDefaultThemeID] ? 0 : 0.1;
    _tableView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:alpha];
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

- (void)loadData {
    [self.view ssj_showLoadingIndicator];
    [SSJLoanHelper queryFundModelListWithSuccess:^(NSArray <SSJLoanFundAccountSelectionViewItem *>*items) {
        
        if (_loanModel.remindID.length) {
            _reminderItem = [SSJLocalNotificationStore queryReminderItemForID:_loanModel.remindID];
        }
        
        _tableView.hidden = NO;
        [self.view ssj_hideLoadingIndicator];
        
        if (!_loanModel.ID.length) {
            _loanModel.ID = SSJUUID();
            _loanModel.userID = SSJUSERID();
            _loanModel.chargeID = SSJUUID();
            _loanModel.targetChargeID = SSJUUID();
            _loanModel.targetFundID = [items firstObject].ID;
            _loanModel.remindID = _reminderItem.remindId ?: @"";
            _loanModel.borrowDate = [NSDate date];
            _loanModel.repaymentDate = [_loanModel.borrowDate dateByAddingMonths:1];
            _loanModel.interest = YES;
            _loanModel.lender = @"";
            _loanModel.memo = @"";
            _loanModel.operatorType = 0;
        }
        
        self.fundingSelectionView.items = items;
        for (int i = 0; i < items.count; i ++) {
            SSJLoanFundAccountSelectionViewItem *item = items[i];
            if ([item.ID isEqualToString:_loanModel.targetFundID]) {
                self.fundingSelectionView.selectedIndex = i;
                break;
            }
        }
        [_tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        _tableView.hidden = NO;
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}

- (float)caculateInterest {
    if (_loanModel.borrowDate && _loanModel.repaymentDate) {
        NSUInteger interval = [_loanModel.repaymentDate daysFrom:_loanModel.borrowDate] + 1;
        return interval * (_loanModel.rate / 365);
    }
    
    return 0;
}

- (void)updateInterest {
    NSString *interestStr = [NSString stringWithFormat:@"%.2f", [self caculateInterest]];
    NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"预期利息为%@元", interestStr]];
    [richText setAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]} range:[richText.string rangeOfString:interestStr]];
    _interestLab.attributedText = richText;
}

- (BOOL)checkLoanModelIsValid {
    switch (_loanModel.type) {
        case SSJLoanTypeLend:
            if (_loanModel.lender.length == 0) {
                [CDAutoHideMessageHUD showMessage:@"请输入借款人"];
                return NO;
            }
            
            if (_loanModel.lender.length > kLenderMaxLength) {
                [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"借款人不能超过%d个字", kLenderMaxLength]];
            }
            
            if (_loanModel.jMoney <= 0) {
                [CDAutoHideMessageHUD showMessage:@"借出金额必须大于0"];
                return NO;
            }
            
            if (_loanModel.targetFundID.length == 0) {
                [CDAutoHideMessageHUD showMessage:@"请选择借出账户"];
                return NO;
            }
            
            if (!_loanModel.borrowDate) {
                [CDAutoHideMessageHUD showMessage:@"请选择借出日期"];
                return NO;
            }
            
            if (!_loanModel.repaymentDate) {
                [CDAutoHideMessageHUD showMessage:@"请选择借款日"];
                return NO;
            }
            break;
            
        case SSJLoanTypeBorrow:
            if (_loanModel.lender.length == 0) {
                [CDAutoHideMessageHUD showMessage:@"请输入欠款人"];
                return NO;
            }
            
            if (_loanModel.lender.length > kLenderMaxLength) {
                [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"欠款人不能超过%d个字", kLenderMaxLength]];
            }
            
            if (_loanModel.jMoney <= 0) {
                [CDAutoHideMessageHUD showMessage:@"欠款金额必须大于0"];
                return NO;
            }
            
            if (_loanModel.targetFundID.length == 0) {
                [CDAutoHideMessageHUD showMessage:@"请选择借入账户"];
                return NO;
            }
            
            if (!_loanModel.borrowDate) {
                [CDAutoHideMessageHUD showMessage:@"请选择欠款日"];
                return NO;
            }
            
            if (!_loanModel.repaymentDate) {
                [CDAutoHideMessageHUD showMessage:@"请选择还款日"];
                return NO;
            }
            break;
    }
    
    if (_loanModel.memo.length > kMemoMaxLength) {
        [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"备注不能超过%d个字", kMemoMaxLength]];
        return NO;
    }
    
    if (_loanModel.rate < 0) {
        [CDAutoHideMessageHUD showMessage:@"收益率不能小于0"];
        return NO;
    }
    
    return YES;
}

- (void)enterReminderVC {
    SSJReminderItem *tmpRemindItem = _reminderItem;
    if (!tmpRemindItem) {
        tmpRemindItem = [[SSJReminderItem alloc] init];
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                tmpRemindItem.remindName = [NSString stringWithFormat:@"被%@借%.2f元", _loanModel.lender, _loanModel.jMoney];
                break;
                
            case SSJLoanTypeBorrow:
                tmpRemindItem.remindName = [NSString stringWithFormat:@"欠%@钱款%.2f元", _loanModel.lender, _loanModel.jMoney];
                break;
        }
        tmpRemindItem.remindCycle = 7;
        tmpRemindItem.remindType = SSJReminderTypeBorrowing;
        tmpRemindItem.remindDate = [NSDate dateWithString:[NSString stringWithFormat:@"%@ 20:00:00", _loanModel.repaymentDate] formatString:@"yyyy-MM-dd HH:mm:ss"];
        tmpRemindItem.remindState = YES;
    }
    
    __weak typeof(self) wself = self;
    SSJReminderEditeViewController *reminderVC = [[SSJReminderEditeViewController alloc] init];
    reminderVC.item = tmpRemindItem;
    reminderVC.addNewReminderAction = ^(SSJReminderItem *item) {
        wself.reminderItem = item;
        wself.loanModel.remindID = item.remindId;
        [wself.tableView reloadData];
    };
    [self.navigationController pushViewController:reminderVC animated:YES];
}

- (void)updateRemindName {
    if (_reminderItem) {
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                _reminderItem.remindName = [NSString stringWithFormat:@"被%@借%.2f元", _loanModel.lender ?: @"", _loanModel.jMoney];
                break;
                
            case SSJLoanTypeBorrow:
                _reminderItem.remindName = [NSString stringWithFormat:@"欠%@钱款%.2f元", _loanModel.lender ?: @"", _loanModel.jMoney];
                break;
        }
    }
}

- (void)deleteLoanModel {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [SSJLoanHelper deleteLoanModel:_loanModel success:^{
        self.navigationItem.rightBarButtonItem.enabled = YES;
        UIViewController *listVC = [self ssj_previousViewControllerBySubtractingIndex:2];
        if ([listVC isKindOfClass:[SSJLoanListViewController class]]) {
            [self.navigationController popToViewController:listVC animated:YES];
        }
    } failure:^(NSError * _Nonnull error) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}

#pragma mark - Getter
- (TPKeyboardAvoidingTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView registerClass:[SSJAddOrEditLoanLabelCell class] forCellReuseIdentifier:kAddOrEditLoanLabelCellId];
        [_tableView registerClass:[SSJAddOrEditLoanTextFieldCell class] forCellReuseIdentifier:kAddOrEditLoanTextFieldCellId];
        [_tableView registerClass:[SSJAddOrEditLoanMultiLabelCell class] forCellReuseIdentifier:kAddOrEditLoanMultiLabelCellId];
        _tableView.sectionHeaderHeight = 10;
        _tableView.sectionFooterHeight = 0;
    }
    return _tableView;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 108)];
        _footerView.backgroundColor = [UIColor clearColor];
        [_footerView addSubview:self.sureButton];
    }
    return _footerView;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sureButton setTitle:@"立借条" forState:UIControlStateNormal];
        [_sureButton setTitle:@"" forState:UIControlStateDisabled];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(sureButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _sureButton.frame = CGRectMake((self.footerView.width - 296) * 0.5, 30, 296, 48);
        _sureButton.clipsToBounds = YES;
        _sureButton.layer.cornerRadius = 3;
    }
    return _sureButton;
}

- (SSJLoanFundAccountSelectionView *)fundingSelectionView {
    if (!_fundingSelectionView) {
        __weak typeof(self) weakSelf = self;
        _fundingSelectionView = [[SSJLoanFundAccountSelectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _fundingSelectionView.shouldSelectAccountAction = ^BOOL(SSJLoanFundAccountSelectionView *view, NSUInteger index) {
            if (index < view.items.count - 1) {
                SSJLoanFundAccountSelectionViewItem *item = [view.items objectAtIndex:index];
                weakSelf.loanModel.targetFundID = item.ID;
                [weakSelf.tableView reloadData];
                return YES;
            } else if (index == view.items.count - 1) {
                SSJNewFundingViewController *newFundingVC = [[SSJNewFundingViewController alloc] init];
                newFundingVC.finishBlock = ^(SSJFundingItem *newFundingItem) {
                    weakSelf.loanModel.targetFundID = newFundingItem.fundingID;
                    [weakSelf loadData];
                };
                [weakSelf.navigationController pushViewController:newFundingVC animated:YES];
                return NO;
            } else {
                SSJPRINT(@"警告：selectedIndex大于数组范围");
                return NO;
            }
        };
    }
    return _fundingSelectionView;
}

- (SSJLoanDateSelectionView *)borrowDateSelectionView {
    if (!_borrowDateSelectionView) {
        __weak typeof(self) weakSelf = self;
        _borrowDateSelectionView = [[SSJLoanDateSelectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _borrowDateSelectionView.selectedDate = _loanModel.borrowDate;
        _borrowDateSelectionView.selectDateAction = ^(SSJLoanDateSelectionView *view) {
            weakSelf.loanModel.borrowDate = view.selectedDate;
            [weakSelf.tableView reloadData];
        };
        _borrowDateSelectionView.shouldSelectDateAction = ^BOOL(SSJLoanDateSelectionView *view, NSDate *date) {
            if ([date compare:weakSelf.loanModel.repaymentDate] == NSOrderedDescending) {
                switch (weakSelf.loanModel.type) {
                    case SSJLoanTypeLend:
                        [CDAutoHideMessageHUD showMessage:@"借款日不能早于还款日"];
                        break;
                        
                    case SSJLoanTypeBorrow:
                        [CDAutoHideMessageHUD showMessage:@"欠款日不能早于还款日"];
                        break;
                }
                return NO;
            }
            return YES;
        };
    }
    return _borrowDateSelectionView;
}

- (SSJLoanDateSelectionView *)repaymentDateSelectionView {
    if (!_repaymentDateSelectionView) {
        __weak typeof(self) weakSelf = self;
        _repaymentDateSelectionView = [[SSJLoanDateSelectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _repaymentDateSelectionView.selectedDate = _loanModel.repaymentDate;
        _repaymentDateSelectionView.selectDateAction = ^(SSJLoanDateSelectionView *view) {
            weakSelf.loanModel.repaymentDate = view.selectedDate;
            [weakSelf.tableView reloadData];
        };
        _repaymentDateSelectionView.shouldSelectDateAction = ^BOOL(SSJLoanDateSelectionView *view, NSDate *date) {
            if ([date compare:weakSelf.loanModel.borrowDate] == NSOrderedAscending) {
                switch (weakSelf.loanModel.type) {
                    case SSJLoanTypeLend:
                        [CDAutoHideMessageHUD showMessage:@"还款日不能早于借款日"];
                        break;
                        
                    case SSJLoanTypeBorrow:
                        [CDAutoHideMessageHUD showMessage:@"还款日不能早于欠款日"];
                        break;
                }
                return NO;
            }
            return YES;
        };
    }
    return _repaymentDateSelectionView;
}

@end