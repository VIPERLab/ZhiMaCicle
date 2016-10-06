//
//  NewDIscoverPhotoPickerView.m
//  YiIM_iOS
//
//  Created by mac on 16/8/22.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "NewDiscoverPhotoPickerView.h"
#import "SDAutoLayout.h"
#import "KXActionSheet.h"
#import "LCProgressHUD.h"

@interface NewDiscoverPhotoPickerView () <KXActionSheetDelegate>

@property (nonatomic, weak) UIButton *currentSelectedButton;
@property (nonatomic, weak) UIButton *tempButton;


@end

@implementation NewDiscoverPhotoPickerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    UIButton *button = [[UIButton alloc] init];
    [button setBackgroundImage:[UIImage imageNamed:@"NewDiscover_AddPhoto"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addPhotoButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    button.imageView.layer.masksToBounds = YES;
    button.clipsToBounds = YES;
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:button];
    self.tempButton = button;
    [self.buttonArray addObject:button];
    
}

- (void)layoutSubviews {
    CGFloat btnW = 70;
    CGFloat btnH = 70;
    CGFloat btnX = 10;
    CGFloat btnY = 0;
    
    self.tempButton.frame = CGRectMake(btnX, btnY, btnW, btnH);
    
    
}


#pragma mark - 图片的点击事件
- (void)addPhotoButtonDidClick:(UIButton *)sender {
    self.currentSelectedButton = sender;
    [[NSNotificationCenter defaultCenter] postNotificationName:K_NewDiscoverPhotoClickNotifcation object:nil userInfo:@{@"CurrentSelectedButton" : sender
                                                                                                                        }];

    KXActionSheet *sheet = [[KXActionSheet alloc] initWithTitle:@"" cancellTitle:@"取消" andOtherButtonTitles:@[@"拍照",@"从手机相册选择"]];
    sheet.delegate = self;
    [sheet show];
        
        
    
    
}


#pragma mark - actionSheetDelegate
- (void)KXActionSheet:(KXActionSheet *)sheet andIndex:(NSInteger)index {
    [[NSNotificationCenter defaultCenter] postNotificationName:K_NewDiscoverPhotoPickerNotifcation object:self userInfo:@{   @"buttonIndex":[NSString stringWithFormat:@"%zd",index],
                      @"currentSelectedButton" : self.currentSelectedButton,
                      @"PhotoPickerViewController" : self
                                                                                                                             }];
}


//增加下一个图片选择按钮
- (void)addAnotherButton {
    
    
    UIButton *lastButton = self.subviews.lastObject;
    
    CGFloat nextButtonW = CGRectGetWidth(lastButton.frame);
    CGFloat nextButtonH = CGRectGetHeight(lastButton.frame);
    CGFloat nextButtonX = CGRectGetMaxX(lastButton.frame) + 5;
    CGFloat nextButtonY = CGRectGetMinY(lastButton.frame);
    
    if ( (nextButtonX + nextButtonW ) > [UIScreen mainScreen].bounds.size.width) { //如果下一个超出屏幕右侧，则下一行
        
        if (self.buttonArray.count == 4) {
            nextButtonY = nextButtonH + 10;
        } else  {
            nextButtonY = (nextButtonH  + 5 ) * 2 + 5;
        }
        
        nextButtonX = 10;
    }
    
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(nextButtonX, nextButtonY, nextButtonW, nextButtonH)];
    nextButton.tag = self.buttonArray.count;
    [nextButton addTarget:self action:@selector(addPhotoButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setImage:[UIImage imageNamed:@"NewDiscover_AddPhoto"] forState:UIControlStateNormal];
    [self addSubview:nextButton];
    
    if (self.buttonArray.count > 9) {
        [nextButton removeFromSuperview];
        
        return;
    }
    
}


- (void)setButtonWithImageArray:(NSArray *)imageArray {
    
    for (UIButton *imageButton in self.subviews) {
        if ([imageButton isKindOfClass:[UIButton class]]) {
            [imageButton removeFromSuperview];
        }
    }
    [self.buttonArray removeAllObjects];
    
    for (NSInteger index = 0; index < imageArray.count; index ++) {
        UIButton *imageButton = [UIButton new];
        NSInteger line =  index % 4;  //行
        NSInteger row = index / 4;  //列
        
        
        CGFloat buttonW = ([UIScreen mainScreen].bounds.size.width - 50) / 4;
        CGFloat buttonH = buttonW;
        CGFloat buttonX = (buttonW + 5) * line + 10;
        CGFloat buttonY = (buttonH + 5) * row + 3;
        imageButton.tag = index;
        imageButton.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        [self addSubview:imageButton];
        
        [self.buttonArray addObject:imageButton];
        [imageButton addTarget:self action:@selector(addPhotoButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [imageButton setImage:imageArray[index] forState:UIControlStateNormal];
        
        
    }
    
    if (imageArray.count < 9  && imageArray.count > 0) {
        [self addAnotherButton];
    }
    
}

#pragma mark - lazyLoad
- (NSMutableArray *)buttonArray {
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}


@end
