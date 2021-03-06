//
//  SSJUserDefaultBillTypesCreater.h
//  SuiShouJi
//
//  Created by old lang on 17/5/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJUserDefaultDataCreaterProtocol.h"

@interface SSJUserDefaultBillTypesCreater : NSObject <SSJUserDefaultDataCreaterProtocol>

+ (void)createDefaultDataTypeForUserId:(NSString *)userId
                               booksId:(NSString *)booksId
                             booksType:(SSJBooksType)booksType
                            inDatabase:(FMDatabase *)db
                                 error:(NSError **)error;

@end
