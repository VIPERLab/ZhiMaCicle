//
//  InfoHeaderCell.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/12.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "InfoHeaderCell.h"
#import "SDPhotoBrowser.h"
@interface InfoHeaderCell()<SDPhotoBrowserDelegate>

@end

@implementation InfoHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvtarClick:)];
    [self.avtar addGestureRecognizer:tap];
    self.avtar.userInteractionEnabled = YES;
}

- (void)setFriendModel:(ZhiMaFriendModel *)friendModel{
    _friendModel = friendModel;
    
    [self.avtar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,friendModel.user_Head_photo]] placeholderImage:[UIImage imageNamed:@"defaultContact"]];
    self.name.text = friendModel.displayName;
    self.nickName.text = [NSString stringWithFormat:@"昵称：%@",friendModel.user_Name];
    if ([friendModel.sex isEqualToString:@"男"]) {
        [self.sexBtn setImage:[UIImage imageNamed:@"man"]];
    }else{
        [self.sexBtn setImage:[UIImage imageNamed:@"women"]];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    NSString *name = _friendModel.displayName;
    CGFloat width = [name sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}].width;
    self.widthConstraints.constant = width + 5;
}

//单击头像
- (void)tapAvtarClick:(UITapGestureRecognizer *)tap{
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = self.contentView;
    browser.delegate = self;
    browser.currentImageIndex = 0;
    browser.imageCount = 1;
    [browser show];
}

#pragma mark -- SDPhotoBrowser代理方法
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    return self.avtar.image;
}

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,self.friendModel.user_Head_photo]];
}

@end
