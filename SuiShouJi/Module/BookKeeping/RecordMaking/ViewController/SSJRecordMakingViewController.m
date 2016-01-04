//
//  SSJRecordMakingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/16.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingViewController.h"
#import "SSJCustomKeyboard.h"
#import "SSJCategoryCollectionView.h"
#import "SSJCategoryListView.h"
#import "SSJCalendarView.h"
#import "SSJDateSelectedView.h"
#import "SSJCalendarCollectionViewCell.h"
#import "SSJFundingTypeSelectView.h"
#import "SSJCategoryCollectionViewCell.h"
#import "SSJADDNewTypeViewController.h"
#import "FMDB.h"
#import "FMDatabaseAdditions.h"

@interface SSJRecordMakingViewController ()
@property (nonatomic,strong) SSJCustomKeyboard* customKeyBoard;
@property (nonatomic,strong) SSJCategoryCollectionView* collectionView;
@property (nonatomic,strong) UIView* selectedCategoryView;
@property (nonatomic,strong) UIView* inputView;
@property (nonatomic,strong) UIView* inputAccessoryView;
@property (nonatomic,strong) UISegmentedControl *titleSegment;
@property (nonatomic,strong) UILabel* textInput;
@property (nonatomic,strong) UILabel* categoryNameLabel;
@property (nonatomic,strong) UIImageView* categoryImage;
@property (nonatomic,strong) SSJCategoryListView* categoryListView;
@property (nonatomic,strong) SSJDateSelectedView *DateSelectedView;
@property (nonatomic,strong) UIButton *datePickerButton;
@property (nonatomic,strong) SSJFundingTypeSelectView *FundingTypeSelectView;
@property (nonatomic,strong) UIButton *fundingTypeButton;
@property (nonatomic,strong) UIBarButtonItem *rightbutton;


@property (nonatomic) long currentYear;
@property (nonatomic) long currentMonth;
@property (nonatomic) long currentDay;
@end

@implementation SSJRecordMakingViewController{
    BOOL _numkeyHavePressed;
    NSString *_caculationResult;
    NSString *_firstNum;
    float _caculationValue;
    NSInteger _lastPressNum;
    NSString *_intPart;
    NSString *_decimalPart;
    int _decimalCount;
    NSString *_categoryID;
    NSString *_defualtColor;
    NSString *_defualtID;
    SSJFundingItem *_selectItem;
    SSJFundingItem *_defualtItem;
}
#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
        [self settitleSegment];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _numkeyHavePressed = NO;
    [self getCurrentDate];
    if (_selectedYear == 0) {
        self.selectedYear = _currentYear;
    }
    if (_selectedMonth == 0) {
        self.selectedMonth = _currentMonth;
    }
    if (_selectedDay == 0) {
        self.selectedDay = _currentDay;
    }
    [self getDefualtItem];
    [self getDefualtColorAndDefualtId];
    [self.view addSubview:self.selectedCategoryView];
    [self.selectedCategoryView addSubview:self.textInput];
    [self.selectedCategoryView addSubview:self.categoryImage];
    [self.view addSubview:self.inputView];
    [self.inputView addSubview:self.customKeyBoard];
    [self.view addSubview:self.inputAccessoryView];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.categoryListView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewType) name:@"addNewTypeNotification" object:nil];
    self.navigationItem.rightBarButtonItem = self.rightbutton;
    _intPart = @"0";
    _decimalPart = @"00";
}


-(void)viewDidLayoutSubviews{
    self.selectedCategoryView.leftTop = CGPointMake(0, 0);
    self.selectedCategoryView.size = CGSizeMake(self.view.width, 71);
    self.categoryImage.left = 12.0f;
    _decimalCount = 0;
    self.categoryImage.centerY = self.selectedCategoryView.centerY;
    self.textInput.right = self.selectedCategoryView.right - 12;
    self.textInput.centerY = self.categoryImage.centerY;
    self.inputView.bottom = self.view.bottom;
    self.customKeyBoard.height = 210;
    self.categoryListView.top = self.selectedCategoryView.bottom;
    self.inputAccessoryView.bottom = self.inputView.top;
    self.categoryListView.size = CGSizeMake(self.view.width, self.inputAccessoryView.top - self.selectedCategoryView.bottom);

}

