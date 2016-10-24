//
//  NewDiscoverHeaderView.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/21.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "NewDiscoverDetailHeaderView.h"
#import "UIButton+WebCache.h"
#import "SDTimeLineCellModel.h"
//#import "SDTimeLineCellOperationMenu.h"
#import "newDiscoverDetailMenu.h"

#define kDiscoverDetailOperationButtonClickedNotification @"DiscoverDetailOperationButtonClickedNotification"
//NSString *const kDiscoverDetailOperationButtonClickedNotification = @"DiscoverDetailOperationButtonClickedNotification";

@interface NewDiscoverDetailHeaderView ()

@property (nonatomic, strong) NSMutableArray *picImageArray;

// 控件存放位置
@property (nonatomic, strong) NSMutableArray *picImageIconArray;

@end

@implementation NewDiscoverDetailHeaderView {
    UIImageView *_userIcon;
    UILabel *_userNameLabel;
    UILabel *_contentLabel;
    UILabel *_creatTimeLabel;
    UILabel *_locationLabel;
    newDiscoverDetailMenu *_operationMenu;
    UIButton *_operationButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    self.backgroundColor = [UIColor whiteColor];
    
    _userIcon = [UIImageView new];
    [self addSubview:_userIcon];
    
    _userNameLabel = [UILabel new];
    _userNameLabel.font = [UIFont boldSystemFontOfSize:16];
    _userNameLabel.textColor = [UIColor colorFormHexRGB:@"576b95"];
    [self addSubview:_userNameLabel];
    
    _contentLabel = [UILabel new];
    _contentLabel.font = [UIFont systemFontOfSize:14];
    _contentLabel.numberOfLines = 0;
    [self addSubview:_contentLabel];
    
    _creatTimeLabel = [UILabel new];
    _creatTimeLabel.textColor = [UIColor colorFormHexRGB:@"737373"];
    _creatTimeLabel.font = [UIFont systemFontOfSize:11];
    [self addSubview:_creatTimeLabel];
    
    _locationLabel = [UILabel new];
    [self addSubview:_locationLabel];
    
    _operationButton = [UIButton new];
    [_operationButton setImage:[UIImage imageNamed:@"Discover_Comment"] forState:UIControlStateNormal];
    [_operationButton addTarget:self action:@selector(operationButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_operationButton];
    
    _operationMenu = [newDiscoverDetailMenu new];
    _operationMenu.show = NO;
    [_operationMenu setLikeButtonClickedOperation:^(newDiscoverDetailMenu *menu) {

    }];
    [self addSubview:_operationMenu];
}

#pragma mark - action
- (void)operationButtonClicked {
//    [[NSNotificationCenter defaultCenter] postNotificationName:kDiscoverDetailOperationButtonClickedNotification object:_operationButton];
    _operationMenu.show = !_operationMenu.isShowing;
}


#pragma mark - layout
- (void)setPicImageArray:(NSMutableArray *)picImageArray {
    _picImageArray = picImageArray;
    
    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
//            [button removeFromSuperview];
            button.hidden = YES;
        }
    }
    
    [self.picImageIconArray removeAllObjects];
    
    for (NSInteger index = 0; index < picImageArray.count; index++) {
        UIButton *button = [[UIButton alloc] init];
        button.tag = index;
        [self.picImageIconArray addObject:button];
        [self addSubview:button];
    }
    
}


- (void)setModel:(SDTimeLineCellModel *)model {
    _model = model;
    [_userIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.head_photo]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
    
    _userNameLabel.text = model.friend_nick;
    
    _contentLabel.text = model.content;
    
    _creatTimeLabel.text = model.create_time;
    
    _locationLabel.text = model.current_location;
    
    self.picImageArray = [model.imglist mutableCopy];
    
    [self setNeedsLayout];
}



