//
//  UserMessageCell.m
//  YiIM_iOS
//
//  Created by mac on 16/8/24.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "UserMessageCell.h"
#import "UIImageView+WebCache.h"
#import "TQRichTextView.h"
#import "UIColor+My.h"
@interface UserMessageCell ()

@property (nonatomic, weak) UIImageView *iconView;      //评论人头像

@property (nonatomic, weak) UILabel *nameLabel;         //评论名字

@property (nonatomic, weak) TQRichTextView *contentLabel;      //评论内容

@property (nonatomic, weak) UIImageView *likeImage;     //点赞图片

@property (nonatomic, weak) UILabel *creatTimeLabel;    //创建时间

@property (nonatomic, weak) UIImageView *discoverPhoto; //朋友圈第一张图片

@property (nonatomic, weak) UILabel *discoverContent;   //朋友圈内容

@property (nonatomic, weak) UIView *bottomLineView;         //底部线条

@end

@implementation UserMessageCell

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
    UIImageView *iconView = [[UIImageView alloc] init];
    self.iconView = iconView;
    [self addSubview:iconView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = [UIFont systemFontOfSize:15];
    self.nameLabel = nameLabel;
    [self addSubview:nameLabel];
    
    TQRichTextView *contentLabel = [[TQRichTextView alloc] init];
    contentLabel.font = [UIFont systemFontOfSize:14];
    self.contentLabel = contentLabel;
    _contentLabel.lineSpacing = 1.5;
    _contentLabel.backgroundColor = [UIColor clearColor];
    _contentLabel.textColor = [UIColor blackColor];
    [self addSubview:contentLabel];
    
    UILabel *creaetTimeLabel = [[UILabel alloc] init];
    creaetTimeLabel.font = [UIFont systemFontOfSize:13];
    self.creatTimeLabel = creaetTimeLabel;
    [self addSubview:creaetTimeLabel];
    
    
    UIImageView *likeImage = [[UIImageView alloc] init];
    likeImage.image = [UIImage imageNamed:@"Discover_Like_Sel"];
    self.likeImage = likeImage;
    [self addSubview:likeImage];
    
    
    UIView *bottomLineView = [[UIView alloc] init];
    bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"eaeae9"];
    self.bottomLineView = bottomLineView;
    [self addSubview:bottomLineView];
    
}


- (void)setModel:(UserMessageModel *)model {
    _model = model;
    self.discoverPhoto.hidden = NO;
    self.discoverContent.hidden = NO;
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.comment_headPhoto]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.iconView.image = image;
    }];
    
    self.nameLabel.text = model.comment_userName;
    
    self.contentLabel.text = model.content;
    
    self.creatTimeLabel.text = model.create_time;
    
    if ([model.circle_content isEqualToString:@""] || model.circle_content == nil) {  //只有图片的朋友圈
        
        if (!self.discoverPhoto) {
            UIImageView *discoverPhoto = [[UIImageView alloc] init];
            self.discoverPhoto = discoverPhoto;
            [self addSubview:discoverPhoto];
            self.discoverContent.hidden = YES;
        }
        [self.discoverPhoto sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.imgurl]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            self.discoverPhoto.image = image;
        }];
        
    } else {            //只有文字的朋友圈
        self.discoverContent.hidden = NO;
        if (!self.discoverContent) {
            UILabel *discoverContent = [[UILabel alloc] init];
            discoverContent.textColor = [UIColor colorFormHexRGB:@"0f0f0f"];
            discoverContent.font = [UIFont systemFontOfSize:13];
            discoverContent.numberOfLines = 3;
            self.discoverContent = discoverContent;
            [self addSubview:discoverContent];
        }
        
        self.discoverContent.text = model.circle_content;
        self.discoverPhoto.hidden = YES;
        
    }
    
    if (model.type == 2) {
        self.likeImage.hidden = NO;
        self.contentLabel.text = @" ";
    } else {
        self.likeImage.hidden = YES;
    }
}

- (void)layoutSubviews {
    self.iconView.frame = CGRectMake(10, 10, 50, 50);
    
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.iconView.frame) + 5, 10, 300, 15);
    
    //获取文字高度
//    CGFloat contentHeight = [self changeStationWidth:self.contentLabel.text anWidthTxtt:[UIScreen mainScreen].bounds.size.width - (CGRectGetMaxX(self.iconView.frame) + 70) anfont:14];
    
    CGFloat contentH = [TQRichTextView getRechTextViewHeightWithText:_contentLabel.text viewWidth:[UIScreen mainScreen].bounds.size.width - (CGRectGetMaxX(self.iconView.frame) + 80) font:[UIFont systemFontOfSize:15] lineSpacing:1.5].height;
    self.contentLabel.frame = CGRectMake(CGRectGetMaxX(self.iconView.frame) + 5, CGRectGetMaxY(self.nameLabel.frame) + 5, [UIScreen mainScreen].bounds.size.width - (CGRectGetMaxX(self.iconView.frame) + 80), contentH);
    
    self.likeImage.frame = CGRectMake(CGRectGetMinX(self.contentLabel.frame) , CGRectGetMinY(self.contentLabel.frame) + 3, 17, 16);
    
    
    self.creatTimeLabel.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.contentLabel.frame) + 5, 200, 20);
    
    self.bottomLineView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame), 0.5);
    
    if (self.discoverPhoto) {
        self.discoverPhoto.frame = CGRectMake([UIScreen mainScreen].bounds.size.width -  70, (CGRectGetHeight(self.frame) - 60) * 0.5, 60, 60);
    } else {
        self.discoverContent.frame = CGRectMake([UIScreen mainScreen].bounds.size.width -  70, CGRectGetMinY(self.nameLabel.frame), 60, 60);
    }
    
    
    
}

//计算文字高度
-(CGFloat)changeStationWidth:(NSString *)string anWidthTxtt:(CGFloat)widthText anfont:(CGFloat)fontSize{
    
    UIFont * tfont = [UIFont systemFontOfSize:fontSize];
    
    //高度估计文本大概要显示几行，宽度根据需求自己定义。 MAXFLOAT 可以算出具体要多高
    
    CGSize size =CGSizeMake(widthText,MAXFLOAT);
    
    //    获取当前文本的属性
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    
    //ios7方法，获取文本需要的size，限制宽度
    
    CGSize  actualsize =[string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    
    return actualsize.height;
    
}


@end
