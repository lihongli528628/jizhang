//
//  SSJCalenderDetailPhotoCell.m
//  SuiShouJi
//
//  Created by old lang on 17/5/16.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCalenderDetailPhotoCell.h"

@implementation SSJCalenderDetailPhotoCellItem

@end

@interface SSJCalenderDetailPhotoCell ()

@property (nonatomic, strong) UIImageView *photo;

@end

@implementation SSJCalenderDetailPhotoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.photo = [[UIImageView alloc] init];
        [self.contentView addSubview:self.photo];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    [self.photo mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(150, 150));
        make.center.mas_equalTo(self.contentView);
    }];
    [super updateConstraints];
}

- (void)setCellItem:(__kindof SSJBaseItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJCalenderDetailPhotoCellItem class]]) {
        return;
    }
    
    SSJCalenderDetailPhotoCellItem *item = cellItem;
    [UIImage ssj_loadUrl:item.photoPath compeltion:^(NSError *error, UIImage *image) {
        if (!image) {
            return;
        }
        if (image.size.width > image.size.height) {
            CGFloat x = (image.size.width - image.size.height) * 0.5;
            self.photo.image = [image ssj_imageWithClipInsets:UIEdgeInsetsMake(0, x, 0, x)];
        } else {
            CGFloat x = (image.size.height - image.size.width) * 0.5;
            self.photo.image = [image ssj_imageWithClipInsets:UIEdgeInsetsMake(x, 0, x, 0)];
        }
    }];
}

@end