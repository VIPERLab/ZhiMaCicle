//
//  LGShareToolBar.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/11/2.
//  Copyright © 2016年 liugang. All rights reserved.
//

#define Margin 6

#import "LGShareToolBar.h"

@interface LGShareToolBar(){
    UIScrollView *_scrollView;
    UIView *_cover;
    UIView *_clearView;
}

@end

static LGShareToolBar *toolBar = nil;

@implementation LGShareToolBar

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!toolBar) {
            toolBar = [[LGShareToolBar alloc] initWithFrame:CGRectMake(0, DEVICEHIGHT, DEVICEWITH, 210)];
            toolBar.backgroundColor = RGB(239, 239, 244);
        }
    });
    return toolBar;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

//设置子试图
- (void)setupViews{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, DEVICEWITH, 21)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"网页由mp.zhima.com提供";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = MAINFONT;
    [self addSubview:titleLabel];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame) + 25, DEVICEWITH, 100)];
    _scrollView.bounces = YES;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    //自定义按钮
    CGFloat iconW = (DEVICEWITH - 2 * Margin)/5;
    CGFloat iconH = 90;
    CGFloat btnWH = iconW - 2*Margin;
    
    NSArray *titles = @[@"发送给朋友",@"分享到芝麻圈",@"收藏",@"查看服务号",@"复制连接",@"调整字体",@"投诉"];
    
    for (int i = 0; i < 7; i++) {
        CGFloat iconX = Margin + i*iconW;
        //容器试图
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(iconX, 0, iconW, iconH)];
        iconView.backgroundColor = [UIColor clearColor];
        [_scrollView addSubview:iconView];
        
        //按钮
        NSString *imageName = [NSString stringWithFormat:@"barIcon%d",i];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(Margin, 0, btnWH, btnWH)];
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        btn.tag = i;
        [btn addTarget:self action:@selector(btnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [iconView addSubview:btn];
        
        //标题
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, btnWH + 7, iconW, 21)];
        title.text = titles[i];
        title.textColor = RGB(53, 53, 53);
        title.font = [UIFont systemFontOfSize:12];
        title.textAlignment = NSTextAlignmentCenter;
        [iconView addSubview:title];
    }
    
    _scrollView.contentSize = CGSizeMake(7*iconW + 2*Margin, 0);
    
    //分割线
    UIView *separtor = [[UIView alloc] initWithFrame:CGRectMake(0, 160, DEVICEWITH, .5)];
    separtor.backgroundColor = RGB(217, 217, 217);
    [self addSubview:separtor];
    
    //取消按钮
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 160.5, DEVICEWITH, 49.5)];
    cancelBtn.backgroundColor = WHITECOLOR;
    [cancelBtn setTitleColor:BLACKCOLOR forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = MAINFONT;
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
}

//按钮点击方法
- (void)btnDidClick:(UIButton *)btn{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareAction:)]) {
        [self.delegate shareAction:btn.tag];
    }
    
    [self cancelAction];
}

//取消按钮点击方法
- (void)cancelAction{
    [UIView animateWithDuration:.3 animations:^{
        toolBar.y = DEVICEHIGHT;
        _cover.alpha = 0;
    } completion:^(BOOL finished) {
        [_clearView removeFromSuperview];
    }];
}

- (void)show{    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    _clearView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _clearView.backgroundColor = [UIColor clearColor];
    [keyWindow addSubview:_clearView];
    
    //透明度蒙版
    _cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _cover.backgroundColor = BLACKCOLOR;
    _cover.alpha = 0;
    [_cover addTapGestureRecognizer:self forAction:@selector(cancelAction)];
    [_clearView addSubview:_cover];
    
    [_clearView addSubview:toolBar];
    [UIView animateWithDuration:.3 animations:^{
        _cover.alpha = 0.3;
        toolBar.y = DEVICEHIGHT - 210;
    }];
}

@end
