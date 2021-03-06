//
//  SSJRecordMakingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/16.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingViewController.h"
#import "SSJNavigationController.h"
#import "SSJImaageBrowseViewController.h"
#import "SSJMemberManagerViewController.h"
#import "SSJNewMemberViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "SSJCreateOrEditBillTypeViewController.h"

#import "SSJCustomKeyboard.h"
#import "SSJMemberSelectView.h"
#import "SSJHomeDatePickerView.h"
#import "SSJFundingTypeSelectView.h"
#import "SSJRecordMakingBillTypeInputView.h"
#import "SSJRecordMakingBillTypeSelectionView.h"
#import "SSJRecordMakingBillTypeInputAccessoryView.h"
#import "SSJRecordMakingCustomNavigationBar.h"

#import "SSJFinancingHomeitem.h"
#import "SSJCreditCardItem.h"
#import "SSJChargeMemberItem.h"
#import "SSJRecordMakingBillTypeSelectionCellItem.h"
#import "YYKeyboardManager.h"
#import "SSJUserTableManager.h"
#import "SSJBooksTypeStore.h"
#import "SSJRecordMakingStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJCategoryListHelper.h"
#import "SSJDataSynchronizer.h"


#define INPUT_DEFAULT_COLOR [UIColor ssj_colorWithHex:@"#dddddd"]

static const NSTimeInterval kAnimationDuration = 0.25;

static NSString *const kIsEverEnteredKey = @"kIsEverEnteredKey";

@interface SSJRecordMakingViewController () <UIScrollViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, YYKeyboardObserver>

@property (nonatomic, strong) SSJRecordMakingCustomNavigationBar *customNaviBar;

@property (nonatomic,strong) UIImage *selectedImage;

@property (nonatomic,strong) SSJHomeDatePickerView *dateSelectedView;

@property (nonatomic,strong) SSJFundingTypeSelectView *FundingTypeSelectView;

@property(nonatomic, strong) SSJMemberSelectView *memberSelectView;

@property (nonatomic) NSInteger selectChargeCircleType;

@property (nonatomic,strong) NSString *chargeMemo;

@property (nonatomic,strong) NSString *categoryID;

@property (nonatomic, strong) SSJRecordMakingBillTypeInputView *billTypeInputView;

@property (nonatomic, strong) SSJRecordMakingBillTypeSelectionView *paymentTypeView;

@property (nonatomic, strong) SSJRecordMakingBillTypeSelectionView *incomeTypeView;

@property (nonatomic, strong) SSJRecordMakingBillTypeInputAccessoryView *accessoryView;

@property (nonatomic, strong) UITextField *currentInput;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic) NSInteger lastSelectedIndex;

/**
 刚进入页面时用户默认的账本id；用于保存记一笔数据时判断有没有改变过账本id
 */
@property (nonatomic, strong) NSString *defaultBooksId;

/**
 新增或编辑的类别id，由新建或者编辑类别页面返回
 */
@property (nonatomic, strong) NSString *addOrEditBillId;

@property (nonatomic, strong) NSMutableArray<NSObject<SSJBooksItemProtocol> *> *booksItems;

@property (nonatomic) long currentYear;
@property (nonatomic) long currentMonth;
@property (nonatomic) long currentDay;

// 是否编辑流水
@property (nonatomic) BOOL edited;

@end

