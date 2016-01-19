//
//  SSJBookKeepingHomeTableViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/15.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeTableViewCell.h"
#import "FMDB.h"

@interface SSJBookKeepingHomeTableViewCell()
@property (nonatomic,strong) UIButton *categoryImageButton;
@property (nonatomic,strong) UIButton *editeButton;
@property (nonatomic,strong) UIButton *deleteButton;
@property (nonatomic,strong) UILabel *incomeLabel;
@property (nonatomic,strong) UILabel *expenditureLabel;
@property (nonatomic,strong) UIView *lineView;
@end

@implementation SSJBookKeepingHomeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.categoryImageButton];
        [self addSubview:self.expenditureLabel];
        [self addSubview:self.incomeLabel];
        [self addSubview:self.editeButton];
        [self addSubview:self.deleteButton];
        [self addSubview:self.lineView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (_isEdite == YES) {
        self.editeButton.frame = self.categoryImageButton.frame;
        self.deleteButton.frame = self.categoryImageButton.frame;
        self.editeButton.hidden = NO;
        self.deleteButton.hidden = NO;
        self.incomeLabel.hidden = YES;
        self.expenditureLabel.hidden = YES;
        [UIView animateWithDuration:0.2 animations:^{
            self.deleteButton.centerX = 40;
            self.editeButton.centerX = self.width - 40;
        }completion:nil];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.deleteButton.centerX = self.width / 2;
            self.editeButton.centerX = self.width / 2;
        }completion:^(BOOL success){
            self.editeButton.hidden = YES;
            self.deleteButton.hidden = YES;
            self.expenditureLabel.hidden = NO;
            self.incomeLabel.hidden = NO;
        }];
    }
    self.categoryImageButton.bottom = self.height;
    self.categoryImageButton.centerX = self.width * 0.5;
    self.incomeLabel.rightBottom = CGPointMake(self.categoryImageButton.left - 5, self.height);
    self.incomeLabel.centerY = self.categoryImageButton.centerY;
    self.expenditureLabel.leftBottom = CGPointMake(self.categoryImageButton.right + 10, self.height);
    self.expenditureLabel.centerY = self.categoryImageButton.centerY;
    self.lineView.size = CGSizeMake(1, self.height - self.categoryImageButton.height);
    self.lineView.centerX = self.centerX;
}

-(UILabel*)incomeLabel{
    if (!_incomeLabel) {
        _incomeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _incomeLabel.font = [UIFont systemFontOfSize:13];
        _incomeLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        [_incomeLabel sizeToFit];
    }
    return _incomeLabel;
}

-(UILabel*)expenditureLabel{
    if (!_expenditureLabel) {
        _expenditureLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _expenditureLabel.font = [UIFont systemFontOfSize:13];
        _expenditureLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        [_expenditureLabel sizeToFit];
    }
    return _expenditureLabel;
}

-(UIButton*)categoryImageButton{
    if (_categoryImageButton == nil) {
        _categoryImageButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 38, 38)];
        _categoryImageButton.contentMode = UIViewContentModeScaleAspectFill;
        _categoryImageButton.layer.cornerRadius = 19;
        [_categoryImageButton addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _categoryImageButton;
}

