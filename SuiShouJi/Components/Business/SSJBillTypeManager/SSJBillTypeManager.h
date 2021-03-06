//
//  SSJBillTypeManager.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SSJBillTypeModel(billId) [SSJBillTypeManager modelForBillId:billId]

@class SSJBillTypeModel;

@interface SSJBillTypeManager : NSObject

@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSDictionary *> *specialBillTypes;

+ (instancetype)sharedManager;

+ (SSJBillTypeModel *)modelForBillId:(NSString *)billId;

@end



@interface SSJBillTypeModel : NSObject

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *color;

@property (nonatomic) BOOL expended;

@property (nonatomic, copy) NSArray *booksIds;

@end
