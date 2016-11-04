//
//  ZhiMaCollectionCell.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/7.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZhiMaCollectionCell.h"
#import "TQRichTextView.h"

#import "ZhiMaCollectionVoiceTypeView.h"
#import "PKFullScreenPlayerView.h"
#import "UIImage+PKShortVideoPlayer.h"
#import "HKPieChartView.h"

#import <AVFoundation/AVFoundation.h>

@interface ZhiMaCollectionCell ()
@property (nonatomic, strong) PKFullScreenPlayerView * playView; //视频播放view
@property (nonatomic, strong) UIButton *playBtn; // 播放按钮
@property (nonatomic, strong) HKPieChartView *progressView; // 进度圈
@property (nonatomic, strong) UIImageView *holderIV; // 视频未下载前显示视频的第一帧图片
@property (nonatomic, strong) UIButton *sendFailBtn; // 上传失败展示按钮

@end

@implementation ZhiMaCollectionCell {
    UIImageView *_userIcon;
    UILabel *_userName;
    TQRichTextView *_contentLabel;
    UILabel *_timeLabel;
    UIImageView *_picImageView;
    UIView *_voiceView;
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
    _contentLabel.font = [UIFont systemFontOfSize:15];
    _contentLabel.textColor = [UIColor blackColor];
    _contentLabel.lineSpacing = 1.5;
    _contentLabel.userInteractionEnabled = NO;
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
    
    
    _voiceView = [ZhiMaCollectionVoiceTypeView new];
    _voiceView.layer.borderWidth = 0.5;
    _voiceView.layer.borderColor = [UIColor colorFormHexRGB:@"dedede"].CGColor;
    _voiceView.layer.cornerRadius = 5;
    _voiceView.clipsToBounds = YES;
    _voiceView.backgroundColor = [UIColor colorFormHexRGB:@"f3f4f5"];
    [self addSubview:_voiceView];
    
    [self setVideoView];
    
}

- (void)setVideoView {
    _playView = [[PKFullScreenPlayerView alloc] init];
    _playView.isMuted = YES;
    _playView.contentMode =  UIViewContentModeScaleAspectFill;
    _playView.layer.cornerRadius = 3;
    _playView.layer.masksToBounds = YES;
    [self addSubview:_playView];
    
    _holderIV = [[UIImageView alloc]initWithFrame:CGRectZero];
    _holderIV.contentMode =  UIViewContentModeScaleAspectFill;
    _holderIV.layer.cornerRadius = 3;
    _holderIV.layer.masksToBounds = YES;
    [self addSubview:_holderIV];
    
    _playBtn = [[UIButton alloc] init];
    [_playBtn setImage:[UIImage imageNamed:@"PK_PlayBtn"] forState:UIControlStateNormal];
    _playBtn.hidden = YES;
    [_playBtn addTarget:self action:@selector(btnAction_play) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playBtn];
    
    _progressView = [[HKPieChartView alloc] init];
    [self addSubview:_progressView];
    
    _sendFailBtn = [[UIButton alloc] init];
    [_sendFailBtn setImage:[UIImage imageNamed:@"sendFail"] forState:UIControlStateNormal];
    [_sendFailBtn addTarget:self action:@selector(reloadViewAction) forControlEvents:UIControlEventTouchUpInside];
    _sendFailBtn.hidden = YES;
    [self addSubview:_sendFailBtn];
    
    
//    self.lastProgress = 0.0;
    
    //添加长按手势
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self addGestureRecognizer:longGesture];
}

- (void)setModel:(ZhiMaCollectionModel *)model {
    _model = model;
    
    [_userIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.head]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
    _userName.text = model.name;
    _timeLabel.text = model.time;
    
    
    if (model.type == 1) {  // 纯文字
        _picImageView.hidden = YES;
        _voiceView.hidden = YES;
        _contentLabel.hidden = NO;
        _contentLabel.text = model.content;
        
    } else if (model.type == 3) { // 纯图片
        _contentLabel.hidden = YES;
        _voiceView.hidden = YES;
        _picImageView.hidden = NO;
        [_picImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",model.photoUrl]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
    } else if (model.type == 5) { // 语音
        _contentLabel.text = @" ";
        _picImageView.hidden = YES;
        _contentLabel.hidden = YES;
        _voiceView.hidden = NO;
    } else if (model.type == 4) { // 视频样式
        _picImageView.hidden = YES;
        _contentLabel.hidden = YES;
        _voiceView.hidden = YES;
        
        [_holderIV sd_setImageWithURL:[NSURL URLWithString:model.pic_name] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
        
    }
    
    [self setNeedsDisplay];
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
    
    if (self.model.type == 1) { //文字
        CGFloat contentX = iconX;
        CGFloat contentY = CGRectGetMaxY(_userIcon.frame) + 10;
        CGFloat contentW = CGRectGetWidth(self.frame) - contentX * 2;
        float contentH = [_model.content sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(contentW, MAXFLOAT)].height;
        if (_model.content.length) {
            contentH = [TQRichTextView getRechTextViewHeightWithText:_contentLabel.text viewWidth:contentW font:[UIFont systemFontOfSize:15] lineSpacing:1.5].height;
            [_contentLabel setFrame:CGRectMake(contentX, contentY, contentW, contentH)];
        }
    } else if (self.model.type == 3) {//图片
        CGFloat picX = iconX;
        CGFloat picY = CGRectGetMaxY(_userIcon.frame) + 10;
        CGFloat picW = 240;
        CGFloat picH = 140;
        _picImageView.frame = CGRectMake(picX, picY, picW, picH);
    } else if (self.model.type == 4) { // 视频
        CGFloat playerX = iconX;
        CGFloat playerY = CGRectGetMaxY(_userIcon.frame) + 10;
        CGFloat playerW = 170;
        CGFloat playerH = playerW;
        _playView.frame = CGRectMake(playerX, playerY, playerW, playerH);
        
        _holderIV.frame = CGRectMake(playerX, playerY, playerW, playerH);
        
        _playBtn.frame = CGRectMake(playerX, playerY, 50, 50);
        
        _sendFailBtn.frame = CGRectMake(playerX, playerY, 50, 50);
        
        _progressView.frame = CGRectMake(playerX, playerY, 50, 50);
        
        
    } else if (self.model.type == 5) { // 语音
        CGFloat voiceX = iconX;
        CGFloat voiceW = CGRectGetWidth(self.frame) - iconX * 2;
        CGFloat voiceH = 60;
        CGFloat voiceY = (CGRectGetHeight(self.frame) - (CGRectGetMaxY(_userIcon.frame) + 10 - voiceH)) * 0.5;
        _voiceView.frame = CGRectMake(voiceX, voiceY, voiceW, voiceH);
    }
    
    
    CGFloat timeW = [_timeLabel.text sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(MAXFLOAT, 15)].width;
    CGFloat timeH = nameH;
    CGFloat timeX = CGRectGetWidth(self.frame) - timeW - 20;
    CGFloat timeY = nameY;
    _timeLabel.frame = CGRectMake(timeX, timeY, timeW, timeH);
    
    
    
}

@end
