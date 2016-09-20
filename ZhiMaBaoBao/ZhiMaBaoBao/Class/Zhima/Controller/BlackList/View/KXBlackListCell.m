//
//  KXBlackListCell.m
//  YiIM_iOS
//
//  Created by mac on 16/9/5.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "KXBlackListCell.h"
//#import "UIImageView+WebCache.h"

@interface KXBlackListCell ()

@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UILabel *nameLabel;

@end

@implementation KXBlackListCell

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
    UIImageView *imageView = [[UIImageView alloc] init];
    self.iconView = imageView;
    [self addSubview:imageView];
    
    UILabel *nameLabel = [UILabel new];
    self.nameLabel = nameLabel;
    [self addSubview:nameLabel];
    
}


- (void)setModel:(KXBlackListModel *)model {
    _model = model;
    
//    [self.iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.head_photo]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        self.iconView.image = image;
//    }];
    
    NSString *name = [NSString string];
    if (![model.friend_nick isEqualToString:@""]) {
        name = model.friend_nick;
    } else {
        name = model.username;
    }
    
    self.nameLabel.text = name;
    
}

- (void)layoutSubviews {
    
    CGFloat iconX = 10;
    CGFloat iconW = 45;
    CGFloat iconH = iconW;
    CGFloat iconY = (CGRectGetHeight(self.frame) - iconH )* 0.5;
    self.iconView.frame = CGRectMake(iconX, iconY, iconW, iconH);
    
    CGFloat nameX = CGRectGetMaxX(self.iconView.frame) + 10;
    CGFloat nameY = 0;
    CGFloat nameW = CGRectGetWidth(self.frame) - nameX;
    CGFloat nameH = CGRectGetHeight(self.frame);
    self.nameLabel.frame = CGRectMake(nameX, nameY, nameW, nameH);
    
}
@end