- (void)layoutSubviews {
    _userIcon.frame = CGRectMake(10, 10, 50, 50);
    UIView *lastView;
    
    CGFloat nameX = CGRectGetMaxX(_userIcon.frame) + 10;
    CGFloat nameY = CGRectGetMinY(_userIcon.frame);
    CGFloat nameW = CGRectGetWidth(self.frame) - nameX;
    CGFloat nameH = 18;
    _userNameLabel.frame = CGRectMake(nameX, nameY , nameW, nameH);
    lastView = _userNameLabel;
    
    if (self.model.content.length) {
        CGFloat contentX = nameX;
        CGFloat contentY = CGRectGetMaxY(_userNameLabel.frame) + 5;
        CGFloat contentW = CGRectGetWidth(self.frame) - contentX - 20;
        CGFloat contentH = [_contentLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:15] maxSize:CGSizeMake(contentW, MAXFLOAT)].height;
        _contentLabel.frame = CGRectMake(contentX, contentY, contentW, contentH);
        lastView = _contentLabel;
    }
    
    if (_picImageArray.count) {
        for (NSInteger index = 0; index < self.picImageArray.count; index++) {
            SDTimeLineCellPicItemModel *picModel = self.picImageArray[index];
            UIButton *button = self.picImageIconArray[index];
            button.hidden = NO;
            
            NSInteger row = 0;
            NSInteger line = 0;
            if (self.picImageArray.count == 4) { // 四宫格样式
                row =  index % 2;  //行
                line = index / 2;  //列
            } else {                             // 九宫格样式
                row =  index % 3;  //行
                line = index / 3;  //列
            }
            
            CGFloat itemW = 0;
            
            CGFloat itemY = 0;
            if (self.picImageArray.count == 1) {
                itemW = 120;
            } else {
                itemW = 80;
            }
            
            CGFloat itemH = itemW;
            
            itemY = CGRectGetMaxY(lastView.frame) + 10 + (line * (itemW + 5));
            
            CGFloat itemX = nameX + (row * (itemW + 5));
            button.frame = CGRectMake(itemX, itemY, itemW, itemH);
            [button sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,picModel.img_url]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
        }
        lastView = self.picImageIconArray.lastObject;
    }
    
    
    CGFloat timeX = nameX;
    CGFloat timeY = CGRectGetMaxY(lastView.frame) + 5;
    CGFloat timeW = [_creatTimeLabel.text sizeWithFont:[UIFont systemFontOfSize:11] maxSize:CGSizeMake(300, MAXFLOAT)].width;
    CGFloat timeH = 15;
    _creatTimeLabel.frame = CGRectMake(timeX, timeY, timeW, timeH);
    
    CGFloat operationX = ScreenWidth - 25 - 10;
    CGFloat operationY = CGRectGetMinY(_creatTimeLabel.frame) - 5;
    CGFloat operationW = 25;
    CGFloat operationH = operationW;
    _operationButton.hidden = NO;
    _operationButton.frame = CGRectMake(operationX, operationY, operationW, operationH);
    
    CGFloat menuW = 161;
    CGFloat menuH = 36;
    CGFloat menuX = CGRectGetMinX(_operationButton.frame) - menuW - 10;
    CGFloat menuY = CGRectGetMinY(_operationButton.frame) + (CGRectGetHeight(_operationButton.frame) - menuH) * 0.5;
    _operationMenu.frame = CGRectMake(menuX, menuY, menuW, menuH);
    
}


- (CGFloat)itemWidthForPicPathArray:(NSArray *)array
{
    if (array.count == 1) {
        return 120;
    } else {
        CGFloat w = [UIScreen mainScreen].bounds.size.width > 320 ? 80 : 70;
        return w;
    }
}

- (NSInteger)perRowItemCountForPicPathArray:(NSArray *)array
{
    if (array.count < 3) {
        return array.count;
    } else if (array.count <= 4) {
        return 2;
    } else {
        return 3;
    }
}


- (NSMutableArray *)picImageIconArray {
    if (!_picImageIconArray) {
        _picImageIconArray = [NSMutableArray array];
    }
    return _picImageIconArray;
}


@end
