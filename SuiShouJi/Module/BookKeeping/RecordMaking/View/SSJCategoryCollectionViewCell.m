//
//  SSJCategoryCollectionViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/21.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCategoryCollectionViewCell.h"
#import "SSJDatabaseQueue.h"
#import "FMDB.h"

@interface SSJCategoryCollectionViewCell()
@property (strong, nonatomic) UIButton *editButton;
@end
@implementation SSJCategoryCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.EditeModel = NO;
        self.categorySelected = NO;
        //        self.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:self.categoryImage];
        [self.contentView addSubview:self.categoryName];
        [self addSubview:self.editButton];
        if (![self.item.categoryTitle isEqualToString:@"添加"]) {
            [self addLongPressGesture];
        }
        
//        self.contentView.layer.borderColor = [UIColor redColor].CGColor;
//        self.contentView.layer.borderWidth = 1;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.categoryImage.centerX = self.width / 2;
    self.categoryImage.top = 3;
    self.categoryName.top = self.categoryImage.bottom + 13;
    self.categoryName.centerX = self.width / 2;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateCategoryImage];
}

- (void)updateCategoryImage {
    if (self.selected) {
        _categoryImage.tintColor = [UIColor whiteColor];
        _categoryImage.image = [[UIImage imageNamed:self.item.categoryImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _categoryImage.backgroundColor = [UIColor ssj_colorWithHex:_item.categoryColor];
    } else {
        _categoryImage.backgroundColor = [UIColor clearColor];
        _categoryImage.image = [[UIImage imageNamed:self.item.categoryImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
}

-(void)setItem:(SSJRecordMakingCategoryItem *)item{
    _item = item;
    [self setNeedsLayout];
    _categoryName.text = _item.categoryTitle;
    [_categoryName sizeToFit];
    [self updateCategoryImage];
    _categoryImage.image = [UIImage imageNamed:self.item.categoryImage];
}

-(void)addLongPressGesture{
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
        longPressGr.minimumPressDuration = 1.0;
        [self addGestureRecognizer:longPressGr];
}

-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture{
    if (self.longPressBlock) {
        self.longPressBlock();
    }
}

-(void)setEditeModel:(BOOL)EditeModel{
    _EditeModel = EditeModel;
    if (_EditeModel == YES && ![self.item.categoryTitle isEqualToString:@"添加"]) {
        self.editButton.hidden = NO;
    }else{
        self.editButton.hidden = YES;
    }
}

-(void)removeCategory:(id)sender{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db){
        [db executeUpdate:@"UPDATE BK_USER_BILL SET ISTATE = 0 , CWRITEDATE = ? , IVERSION = ? , OPERATORTYPE = ? WHERE CBILLID = ? AND CUSERID = ? ",[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithLongLong:SSJSyncVersion()],[NSNumber numberWithInt:1],self.item.categoryID,SSJUSERID()];
        SSJDispatch_main_async_safe(^(){
            if (weakSelf.removeCategoryBlock) {
                weakSelf.removeCategoryBlock();
            }
            weakSelf.EditeModel = NO;
        });
    }];

}

-(void)setCategorySelected:(BOOL)categorySelected{
    _categorySelected = categorySelected;
    if (categorySelected == YES) {
        self.categoryImage.layer.borderWidth = 1;
        self.categoryImage.layer.borderColor = [UIColor ssj_colorWithHex:self.item.categoryColor].CGColor;
    }else{
        self.categoryImage.layer.borderWidth = 0;
    }
}

-(UIImageView*)categoryImage{
    if (!_categoryImage) {
        _categoryImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 58, 58)];
        _categoryImage.layer.cornerRadius = 29;
        _categoryImage.layer.masksToBounds = YES;
        _categoryImage.contentMode = UIViewContentModeCenter;
    }
    return _categoryImage;
}

-(UILabel*)categoryName{
    if (!_categoryName) {
        _categoryName = [[UILabel alloc]init];
        [_categoryName sizeToFit];
        _categoryName.font = [UIFont systemFontOfSize:14];
        _categoryName.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _categoryName.textAlignment = NSTextAlignmentCenter;
    }
    return _categoryName;
}

-(UIButton *)editButton{
    if (!_editButton) {
        _editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 12, 12)];
        [_editButton setImage:[UIImage imageNamed:@"bt_delete"] forState:UIControlStateNormal];
        _editButton.layer.cornerRadius = 6.0f;
        _editButton.layer.masksToBounds = YES;
        _editButton.hidden = YES;
        [_editButton addTarget:self action:@selector(removeCategory:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

@end