@implementation SSJRecordMakingViewController{
    BOOL _needToDismiss;
}
#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.statisticsTitle = @"记一笔";
        self.hidesBottomBarWhenPushed = YES;
        self.hidesNavigationBarWhenPushed = YES;
        self.booksItems = [NSMutableArray array];
        [[YYKeyboardManager defaultManager] addObserver:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _needToDismiss = YES;
    _edited = (self.item != nil);
    
    if (!self.item) {
        self.item = [[SSJBillingChargeCellItem alloc] init];
    }
    
    [self initDate];
    [self loadFundData];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.customNaviBar];
    [self.view addSubview:self.billTypeInputView];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.accessoryView];
    [self.scrollView addSubview:self.paymentTypeView];
    [self.scrollView addSubview:self.incomeTypeView];
    
    if (self.item.ID.length && self.item.incomeOrExpence == 0) {
        _lastSelectedIndex = 1;
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.width, 0)];
        self.customNaviBar.selectedBillType = SSJBillTypeIncome;
    }
    
    [self updateNavigationRightItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 如果没有账本id就传当前账本（从首页进入没有传账本id）
    
    [self.view ssj_showLoadingIndicator];
    [[[[self loadCurrentBooksIdSignal] then:^RACSignal *{
        return [self loadBooksListSignal];
    }] then:^RACSignal *{
        return [self loadBillTypeSignal];
    }] subscribeError:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showError:error];
    } completed:^{
        [self.view ssj_hideLoadingIndicator];
    }];
    
    self.memberSelectView.chargeId = self.item.ID;
    [self.memberSelectView reloadData:^{
        [self updateMemberButtonTitle];
    }];
    
    [self.FundingTypeSelectView dismiss];
    //        [self.dateSelectedView dismiss];
    if (_needToDismiss) {
        [self.memberSelectView dismiss];
        [self.billTypeInputView.moneyInput becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _paymentTypeView.editing = NO;
    _incomeTypeView.editing = NO;
    [self.view endEditing:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _scrollView.contentSize = CGSizeMake(self.view.width * 2, self.view.height - self.billTypeInputView.bottom);
    _paymentTypeView.height = _incomeTypeView.height = _scrollView.height = self.view.height - self.billTypeInputView.bottom;
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

#pragma mark - Getter
- (SSJRecordMakingCustomNavigationBar *)customNaviBar {
    if (!_customNaviBar) {
        __weak typeof(self) wself = self;
        _customNaviBar = [[SSJRecordMakingCustomNavigationBar alloc] init];
        _customNaviBar.selectBookHandle = ^(SSJRecordMakingCustomNavigationBar *naviBar) {
            [SSJAnaliyticsManager event:@"addRecord_changeBooks"];//记一笔-切换账本
            NSObject<SSJBooksItemProtocol> *bookItem = [wself.booksItems ssj_safeObjectAtIndex:naviBar.selectedTitleIndex];
            wself.item.booksId = bookItem.booksId;
            [wself.currentInput becomeFirstResponder];
            [[wself loadBillTypeSignal] subscribeError:^(NSError *error) {
                [SSJAlertViewAdapter showError:error];
            } completed:NULL];
            wself.accessoryView.memberBtn.hidden = [bookItem isKindOfClass:[SSJShareBookItem class]];
        };
        _customNaviBar.selectBillTypeHandle = ^(SSJRecordMakingCustomNavigationBar *naviBar) {
            [wself segmentPressed];
        };
        _customNaviBar.backOffHandle = ^(SSJRecordMakingCustomNavigationBar *naviBar) {
            [wself goBackAction];
        };
        _customNaviBar.managementHandle = ^(SSJRecordMakingCustomNavigationBar *naviBar) {
            [wself managerItemAction];
        };
    }
    return _customNaviBar;
}

- (SSJHomeDatePickerView *)dateSelectedView {
    if (!_dateSelectedView) {
        _dateSelectedView = [[SSJHomeDatePickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 288)];
        _dateSelectedView.datePickerMode = SSJDatePickerModeYearDateAndTime;
        _dateSelectedView.warningDate = [NSDate date];
        _dateSelectedView.maxDate = [NSDate date];
        __weak typeof(self) weakSelf = self;
        _dateSelectedView.shouldConfirmBlock = ^BOOL(SSJHomeDatePickerView *view, NSDate *selecteDate) {
            if ([[NSDate date] compare:selecteDate] == NSOrderedAscending) {
                [CDAutoHideMessageHUD showMessage:@"不能记未来日期的账哦"];
                return NO;
            }
            return YES;
        };
        _dateSelectedView.confirmBlock = ^(SSJHomeDatePickerView *view) {
            NSDate *currentDetailDate = [NSDate dateWithString:weakSelf.item.billDetailDate formatString:@"HH:mm"];
            if (view.date.hour != currentDetailDate.hour || view.date.minute != currentDetailDate.minute) {
                [SSJAnaliyticsManager event:@"add_record_time_select"];
            }
            weakSelf.selectedDay = view.date.day;
            weakSelf.selectedMonth = view.date.month;
            weakSelf.selectedYear = view.date.year;
            weakSelf.item.billDate = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(long)view.date.year,(long)view.date.month,(long)view.date.day];
            weakSelf.item.billDetailDate = [NSString stringWithFormat:@"%02ld:%02ld",(long)view.date.hour,(long)view.date.minute];
            [weakSelf.accessoryView.dateBtn setTitle:[NSString stringWithFormat:@"%ld月%ld日", weakSelf.selectedMonth, weakSelf.selectedDay] forState:SSJButtonStateNormal];
            [weakSelf.dateSelectedView dismiss];
        };
        _dateSelectedView.dismissBlock = ^(SSJHomeDatePickerView *view) {
            [weakSelf.billTypeInputView.moneyInput becomeFirstResponder];
        };
    }
    return _dateSelectedView;
}

-(SSJFundingTypeSelectView *)FundingTypeSelectView{
    if (!_FundingTypeSelectView) {
        __weak typeof(self) weakSelf = self;
        _FundingTypeSelectView = [[SSJFundingTypeSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _FundingTypeSelectView.fundingTypeSelectBlock = ^(SSJFinancingHomeitem *fundingItem){
            if (![fundingItem.fundingName isEqualToString:@"添加新的资金账户"]) {
                weakSelf.item.fundId = fundingItem.fundingID;
                weakSelf.item.fundName = fundingItem.fundingName;
                weakSelf.item.fundOperatorType = 1;
                [weakSelf updateFundingType];
            }else{
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
                NewFundingVC.needLoanOrNot = NO;
                NewFundingVC.addNewFundingBlock = ^(SSJFinancingHomeitem *item){
                        [weakSelf.FundingTypeSelectView reloadDate];
                        weakSelf.item.fundId = item.fundingID;
                        weakSelf.item.fundName = item.fundingName;
                        weakSelf.item.fundOperatorType = 0;
                        [weakSelf updateFundingType];
                };
                [weakSelf.navigationController pushViewController:NewFundingVC animated:YES];
            }
            [weakSelf.FundingTypeSelectView dismiss];
        };
        _FundingTypeSelectView.dismissBlock = ^{
            if ([[weakSelf.navigationController.viewControllers lastObject] isKindOfClass:[SSJRecordMakingViewController class]]) {
                [weakSelf.billTypeInputView.moneyInput becomeFirstResponder];
            }
        };
    }
    return _FundingTypeSelectView;
}

- (SSJRecordMakingBillTypeInputView *)billTypeInputView {
    if (!_billTypeInputView) {
        _billTypeInputView = [[SSJRecordMakingBillTypeInputView alloc] initWithFrame:CGRectMake(0, self.customNaviBar.bottom, self.view.width, 70)];
        _billTypeInputView.fillColor = INPUT_DEFAULT_COLOR;
        _billTypeInputView.moneyInput.delegate = self;
        if (_item.money) {
            _billTypeInputView.moneyInput.text = [NSString stringWithFormat:@"%.2f", [_item.money doubleValue]];
        }
    }
    return _billTypeInputView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.billTypeInputView.bottom, self.view.width, self.view.height - self.billTypeInputView.bottom)];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (SSJRecordMakingBillTypeSelectionView *)paymentTypeView {
    if (!_paymentTypeView) {
        _paymentTypeView = [[SSJRecordMakingBillTypeSelectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - self.billTypeInputView.bottom)];
        [self initBillTypeView:_paymentTypeView];
    }
    return _paymentTypeView;
}

- (SSJRecordMakingBillTypeSelectionView *)incomeTypeView {
    if (!_incomeTypeView) {
        _incomeTypeView = [[SSJRecordMakingBillTypeSelectionView alloc] initWithFrame:CGRectMake(self.view.width, 0, self.view.width, self.view.height - self.billTypeInputView.bottom)];
        [self initBillTypeView:_incomeTypeView];
    }
    return _incomeTypeView;
}

-(SSJMemberSelectView *)memberSelectView{
    if (!_memberSelectView) {
        __weak typeof(self) weakSelf = self;
        _memberSelectView = [[SSJMemberSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _memberSelectView.dismissBlock = ^(){
            if ([[weakSelf.navigationController.viewControllers lastObject] isKindOfClass:[SSJRecordMakingViewController class]]) {
                [weakSelf.billTypeInputView.moneyInput becomeFirstResponder];
            }
        };
        _memberSelectView.showBlock = ^(){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf -> _needToDismiss = YES;
        };
        _memberSelectView.selectedMemberDidChangeBlock = ^(NSArray *selectedMemberItems){
            weakSelf.item.membersItem = [selectedMemberItems mutableCopy];
            [weakSelf updateMemberButtonTitle];
        };
        _memberSelectView.manageBlock = ^(NSMutableArray *items){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf -> _needToDismiss = YES;
            [weakSelf.billTypeInputView.moneyInput resignFirstResponder];
            [weakSelf.accessoryView.memoView resignFirstResponder];
            SSJMemberManagerViewController *membermanageVc = [[SSJMemberManagerViewController alloc]init];
            membermanageVc.items = items;
            [weakSelf.navigationController pushViewController:membermanageVc animated:YES];
        };
        _memberSelectView.addNewMemberBlock = ^(){
            [weakSelf.memberSelectView dismiss];
            SSJNewMemberViewController *newMemberVc = [[SSJNewMemberViewController alloc]init];
            newMemberVc.addNewMemberAction = ^(SSJChargeMemberItem *item){
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [weakSelf.memberSelectView show];
                [weakSelf.memberSelectView addSelectedMemberItem:item];
                strongSelf -> _needToDismiss = NO;
            };
            [weakSelf.navigationController pushViewController:newMemberVc animated:YES];
        };
    }
    return _memberSelectView;
}

- (SSJRecordMakingBillTypeInputAccessoryView *)accessoryView {
    if (!_accessoryView) {
        _accessoryView = [[SSJRecordMakingBillTypeInputAccessoryView alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, 86)];
        [_accessoryView.accountBtn addTarget:self action:@selector(selectFundAccountAction) forControlEvents:UIControlEventTouchUpInside];
        [_accessoryView.dateBtn addTarget:self action:@selector(selectBillDateAction) forControlEvents:UIControlEventTouchUpInside];
        [_accessoryView.photoBtn addTarget:self action:@selector(selectPhotoAction) forControlEvents:UIControlEventTouchUpInside];
        [_accessoryView.memberBtn addTarget:self action:@selector(selectMemberAction) forControlEvents:UIControlEventTouchUpInside];
        [_accessoryView.dateBtn setTitle:[NSString stringWithFormat:@"%ld月%ld日", _selectedMonth, _selectedDay] forState:SSJButtonStateNormal];
        [_accessoryView.photoBtn setTitle:@"照片" forState:SSJButtonStateNormal];
        _accessoryView.memoView.delegate = self;
        _accessoryView.memoView.text = _item.chargeMemo;
        _accessoryView.dateBtn.selected = YES;
        _accessoryView.memberBtn.selected = YES;
        _accessoryView.photoBtn.selected = _item.chargeImage.length > 0;
    }
    return _accessoryView;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [super textFieldDidBeginEditing:textField];
    _currentInput = textField;
    _paymentTypeView.editing = NO;
    _incomeTypeView.editing = NO;
    _billTypeInputView.moneyInput.clearsOnInsertion = YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (_billTypeInputView.moneyInput == textField) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = [text ssj_reserveDecimalDigits:2 intDigits:9];
        
        // 键盘输入要隐藏引导
        if (self.customNaviBar.selectedBillType == SSJBillTypePay) {
            [self.paymentTypeView hideGuide];
        } else if (self.customNaviBar.selectedBillType == SSJBillTypeIncome) {
            [self.incomeTypeView hideGuide];
        }
        
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _billTypeInputView.moneyInput
        || textField == _accessoryView.memoView) {
        [self makeArecord];
        [SSJAnaliyticsManager event:@"addRecord_save"];
    }
    return YES;
}

#pragma mark - UIActionSheetDelegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // ios8以上UIActionSheet也是控制器，如果立即调用相册／相机，在ipad上无法正常调用，所以要在主线程的下一次loop迭代中调用
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        switch (buttonIndex)
        {
            case 0:  //打开照相机拍照
                [weakSelf takePhoto];
                break;
            case 1:  //打开本地相册
                [weakSelf localPhoto];
                break;
            case 2:  //打开本地相册
                [weakSelf.billTypeInputView.moneyInput becomeFirstResponder];
                break;
        }
    }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    _selectedImage = image;
    [self.billTypeInputView.moneyInput becomeFirstResponder];
    _accessoryView.photoBtn.selected = YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _scrollView) {
        NSInteger currentSelectedIndex = scrollView.contentOffset.x / scrollView.width;
        if (_lastSelectedIndex != currentSelectedIndex) {
            _lastSelectedIndex = currentSelectedIndex;
            
            if (_lastSelectedIndex == 0) {
                _customNaviBar.selectedBillType = SSJBillTypePay;
            } else if (_lastSelectedIndex == 1) {
                _customNaviBar.selectedBillType = SSJBillTypeIncome;
            }
            
            _paymentTypeView.editing = NO;
            _incomeTypeView.editing = NO;
            [[self loadBillTypeSignal] subscribeError:^(NSError *error) {
                [SSJAlertViewAdapter showError:error];
            } completed:NULL];
            [self updateNavigationRightItem];
        }
    }
}

#pragma mark - YYKeyboardObserver
- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    if (transition.toVisible) {
        if ([_billTypeInputView.moneyInput isFirstResponder]
            || [_accessoryView.memoView isFirstResponder]) {
            _accessoryView.top = self.view.height;
            [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
                _accessoryView.bottom = self.view.height - transition.toFrame.size.height;
            } completion:NULL];
        }
    } else {
        [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
            _accessoryView.top = self.view.height;
        } completion:NULL];
    }
}

