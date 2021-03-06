//
//  SSJHomeBarButton.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJHomeBarCalenderButton.h"

@interface SSJHomeBarCalenderButton()
@property (nonatomic,strong) UIImageView *calenderImage;
@property (nonatomic,strong) UILabel *dateLabel;
@end

@implementation SSJHomeBarCalenderButton
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.calenderImage];
        [self addSubview:self.dateLabel];
        self.btn = [[UIButton alloc]init];
        [self addSubview:self.btn];
    }
    return self;
}

-(void)layoutSubviews{
    _calenderImage.center = CGPointMake(self.width / 2, self.height / 2);
    _dateLabel.bottom = self.height;
    _dateLabel.center = CGPointMake(self.width / 2, self.height / 2);
    _btn.frame = CGRectMake(0, 0, self.width, self.height);
}

-(UIImageView *)calenderImage{
    if (_calenderImage == nil) {
        _calenderImage = [[UIImageView alloc]init];
        _calenderImage.image = [UIImage ssj_themeImageWithName:@"home_calender"];
        [_calenderImage sizeToFit];
    }
    return _calenderImage;
}

-(UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.recordHomeCalendarColor];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _dateLabel;
}

-(void)setCurrentDay:(long)currentDay{
    _currentDay = currentDay;
    self.dateLabel.text = [NSString stringWithFormat:@"%02ld",_currentDay];
    [self.dateLabel sizeToFit];
}

- (void)updateAfterThemeChange{
    self.dateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.recordHomeCalendarColor];
    self.calenderImage.image = [UIImage ssj_themeImageWithName:@"home_calender"];
    [self.calenderImage sizeToFit];
}

@end
