//
//  SSJAnnoucementService.m
//  SuiShouJi
//
//  Created by ricky on 2017/3/2.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAnnoucementService.h"

static NSString *const kLastAnnoucementIdKey = @"kLastAnnoucementIdKey";

@implementation SSJAnnoucementService

- (void)requestAnnoucements {
    NSString *lastAnnoucementIdStr = [[NSUserDefaults standardUserDefaults] objectForKey:kLastAnnoucementIdKey];
    
    NSInteger lastAnnoucementId = [lastAnnoucementIdStr integerValue];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [dic setObject:@(lastAnnoucementId) forKey:@"aid"];
    
    [dic setObject:@(0) forKey:@"pn"];
    
    [self request:SSJURLWithAPI(@"/admin/announcement.go") params:dic];
}

- (void)requestDidFinish:(id)rootElement {
    [super requestDidFinish:rootElement];
    if ([self.returnCode isEqualToString:@"1"]) {
        NSDictionary *results = [[NSDictionary dictionaryWithDictionary:rootElement] objectForKey:@"results"];
        NSArray *announcementArr = [results objectForKey:@"announcements"];
        [self saveAnnoucementAtLocalWithArr:announcementArr];
        self.annoucements = [SSJAnnoucementItem mj_objectArrayWithKeyValuesArray:announcementArr];
        self.hasNewAnnouceMent = [[results objectForKey:@"new_announcement"] boolValue];
    }
}

- (void)saveAnnoucementAtLocalWithArr:(NSArray *)arr {
    NSArray *annoucements = arr;
    if (annoucements.count) {
        if (annoucements.count > 3) {
            annoucements = [annoucements subarrayWithRange:NSMakeRange(0, 3)];
        }
        NSData *announceData = [NSJSONSerialization dataWithJSONObject:[annoucements mj_JSONObject]
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:NULL];
        
        NSString *directory = [SSJDocumentPath() stringByAppendingPathComponent:@"annoucements"];
        
        NSString *filePath = [directory stringByAppendingPathComponent:@"lastAnnoucements.json"];
        
        BOOL isExisted = [[NSFileManager defaultManager] fileExistsAtPath:directory];
        if (!isExisted) {
            [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        [announceData writeToFile:filePath atomically:YES];
    }
}

@end