#pragma mark - Event
- (void)segmentPressed {
    if (_customNaviBar.selectedBillType == SSJBillTypePay) {
        [SSJAnaliyticsManager event:@"addRecord_type_out"];
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else if (_customNaviBar.selectedBillType == SSJBillTypeIncome) {
        [SSJAnaliyticsManager event:@"addRecord_type_in"];
        [_scrollView setContentOffset:CGPointMake(_scrollView.width, 0) animated:YES];
    }
    
    _paymentTypeView.editing = NO;
    _incomeTypeView.editing = NO;
    [[self loadBillTypeSignal] subscribeError:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    } completed:NULL];
    [self updateNavigationRightItem];
}

- (void)selectFundAccountAction {
    [SSJAnaliyticsManager event:@"addRecord_fund"];
    [self.FundingTypeSelectView show];
    [_billTypeInputView.moneyInput resignFirstResponder];
    [_accessoryView.memoView resignFirstResponder];
}

- (void)selectBillDateAction {
    NSString *currentDateStr = [NSString stringWithFormat:@"%@ %@",self.item.billDate,self.item.billDetailDate];
    NSDate *currentDate = [NSDate dateWithString:currentDateStr formatString:@"yyyy-MM-dd HH:mm"];
    [SSJAnaliyticsManager event:@"addRecord_calendar"];
    self.dateSelectedView.date = currentDate;
    [self.dateSelectedView show];
    [_billTypeInputView.moneyInput resignFirstResponder];
    [_accessoryView.memoView resignFirstResponder];
}

