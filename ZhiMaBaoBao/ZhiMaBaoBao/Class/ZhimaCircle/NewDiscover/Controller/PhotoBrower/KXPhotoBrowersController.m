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
    BOOL _statusBarShouldBeHidden;
    BOOL _didSavePreviousStateOfNavBar;
    BOOL _viewIsActive;
    BOOL _viewHasAppearedInitially;
    // Appearance
    BOOL _previousNavBarHidden;
    BOOL _previousNavBarTranslucent;
    
    UIBarStyle _previousNavBarStyle;
    UIStatusBarStyle _previousStatusBarStyle;
    UIColor *_previousNavBarTintColor;
    UIColor *_previousNavBarBarTintColor;
    UIBarButtonItem *_previousViewControllerBackButton;
    UIImage *_previousNavigationBarBackgroundImageDefault;
    UIImage *_previousNavigationBarBackgroundImageLandscapePhone;
    
    UIToolbar *_toolbar;
    UILabel *_titleLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self setupNav];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self storePreviousNavBarAppearance];
    _previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
    [self setNavBarAppearance:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self restorePreviousNavBarAppearance:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle animated:animated];
    [self.navigationController.navigationBar setAlpha:1];
}

- (void)setupNav {
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Photo_Borwers_Del"] style:UIBarButtonItemStylePlain target:self action:@selector(deletedButtonDidClcik)];
    self.navigationItem.rightBarButtonItem = rightBar;
}

#pragma mark - Nav Bar Appearance
- (void)setNavBarAppearance:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = [UIColor whiteColor];
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = nil;
        navBar.shadowImage = nil;
    }
    navBar.translucent = YES;
    navBar.barStyle = UIBarStyleBlackTranslucent;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsCompact];
    }
}

- (void)storePreviousNavBarAppearance {
    _didSavePreviousStateOfNavBar = YES;
//    if ([UINavigationBar instancesRespondToSelector:@selector(barTintColor)]) {
        _previousNavBarBarTintColor = self.navigationController.navigationBar.barTintColor;
//    }
    _previousNavBarTranslucent = self.navigationController.navigationBar.translucent;
    _previousNavBarTintColor = self.navigationController.navigationBar.tintColor;
    _previousNavBarHidden = self.navigationController.navigationBarHidden;
    _previousNavBarStyle = self.navigationController.navigationBar.barStyle;
//    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        _previousNavigationBarBackgroundImageDefault = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
        _previousNavigationBarBackgroundImageLandscapePhone = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsCompact];
//    }
}

- (void)restorePreviousNavBarAppearance:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:_previousNavBarHidden animated:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = THEMECOLOR;
    navBar.translucent = _previousNavBarTranslucent;
//    if ([UINavigationBar instancesRespondToSelector:@selector(barTintColor)]) {
        navBar.barTintColor = _previousNavBarBarTintColor;
//    }
    navBar.barStyle = _previousNavBarStyle;
//    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [navBar setBackgroundImage:_previousNavigationBarBackgroundImageDefault forBarMetrics:UIBarMetricsDefault];
        [navBar setBackgroundImage:_previousNavigationBarBackgroundImageLandscapePhone forBarMetrics:UIBarMetricsCompact];
//    }
    
}


- (void)setCustomTitle:(NSString *)title {
    self.title = title;
}



#pragma mark - nav动画
// Fades all controls slide and fade
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated{
    
    // Force visible
//    if (self.imageArray.count == 0)
//        hidden = NO;
    // Animations & positions
    CGFloat animationDuration = (animated ? 0.35 : 0);
    
    // Status bar
//    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
//        // Hide status bar
//        _statusBarShouldBeHidden = hidden;
//        [UIView animateWithDuration:animationDuration animations:^(void) {
//            [self setNeedsStatusBarAppearanceUpdate];
//        } completion:^(BOOL finished) {}];
//    }
    

    
    [UIView animateWithDuration:animationDuration animations:^(void) {
        CGFloat alpha = hidden == YES ? 0 : 1;
        [self.navigationController.navigationBar setAlpha:alpha];
        
    } completion:^(BOOL finished) {
        self.show = hidden == YES ? NO : YES;
        
    }];
}


#pragma mark - 布局
- (void)setupView {
    self.view.backgroundColor = [UIColor blackColor];
    
    KXPhotoBorwerScrollView *scrollView = [[KXPhotoBorwerScrollView alloc] initWithFrame:CGRectMake(0, -64, ScreenWidth, ScreenHeight + 64)];
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
        CGFloat imageY = (CGRectGetHeight(self.scrollView.frame) - imageHeight) * 0.5;
        if (imageHeight == ScreenHeight) {
            imageY = 0;
        }
        SDBrowserImageView *imageView = [[SDBrowserImageView alloc] initWithFrame:CGRectMake(index * ScreenWidth, imageY, imageWidth, imageHeight)];
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
        [self setControlsHidden:YES animated:YES];
    } else {
        [self setControlsHidden:NO animated:YES];
    }
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isShow) {
        [self setControlsHidden:YES animated:YES];
    }
    
    CGFloat result = scrollView.contentOffset.x / ScreenWidth;
    [self setCustomTitle:[NSString stringWithFormat:@"%zd/%zd",(int)result + 1 ,self.imageArray.count]];
    
    self.contentOffset = scrollView.contentOffset;
}

#pragma mark - 返回按钮
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 手势处理
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
            [self backAction];
        }
        
    }
}

@end