#pragma mark SSJCustomKeyboardDelegate
- (void)didNumKeyPressed:(UIButton *)button{
    self.textInput.textColor = [UIColor whiteColor];
    if ([_intPart length] > 7 && self.customKeyBoard.decimalModel == NO) {
        return;
    }
    if (self.customKeyBoard.decimalModel == NO) {
        if ([self.textInput.text isEqualToString:@"0.00"]) {
            _intPart = button.titleLabel.text;
            self.textInput.text = [NSString stringWithFormat:@"%@.00",_intPart];
            if ([self.textInput.text isEqualToString:@"0.00"]) {
                _textInput.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
            }
        }else{
        self.textInput.text = [NSString stringWithFormat:@"%@%@.00",_intPart,button.titleLabel.text];
        _intPart = [NSString stringWithFormat:@"%@%@",_intPart,button.titleLabel.text];
        }
    }else{
        if (_decimalCount == 0) {
            _decimalPart = [_decimalPart stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:button.titleLabel.text];
            _decimalCount = _decimalCount + 1;
        }else if (_decimalCount == 1) {
            _decimalPart = [_decimalPart stringByReplacingCharactersInRange:NSMakeRange(1, 1) withString:button.titleLabel.text];
            _decimalCount = _decimalCount + 1;
        }
        self.textInput.text = [NSString stringWithFormat:@"%@.%@",_intPart,_decimalPart];
    _lastPressNum = [button.titleLabel.text integerValue];
    }
}

- (void)didDecimalPointKeyPressed{
    self.customKeyBoard.decimalModel = YES;
}

//- (void)didClearKeyPressed{
//    self.textInput.text = @"0.00";
//    self.customKeyBoard.decimalModel = NO;
//    _decimalPart = @"00";
//    _intPart = @"0";
//    _decimalCount = 0;
//}

