//
//  PersonalDiscoverCell.m
//  YiIM_iOS
//
//  Created by mac on 16/8/22.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "PersonalDiscoverCell.h"
#import "UIImageView+WebCache.h"
#import "NSString+FontSize.h"
#import "MLLinkLabel.h"
#import "UIColor+My.h"

typedef enum : NSUInteger {
    PersonalDiscoverCell_PhotoStyle_OnePhoto = 0,
    PersonalDiscoverCell_PhotoStyle_TwoPhoto = 1,
    PersonalDiscoverCell_PhotoStyle_ThreePhoto = 2,
    PersonalDiscoverCell_PhotoStyle_ThourPhoto = 3
} PersonalDiscoverCell_PhotoStyle;

@interface PersonalDiscoverCell () 

@property (nonatomic, weak) UILabel *timeLabel;     //时间文本   --  月份
@property (nonatomic, weak) UILabel *subTimeLabel;  //时间副文本  --  天数

@property (nonatomic, weak) UIButton *photoButton;  //图片

@property (nonatomic, weak) UILabel *contentLabel;  //朋友圈内容

@property (nonatomic, weak) UILabel *countLabel;   //图片数量



@end

@implementation PersonalDiscoverCell

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
//        self.cellstyle = PersonalCellStyleCreatNewDiscover;
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    
    
    UILabel *timeLabel = [[UILabel alloc] init];
    self.timeLabel = timeLabel;
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.font = [UIFont boldSystemFontOfSize:28];
    [self addSubview:timeLabel];
    
    
    UILabel *subTimeLabel = [[UILabel alloc] init];
    self.subTimeLabel = subTimeLabel;
    self.subTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.subTimeLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:subTimeLabel];
    
    
    UIButton *photoButton = [[UIButton alloc] init];
    self.photoButton = photoButton;
    [self addSubview:photoButton];
    
    
    UILabel *contentLabel = [[UILabel alloc] init];
    self.contentLabel = contentLabel;
    [self addSubview:contentLabel];
    contentLabel.numberOfLines = 3;
    contentLabel.font = [UIFont systemFontOfSize:15];
    contentLabel.textColor = [UIColor colorFormHexRGB:@"0f0f0f"];
    
    
    UILabel *countLabel = [[UILabel alloc] init];
    self.countLabel = countLabel;
    self.countLabel.font = [UIFont systemFontOfSize:12];
    self.countLabel.textColor = [UIColor colorFormHexRGB:@"404040"];
    [self addSubview:countLabel];
    
    
}


#pragma mark - 设置模型
- (void)setModel:(PersonalDiscoverPhotoModel *)model {
    _model = model;
    
    NSLog(@"%zd",model.imageList.count);
    
    [self setupButtonViewWithImageArray:model.imageList];
    
    
    //评论
    _contentLabel.text = [NSString stringWithFormat:@" %@",model.content];
    
    
    if (model.imageList.count) {  //有图片
        _photoButton.hidden = NO;
        _countLabel.hidden = NO;
    } else {                      //没有图片
        _photoButton.hidden = YES;
        _countLabel.hidden = YES;
        
    }
    
    if (_model.imageList.count == 0 || _model.imageList.count == 1) {
        _countLabel.hidden = YES;
    } else {
        _countLabel.text = [NSString stringWithFormat:@"共%zd张",_model.imageList.count];
    }
    
    self.subTimeLabel.hidden = YES;
    
}


- (void)setPersonalIndexPath:(NSIndexPath *)personalIndexPath {
    _personalIndexPath = personalIndexPath;
    if (personalIndexPath.section == 0 && personalIndexPath.row == 0) {
//        self.countLabel.hidden = YES;
        if ([self.openFirAccount isEqualToString:USERINFO.openfireaccount]) {
            self.photoButton.userInteractionEnabled = YES;
            [self.photoButton addTarget:self action:@selector(photoButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            self.photoButton.userInteractionEnabled = NO;
        }
    } else {
        self.photoButton.userInteractionEnabled = NO;
    }
}


- (void)setIsShowTimeLabel:(BOOL)isShowTimeLabel {
    _isShowTimeLabel = isShowTimeLabel;
    
    if (_isShowTimeLabel) {
        self.timeLabel.hidden = NO;
        self.subTimeLabel.hidden = NO;
    } else {
        self.timeLabel.hidden = YES;
        self.subTimeLabel.hidden = YES;
    }
}


- (void)setupYear:(NSString *)year andMonth:(NSString *)month andDay:(NSString *)day {
    self.year = year;
    self.month = month;
    self.day = day;
    
    if (([year isEqualToString:@""]  && [month isEqualToString:@""]) || [day isEqualToString:@"今天"] ||  [day isEqualToString:@"昨天"]) {
        self.timeLabel.text = day;
        self.timeLabel.frame = CGRectMake(0, 0, 70, 30);
        self.subTimeLabel.frame = CGRectMake(60, 0, 0, 17);
    } else {
        self.timeLabel.text = day;
        self.subTimeLabel.text = month;
        self.timeLabel.frame = CGRectMake(0, 0, 30, 30);
        self.subTimeLabel.frame = CGRectMake(30,(CGRectGetMaxY(self.timeLabel.frame) - 19 )* 0.5 , 30, 17);
    }
}


#pragma mark - 图片的点击事件
- (void)photoButtonDidClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(PersonalDiscoverCellFirstCellDidClick)]) {
        [self.delegate PersonalDiscoverCellFirstCellDidClick];
    }
}


