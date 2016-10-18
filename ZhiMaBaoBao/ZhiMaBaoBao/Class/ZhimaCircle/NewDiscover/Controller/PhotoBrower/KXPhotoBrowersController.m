//
//  KXPhotoBrowersController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/18.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "KXPhotoBrowersController.h"
#import "KXPhotoBorwerScrollView.h"
#import "SDBrowserImageView.h"
#import "KXActionSheet.h"

@interface KXPhotoBrowersController () <UIScrollViewDelegate,KXActionSheetDelegate>

@property (nonatomic, weak) KXPhotoBorwerScrollView *scrollView;

@property (nonatomic, weak) UIView *navView;
@property (nonatomic, assign) BOOL animatied;
@property (nonatomic, assign, getter=isShow) BOOL show;
@property (nonatomic, assign) CGPoint contentOffset;

@end

@implementation KXPhotoBrowersController {
    UILabel *_titleLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self setupView];
    [self setupNav];
    
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];

    [self showNavView];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
}

- (void)setupNav {
    self.navigationController.navigationBar.hidden = YES;
    
    if (self.navView) {
        return;
    }
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, -40 , ScreenWidth, 44)];
    navView.backgroundColor = [UIColor colorFormHexRGB:@"151419"];
    navView.userInteractionEnabled = YES;
    [self.view addSubview:navView];
    self.navView = navView;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth - 100) * 0.5, 0, 100, 44)];
    _titleLabel = titleLabel;
    titleLabel.text = [NSString stringWithFormat:@"%zd/%zd",self.currentIndex,self.imageArray.count];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [navView addSubview:titleLabel];
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 40 - 20, 0, 44, 44)];
    [rightBtn setImage:[UIImage imageNamed:@"Photo_Borwers_Del"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(deletedButtonDidClcik) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:rightBtn];
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
    [leftBtn setImage:[UIImage imageNamed:@"Photo_Borwers_back"] forState:UIControlStateNormal];
    [leftBtn setTitle:@"返回" forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(backButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [navView addSubview:leftBtn];
}

- (void)setCustomTitle:(NSString *)title {
    _titleLabel.text = title;
}


#pragma mark - nav动画
// nav 展示动画
- (void)showNavView {
    if (self.animatied) {
        return;
    }
    
    self.animatied = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.navView.frame = CGRectMake(0, 20, ScreenWidth, 40);
        [UIApplication sharedApplication].statusBarHidden = NO;
    } completion:^(BOOL finished) {
        self.animatied = NO;
        self.show = YES;
    }];
}

// nav 隐藏动画
- (void)hideNavView {
    if (self.animatied) {
        return;
    }
    
    self.animatied = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.navView.frame = CGRectMake(0, -40, ScreenWidth, 40);
        [UIApplication sharedApplication].statusBarHidden = YES;
    } completion:^(BOOL finished) {
        self.animatied = NO;
        self.show = NO;
    }];
}

#pragma mark - 布局
- (void)setupView {
    self.view.backgroundColor = [UIColor blackColor];
    
    KXPhotoBorwerScrollView *scrollView = [[KXPhotoBorwerScrollView alloc] initWithFrame:CGRectMake(0, -20, ScreenWidth, ScreenHeight + 20)];
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(ScreenWidth * self.imageArray.count, 0);
    self.scrollView.contentOffset = CGPointMake(ScreenWidth * (self.currentIndex - 1), 0);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    [self setupImageView];
    
}

- (void)setupImageView {
    // 移除之前的imgeView
    for (UIImageView *imageView in self.scrollView.subviews) {
        if ([imageView isKindOfClass:[UIImageView class]]) {
            [imageView removeFromSuperview];
        }
    }
    
    // 布局新的视图
    for (NSInteger index = 0; index < self.imageArray.count; index++) {
        UIImage *image = self.imageArray[index];
        
        CGFloat scale = image.size.width / ScreenWidth;
        CGSize imageSize = image.size;
        CGFloat imageWidth = imageSize.width > ScreenWidth ? ScreenWidth : imageSize.width;
        CGFloat imageHeight = imageSize.height / scale;
        
        SDBrowserImageView *imageView = [[SDBrowserImageView alloc] initWithFrame:CGRectMake(index * ScreenWidth, (CGRectGetHeight(self.scrollView.frame) - imageHeight) * 0.5, imageWidth, imageHeight)];
        imageView.userInteractionEnabled = YES;
        imageView.image = image;
        [self.scrollView addSubview:imageView];
        
        // 单击图片
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGroud:)];
        
        // 双击放大图片
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDoubleTaped:)];
        doubleTap.numberOfTapsRequired = 2;
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        [imageView addGestureRecognizer:singleTap];
        [imageView addGestureRecognizer:doubleTap];
    }
    
    
}

- (void)tapBackGroud:(UIGestureRecognizer *)gesture {
    if (self.isShow) {
        [self hideNavView];
    } else {
        [self showNavView];
    }
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isShow) {
        [self hideNavView];
    }
    
    CGFloat result = scrollView.contentOffset.x / ScreenWidth;
    [self setCustomTitle:[NSString stringWithFormat:@"%zd/%zd",(int)result + 1 ,self.imageArray.count]];
    
    self.contentOffset = scrollView.contentOffset;
}

#pragma mark - 返回按钮
- (void)backButtonDidClick {
    self.backBlock(self.imageArray);
    [self.navigationController popViewControllerAnimated:YES];
}

// 双击手势
- (void)imageViewDoubleTaped:(UITapGestureRecognizer *)recognizer
{
    SDBrowserImageView *imageView = (SDBrowserImageView *)recognizer.view;
    CGFloat scale;
    if (imageView.isScaled) {
        scale = 1.0;
    } else {
        scale = 2.0;
    }
    
    [imageView doubleTapToZommWithScale:scale];
}



#pragma mark - 删除按钮
- (void)deletedButtonDidClcik {
    KXActionSheet *sheet = [[KXActionSheet alloc] initWithTitle:@"要删除这张照片吗" cancellTitle:@"取消" andOtherButtonTitles:@[@"删除"]];
    sheet.delegate = self;
    [sheet show];
}

- (void)KXActionSheet:(KXActionSheet *)sheet andIndex:(NSInteger)index {
    if (index == 0) {
        // 删除该图片
        int index = self.contentOffset.x / ScreenWidth;
        self.scrollView.contentOffset = CGPointMake(ScreenWidth * (index - 1), 0);
        [_imageArray removeObjectAtIndex:index];
        
        // 更新scrollView 的内容
        if (_imageArray.count) {
            [self setupImageView];
            [self setCustomTitle:[NSString stringWithFormat:@"%zd/%zd",index,self.imageArray.count]];
            self.scrollView.contentSize = CGSizeMake(ScreenWidth * self.imageArray.count, 0);
        } else {
            [self backButtonDidClick];
        }
        
    }
}

@end