- (void)didBackspaceKeyPressed{
    self.textInput.textColor = [UIColor whiteColor];
    NSString *intPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
    NSString *decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
    if (![decimalPart isEqualToString:@"00"]) {
        self.customKeyBoard.decimalModel = YES;
    }
    if (self.customKeyBoard.decimalModel == NO) {
        if ([intPart isEqualToString:@"0"] | ([intPart length] == 1)) {
            self.textInput.text = @"0.00";
            _textInput.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
            _decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
            _intPart =  [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
            return;
        }
        if ([intPart hasPrefix:@"-"]&&[intPart length] == 2) {
            self.textInput.text = @"0.00";
            _textInput.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
            _textInput.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
            _decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
            _intPart =  [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
            return;
        }
        intPart = [intPart substringToIndex:[intPart length] - 1];
        self.textInput.text = [NSString stringWithFormat:@"%@.%@",intPart,decimalPart];
    }else{
        if ([decimalPart isEqualToString:@"00"]) {
            self.customKeyBoard.decimalModel = NO;
            if ([intPart isEqualToString:@"0"]) {
                self.textInput.text = @"0.00";
                _textInput.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
                _textInput.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
                _decimalCount = 0;
                return;
            }
            if ([intPart length] == 1) {
                self.textInput.text = @"0.00";
                _textInput.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
                _decimalCount = 0;
                return;
            }
            intPart = [intPart substringToIndex:[intPart length] - 1];
            self.textInput.text = [NSString stringWithFormat:@"%@.00",intPart];
        }else if ([decimalPart hasSuffix:@"0"]){
            self.textInput.text = [NSString stringWithFormat:@"%@.00",intPart];
            _textInput.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
            _decimalCount = _decimalCount - 1;
        }else{
            decimalPart = [decimalPart substringToIndex:1];
            self.textInput.text = [NSString stringWithFormat:@"%@.%@0",intPart,decimalPart];
            _decimalCount = _decimalCount - 1;
        }
    }
    _decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
    _intPart =  [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
}

//- (void)didPlusKeyPressed{
//    self.customKeyBoard.PlusOrMinusModel = YES;
//    _caculationValue =_caculationValue + [self.textInput.text floatValue];
//    self.textInput.text = @"0.00";
//    [self.customKeyBoard.ComfirmButton setTitle:@"=" forState:UIControlStateNormal];
//    self.customKeyBoard.decimalModel = NO;
//    _decimalPart = @"00";
//    _intPart = @"0";
//    _decimalCount = 0;
//}
//
//- (void)didMinusKeyPressed{
//    self.customKeyBoard.PlusOrMinusModel = NO;
//    if (_numkeyHavePressed == NO) {
//        _caculationValue = [self.textInput.text floatValue];
//    }else{
//        _caculationValue = _caculationValue - [self.textInput.text floatValue];
//    }
//    self.textInput.text = @"0.00";
//    [self.customKeyBoard.ComfirmButton setTitle:@"=" forState:UIControlStateNormal];
//    self.customKeyBoard.decimalModel = NO;
//    _decimalPart = @"00";
//    _intPart = @"0";
//    _decimalCount = 0;
//}

- (void)comfirmButtonClick:(id)sender{
    if ([self.textInput.text isEqualToString:@"0.00"]) {
        [CDAutoHideMessageHUD showMessage:@"记账金额不能为0"];
        return;
    }
    [self makeArecord];
//    }else if ([button.titleLabel.text isEqualToString:@"="]){
//        if (self.customKeyBoard.PlusOrMinusModel == YES) {
//            _caculationValue = _caculationValue + [self.textInput.text floatValue];
//            self.textInput.text = [NSString stringWithFormat:@"%.2f",_caculationValue];
//            _caculationValue = 0.0f;
//            self.customKeyBoard.decimalModel = NO;
//            _decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
//            _intPart =  [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
//            _decimalCount = 0;
//        }else{
//            _caculationValue = _caculationValue  - [self.textInput.text floatValue];
//            self.textInput.text = [NSString stringWithFormat:@"%.2f",_caculationValue];
//            _caculationValue = 0.0f;
//            self.customKeyBoard.decimalModel = NO;
//            _decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
//            _intPart =  [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
//            _decimalCount = 0;
//        }
//        [self.customKeyBoard.ComfirmButton setTitle:@"确定" forState:UIControlStateNormal];
//    }
}

#pragma mark - Getter
-(SSJCustomKeyboard*)customKeyBoard{
    if (!_customKeyBoard) {
        _customKeyBoard = [[SSJCustomKeyboard alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 210)];
        _customKeyBoard.delegate = self;
    }
    return _customKeyBoard;
}

-(UIView*)selectedCategoryView{
    if (!_selectedCategoryView) {
        _selectedCategoryView = [[UIView alloc]init];
//        _selectedCategoryView.backgroundColor = [UIColor redColor];
        _selectedCategoryView.layer.borderColor = [UIColor ssj_colorWithHex:@"cccccc"].CGColor;
        _selectedCategoryView.layer.borderWidth = 1.0f;
        _selectedCategoryView.backgroundColor = [UIColor ssj_colorWithHex:_defualtColor];
    }
    return _selectedCategoryView;
}

-(SSJCategoryListView*)categoryListView{
    if (_categoryListView == nil) {
        _categoryListView = [[SSJCategoryListView alloc]initWithFrame:CGRectZero];
        _categoryListView.incomeOrExpence = !_titleSegment.selectedSegmentIndex;
        __weak typeof(self) weakSelf = self;
        _categoryListView.CategorySelected = ^(NSString *categoryTitle , NSString *categoryImage,NSString *categoryID , NSString *categoryColor){
            _categoryID = categoryID;
            if (![categoryTitle isEqualToString:@"添加"]) {
                weakSelf.categoryNameLabel.text = categoryTitle;
                [weakSelf.categoryNameLabel sizeToFit];
                weakSelf.selectedCategoryView.backgroundColor = [UIColor ssj_colorWithHex:categoryColor];
                weakSelf.categoryImage.tintColor = [UIColor whiteColor];
                weakSelf.categoryImage.image = [[UIImage imageNamed:categoryImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }else{
                SSJADDNewTypeViewController *addNewTypeVc = [[SSJADDNewTypeViewController alloc]init];
                addNewTypeVc.incomeOrExpence = !weakSelf.titleSegment.selectedSegmentIndex;
                [weakSelf.navigationController pushViewController:addNewTypeVc animated:YES];
            }
        };
    }
    return _categoryListView;
}

-(UILabel*)textInput{
    if (!_textInput) {
        _textInput = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
        _textInput.font = [UIFont systemFontOfSize:30];
        _textInput.textAlignment = NSTextAlignmentRight;
        _textInput.text = @"0.00";
        _textInput.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    }
    return _textInput;
}

-(UIImageView*)categoryImage{
    if (!_categoryImage) {
        _categoryImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 26, 26)];
        _categoryImage.layer.cornerRadius = 13;
        _categoryImage.layer.masksToBounds = YES;
        _categoryImage.tintColor = [UIColor whiteColor];
        [_categoryImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return _categoryImage;
}

-(UIView*)inputView{
    if (!_inputView ) {
        _inputView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 210)];
    }
    return _inputView;
}

-(UIView*)inputAccessoryView{
    if (!_inputAccessoryView ) {
        _inputAccessoryView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
        _inputAccessoryView.backgroundColor = [UIColor whiteColor];
        [_inputAccessoryView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"e2e2e2"]];
        [_inputAccessoryView ssj_setBorderStyle:SSJBorderStyleTop];
        _fundingTypeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.width / 2, 50)];
        [_fundingTypeButton setTitle:_defualtItem.fundingName forState:UIControlStateNormal];
        [_fundingTypeButton setTitleColor:[UIColor ssj_colorWithHex:@"393939"] forState:UIControlStateNormal];
        _fundingTypeButton.titleLabel.font = [UIFont systemFontOfSize:18];
        _fundingTypeButton.layer.borderColor = [UIColor ssj_colorWithHex:@"e2e2e2"].CGColor;
        _fundingTypeButton.layer.borderWidth = 1.0f / 2;
        [_fundingTypeButton addTarget:self action:@selector(fundingTypeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_inputAccessoryView addSubview:_fundingTypeButton];
        self.datePickerButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.width / 2, 0, self.view.width / 2, 50)];
        [self.datePickerButton setTitle:[NSString stringWithFormat:@"%ld月%ld日",self.selectedMonth,self.selectedDay] forState:UIControlStateNormal];
        [self.datePickerButton setTitleColor:[UIColor ssj_colorWithHex:@"393939"] forState:UIControlStateNormal];
        self.datePickerButton.titleLabel.font = [UIFont systemFontOfSize:18];
        self.datePickerButton.layer.borderColor = [UIColor ssj_colorWithHex:@"e2e2e2"].CGColor;
        self.datePickerButton.layer.borderWidth = 1.0f / 2;
        [self.datePickerButton addTarget:self action:@selector(datePickerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_inputAccessoryView addSubview:self.datePickerButton];

    }
    return _inputAccessoryView;
}