- (void)selectPhotoAction {
    if (_selectedImage || self.item.chargeImage.length != 0) {
        SSJImaageBrowseViewController *imageBrowserVC = [[SSJImaageBrowseViewController alloc]init];
        __weak typeof(self) weakSelf = self;
        [SSJAnaliyticsManager event:@"addRecord_camera"];
        imageBrowserVC.DeleteImageBlock = ^(){
            weakSelf.selectedImage = nil;
            weakSelf.item.chargeImage = @"";
            weakSelf.item.chargeThumbImage = @"";
            weakSelf.accessoryView.photoBtn.selected = NO;
        };
        imageBrowserVC.NewImageSelectedBlock = ^(UIImage *image){
            weakSelf.selectedImage = image;
        };
        imageBrowserVC.type = SSJImageBrowseVcTypeEdite;
        if (_selectedImage) {
            imageBrowserVC.image = _selectedImage;
        } else {
            imageBrowserVC.item = self.item;
        }
        [self.navigationController pushViewController:imageBrowserVC animated:YES];
    } else {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄照片" ,@"从相册选择", nil];
        [sheet showInView:self.view];
        [_billTypeInputView.moneyInput resignFirstResponder];
        [_accessoryView.memoView resignFirstResponder];
    }
}

- (void)selectMemberAction{
    [SSJAnaliyticsManager event:@"addRecord_member"];
    [self.memberSelectView show];
    [_billTypeInputView.moneyInput resignFirstResponder];
    [_accessoryView.memoView resignFirstResponder];
}

