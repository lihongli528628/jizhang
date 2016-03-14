//
//  calendarView.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/14.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCalendarView.h"
#import "SSJCalendarCollectionViewCell.h"


@interface SSJCalendarView()
@property (nonatomic,strong) NSMutableArray *items;
@end

@implementation SSJCalendarView{
    CGFloat _marginForHorizon;
    CGFloat _marginForvertical;
    NSArray *_weekArray;
    long _currentYear;
    long _currentMonth;
    long _currentDay;

}
#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _marginForHorizon = (self.width - 35*7) / 9;
        _marginForvertical = (self.height - 35*7) / 14;
        _weekArray = [NSArray arrayWithObjects:@"日",@"一",@"二",@"三",@"四",@"五",@"六",  nil];
        [self addSubview:self.calendar];
        [self.calendar registerClass:[SSJCalendarCollectionViewCell class] forCellWithReuseIdentifier:@"NormalCell"];
        if ([self.selectDateStr isEqualToString:@""] || self.selectDateStr == nil) {
            self.selectDateStr = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"];
        }
        [self getCurrentDate];
        [self getItems];
    }
    return self;
}

-(void)layoutSubviews{
    self.calendar.frame = CGRectMake(0, 0, self.width, self.height);
}

#pragma mark - Getter
- (UICollectionView *)calendar{
    if (_calendar == nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = _marginForHorizon;
        _calendar =[[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _calendar.backgroundColor=[UIColor whiteColor];
        _calendar.dataSource=self;
        _calendar.delegate=self;
        _calendar.allowsMultipleSelection = NO;
    }
    return _calendar;
}

#pragma mark - UICollectionViewDataSource
//返回section的个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//返回section中的cell个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 49;

}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(_marginForvertical,_marginForHorizon,_marginForvertical,_marginForHorizon);
}


//返回cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SSJCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NormalCell" forIndexPath:indexPath];
    cell.item = [self.items objectAtIndex:indexPath.row];
//    if (indexPath.row < 7) {
//        SSJCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NormalCell" forIndexPath:indexPath];
//        cell.currentDay = [_weekArray objectAtIndex:indexPath.row];
//        cell.selectable = NO;
//        cell.isSelected = NO;
//        return cell;
//    }
//    if (indexPath.row < [self getWeekOfFirstDayOfMonth:self.year withMonth:self.month] + 7 - 1) {
//        SSJCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NormalCell" forIndexPath:indexPath];
//        cell.currentDay = @"";
//        cell.selectable = NO;
//        cell.isSelected = NO;
//        return cell;
//    }else{
//        if (indexPath.row > [self getWeekOfFirstDayOfMonth:self.year withMonth:self.month] + [self getDaysOfMonth:self.year withMonth:self.month] + 5) {
//            SSJCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NormalCell" forIndexPath:indexPath];
//            cell.currentDay = @"";
//            cell.selectable = NO;
//            cell.isSelected = NO;
//            return cell;
//        }else{
//            SSJCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NormalCell" forIndexPath:indexPath];
//            cell.currentDay = [[NSString alloc] initWithFormat:@"%ld",indexPath.row - [self getWeekOfFirstDayOfMonth:self.year withMonth:self.month] - 5];
//            if (_year > _currentYear) {
//                cell.selectable = NO;
//                cell.iscurrentDay = NO;
//                cell.isSelected = NO;
//            }else if (_year == _currentYear && _month > _currentMonth){
//                cell.selectable = NO;
//                cell.iscurrentDay = NO;
//                cell.isSelected = NO;
//            }else if ([cell.currentDay integerValue] > _currentDay && _year == _currentYear && _month == _currentMonth){
//                cell.selectable = NO;
//                cell.iscurrentDay = NO;
//                cell.isSelected = NO;
//            }else{
//                if ([cell.currentDay integerValue] == _currentDay && _year == _currentYear && _month == _currentMonth) {
//                    cell.selectable = YES;
//                    cell.iscurrentDay = YES;
//                }else if([cell.currentDay integerValue] == self.day && _year == self.selectedYear && _month == self.selectedMonth){
//                    cell.selectable = YES;
//                    cell.iscurrentDay = NO;
//                    cell.isSelected = YES;
//                }else{
//                    cell.selectable = YES;
//                    cell.iscurrentDay = NO;
//                    cell.isSelected = NO;
//                }
//            }
//            return cell;
//        }
//    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
//返回cell的宽和高
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(36, 36);
}

//每行cell之间的间隔
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return _marginForvertical;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SSJCalendarCollectionViewCell *cell = (SSJCalendarCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    self.selectDateStr = cell.item.dateStr;
    if (self.DateSelectedBlock) {
        self.DateSelectedBlock(_year,_month,[((SSJCalendarCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath]).currentDay integerValue],cell.item.dateStr);
    }
    [self reloadCalender];
//    if (cell.isSelected == NO) {
//        for (int i = 0; i < [collectionView.visibleCells count]; i++) {
//            ((SSJCalendarCollectionViewCell*)[collectionView.visibleCells objectAtIndex:i]).isSelected = NO;
//        }
//        cell.isSelected = YES;
//        if (self.DateSelectedBlock) {
//            self.DateSelectedBlock(_year,_month,[((SSJCalendarCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath]).currentDay integerValue]);
//        }
//    }else{
//        for (int i = 0; i < [collectionView.visibleCells count]; i++) {
//            ((SSJCalendarCollectionViewCell*)[collectionView.visibleCells objectAtIndex:i]).isSelected = NO;
//        }
//    }
}

