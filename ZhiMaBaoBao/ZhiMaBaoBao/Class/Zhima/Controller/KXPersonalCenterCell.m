//
//  KXPersonalCenterCell.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "KXPersonalCenterCell.h"

@implementation KXPersonalCenterCell {
    UIImageView *_userIcon;
    UIImageView *_sexImage;
    UILabel *_userName;
    UILabel *_subTitle;
    BOOL hasSubView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    hasSubView = YES;
    _userIcon = [[UIImageView alloc] init];
    _userIcon.layer.cornerRadius = 5;
    [self addSubview:_userIcon];
    
    _sexImage = [UIImageView new];
    _sexImage.image = [UIImage imageNamed:@"Male"];
    [self addSubview:_sexImage];
    
    _userName = [UILabel new];
    [self addSubview:_userName];
    _userName.textColor = [UIColor blackColor];
    _userName.font = [UIFont systemFontOfSize:17];
    _userName.textAlignment = NSTextAlignmentLeft;
    
    _subTitle = [UILabel new];
    [self addSubview:_subTitle];
    _subTitle.textColor = [UIColor lightGrayColor];
    _subTitle.font = [UIFont systemFontOfSize:14];
    _subTitle.textAlignment = NSTextAlignmentLeft;
    
}

- (void)setImageName:(NSString *)imageName {
    _imageName = imageName;
    _userIcon.image = [UIImage imageNamed:imageName];
}

- (void)setName:(NSString *)name {
    _name = name;
    _userName.text = name;
}

- (void)setSubName:(NSString *)subName {
    _subName = subName;
    _subTitle.text = subName;
}


- (void)layoutSubviews {
    if (hasSubView) {
        CGFloat userX = 10;
        CGFloat userW = 70;
        CGFloat userH = 70;
        CGFloat userY = (CGRectGetHeight(self.frame) - userH) * 0.5;
        _userIcon.frame = CGRectMake(userX, userY, userW, userH);
        
        CGFloat nameW = [_userName.text sizeWithFont:[UIFont systemFontOfSize:17] maxSize:CGSizeMake(ScreenWidth - 90 - 25, 15)].width;
        _userName.frame = CGRectMake(CGRectGetMaxX(_userIcon.frame) + userX, CGRectGetMinY(_userIcon.frame) + 5, nameW, 30);
        
        CGFloat sexX = CGRectGetMaxX(_userName.frame) + 10;
        CGFloat sexW = 15;
        CGFloat sexH = sexW;
        CGFloat sexY = (CGRectGetHeight(_userName.frame) - sexH) * 0.5 + userY + 5;
        _sexImage.frame = CGRectMake(sexX, sexY, sexW, sexH);
        
        
        CGFloat subX = CGRectGetMinX(_userName.frame);
        CGFloat subH = 30;
        CGFloat subW = ScreenWidth - CGRectGetMinX(_userIcon.frame) - 20;
        CGFloat subY = CGRectGetMaxY(_userIcon.frame) - subH;
        _subTitle.frame = CGRectMake(subX, subY, subW, subH);
        
        hasSubView = NO;
    }
}


@end
