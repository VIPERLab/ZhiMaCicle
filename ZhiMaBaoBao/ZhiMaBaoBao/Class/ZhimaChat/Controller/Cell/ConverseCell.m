//
//  ConverseCell.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/26.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ConverseCell.h"
#import "UIImageView+WebCache.h"
#import "NSDate+TimeCategory.h"

@implementation ConverseCell {
    UIImageView *_iconView;
    UILabel *_converseLabel;
    UILabel *_lastConverseLabel;
    UILabel *_timeLabel;
    UILabel *_unReadCountLabel;
    UIView *_bottomLineView;
    UIImageView *_disturbIcon;
    UIImageView *_activityImage;
    int _unReadWidth;
    BOOL hasSubViews;
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
    
//    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _iconView = [UIImageView new];
    _iconView.layer.cornerRadius = 5;
    _iconView.clipsToBounds = YES;
    [self addSubview:_iconView];
    
    _converseLabel = [UILabel new];
    _converseLabel.font = [UIFont systemFontOfSize:17];
    [self addSubview:_converseLabel];
    
    _lastConverseLabel = [UILabel new];
    _lastConverseLabel.textColor = [UIColor colorFormHexRGB:@"9b9b9b"];
    _lastConverseLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:_lastConverseLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:13];
    _timeLabel.textColor = [UIColor colorFormHexRGB:@"b8b8b8"];
    [self addSubview:_timeLabel];
    
    _unReadCountLabel = [UILabel new];
    _unReadCountLabel.backgroundColor = THEMECOLOR;
    _unReadCountLabel.textAlignment = NSTextAlignmentCenter;
    _unReadCountLabel.font = [UIFont systemFontOfSize:13];
    _unReadCountLabel.textColor = [UIColor whiteColor];
    _unReadCountLabel.clipsToBounds = YES;
    [self addSubview:_unReadCountLabel];
    
    _bottomLineView = [UIView new];
    _bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"d9d9d9"];
    [self addSubview:_bottomLineView];
    
    
    _disturbIcon = [UIImageView new];
    _disturbIcon.image = [UIImage imageNamed:@"newMessageAlret"];
    [self addSubview:_disturbIcon];
    
    _activityImage = [UIImageView new];
    _activityImage.image = [UIImage imageNamed:@"activityChatPurse"];
    [self addSubview:_activityImage];
    
    hasSubViews = YES;
}


- (void)setModel:(ConverseModel *)model {
    _model = model;
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",DFAPIURL,model.converseHead_photo];
    if (model.converseType) {
        [_iconView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
    }else{
        [_iconView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
    }
    
    _converseLabel.text = model.converseName;
    
    _lastConverseLabel.text = model.lastConverse;
    
    if (model.unReadCount < 1) {
        _unReadCountLabel.hidden = YES;
    }else{
        _unReadCountLabel.hidden = NO;
    }
    
    if (!model.disturb) {
        // 如果不是免打扰
        if (model.unReadCount > 99) {
            _unReadCountLabel.hidden = NO;
            _unReadCountLabel.text = [NSString stringWithFormat:@"99"];
        } else if (model.unReadCount == 0) {
            _unReadCountLabel.hidden = YES;
        } else {
            _unReadCountLabel.hidden = NO;
            _unReadCountLabel.text = [NSString stringWithFormat:@"%zd",model.unReadCount];
        }
        
        
        _unReadWidth = 20;
    } else {
        // 如果是免打扰
        hasSubViews = YES;
        _unReadWidth = 10;
        _unReadCountLabel.text = @"";
    }
    
    if (model.topChat) {
        self.backgroundColor = [UIColor colorFormHexRGB:@"f3f3f7"];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    _timeLabel.text = [NSString timeStringChangeToZMTimeString:[NSDate dateStrFromCstampTime:model.time withDateFormat:@"yyyy-MM-dd HH:mm:ss"]];
    hasSubViews = YES;
    
    _disturbIcon.hidden = !model.disturb;
    
    if (model.converseType == ConversionTypeActivity) {
        _converseLabel.textColor = [UIColor colorFormHexRGB:@"ec3f38"];
        _lastConverseLabel.textColor = [UIColor colorFormHexRGB:@"ec3f38"];
    }
    
    [self setNeedsLayout];
    
}

- (void)layoutSubviews {
    if (hasSubViews) {
        
        CGFloat iconX = 10;
        CGFloat iconW = 55;
        CGFloat iconH = iconW;
        CGFloat iconY = (CGRectGetHeight(self.frame) - iconH) * 0.5;
        _iconView.frame = CGRectMake(iconX, iconY, iconW, iconH);
        
        
        CGFloat timeY = CGRectGetMinY(_iconView.frame) + 5;
        CGFloat timeW = [_timeLabel.text sizeWithFont:[UIFont systemFontOfSize:13] maxSize:CGSizeMake(MAXFLOAT, 15)].width;
        CGFloat timeX = CGRectGetWidth(self.frame) - timeW - 20;
        CGFloat timeH = 13;
        _timeLabel.frame = CGRectMake(timeX, timeY, timeW, timeH);
        
        CGFloat activityH = 35;
        CGFloat activityW;
        if (self.model.converseType == ConversionTypeActivity) {
            activityW = 25;
        } else {
            activityW = 0;
        }
        CGFloat activityY = (CGRectGetHeight(self.frame) - activityH) * 0.5;
        CGFloat activityX = CGRectGetMinX(_timeLabel.frame) - activityW - 10;
        _activityImage.frame = CGRectMake(activityX, activityY, activityW, activityH);
        
        CGFloat nameX = CGRectGetMaxX(_iconView.frame) + 10;
        CGFloat nameY = CGRectGetMinY(_iconView.frame);
        CGFloat nameW = CGRectGetWidth(self.frame) - nameX - timeW - 20 - activityW - 10;
        CGFloat nameH = 30;
        _converseLabel.frame = CGRectMake(nameX, nameY, nameW, nameH);
        
        CGFloat countWidth = _unReadWidth;
        CGFloat countHight = countWidth;
        CGFloat countX = CGRectGetMaxX(_iconView.frame) - countWidth * 0.5;
        CGFloat countY = CGRectGetMinY(_iconView.frame) - countHight * 0.5 + 3;
        _unReadCountLabel.layer.cornerRadius = _unReadWidth * 0.5;
        _unReadCountLabel.frame = CGRectMake(countX, countY, countWidth, countHight);

        _bottomLineView.frame = CGRectMake(10, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame), 0.5);
        
        CGFloat lastX = nameX;
        CGFloat lastY = CGRectGetMaxY(_converseLabel.frame);
        CGFloat lastW = nameW;
        CGFloat lastH = 20;
        _lastConverseLabel.frame = CGRectMake(lastX, lastY, lastW, lastH);
        
        CGFloat disturbW = 15;
        CGFloat disturbH = 15;
        CGFloat disturX = CGRectGetWidth(self.frame) - disturbW - 20;
        CGFloat disturY = CGRectGetMinY(_lastConverseLabel.frame) + 5;
        _disturbIcon.frame = CGRectMake(disturX, disturY, disturbW, disturbH);
        
        
        
        
        hasSubViews = NO;
        
    }
}

@end
