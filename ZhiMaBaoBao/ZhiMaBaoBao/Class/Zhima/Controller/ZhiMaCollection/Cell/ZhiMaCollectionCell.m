//
//  ZhiMaCollectionCell.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/7.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZhiMaCollectionCell.h"
#import "TQRichTextView.h"

@interface ZhiMaCollectionCell ()

@end

@implementation ZhiMaCollectionCell {
    UIImageView *_userIcon;
    UILabel *_userName;
    TQRichTextView *_contentLabel;
    UILabel *_timeLabel;
    UIImageView *_picImageView;
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
    self.backgroundColor = [UIColor whiteColor];
    _userIcon = [UIImageView new];
    [self addSubview:_userIcon];
    
    _userName = [UILabel new];
    _userName.font = [UIFont systemFontOfSize:15];
    [self addSubview:_userName];
    
    _contentLabel = [TQRichTextView new];
    _contentLabel.backgroundColor = [UIColor clearColor];
    _contentLabel.textColor = [UIColor blackColor];
    _contentLabel.lineSpacing = 1.5;
    [self addSubview:_contentLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.textColor = [UIColor colorFormHexRGB:@"bcbcbc"];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_timeLabel];
    
    _picImageView = [UIImageView new];
    _picImageView.contentMode = UIViewContentModeScaleAspectFill;
    _picImageView.clipsToBounds = YES;
    [self addSubview:_picImageView];
    
}

- (void)setModel:(ZhiMaCollectionModel *)model {
    _model = model;
    
    [_userIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.head]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
    _userName.text = model.name;
    _timeLabel.text = model.time;
    
    
    if (model.type == 1) {  // 纯文字
        _picImageView.hidden = YES;
        _contentLabel.hidden = NO;
        _contentLabel.text = model.content;
        
    } else if (model.type == 3) { // 纯图片
        _contentLabel.hidden = YES;
        _picImageView.hidden = NO;
        [_picImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",model.photoUrl]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
    }
}


- (void)layoutSubviews {
    
    CGFloat iconW = 32;
    CGFloat iconH = 32;
    CGFloat iconX = 30;
    CGFloat iconY = 20;
    _userIcon.frame = CGRectMake(iconX, iconY, iconW, iconH);
    _userIcon.layer.cornerRadius = iconW * 0.5;
    _userIcon.clipsToBounds = YES;
    
    CGFloat nameX = CGRectGetMaxX(_userIcon.frame) + 8;
    CGFloat nameW = [_userName.text sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(MAXFLOAT, 15)].width;
    CGFloat nameH = 20;
    CGFloat nameY = _userIcon.center.y - nameH * 0.5;
    _userName.frame = CGRectMake(nameX, nameY, nameW, nameH);
    
    CGFloat contentX = iconX;
    CGFloat contentY = CGRectGetMaxY(_userIcon.frame) + 10;
    CGFloat contentW = CGRectGetWidth(self.frame) - contentX * 2;
    float contentH = [_model.content sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(contentW, MAXFLOAT)].height;
    if (![_model.content isEqualToString:@""]) {
        contentH = [TQRichTextView getRechTextViewHeightWithText:_contentLabel.text viewWidth:contentW font:[UIFont systemFontOfSize:15] lineSpacing:1.5].height;
        [_contentLabel setFrame:CGRectMake(contentX, contentY, contentW, contentH)];
    }
    
    
    
    
    CGFloat timeW = [_timeLabel.text sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(MAXFLOAT, 15)].width;
    CGFloat timeH = nameH;
    CGFloat timeX = CGRectGetWidth(self.frame) - timeW - 20;
    CGFloat timeY = nameY;
    _timeLabel.frame = CGRectMake(timeX, timeY, timeW, timeH);
    
    CGFloat picX = iconX;
    CGFloat picY = contentY;
    CGFloat picW = 240;
    CGFloat picH = 140;
    _picImageView.frame = CGRectMake(picX, picY, picW, picH);
    
    
}

@end