#pragma mark - Private
//获得某个月的第一天是星期几
-(long)getWeekOfFirstDayOfMonth:(long)year withMonth:(long)month{
    if (month == 0) {
        month = 12;
        year = year - 1;
    }else if(month == 13){
        month = 1;
        year = year + 1;
    }
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSString *firstWeekDayMonth = [[NSString alloc] initWithFormat:@"%ld",year];
    firstWeekDayMonth = [firstWeekDayMonth stringByAppendingString:[[NSString alloc]initWithFormat:@"%s","-"]];
    firstWeekDayMonth = [firstWeekDayMonth stringByAppendingString:[[NSString alloc]initWithFormat:@"%ld",month]];
    firstWeekDayMonth = [firstWeekDayMonth stringByAppendingString:[[NSString alloc]initWithFormat:@"%s","-"]];
    firstWeekDayMonth = [firstWeekDayMonth stringByAppendingString:[[NSString alloc]initWithFormat:@"%d",1]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *weekOfFirstDayOfMonth = [dateFormatter dateFromString:firstWeekDayMonth];
    NSDateComponents *newCom = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:weekOfFirstDayOfMonth];
    return [newCom weekday];
}

//返回一个月有多少天
-(long)getDaysOfMonth:(long)year withMonth:(long)month{
    if (month == 0) {
        month = 12;
        year = year - 1;
    }else if(month == 13){
        month = 1;
        year = year + 1;
    }
    NSInteger days = 0;
    //1,3,5,7,8,10,12
    NSArray *bigMoth = [[NSArray alloc] initWithObjects:@"1",@"3",@"5",@"7",@"8",@"10",@"12", nil];
    //4,6,9,11
    NSArray *milMoth = [[NSArray alloc] initWithObjects:@"4",@"6",@"9",@"11", nil];
    if ([bigMoth containsObject:[[NSString alloc] initWithFormat:@"%ld",(long)month]]) {
        days = 31;
    }else if([milMoth containsObject:[[NSString alloc] initWithFormat:@"%ld",(long)month]]){
        days = 30;
    }else{
        if ([self isLoopYear:year]) {
            days = 29;
        }else
            days = 28;
    }
    return days;
}

//判断是否是闰年
-(BOOL)isLoopYear:(NSInteger)year{
    if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return true;
    }else
        return NO;
}

//返回日历高度
- (CGFloat)viewHeight{

    return 315;
}

-(void)setMonth:(long)month{
    _month = month;
    [self.calendar reloadData];
}

-(void)getCurrentDate{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    _currentYear = [dateComponent year];
    _currentDay = [dateComponent day];
    _currentMonth = [dateComponent month];
}

-(void)getItems{
    self.items = [[NSMutableArray alloc]initWithCapacity:0];
    NSString *currentDateStr = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"];
    for (int i = 0; i < 49; i++) {
        SSJCalenderCellItem *item = [[SSJCalenderCellItem alloc]init];
        if (i < 7) {
            item.dateStr = [_weekArray objectAtIndex:i];
            item.backGroundColor = @"FFFFFF";
            item.titleColor = @"e7e7e7";
            item.isSelectable = NO;
            [self.items addObject:item];
        }else if (i < [self getWeekOfFirstDayOfMonth:self.year withMonth:self.month] + 7 - 1){
            item.dateStr = @"";
            item.backGroundColor = @"FFFFFF";
            item.titleColor = @"e7e7e7";
            item.isSelectable = NO;
            [self.items addObject:item];
        }else if(i > [self getWeekOfFirstDayOfMonth:self.year withMonth:self.month] + [self getDaysOfMonth:self.year withMonth:self.month] + 5){
            item.dateStr = @"";
            item.backGroundColor = @"FFFFFF";
            item.titleColor = @"e7e7e7";
            item.isSelectable = NO;
            [self.items addObject:item];
        }else{
            NSString *cellDay = [[NSString alloc] initWithFormat:@"%ld",i - [self getWeekOfFirstDayOfMonth:self.year withMonth:self.month] - 5];
            item.dateStr = [NSString stringWithFormat:@"%ld-%02ld-%02d",self.year,self.month,[cellDay intValue]];
            if (_year > _currentYear) {
                item.backGroundColor = @"FFFFFF";
                item.titleColor = @"e7e7e7";
                item.isSelectable = NO;
                [self.items addObject:item];
            }else if (_year == _currentYear && _month > _currentMonth){
                item.backGroundColor = @"FFFFFF";
                item.titleColor = @"e7e7e7";
                item.isSelectable = NO;
                [self.items addObject:item];
            }else if ([cellDay integerValue] > _currentDay && _year == _currentYear && _month == _currentMonth){
                item.backGroundColor = @"FFFFFF";
                item.titleColor = @"e7e7e7";
                item.isSelectable = NO;
                [self.items addObject:item];
            }else{
                if ([item.dateStr isEqualToString:self.selectDateStr]) {
                    if ([item.dateStr isEqualToString:currentDateStr]) {
                        item.backGroundColor = @"47cfbe";
                        item.titleColor = @"FFFFFF";
                        item.isSelectable = YES;
                        [self.items addObject:item];
                    }else{
                        item.backGroundColor = @"cccccc";
                        item.titleColor = @"FFFFFF";
                        item.isSelectable = YES;
                        [self.items addObject:item];
                    }
                }else{
                    if ([item.dateStr isEqualToString:currentDateStr]) {
                        item.backGroundColor = @"FFFFFF";
                        item.titleColor = @"47cfbe";
                        item.isSelectable = YES;
                        [self.items addObject:item];
                    }else{
                        item.backGroundColor = @"FFFFFF";
                        item.titleColor = @"393939";
                        item.isSelectable = YES;
                        [self.items addObject:item];
                    }
                }
            }
        }
    }
}

-(void)reloadCalender{
    [self getCurrentDate];
    [self getItems];
    [self.calendar reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