- (void)managerItemAction {
    switch (_customNaviBar.selectedBillType) {
        case SSJBillTypePay:
            _paymentTypeView.editing = !_customNaviBar.managed;
            break;
            
        case SSJBillTypeIncome:
            _incomeTypeView.editing = !_customNaviBar.managed;
            break;
            
        case SSJBillTypeUnknown:
        case SSJBillTypeSurplus:
            SSJPRINT(@"未定义选项");
            break;
    }
    
    if (_customNaviBar.managed) {
        [SSJAnaliyticsManager event:@"addRecord_manage"];
    }
}

#pragma mark - private
- (void)initDate {
    NSDate *now = [NSDate date];
    _currentYear= now.year;
    _currentDay = now.day;
    _currentMonth = now.month;
    //获取日期
    if (self.item.ID.length == 0) {
        if (_selectedYear == 0) {
            self.selectedYear = _currentYear;
        }
        if (_selectedMonth == 0) {
            self.selectedMonth = _currentMonth;
        }
        if (_selectedDay == 0) {
            self.selectedDay = _currentDay;
        }
        self.item.billDetailDate = [[NSDate date] formattedDateWithFormat:@"HH:mm"];
    }else{
        if (self.item.ID.length == 0) {
            self.selectedYear = _currentYear;
            self.selectedMonth = _currentMonth;
            self.selectedDay = _currentDay;
        }else{
            self.selectedYear = [[self.item.billDate substringWithRange:NSMakeRange(0, 4)] integerValue];
            self.selectedMonth = [[self.item.billDate substringWithRange:NSMakeRange(5, 2)] integerValue];
            self.selectedDay = [[self.item.billDate substringWithRange:NSMakeRange(8, 2)] integerValue];
        }
    }
    self.item.billDate = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",self.selectedYear,self.selectedMonth,self.selectedDay];
}

/**
 加载收支类别和账本数据
 */
- (RACSignal *)loadCurrentBooksIdSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJUserTableManager currentBooksId:^(NSString * _Nonnull booksId) {
            self.defaultBooksId = booksId;
            if (!self.item.booksId) {
                self.item.booksId = booksId;
            }
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (RACSignal *)loadBooksListSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        RACSignal *sg_1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [SSJBooksTypeStore queryForBooksListWithSuccess:^(NSMutableArray<SSJBooksTypeItem *> *bookList) {
                [subscriber sendNext:bookList];
                [subscriber sendCompleted];
            } failure:^(NSError *error) {
                [subscriber sendError:error];
            }];
            return nil;
        }];
        
        RACSignal *sg_2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [SSJBooksTypeStore queryForShareBooksListWithSuccess:^(NSMutableArray<SSJShareBookItem *> *result) {
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            } failure:^(NSError *error) {
                [SSJAlertViewAdapter showError:error];
            }];
            return nil;
        }];
        
        [self.booksItems removeAllObjects];
        [[RACSignal merge:@[sg_1, sg_2]] subscribeNext:^(NSArray *booksItems) {
            [self.booksItems addObjectsFromArray:booksItems];
        } completed:^{
            NSInteger selectedIndex = -1;
            NSMutableArray *bookItems = [[NSMutableArray alloc] initWithCapacity:self.booksItems.count];
            BOOL isSharedBook = NO;
            for (int i = 0; i < self.booksItems.count; i ++) {
                NSObject<SSJBooksItemProtocol> *item = self.booksItems[i];
                NSString *iconName = nil;
                if ([item isKindOfClass:[SSJBooksTypeItem class]]) {
                    iconName = @"record_making_private_book";
                } else if ([item isKindOfClass:[SSJShareBookItem class]]) {
                    iconName = @"record_making_shared_book";
                }
                [bookItems addObject:[SSJRecordMakingCustomNavigationBarBookItem itemWithTitle:item.booksName iconName:iconName]];
                if ([item.booksId isEqualToString:self.item.booksId]) {
                    selectedIndex = i;
                    isSharedBook = [item isKindOfClass:[SSJShareBookItem class]];
                }
            }
            
            self.accessoryView.memberBtn.hidden = isSharedBook;
            self.customNaviBar.bookItems = bookItems;
            self.customNaviBar.selectedTitleIndex = selectedIndex;
            if ((isSharedBook && self.edited)
                || bookItems.count <= 1) {
                self.customNaviBar.canSelectTitle = NO;
            } else {
                self.customNaviBar.canSelectTitle = YES;
            }
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)loadBillTypeSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJCategoryListHelper queryForCategoryListWithIncomeOrExpenture:self.customNaviBar.selectedBillType booksId:self.item.booksId Success:^(NSMutableArray<SSJRecordMakingBillTypeSelectionCellItem *> *categoryList) {
            
            SSJRecordMakingBillTypeSelectionView *billTypeView = nil;
            if (self.customNaviBar.selectedBillType == SSJBillTypePay) {
                billTypeView = self.paymentTypeView;
            } else if (self.customNaviBar.selectedBillType == SSJBillTypeIncome) {
                billTypeView = self.incomeTypeView;
            } else {
#ifdef DEBUG
                [SSJAlertViewAdapter showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"未定义的控件行为，selectedBillType：%d", (int)self.customNaviBar.selectedBillType]}]];
