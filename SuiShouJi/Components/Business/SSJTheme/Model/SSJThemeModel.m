//
//  SSJThemeModel.m
//  SuiShouJi
//
//  Created by old lang on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeModel.h"

@implementation SSJThemeModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_ID forKey:@"ID"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_size forKey:@"size"];
    [aCoder encodeObject:_etag forKey:@"etag"];
    [aCoder encodeObject:_version forKey:@"version"];
    [aCoder encodeObject:_previewUrlStr forKey:@"previewUrlStr"];
    [aCoder encodeObject:_thumbUrlStr forKey:@"thumbUrlStr"];
    [aCoder encodeObject:_previewUrlArr forKey:@"previewUrlArr"];
    [aCoder encodeObject:_desc forKey:@"desc"];
    [aCoder encodeFloat:_backgroundAlpha forKey:@"backgroundAlpha"];
    [aCoder encodeObject:_mainColor forKey:@"mainColor"];
    [aCoder encodeObject:_secondaryColor forKey:@"secondaryColor"];
    [aCoder encodeObject:_marcatoColor forKey:@"marcatoColor"];
    [aCoder encodeObject:_mainFillColor forKey:@"mainFillColor"];
    [aCoder encodeObject:_secondaryFillColor forKey:@"secondaryFillColor"];
    [aCoder encodeObject:_borderColor forKey:@"borderColor"];
    [aCoder encodeObject:_buttonColor forKey:@"buttonColor"];
    [aCoder encodeObject:_naviBarTitleColor forKey:@"naviBarTitleColor"];
    [aCoder encodeObject:_naviBarTintColor forKey:@"naviBarTintColor"];
    [aCoder encodeObject:_naviBarBackgroundColor forKey:@"naviBarBackgroundColor"];
    [aCoder encodeObject:_tabBarTitleColor forKey:@"tabBarTitleColor"];
    [aCoder encodeObject:_tabBarSelectedTitleColor forKey:@"tabBarSelectedTitleColor"];
    [aCoder encodeObject:_tabBarBackgroundColor forKey:@"tabBarBackgroundColor"];
    [aCoder encodeObject:_tabBarBackgroundImage forKey:@"tabBarBackgroundImage"];
    [aCoder encodeFloat:_cellSeparatorAlpha forKey:@"cellSeparatorAlpha"];
    [aCoder encodeObject:_cellSeparatorColor forKey:@"cellSeparatorColor"];
    [aCoder encodeObject:_cellIndicatorColor forKey:@"cellIndicatorColor"];
    [aCoder encodeInt:_cellSelectionStyle forKey:@"cellSelectionStyle"];
    [aCoder encodeInt:_statusBarStyle forKey:@"statusBarStyle"];
    [aCoder encodeObject:_moreHomeTitleColor forKey:@"moreHomeTitleColor"];
    [aCoder encodeObject:_moreHomeSubtitleColor forKey:@"moreHomeSubtitleColor"];
    [aCoder encodeObject:_recordHomeBorderColor forKey:@"recordHomeBorderColor"];
    [aCoder encodeObject:_recordHomeButtonBackgroundColor forKey:@"recordHomeButtonBackgroundColor"];
    [aCoder encodeObject:_recordHomeCalendarColor forKey:@"recordHomeCalendarColor"];
    [aCoder encodeObject:_recordHomeCategoryBackgroundColor forKey:@"recordHomeCategoryBackgroundColor"];
    [aCoder encodeObject:_loginMainColor forKey:@"loginMainColor"];
    [aCoder encodeObject:_loginSecondaryColor forKey:@"loginSecondaryColor"];
    [aCoder encodeObject:_loginButtonTitleColor forKey:@"loginButtonTitleColor"];
    [aCoder encodeObject:_motionPasswordNormalColor forKey:@"motionPasswordNormalColor"];
    [aCoder encodeObject:_motionPasswordHighlightedColor forKey:@"motionPasswordHighlightedColor"];
    [aCoder encodeObject:_motionPasswordErrorColor forKey:@"motionPasswordErrorColor"];
    [aCoder encodeObject:_reportFormsCurveIncomeColor forKey:@"reportFormsCurveIncomeColor"];
    [aCoder encodeObject:_reportFormsCurvePaymentColor forKey:@"reportFormsCurvePaymentColor"];
    [aCoder encodeObject:_reportFormsCurveIncomeFillColor forKey:@"reportFormsCurveIncomeFillColor"];
    [aCoder encodeObject:_reportFormsCurvePaymentFillColor forKey:@"reportFormsCurvePaymentFillColor"];
    [aCoder encodeFloat:_recordMakingInputViewAlpha forKey:@"recordMakingInputViewAlpha"];
    [aCoder encodeObject:_bookKeepingHomeMutiButtonSelectColor forKey:@"bookKeepingHomeMutiButtonSelectColor"];
    [aCoder encodeObject:_bookKeepingHomeMutiButtonNormalColor forKey:@"bookKeepingHomeMutiButtonNormalColor"];
    [aCoder encodeObject:_searchResultHeaderBackgroundColor forKey:@"searchResultHeaderBackgroundColor"];
    [aCoder encodeObject:_summaryBooksHeaderColor forKey:@"summaryBooksHeaderColor"];
    [aCoder encodeFloat:_summaryBooksHeaderAlpha forKey:@"summaryBooksHeaderAlpha"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _ID = [aDecoder decodeObjectForKey:@"ID"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _size = [aDecoder decodeObjectForKey:@"size"];
        _etag = [aDecoder decodeObjectForKey:@"etag"];
        _version = [aDecoder decodeObjectForKey:@"version"];
        _previewUrlStr = [aDecoder decodeObjectForKey:@"previewUrlStr"];
        _thumbUrlStr = [aDecoder decodeObjectForKey:@"thumbUrlStr"];
        _previewUrlArr = [aDecoder decodeObjectForKey:@"previewUrlArr"];
        _desc = [aDecoder decodeObjectForKey:@"desc"];
        _backgroundAlpha = [aDecoder decodeFloatForKey:@"backgroundAlpha"];
        _mainColor = [aDecoder decodeObjectForKey:@"mainColor"];
        _secondaryColor = [aDecoder decodeObjectForKey:@"secondaryColor"];
        _marcatoColor = [aDecoder decodeObjectForKey:@"marcatoColor"];
        _mainFillColor = [aDecoder decodeObjectForKey:@"mainFillColor"];
        _secondaryFillColor = [aDecoder decodeObjectForKey:@"secondaryFillColor"];
        _borderColor = [aDecoder decodeObjectForKey:@"borderColor"];
        _buttonColor = [aDecoder decodeObjectForKey:@"buttonColor"];
        _naviBarTitleColor = [aDecoder decodeObjectForKey:@"naviBarTitleColor"];
        _naviBarTintColor = [aDecoder decodeObjectForKey:@"naviBarTintColor"];
        _naviBarBackgroundColor = [aDecoder decodeObjectForKey:@"naviBarBackgroundColor"];
        _tabBarTitleColor = [aDecoder decodeObjectForKey:@"tabBarTitleColor"];
        _tabBarSelectedTitleColor = [aDecoder decodeObjectForKey:@"tabBarSelectedTitleColor"];
        _tabBarBackgroundColor = [aDecoder decodeObjectForKey:@"tabBarBackgroundColor"];
        _tabBarBackgroundImage = [aDecoder decodeObjectForKey:@"tabBarBackgroundImage"];
        _cellSeparatorAlpha = [aDecoder decodeFloatForKey:@"cellSeparatorAlpha"];
        _cellSeparatorColor = [aDecoder decodeObjectForKey:@"cellSeparatorColor"];
        _cellIndicatorColor = [aDecoder decodeObjectForKey:@"cellIndicatorColor"];
        _cellSelectionStyle = [aDecoder decodeIntForKey:@"cellSelectionStyle"];
        _statusBarStyle = [aDecoder decodeIntForKey:@"statusBarStyle"];
        _moreHomeTitleColor = [aDecoder decodeObjectForKey:@"moreHomeTitleColor"];
        _moreHomeSubtitleColor = [aDecoder decodeObjectForKey:@"moreHomeSubtitleColor"];
        _recordHomeBorderColor = [aDecoder decodeObjectForKey:@"recordHomeBorderColor"];
        _recordHomeButtonBackgroundColor = [aDecoder decodeObjectForKey:@"recordHomeButtonBackgroundColor"];
        _recordHomeCalendarColor = [aDecoder decodeObjectForKey:@"recordHomeCalendarColor"];
        _recordHomeCategoryBackgroundColor = [aDecoder decodeObjectForKey:@"recordHomeCategoryBackgroundColor"];
        _loginMainColor = [aDecoder decodeObjectForKey:@"loginMainColor"];
        _loginSecondaryColor = [aDecoder decodeObjectForKey:@"loginSecondaryColor"];
        _loginButtonTitleColor = [aDecoder decodeObjectForKey:@"loginButtonTitleColor"];
        _motionPasswordNormalColor = [aDecoder decodeObjectForKey:@"motionPasswordNormalColor"];
        _motionPasswordHighlightedColor = [aDecoder decodeObjectForKey:@"motionPasswordHighlightedColor"];
        _motionPasswordErrorColor = [aDecoder decodeObjectForKey:@"motionPasswordErrorColor"];
        _reportFormsCurveIncomeColor = [aDecoder decodeObjectForKey:@"reportFormsCurveIncomeColor"];
        _reportFormsCurvePaymentColor = [aDecoder decodeObjectForKey:@"reportFormsCurvePaymentColor"];
        _reportFormsCurveIncomeFillColor = [aDecoder decodeObjectForKey:@"reportFormsCurveIncomeFillColor"];
        _reportFormsCurvePaymentFillColor = [aDecoder decodeObjectForKey:@"reportFormsCurvePaymentFillColor"];
        _recordMakingInputViewAlpha = [aDecoder decodeFloatForKey:@"recordMakingInputViewAlpha"];
        _bookKeepingHomeMutiButtonSelectColor = [aDecoder decodeObjectForKey:@"bookKeepingHomeMutiButtonSelectColor"];
        _bookKeepingHomeMutiButtonNormalColor = [aDecoder decodeObjectForKey:@"bookKeepingHomeMutiButtonNormalColor"];
        _searchResultHeaderBackgroundColor = [aDecoder decodeObjectForKey:@"recordMakingInputViewAlpha"];
        _summaryBooksHeaderColor = [aDecoder decodeObjectForKey:@"summaryBooksHeaderColor"];
        _summaryBooksHeaderAlpha = [aDecoder decodeFloatForKey:@"summaryBooksHeaderAlpha"];
    }
    return self;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@>:%@", self, @{@"ID":_ID,
                                                          @"name":_name,
                                                          @"size":_size,
                                                          @"previewUrlStr":_previewUrlStr,
                                                          @"thumbUrlStr":_thumbUrlStr,
                                                          @"previewUrlArr":_previewUrlArr,
                                                          @"desc":_desc,
                                                          @"backgroundAlpha":@(_backgroundAlpha),
                                                          @"mainColor":_mainColor,
                                                          @"secondaryColor":_secondaryColor,
                                                          @"marcatoColor":_marcatoColor,
                                                          @"mainFillColor":_mainFillColor,
                                                          @"secondaryFillColor":_secondaryFillColor,
                                                          @"borderColor":_borderColor,
                                                          @"buttonColor":_buttonColor,
                                                          @"naviBarTitleColor":_naviBarTitleColor,
                                                          @"naviBarTintColor":_naviBarTintColor,
                                                          @"naviBarBackgroundColor":_naviBarBackgroundColor,
                                                          @"tabBarTitleColor":_tabBarTitleColor,
                                                          @"tabBarSelectedTitleColor":_tabBarSelectedTitleColor,
                                                          @"tabBarBackgroundColor":_tabBarBackgroundColor,
                                                          @"tabBarShadowImageAlpha":@(_tabBarShadowImageAlpha),
                                                          @"tabBarBackgroundImage":_tabBarBackgroundImage,  
                                                          @"cellSeparatorAlpha":@(_cellSeparatorAlpha),
                                                          @"cellSeparatorColor":_cellSeparatorColor,
                                                          @"cellIndicatorColor":_cellIndicatorColor,
                                                          @"cellSelectionStyle":@(_cellSelectionStyle),
                                                          @"statusBarStyle":@(_statusBarStyle),
                                                          @"moreHomeTitleColor":_moreHomeTitleColor,
                                                          @"moreHomeSubtitleColor":_moreHomeSubtitleColor,
                                                          @"recordHomeBorderColor":_recordHomeBorderColor,
                                                          @"recordHomeButtonBackgroundColor":_recordHomeButtonBackgroundColor,
                                                          @"recordHomeCalendarColor":_recordHomeCalendarColor,
                                                          @"recordHomeCategoryBackgroundColor":_recordHomeCategoryBackgroundColor,
                                                          @"loginMainColor":_loginMainColor,
                                                          @"loginSecondaryColor":_loginSecondaryColor,
                                                          @"loginButtonTitleColor":_loginButtonTitleColor,
                                                          @"motionPasswordNormalColor":_motionPasswordNormalColor,
                                                          @"motionPasswordHighlightedColor":_motionPasswordHighlightedColor,
                                                          @"motionPasswordErrorColor":_motionPasswordErrorColor,
                                                          @"reportFormsCurveIncomeColor":_reportFormsCurveIncomeColor,
                                                          @"reportFormsCurvePaymentColor":_reportFormsCurvePaymentColor,
                                                          @"reportFormsCurveIncomeFillColor":_reportFormsCurveIncomeFillColor,
                                                          @"reportFormsCurvePaymentFillColor":_reportFormsCurvePaymentFillColor,
                                                          @"recordMakingInputViewAlpha":@(_recordMakingInputViewAlpha),
                                                          @"bookKeepingHomeMutiButtonSelectColor":_bookKeepingHomeMutiButtonSelectColor,
                                                          @"bookKeepingHomeMutiButtonNormalColor":_bookKeepingHomeMutiButtonNormalColor,
                                                          @"searchResultHeaderBackgroundColor":_searchResultHeaderBackgroundColor,
                                                          @"summaryBooksHeaderColor":_summaryBooksHeaderColor,
                                                          @"summaryBooksHeaderAlpha":@(_summaryBooksHeaderAlpha)}];
}

@end
