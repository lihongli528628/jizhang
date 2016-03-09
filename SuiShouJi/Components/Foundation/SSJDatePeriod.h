//
//  SSJDatePeriod.h
//  SuiShouJi
//
//  Created by old lang on 16/3/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SSJDatePeriodType) {
    SSJDatePeriodTypeWeek = NSCalendarUnitWeekOfYear,
    SSJDatePeriodTypeMonth = NSCalendarUnitMonth,
    SSJDatePeriodTypeYear = NSCalendarUnitYear
};

typedef NS_ENUM(NSInteger, SSJDatePeriodComparisonResult) {
    SSJDatePeriodComparisonResultUnknown = NSIntegerMin,
    SSJDatePeriodComparisonResultAscending = NSOrderedAscending,
    SSJDatePeriodComparisonResultSame = NSOrderedSame,
    SSJDatePeriodComparisonResultDescending = NSOrderedDescending
};

@interface SSJDatePeriod : NSObject

@property (nullable, nonatomic, strong, readonly) NSDate *startDate;

@property (nullable, nonatomic, strong, readonly) NSDate *endDate;

@property (nonatomic, readonly) SSJDatePeriodType periodType;

- (nullable instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

+ (nullable instancetype)datePeriodWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

+ (instancetype)datePeriodWithPeriodType:(SSJDatePeriodType)type date:(NSDate *)date;

+ (SSJDatePeriodComparisonResult)compareDate:(NSDate *)date withAnotherDate:(NSDate *)anotherDate periodType:(SSJDatePeriodType)type;

- (SSJDatePeriodComparisonResult)compareWithPeriod:(SSJDatePeriod *)period;

- (SSJDatePeriodComparisonResult)compareWithDate:(NSDate *)date;

+ (nullable NSArray *)periodsBetweenDate:(NSDate *)date andAnotherDate:(NSDate *)anotherDate periodType:(SSJDatePeriodType)type;

- (nullable NSArray *)periodsFromPeriod:(SSJDatePeriod *)period;

- (nullable NSArray *)periodsFromDate:(NSDate *)date;

+ (NSInteger)periodCountFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate periodType:(SSJDatePeriodType)type;

- (NSInteger)periodCountFromPeriod:(SSJDatePeriod *)period;

- (NSInteger)periodCountFromDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END