#pragma mark - 根据图片张数设置图片显示方式
- (void)setupButtonViewWithImageArray:(NSArray *)imageList {
    PersonalDiscoverCell_PhotoStyle style= 0;
    switch (imageList.count) {
        case 1:
            style = PersonalDiscoverCell_PhotoStyle_OnePhoto;
            break;
        case 2:
            style = PersonalDiscoverCell_PhotoStyle_TwoPhoto;
            break;
        case 3:
            style = PersonalDiscoverCell_PhotoStyle_ThreePhoto;
            break;
        default:
            style = PersonalDiscoverCell_PhotoStyle_ThourPhoto;
            break;
    }
    
    
    [self setButtonViewWithStyle:style andImageArray:imageList];
}

- (void)setButtonViewWithStyle:(PersonalDiscoverCell_PhotoStyle) style andImageArray:(NSArray *)imageList{
    //清除photoButton所有图片
    for (UIImageView *imageView in self.photoButton.subviews) {
        if ([imageView isKindOfClass:[UIImageView class]]) {
            [imageView removeFromSuperview];
        }
    }
    
    if (!imageList.count) {
        return;
    }
    NSInteger count = 0;
    switch (style) {
        case PersonalDiscoverCell_PhotoStyle_OnePhoto: {   //当只有1张图片的时候
            count = 1;
            break;
        }
        case PersonalDiscoverCell_PhotoStyle_TwoPhoto:{ //当有2张图片
            count = 2;
            break;
        }
        case PersonalDiscoverCell_PhotoStyle_ThreePhoto: {
            count = 3;
            break;
        }
        case PersonalDiscoverCell_PhotoStyle_ThourPhoto: {
            count = 4;
            break;
        }
        default:
            count = 4;
            break;
    }
    
    for (NSInteger index = 0; index <= style ; index++) {
        
        NSInteger line =  index % 2;  //行
        NSInteger row = index / 2;  //列
        
        CGFloat buttonW = 70;
        CGFloat buttonH = buttonW;
        
        
        if (count >= 2) {
            buttonW = buttonW * 0.5;
        }
        
        if (count >=3) {
            buttonH = buttonH * 0.5;
        }
        
        CGFloat buttonX = (buttonW + 1)* line + 1.5;
        CGFloat buttonY = (buttonH + 1) * row + 1;
        
        
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
        [self.photoButton addSubview:imageView];
        imageView.clipsToBounds = YES;
        if (imageList.count > 1) {
            imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
        
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,imageList[index]]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imageView.image = image;
        }];
    }
}


- (void)layoutSubviews {
    
    if ([self.day isEqualToString:@"今天"] || [self.day isEqualToString:@"昨天"] || [self.day isEqualToString:@"前天"]) {
        self.timeLabel.frame = CGRectMake(0, 0, 70, 30);
        self.subTimeLabel.frame = CGRectMake(60, 0, 0, 17);
    } else {
        self.timeLabel.frame = CGRectMake(0, 0, 50, 30);
        self.subTimeLabel.frame = CGRectMake(30,(CGRectGetMaxY(self.timeLabel.frame) - 12 )* 0.5 , 50, 17);
    }
    
    CGFloat textHight = [self changeStationWidth:self.model.content anWidthTxtt:300 anfont:15];
    
    if (self.model.imageList.count) {
        
        self.photoButton.frame = CGRectMake(70, (CGRectGetHeight(self.frame) - 74 )* 0.5, 74, 74);
        textHight = [self changeStationWidth:self.model.content anWidthTxtt:[UIScreen mainScreen].bounds.size.width - CGRectGetMaxX(self.photoButton.frame) - 20 anfont:15];
        self.contentLabel.frame = CGRectMake(CGRectGetMaxX(self.photoButton.frame) + 5, 2, [UIScreen mainScreen].bounds.size.width - CGRectGetMaxX(self.photoButton.frame) - 20, textHight);
        self.contentLabel.backgroundColor = [UIColor clearColor];
        
    } else {
        
        self.photoButton.frame = CGRectMake(70, (CGRectGetHeight(self.frame) - 74 )* 0.5, 0, 74);
        self.contentLabel.frame = CGRectMake(70, 2, [UIScreen mainScreen].bounds.size.width - CGRectGetMaxX(self.photoButton.frame) - 20, textHight + 10);
        self.contentLabel.backgroundColor = [UIColor colorFormHexRGB:@"f3f3f5"];
    }
    
    
    self.countLabel.frame = CGRectMake(CGRectGetMaxX(self.photoButton.frame) + 5, CGRectGetMaxY(self.photoButton.frame) - 20, 100, 20);
    
}


-(CGFloat)changeStationWidth:(NSString *)string anWidthTxtt:(CGFloat)widthText anfont:(CGFloat)fontSize{
    
    UIFont * tfont = [UIFont systemFontOfSize:fontSize];
    
    //高度估计文本大概要显示几行，宽度根据需求自己定义。 MAXFLOAT 可以算出具体要多高
    
    CGSize size =CGSizeMake(widthText,60);
    
    //    获取当前文本的属性
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    
    //ios7方法，获取文本需要的size，限制宽度
    
    CGSize  actualsize =[string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    
    return actualsize.height;
    
}

@end