#endif
                return;
            }
            
            // 设置选中的类别；
            // 优先级顺序：1.新增或者编辑的类别 2.用户自己选中的类别 3.从前一个页面带过来的类别 4.第一个类别
            NSString *selectedId = self.addOrEditBillId ?: (billTypeView.selectedItem.ID ?: self.item.billId);
            self.addOrEditBillId = nil;
            __block SSJRecordMakingBillTypeSelectionCellItem *selectedItem = nil;
            [categoryList enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(SSJRecordMakingBillTypeSelectionCellItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (selectedId && [obj.ID isEqualToString:selectedId]) {
                    selectedItem = obj;
                    *stop = YES;
                }
            }];
            
            if (!selectedItem) {
                selectedItem = [categoryList firstObject];
            }
            
            if (![self needToShowGuide]) {
                selectedItem.state = SSJRecordMakingBillTypeSelectionCellStateSelected;
            }
            
            self.item.billId = selectedItem.ID;
            billTypeView.items = categoryList;
            
            [UIView animateWithDuration:kAnimationDuration animations:^{
                self.billTypeInputView.fillColor = selectedItem ? [UIColor ssj_colorWithHex:selectedItem.colorValue] : INPUT_DEFAULT_COLOR;
            }];
            self.billTypeInputView.billTypeName = selectedItem.title;
            
            [self showGuideViewIfNeeded];
            
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        } failure:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

// 获取选中的资金账户
- (void)loadFundData {
    @weakify(self);
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        @strongify(self);
        NSString *userId = SSJUSERID();
        if (self.item.ID.length != 0 || self.selectFundId.length) {
            if (!self.item.fundName.length) {
                if (self.selectFundId.length && !self.item.fundId.length) {
                    self.item.fundId = self.selectFundId;
                }
                if ([db intForQuery:@"select operatortype from bk_fund_info where cfundid = ?",self.item.fundId] == 2) {
                    self.item.fundName = @"选择账户";
                    self.item.fundOperatorType = 2;
                }else{
                    self.item.fundName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ? and cuserid = ? and operatortype <> 2",self.item.fundId,userId];
                    self.item.fundOperatorType = [db intForQuery:@"select operatortype from bk_fund_info where cfundid = ? and cuserid = ?",self.item.fundId,userId];
                }
            }
        }else{
            if (![db stringForQuery:@"select lastselectfundid from bk_user where cuserid = ?",userId].length) {
                self.item.fundId = [db stringForQuery:@"select cfundid from bk_fund_info where cparent != '10' and cparent != '11' and cparent != '17' and operatortype <> 2 and cuserid = ? order by iorder limit 1",userId];
                self.item.fundName = [db stringForQuery:@"select cacctname from bk_fund_info where cparent != '10' and cparent != '11' and cparent != '17' and operatortype <> 2 and cuserid = ? order by iorder limit 1",userId];
            }else{
                if ([db intForQuery:@"select operatortype from bk_fund_info where cfundid = (select lastselectfundid from bk_user where cuserid = ?)",userId] == 2) {
                    self.item.fundId = [db stringForQuery:@"select cfundid from bk_fund_info where cparent != '10' and cparent != '11' and cparent != '17' and operatortype <> 2 and cuserid = ? order by iorder limit 1",userId];
                    self.item.fundName = [db stringForQuery:@"select cacctname from bk_fund_info where cparent != '10' and cparent != '11' and cparent != '17' and operatortype <> 2 and cuserid = ? order by iorder limit 1",userId];
                }else{
                    self.item.fundId = [db stringForQuery:@"select lastselectfundid from bk_user as a where a.cuserid = ? and a.lastselectfundid in (select cfundid from bk_fund_info where cuserid = ? and operatortype <> 2 and cparent != 'root')",userId,userId];
                    self.item.fundName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ? and cuserid = ? and operatortype <> 2",self.item.fundId,userId];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self updateFundingType];
        });
    }];
}

-(void)takePhoto{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:^{}];
    }else
    {
        SSJPRINT(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

-(void)localPhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:^{}];
}

- (BOOL)verifyItem {
    if (!_item.billId.length) {
        [_billTypeInputView.moneyInput becomeFirstResponder];
        [CDAutoHideMessageHUD showMessage:@"请添加并选择一个类别"];
        return NO;
    }
    
    if ([self.item.money doubleValue] == 0) {
        [_billTypeInputView.moneyInput becomeFirstResponder];
        [CDAutoHideMessageHUD showMessage:@"金额不能为0"];
        return NO;
    }
    
    if ([self.item.money doubleValue] < 0) {
        [_billTypeInputView.moneyInput becomeFirstResponder];
        [CDAutoHideMessageHUD showMessage:@"金额不能小于0"];
        return NO;
    }
    
    if (self.item.fundOperatorType == 2) {
        [_billTypeInputView.moneyInput becomeFirstResponder];
        [CDAutoHideMessageHUD showMessage:@"请先添加资金账户"];
        return NO;
    }
    
    if (self.item.chargeMemo.length > 500) {
        [CDAutoHideMessageHUD showMessage:@"备注最多只能输入500个字"];
        return NO;
    }
    
    if (self.item.membersItem.count == 0) {
        [CDAutoHideMessageHUD showMessage:@"请至少选择一个成员"];
        return NO;
    }
    
    return YES;
}