-(SSJDateSelectedView*)DateSelectedView{
    if (!_DateSelectedView) {
        _DateSelectedView = [[SSJDateSelectedView alloc]initWithFrame:[UIScreen mainScreen].bounds forYear:self.selectedYear Month:self.selectedMonth Day:self.selectedDay];
        __weak typeof(self) weakSelf = self;
        _DateSelectedView.calendarView.DateSelectedBlock = ^(long year , long month ,long day){
            _selectedDay = day;
            _selectedMonth = month;
            _selectedYear = year;
            [weakSelf.datePickerButton setTitle:[NSString stringWithFormat:@"%ld月%ld日",weakSelf.selectedMonth,weakSelf.selectedDay] forState:UIControlStateNormal];
            for (int i = 0; i < [self.DateSelectedView.calendarView.calendar.visibleCells count]; i ++) {
                if ([((SSJCalendarCollectionViewCell*)[weakSelf.DateSelectedView.calendarView.calendar.visibleCells objectAtIndex:i]).currentDay integerValue] == day && ((SSJCalendarCollectionViewCell*)[weakSelf.DateSelectedView.calendarView.calendar.visibleCells objectAtIndex:i]).selectable == YES) {
                    ((SSJCalendarCollectionViewCell*)[weakSelf.DateSelectedView.calendarView.calendar.visibleCells objectAtIndex:i]).isSelected = YES;
                }else{
                    ((SSJCalendarCollectionViewCell*)[weakSelf.DateSelectedView.calendarView.calendar.visibleCells objectAtIndex:i]).isSelected = NO;
                }
            }
            [weakSelf.DateSelectedView removeFromSuperview];
        };
    }
    return _DateSelectedView;
}

-(SSJCategoryCollectionView*)collectionView{
    if (!_collectionView) {
        _collectionView = [[SSJCategoryCollectionView alloc]init];
        _collectionView.frame = CGRectMake(0, 0, self.view.width, 230);
    }
    return _collectionView;
}