-(UIButton *)editeButton{
    if (!_editeButton) {
        _editeButton = [[UIButton alloc]init];
        _editeButton.hidden = YES;
        [_editeButton setImage:[UIImage imageNamed:@"home_edit"] forState:UIControlStateNormal];
        _editeButton.layer.cornerRadius = 16;
        [_editeButton addTarget:self action:@selector(editeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editeButton;
}

-(UIButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc]init];
        _deleteButton.hidden = YES;
        [_deleteButton setImage:[UIImage imageNamed:@"home_delet"] forState:UIControlStateNormal];
        _deleteButton.layer.cornerRadius = 16;
        [_deleteButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = [UIColor ssj_colorWithHex:@"cccccc"];
    }
    return _lineView;
}

-(void)buttonClicked{
    if (self.beginEditeBtnClickBlock) {
        self.beginEditeBtnClickBlock(self);
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(ctx, self.centerX, 0);
    CGContextAddLineToPoint(ctx, self.centerX, self.categoryImageButton.top);
    CGContextSetRGBStrokeColor(ctx, 204.0/225, 204.0/255, 204.0/255, 1.0);
    CGContextSetLineWidth(ctx, 1);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextStrokePath(ctx);
    [self setNeedsDisplay];
}

-(void)setItem:(SSJBookKeepHomeItem *)item{
    _item = item;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *billDate=[dateFormatter dateFromString:item.billDate];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:billDate];
    NSDateComponents *currentdateComponent = [calendar components:unitFlags fromDate:[NSDate date]];
    long day = [dateComponent day];
    long month = [dateComponent month];
    long currentMonth = [currentdateComponent month];
    if ([item.billID isEqualToString:@"-1"]) {
        _categoryImageButton.layer.borderWidth = 0;
        _categoryImageButton.userInteractionEnabled = NO;
        [_categoryImageButton setImage:nil forState:UIControlStateNormal];
        [_categoryImageButton setTitle:@"结余" forState:UIControlStateNormal];
        _categoryImageButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_categoryImageButton setTintColor:[UIColor whiteColor]];
        _categoryImageButton.backgroundColor = [UIColor ssj_colorWithHex:@"47cfbe"];
        if (item.chargeMoney < 0) {
            self.expenditureLabel.hidden = NO;
            self.incomeLabel.hidden = NO;
            self.incomeLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
            self.expenditureLabel.text = [NSString stringWithFormat:@"%.2f",item.chargeMoney];
            self.expenditureLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
            [self.expenditureLabel sizeToFit];

            if (month == currentMonth) {
                self.incomeLabel.text = [NSString stringWithFormat:@"%ld日",day];
            }else{
                self.incomeLabel.text = [NSString stringWithFormat:@"%ld月%ld日",month,day];
            }
            [self.incomeLabel sizeToFit];

        }else{
            self.expenditureLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
            self.incomeLabel.text = [NSString stringWithFormat:@"%.2f",item.chargeMoney];
            self.incomeLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
            [self.incomeLabel sizeToFit];
            if (month == currentMonth) {
                self.expenditureLabel.text = [NSString stringWithFormat:@"%ld日",day];
            }else{
                self.expenditureLabel.text = [NSString stringWithFormat:@"%ld日",day];
            }
            self.expenditureLabel.text = [NSString stringWithFormat:@"%ld日",day];
            [self.expenditureLabel sizeToFit];
        }
    }else{
        NSString *iconName;
        NSString *categoryName;
        NSString *categoryColor;
        int categoryType = 0;
        FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
        if (![db open]) {
            NSLog(@"Could not open db");
            return ;
        }
        FMResultSet *rs = [db executeQuery:@"SELECT CCOIN, CNAME , ITYPE , CCOLOR FROM BK_BILL_TYPE WHERE ID = ?",item.billID];
        while ([rs next]) {
            iconName = [rs stringForColumn:@"CCOIN"];
            categoryName = [rs stringForColumn:@"CNAME"];
            categoryType = [rs intForColumn:@"ITYPE"];
            categoryColor =[rs stringForColumn:@"CCOLOR"];
        }
        if (!categoryType) {
            self.incomeLabel.text = [NSString stringWithFormat:@"%@%.2f",categoryName,item.chargeMoney];
            [self.incomeLabel sizeToFit];
            self.incomeLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
            self.expenditureLabel.text = @"";
        }else{
            self.expenditureLabel.text = [NSString stringWithFormat:@"%@%.2f",categoryName,item.chargeMoney];
            self.expenditureLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
            [self.expenditureLabel sizeToFit];
            self.incomeLabel.text = @"";
        }
        
        UIImage *image = [UIImage imageWithCGImage:[UIImage imageNamed:iconName].CGImage scale:1.5*[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        _categoryImageButton.contentMode = UIViewContentModeCenter;
        [_categoryImageButton setImage:image forState:UIControlStateNormal];
        _categoryImageButton.layer.borderColor = [UIColor ssj_colorWithHex:categoryColor].CGColor;
        _categoryImageButton.layer.borderWidth = 1;
        _categoryImageButton.backgroundColor = [UIColor clearColor];
        _categoryImageButton.userInteractionEnabled = YES;
        [_categoryImageButton setTitle:@"" forState:UIControlStateNormal];
    }
    [self setNeedsLayout];
}

-(void)setIsEdite:(BOOL)isEdite{
    _isEdite = isEdite;
    
}

-(void)editeButtonClicked{
    if (self.editeBtnClickBlock) {
        self.editeBtnClickBlock(self);
    }
}

-(void)deleteButtonClick{
    [self deleteCharge];
    if (self.deleteButtonClickBlock) {
        self.deleteButtonClickBlock();
    }
}

-(void)deleteCharge{
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
        return ;
    }
    [db executeUpdate:@"UPDATE BK_USER_CHARGE SET OPERATORTYPE = 2 , CWRITEDATE = ? WHERE ICHARGEID = ?",[[NSDate alloc] ssj_systemCurrentDateWithFormat:nil],self.item.chargeID];
    if ([db intForQuery:@"SELECT ITYPE FROM BK_BILL_TYPE WHERE ID = ?",self.item.billID]) {
        [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE + ? WHERE  CFUNDID = ?",[NSNumber numberWithDouble:self.item.chargeMoney],self.item.fundID];
        [db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET EXPENCEAMOUNT = EXPENCEAMOUNT - ? , SUMAMOUNT = SUMAMOUNT + ? , CWRITEDATE = ? WHERE CBILLDATE = ?",[NSNumber numberWithDouble:self.item.chargeMoney],[NSNumber numberWithDouble:self.item.chargeMoney],[[NSDate alloc]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],self.item.billDate];
    }else{
        [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE - ? WHERE  CFUNDID = ?",[NSNumber numberWithDouble:self.item.chargeMoney],self.item.fundID];
        [db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET INCOMEAMOUNT = INCOMEAMOUNT - ? , SUMAMOUnT = SUMAMOUNT - ? , CWRITEDATE = ? WHERE CBILLDATE = ?",[NSNumber numberWithDouble:self.item.chargeMoney],[NSNumber numberWithDouble:self.item.chargeMoney],[[NSDate alloc]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],self.item.billDate];
    }
    [db executeUpdate:@"DELETE FROM BK_DAILYSUM_CHARGE WHERE SUMAMOUNT = 0 AND INCOMEAMOUNT = 0 AND EXPENCEAMOUNT = 0"];
    [db close];
}

@end