- (void)makeArecord {
    self.item.incomeOrExpence = _customNaviBar.selectedBillType;
    self.item.money = _billTypeInputView.moneyInput.text;
    self.item.chargeMemo = _accessoryView.memoView.text;
    self.item.membersItem = self.memberSelectView.selectedMemberItems;
    
    NSObject<SSJBooksItemProtocol> *bookItem = [self.booksItems ssj_safeObjectAtIndex:self.customNaviBar.selectedTitleIndex];
    if ([bookItem isKindOfClass:[SSJBooksTypeItem class]]) {
        // 如果是编辑周期记账流水，不改变原有的流水类型，如果改变了，又会生成一笔周期流水
        if (self.item.idType != SSJChargeIdTypeCircleConfig) {
            self.item.sundryId = nil;
            self.item.idType = SSJChargeIdTypeNormal;
        }
    } else if ([bookItem isKindOfClass:[SSJShareBookItem class]]) {
        self.item.sundryId = bookItem.booksId;
        self.item.idType = SSJChargeIdTypeShareBooks;
    }
    
    if (![self verifyItem]) {
        return;
    }
    
    if (self.item.chargeMemo && self.item.ID.length) {
        [SSJAnaliyticsManager event:@"addRecord_memo"];
    }
    
    if (_selectedImage != nil) {
        NSString *imageName = SSJUUID();
        if (SSJSaveImage(_selectedImage, imageName) && SSJSaveThumbImage(_selectedImage, imageName)) {
            self.item.chargeImage = [NSString stringWithFormat:@"%@.jpg",imageName];
            self.item.chargeThumbImage = [NSString stringWithFormat:@"%@-thumb.jpg",imageName];
        }
    }
    
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJRecordMakingStore saveChargeWithChargeItem:self.item Success:^(SSJBillingChargeCellItem *editeItem){
            [subscriber sendNext:editeItem];
            [subscriber sendCompleted];
        } failure:^{
            [subscriber sendError:nil];
        }];
        return nil;
    }] flattenMap:^RACStream *(SSJBillingChargeCellItem *editeItem) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            BOOL hasChangeBooksType = ![editeItem.booksId isEqualToString:self.defaultBooksId];
            if (hasChangeBooksType) {
                NSObject<SSJBooksItemProtocol> *bookItem = [self.booksItems ssj_safeObjectAtIndex:self.customNaviBar.selectedTitleIndex];
                ;
                if ([bookItem isKindOfClass:[SSJBooksTypeItem class]]) {
                    SSJSaveBooksCategory(SSJBooksCategoryPersional);
                } else if ([bookItem isKindOfClass:[SSJShareBookItem class]]) {
                    SSJSaveBooksCategory(SSJBooksCategoryPublic);
                }
                [SSJUserTableManager updateCurrentBooksId:editeItem.booksId success:^{
                    [subscriber sendNext:editeItem];
                    [subscriber sendCompleted];
                } failure:^(NSError * _Nonnull error) {
                    [subscriber sendError:error];
                }];
            } else {
                [subscriber sendNext:editeItem];
                [subscriber sendCompleted];
            }
            return nil;
        }];
    }] subscribeNext:^(SSJBillingChargeCellItem *editeItem) {
        BOOL hasChangeBooksType = ![editeItem.booksId isEqualToString:self.defaultBooksId];
        if (self.addNewChargeBlock) {
            self.addNewChargeBlock(@[editeItem],hasChangeBooksType);
        }
        //发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:SSJReminderNotificationKey object:nil];
        [self goBackAction];
    } error:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

- (BOOL)showGuideViewIfNeeded {
    if ([self needToShowGuide]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsEverEnteredKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (self.customNaviBar.selectedBillType == SSJBillTypePay
            || self.customNaviBar.selectedBillType == SSJBillTypeIncome) {
            __weak typeof(self) wself = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                SSJRecordMakingBillTypeSelectionView *selectionView = wself.customNaviBar.selectedBillType == SSJBillTypePay ? wself.paymentTypeView : wself.incomeTypeView;
                [selectionView showGuideWithDismissHandler:^(SSJRecordMakingBillTypeSelectionView *view){
                    [view.items enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(SSJRecordMakingBillTypeSelectionCellItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (wself.item.billId && [obj.ID isEqualToString:wself.item.billId]) {
                            obj.state = SSJRecordMakingBillTypeSelectionCellStateSelected;
                            *stop = YES;
                        }
                    }];
                }];
            });
        }
    }
    return [self needToShowGuide];
}

- (BOOL)needToShowGuide {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:kIsEverEnteredKey];
}

