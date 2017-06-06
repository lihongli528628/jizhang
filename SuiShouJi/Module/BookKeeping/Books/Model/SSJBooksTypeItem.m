//
//  SSJBooksTypeItem.m
//  SuiShouJi
//
//  Created by ricky on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksTypeItem.h"

@implementation SSJBooksTypeItem
@synthesize booksId;
@synthesize booksName;
@synthesize booksColor;
@synthesize booksOrder;
@synthesize booksParent;
@synthesize cwriteDate;

+ (NSDictionary *)propertyMapping {
    static NSDictionary *mapping = nil;
    if (!mapping) {
        mapping = @{@"booksId":@"cbooksid",
                    @"booksName":@"cbooksname",
                    @"booksColor":@"cbookscolor",
                    @"booksParent":@"iparenttype",
                    @"userId":@"cuserid",
                    @"cwriteDate":@"cwritedate",
                    @"operatorType":@"operatortype",
                    @"booksOrder":@"iorder",
                    @"booksIcoin":@"cicoin"};
    }
    return mapping;
}


-(BOOL)isEqual:(id)object{
    [super isEqual:object];
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[SSJBooksTypeItem class]]) {
        return NO;
    }
    
    SSJBooksTypeItem *memberItem = (SSJBooksTypeItem *)object;
    
    if ([self.booksId isEqualToString:memberItem.booksId]) {
        return YES;
    }else{
        return NO;
    }
    
    return NO;
}

- (NSString *)getSingleColor {
    
    if ([self.booksColor.startColor isEqualToString:self.booksColor.endColor]) {
        return self.booksColor.startColor;
    }
    
    NSInteger index = [[SSJFinancingGradientColorItem defualtColors] indexOfObject:self.booksColor];
    
    NSString *singleColor;
    
    switch (index) {
        case 0:
            singleColor = @"#fc72ae";
            break;
            
        case 1:
            singleColor = @"#f96a6a";
            break;
            
        case 2:
            singleColor = @"#8094f9";
            break;
            
        case 3:
            singleColor = @"#81b9f0";
            break;
            
        case 4:
            singleColor = @"#39d4da";
            break;
            
        case 5:
            singleColor = @"#56d696";
            break;
            
        case 6:
            singleColor = @"#f8b556";
            break;
            
        case 7:
            singleColor = @"#fc835a";
            break;
            
        case 8:
            singleColor = @"#c6b244";
            break;
            
        case 9:
            singleColor = @"#8d79ff";
            break;
            
        case 10:
            singleColor = @"#c565e5";
            break;
            
        case 11:
            singleColor = @"#51a4ff";
            break;
            
        default:
            singleColor = @"#fc72ae";
            break;
            
    }
    
    return singleColor; 
}

- (NSString *)parentIcon {
    switch (self.booksParent) {
        case SSJBooksTypeDaily:
            return @"bk_moren";
            break;
            
        case SSJBooksTypeBusiness:
            return @"bk_shengyi";
            break;
            
        case SSJBooksTypeMarriage:
            return @"bk_jiehun";
            break;
            
        case SSJBooksTypeDecoration:
            return @"bk_zhuangxiu";
            break;
            
        case SSJBooksTypeTravel:
            return @"bk_lvxing";
            break;
    }
}

@end