-(SSJFundingTypeSelectView *)FundingTypeSelectView{
    if (!_FundingTypeSelectView) {
        __weak typeof(self) weakSelf = self;
        _FundingTypeSelectView = [[SSJFundingTypeSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _FundingTypeSelectView.fundingTypeSelectBlock = ^(SSJFundingItem *fundingItem){
            [weakSelf.fundingTypeButton setTitle:fundingItem.fundingName forState:UIControlStateNormal];
            _selectItem = fundingItem;
            [weakSelf.FundingTypeSelectView removeFromSuperview];
        };
    }
    return _FundingTypeSelectView;
}

-(UIBarButtonItem *)rightbutton{
    if (!_rightbutton) {
        _rightbutton = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(comfirmButtonClick:)];
    }
    return _rightbutton;
}
#pragma mark - private
-(void)settitleSegment{
    NSArray *segmentArray = @[@"支出",@"收入"];
    _titleSegment = [[UISegmentedControl alloc]initWithItems:segmentArray];
    _titleSegment.selectedSegmentIndex = 0;
    _titleSegment.size = CGSizeMake(115, 30);
    _titleSegment.tintColor = [UIColor ssj_colorWithHex:@"47cfbe"];
    NSDictionary *dictForNormal = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor ssj_colorWithHex:@"a7a7a7"],NSForegroundColorAttributeName,[UIFont systemFontOfSize:15],NSFontAttributeName,nil];
    [_titleSegment setTitleTextAttributes:dictForNormal forState:UIControlStateNormal];
    NSDictionary *dictForSelected = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:15],NSFontAttributeName,nil];
    [_titleSegment setTitleTextAttributes:dictForSelected forState:UIControlStateSelected];
    [_titleSegment addTarget: self action: @selector(segmentPressed:)forControlEvents: UIControlEventValueChanged];
    self.navigationItem.titleView = _titleSegment;
}

-(void)datePickerButtonClicked:(UIButton*)button{
    [[UIApplication sharedApplication].keyWindow addSubview:self.DateSelectedView];
}

-(void)fundingTypeButtonClicked:(UIButton*)button{
    [[UIApplication sharedApplication].keyWindow addSubview:self.FundingTypeSelectView];
}

-(void)getCurrentDate{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    _currentYear= [dateComponent year];
    _currentDay = [dateComponent day];
    _currentMonth = [dateComponent month];
}

