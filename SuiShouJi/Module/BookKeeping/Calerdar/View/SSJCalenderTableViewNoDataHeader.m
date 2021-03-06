//
//  SSJCalenderTableViewNoDataHeader.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCalenderTableViewNoDataHeader.h"
@interface SSJCalenderTableViewNoDataHeader()
@property (weak, nonatomic) IBOutlet UIButton *recordMakingButton;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;

@end
@implementation SSJCalenderTableViewNoDataHeader

+ (id)CalenderTableViewNoDataHeader {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SSJCalenderTableViewNoDataHeader" owner:nil options:nil];
    return array[0];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self.recordMakingButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
    self.recordMakingButton.layer.cornerRadius = 20;
    self.recordMakingButton.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor].CGColor;
    self.recordMakingButton.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    self.hintLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

- (IBAction)recordButtonClicked:(id)sender {
    if (self.RecordMakingButtonBlock) {
        self.RecordMakingButtonBlock();
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