- (void)initBillTypeView:(SSJRecordMakingBillTypeSelectionView *)billTypeView {
    __weak typeof(self) wself = self;
    billTypeView.contentInsets = UIEdgeInsetsMake(0, 0, [SSJCustomKeyboard sharedInstance].height + self.accessoryView.height, 0);
    
    billTypeView.deleteAction = ^(SSJRecordMakingBillTypeSelectionView *selectionView, SSJRecordMakingBillTypeSelectionCellItem *item) {
        [wself deleteItem:item ofItems:selectionView.items];
        [SSJAnaliyticsManager event:@"bill_type_delete"];
    };
    
    billTypeView.editAction = ^(SSJRecordMakingBillTypeSelectionView *view, SSJRecordMakingBillTypeSelectionCellItem *item) {
        SSJCreateOrEditBillTypeViewController *addBillTypeVC = [[SSJCreateOrEditBillTypeViewController alloc] init];
        addBillTypeVC.created = NO;
        addBillTypeVC.expended = wself.customNaviBar.selectedBillType;
        addBillTypeVC.booksId = wself.item.booksId;
        addBillTypeVC.billId = item.ID;
        addBillTypeVC.icon = item.imageName;
        addBillTypeVC.name = item.title;
        addBillTypeVC.color = item.colorValue;
        addBillTypeVC.saveHandler = ^(NSString * _Nonnull billID) {
            wself.addOrEditBillId = billID;
        };
        [wself.navigationController pushViewController:addBillTypeVC animated:YES];
    };
    
    billTypeView.selectAction = ^(SSJRecordMakingBillTypeSelectionView *selectionView, SSJRecordMakingBillTypeSelectionCellItem *item) {
        [wself.billTypeInputView.moneyInput becomeFirstResponder];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            wself.billTypeInputView.billTypeName = item.title;
            wself.billTypeInputView.fillColor = [UIColor ssj_colorWithHex:item.colorValue];
        }];
        wself.item.billId = item.ID;
    };
    
    billTypeView.addAction = ^(SSJRecordMakingBillTypeSelectionView *selectionView) {
        SSJCreateOrEditBillTypeViewController *addBillTypeVC = [[SSJCreateOrEditBillTypeViewController alloc] init];
        addBillTypeVC.created = YES;
        addBillTypeVC.expended = wself.customNaviBar.selectedBillType;
        addBillTypeVC.booksId = wself.item.booksId;
        addBillTypeVC.saveHandler = ^(NSString * _Nonnull billID) {
            wself.addOrEditBillId = billID;
        };
        [wself.navigationController pushViewController:addBillTypeVC animated:YES];
    };
    
    billTypeView.dragAction = ^(SSJRecordMakingBillTypeSelectionView *selectionView, BOOL isDragUp) {
        if (!selectionView.editing) {
            [wself.currentInput resignFirstResponder];
        }
    };
    
    billTypeView.beginEditingAction = ^(SSJRecordMakingBillTypeSelectionView *selectionView) {
        wself.customNaviBar.managed = YES;
        [wself.currentInput resignFirstResponder];
    };
    
    billTypeView.endEditingAction = ^(SSJRecordMakingBillTypeSelectionView *selectionView) {
        [wself.currentInput becomeFirstResponder];
        wself.customNaviBar.managed = NO;
        
        if (selectionView.orderChanged) {
            [SSJCategoryListHelper updateCategoryOrderWithItems:selectionView.items booksID:(NSString *)wself.item.booksId success:^{
                [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
            } failure:^(NSError *error) {
                [CDAutoHideMessageHUD showError:error];
            }];
        }
        
        SSJRecordMakingBillTypeSelectionCellItem *selectedItem = [selectionView selectedItem];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            wself.billTypeInputView.billTypeName = selectedItem ? selectedItem.title : nil;
            wself.billTypeInputView.fillColor = selectedItem ? [UIColor ssj_colorWithHex:selectedItem.colorValue] : INPUT_DEFAULT_COLOR;
        }];
        wself.item.billId = selectedItem ? selectedItem.ID : nil;
    };
}

- (void)updateMemberButtonTitle {
    if (self.memberSelectView.selectedMemberItems.count == 1) {
        SSJChargeMemberItem *item = [self.memberSelectView.selectedMemberItems firstObject];
        [self.accessoryView.memberBtn setTitle:item.memberName forState:SSJButtonStateNormal];
    }else{
        NSString *title = [NSString stringWithFormat:@"%d人",(int)self.memberSelectView.selectedMemberItems.count];
        [self.accessoryView.memberBtn setTitle:title forState:SSJButtonStateNormal];
    }
}

- (void)updateFundingType {
    [self.accessoryView.accountBtn setTitle:self.item.fundName forState:SSJButtonStateNormal];
    self.accessoryView.accountBtn.selected = YES;
    self.FundingTypeSelectView.selectFundID = self.item.fundId;
}

- (void)updateNavigationRightItem {
    if (_customNaviBar.selectedBillType == SSJBillTypePay) {
        _customNaviBar.managed = _paymentTypeView.editing;
    } else if (_customNaviBar.selectedBillType == SSJBillTypeIncome) {
        _customNaviBar.managed = _incomeTypeView.editing;
    }
}

- (void)deleteItem:(SSJRecordMakingBillTypeSelectionCellItem *)item ofItems:(NSArray *)items {
    [SSJCategoryListHelper deleteBillTypeWithId:item.ID userId:SSJUSERID() booksId:self.item.booksId success:NULL failure:^(NSError *error) {
        [CDAutoHideMessageHUD showError:error];
    }];
}

- (void)updateAppearance {
    [self.customNaviBar updateAppearance];
    [self.accessoryView updateAppearance];
    self.dateSelectedView.horuAndMinuBgViewBgColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainFillColor alpha:1];
}

@end