-(void)makeArecord{
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
        return ;
    }
    if (!_categoryID) {
        _categoryID = _defualtID;
    }
    NSString *chargeID = SSJUUID();
    NSString *userID = SSJUSERID();
    double chargeMoney = [self.textInput.text doubleValue];
    SSJFundingItem *fundingType;
    if (_selectItem == nil) {
        fundingType = _defualtItem;
    }else{
        fundingType = _selectItem;
    }
    double fundingSum;
    if (self.titleSegment.selectedSegmentIndex == 0) {
        fundingSum = fundingType.fundingBalance - chargeMoney;
    }else{
        fundingSum = fundingType.fundingBalance + chargeMoney;
    }
    [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = ? WHERE CFUNDID = ? ",[NSNumber numberWithDouble:fundingSum],fundingType.fundingID];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss.SSS"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *operationTime = [NSString stringWithFormat:@"%@",currentDateStr];
    NSString *selectDate;
    if (self.selectedDay < 10) {
        if (self.selectedMonth < 10) {
            selectDate = [NSString stringWithFormat:@"%ld-0%ld-0%ld",self.selectedYear,self.selectedMonth,self.selectedDay];
        }else{
            selectDate = [NSString stringWithFormat:@"%ld-%ld-0%ld",self.selectedYear,self.selectedMonth,self.selectedDay];
        }
    }else{
        if (self.selectedMonth < 10) {
            selectDate = [NSString stringWithFormat:@"%ld-0%ld-%ld",self.selectedYear,self.selectedMonth,self.selectedDay];
        }else{
            selectDate = [NSString stringWithFormat:@"%ld-%ld-%ld",self.selectedYear,self.selectedMonth,self.selectedDay];
        }
    }
    [db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFID , CADDDATE , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE , CBILLDATE) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)",chargeID,userID,[NSNumber numberWithDouble:chargeMoney],_categoryID,fundingType.fundingID,@"111",[NSNumber numberWithDouble:19.99],[NSNumber numberWithDouble:19.99],operationTime,[NSNumber numberWithInt:100],[NSNumber numberWithBool:self.recordMakingType],selectDate];
    int count = 0;
    FMResultSet *s = [db executeQuery:@"SELECT COUNT(CBILLDATE) AS COUNT FROM BK_DAILYSUM_CHARGE WHERE CBILLDATE = ?",selectDate];
    if ([s next]) {
        count = [s intForColumn:@"COUNT"];
    }
    double incomeSum = 0.0;
    double expenseSum = 0.0;
    double sum = 0.0;
    if (count == 0) {
        if (self.titleSegment.selectedSegmentIndex == 0) {
            incomeSum = incomeSum - chargeMoney;
            sum = sum - chargeMoney;
        }else{
            expenseSum = expenseSum + chargeMoney;
            sum = sum + chargeMoney;
        }
        [db executeUpdate:@"INSERT INTO BK_DAILYSUM_CHARGE (CBILLDATE , EXPENCEAMOUNT , INCOMEAMOUNT  , SUMAMOUNT  , ICHARGEID  , IBILLID , CWRITEDATE) VALUES(?,?,?,?,?,?,?)",selectDate,[NSNumber numberWithDouble:expenseSum],[NSNumber numberWithDouble:incomeSum],[NSNumber numberWithDouble:sum],@"0",@"-1",@"0"];
    }else{
        FMResultSet *rs = [db executeQuery:@"SELECT EXPENCEAMOUNT, INCOMEAMOUNT , SUMAMOUNT FROM BK_DAILYSUM_CHARGE WHERE CBILLDATE = ?",selectDate];
        while ([rs next]) {
            incomeSum = [rs doubleForColumn:@"INCOMEAMOUNT"];
            expenseSum = [rs doubleForColumn:@"EXPENCEAMOUNT"];
            sum = [rs doubleForColumn:@"SUMAMOUNT"];
        }
        if (self.titleSegment.selectedSegmentIndex == 0) {
            expenseSum = expenseSum + chargeMoney;
            sum = sum - chargeMoney;
            [db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET EXPENCEAMOUNT = ? , SUMAMOUNT = ? WHERE CBILLDATE = ?",[NSNumber numberWithDouble:expenseSum],[NSNumber numberWithDouble:sum],selectDate];
        }else{
            incomeSum = incomeSum + chargeMoney;
            sum = sum + chargeMoney;
            [db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET INCOMEAMOUNT = ? , SUMAMOUNT = ? WHERE CBILLDATE = ?",[NSNumber numberWithDouble:incomeSum],[NSNumber numberWithDouble:sum],selectDate];
        }
    }
    [db close];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)segmentPressed:(id)sender{
    self.categoryListView.incomeOrExpence = !self.titleSegment.selectedSegmentIndex;
    self.categoryListView.scrollView.contentOffset = CGPointMake(0, 0);
    [self getDefualtColorAndDefualtId];
    self.selectedCategoryView.backgroundColor = [UIColor ssj_colorWithHex:_defualtColor];
    [self.categoryListView reloadData];
}

-(void)getDefualtColorAndDefualtId{
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
        return ;
    }
    FMResultSet *rs = [db executeQuery:@"SELECT ID , CCOLOR FROM BK_BILL_TYPE WHERE ITYPE = ? AND ISTATE = 1 LIMIT 1",[NSNumber numberWithDouble:!self.titleSegment.selectedSegmentIndex]];
    while([rs next]) {
        _defualtColor = [rs stringForColumn:@"CCOLOR"];
        _defualtID = [rs stringForColumn:@"ID"];
    }
    [db close];
}

-(void)getDefualtItem{
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
        return ;
    }
    FMResultSet * rs = [db executeQuery:@"SELECT A.* , B.IBALANCE FROM BK_FUND_INFO  A , BK_FUNS_ACCT B WHERE CPARENT != ? AND A.CFUNDID = B.CFUNDID LIMIT 1",@"root"];
    _defualtItem = [[SSJFundingItem alloc]init];
    while ([rs next]) {
        _defualtItem.fundingColor = [rs stringForColumn:@"CCOLOR"];
        _defualtItem.fundingIcon = [rs stringForColumn:@"CICOIN"];
        _defualtItem.fundingID = [rs stringForColumn:@"CFUNDID"];
        _defualtItem.fundingName = [rs stringForColumn:@"CACCTNAME"];
        _defualtItem.fundingParent = [rs stringForColumn:@"CPARENT"];
        _defualtItem.fundingBalance = [rs doubleForColumn:@"IBALANCE"];
    }
    [db close];
}

-(void)addNewType{
    [self.categoryListView reloadData];
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
