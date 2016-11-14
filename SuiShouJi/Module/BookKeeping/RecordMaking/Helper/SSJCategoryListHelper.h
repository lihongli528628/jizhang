//
//  SSJCategoryListHelper.h
//  SuiShouJi
//
//  Created by ricky on 16/3/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJRecordMakingBillTypeSelectionCellItem;
@class SSJRecordMakingCategoryItem;
@class SSJBillModel;

@interface SSJCategoryListHelper : NSObject

/**
 *  查询所有的启用的记账类型
 *
 *  @param incomeOrExpenture 收入还是支出(1为支出,0为收入)
 *  @param success           查询成功的回调
 *  @param failure           查询失败的回调
 */
+ (void)queryForCategoryListWithIncomeOrExpenture:(int)incomeOrExpenture
                                          booksId:(NSString *)booksId
                                          Success:(void(^)(NSMutableArray<SSJRecordMakingBillTypeSelectionCellItem *> *result))success
                                          failure:(void (^)(NSError *error))failure;

/**
 *  查询收支类别对应开启、关闭状态下的最大序号
 *
 *  @param state    0:关闭 1:开启
 *  @param type     0:收入 1:支出
 */
+ (int)queryForBillTypeMaxOrderWithState:(int)state
                                    type:(int)type
                                 booksId:(NSString *)booksId;

/**
 *  更改收支类型
 *
 *  @param categoryId           记账类型id
 *  @param name                 类别名称
 *  @param color                类别颜色
 *  @param image                类别图片
 *  @param order                类别序号
 *  @param state                0:关闭 1:开启
 *  @param incomeOrExpenture    0:收入 1:支出
 *  @param success              删除成功的回调
 *  @param failure              删除失败的回调
 */
+ (void)updateCategoryWithID:(NSString *)categoryId
                        name:(NSString *)name
                       color:(NSString *)color
                       image:(NSString *)image
                       order:(int)order
                       state:(int)state
                     booksId:(NSString *)booksId
                     Success:(void(^)(NSString *categoryId))success
                     failure:(void (^)(NSError *error))failure;

/**
 *  查询未启用的默认、自定义类别
 *
 *  @param incomeOrExpenture 收入还是支出(1为支出,0为收入)
 *  @param custom            默认、自定义(0为默认,1为自定义)
 *  @param success           查询成功的回调
 *  @param failure           查询失败的回调
 */
+ (void)queryForUnusedCategoryListWithIncomeOrExpenture:(int)incomeOrExpenture
                                                 custom:(int)custom
                                                booksId:(NSString *)booksId
                                                success:(void(^)(NSMutableArray<SSJRecordMakingCategoryItem *> *result))success
                                                failure:(void (^)(NSError *error))failure;

/**
 *  查询自定义收支类型图标
 *
 *  @param incomeOrExpenture 收入还是支出(1为支出,0为收入)
 *  @param success    查询成功的回调
 *  @param failure    查询失败的回调
 */
+ (void)queryCustomCategoryImagesWithIncomeOrExpenture:(int)incomeOrExpenture
                                              success:(void(^)(NSArray<NSString *> *images))success
                                              failure:(void (^)(NSError *error))failure;

/**
 *  新增自定义收支类型
 *
 *  @param incomeOrExpenture 收入还是支出(1为支出,0为收入)
 *  @param name         类型名称
 *  @param icon         类型图标
 *  @param color        类型颜色
 *  @param success      查询成功的回调
 *  @param failure      查询失败的回调
 */
+ (void)addNewCustomCategoryWithIncomeOrExpenture:(int)incomeOrExpenture
                                             name:(NSString *)name
                                             icon:(NSString *)icon
                                            color:(NSString *)color
                                          booksId:(NSString *)booksId
                                          success:(void(^)(NSString *categoryId))success
                                          failure:(void (^)(NSError *error))failure;

/**
 *  更新收支类型的排序
 *
 *  @param items        模型数组
 *  @param success      查询成功的回调
 *  @param failure      查询失败的回调
 */
+ (void)updateCategoryOrderWithItems:(NSArray <SSJRecordMakingBillTypeSelectionCellItem *>*)items
                             success:(void (^)())success
                             failure:(void(^)(NSError *error))failure;


/**
 *  获取第一个记账类型
 *
 *  @param incomeOrExpenture 收入还是支出
 *
 *  @return 收支类型
 */
+ (SSJRecordMakingCategoryItem *)queryfirstCategoryItemWithIncomeOrExpence:(BOOL)incomeOrExpenture;

/**
 *  删除类别
 *
 *  @param categoryID   列别ID
 *  @param success      查询成功的回调
 *  @param failure      查询失败的回调
 */
+ (void)deleteCategoryWithIDs:(NSArray *)categoryIDs
                      booksId:(NSString *)booksId
                      success:(void(^)())success
                      failure:(void(^)(NSError *error))failure;

/**
 *  查询相同名称的收支类别
 *
 *  @param name         类别名称
 *  @param success      查询成功的回调
 *  @param failure      查询失败的回调
 */
+ (void)querySameNameCategoryWithName:(NSString *)name
                              booksId:(NSString *)booksId
                              success:(void(^)(SSJBillModel *model))success
                              failure:(void(^)(NSError *))failure;

+ (void)queryAnotherCategoryWithSameName:(NSString *)name
                     exceptForCategoryID:(NSString *)categoryID
                                 booksId:(NSString *)booksId
                                 success:(void(^)(SSJBillModel *model))success
                                 failure:(void(^)(NSError *))failure;

/**
 *  自定义支出类型颜色
 */
+ (NSArray *)payOutColors;

/**
 *  自定义收入类型颜色
 */
+ (NSArray *)incomeColors;

@end
