//
//  SDPhotoBrowser.m
//  photobrowser
//
//  Created by aier on 15-2-3.
//  Copyright (c) 2015年 aier. All rights reserved.
//

#import "SDPhotoBrowser.h"
#import "UIImageView+WebCache.h"
#import "SDBrowserImageView.h"
#import "KXActionSheet.h"

 
//  ============在这里方便配置样式相关设置===========

//                      ||
//                      ||
//                      ||
//                     \\//
//                      \/

#import "SDPhotoBrowserConfig.h"

//  =============================================

@interface SDPhotoBrowser () <KXActionSheetDelegate>

@end

@implementation SDPhotoBrowser 
{
    UIScrollView *_scrollView;
    BOOL _hasShowedFistView;
    UILabel *_indexLabel;
    UIButton *_saveButton;
    UIActivityIndicatorView *_indicatorView;
    BOOL _willDisappear;
    KXActionSheet *_actionSheet;
    UILongPressGestureRecognizer *_longPressGesture;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = SDPhotoBrowserBackgrounColor;
    }
    return self;
}


- (void)didMoveToSuperview
{
    [self setupScrollView];
    
    [self setupToolbars];
}

- (void)setType:(int)type {
    _type = type;
    if (type == 0) {
        int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
        UIImageView *currentImageView = _scrollView.subviews[index];
        [currentImageView removeGestureRecognizer:_longPressGesture];
    }
}

- (void)dealloc
{
    [[UIApplication sharedApplication].keyWindow removeObserver:self forKeyPath:@"frame"];
}

- (void)setupToolbars
{
    // 1. 序标
    UILabel *indexLabel = [[UILabel alloc] init];
    indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = [UIFont boldSystemFontOfSize:20];
    indexLabel.backgroundColor = [UIColor clearColor];
    indexLabel.layer.cornerRadius = indexLabel.bounds.size.height * 0.5;
    indexLabel.clipsToBounds = YES;
    if (self.imageCount > 1) {
        indexLabel.text = [NSString stringWithFormat:@"1/%ld", (long)self.imageCount];
    } else {
        indexLabel.hidden = YES;
    }
    _indexLabel = indexLabel;
    [self addSubview:indexLabel];
    
}

// 收藏图片
- (void)collectionImage {
    if (!self.userId.length) {
        [LCProgressHUD showFailureText:@"收藏失败"];
        return;
    }
    int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
    NSURL *url = [self highQualityImageURLForIndex:index];
    NSString *str = url.absoluteString;
    
    if (self.fcId.length) {
        [LGNetWorking collectionCircleListWithCollectionType:3 andSessionId:USERINFO.sessionId andConent:@"" andSmallImg:@"" andBigImage:str andSource:@"" andAccount:self.userId andMsgId:@"" andFcId:self.fcId andUsertype:@"4" success:^(ResponseData *responseData) {
            if (responseData.code != 0) {
                [LCProgressHUD showFailureText:@"收藏失败"];
                return ;
            }
            [LCProgressHUD showSuccessText:@"收藏成功"];
        } failure:^(ErrorData *error) {
            
        }];
    } else if (self.msgId.length) {
#warning 这里的userType 需要判断
        [LGNetWorking collectionCircleListWithCollectionType:3 andSessionId:USERINFO.sessionId andConent:@"" andSmallImg:@"" andBigImage:str andSource:@"" andAccount:self.userId andMsgId:self.msgId andFcId:@"" andUsertype:@"1" success:^(ResponseData *responseData) {
            if (responseData.code != 0) {
                [LCProgressHUD showFailureText:@"收藏失败"];
                return ;
            }
            [LCProgressHUD showSuccessText:@"收藏成功"];
        } failure:^(ErrorData *error) {
            
        }];
    }
    
    
}

- (void)notinceQRCode {
    int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
    SDBrowserImageView *tempImageView = _scrollView.subviews[index];
    NSLog(@"%@",tempImageView.image);
    
    
    
    if(tempImageView.image){
        //1. 初始化扫描仪，设置设别类型和识别质量
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
        //2. 扫描获取的特征组
        NSArray *features = [detector featuresInImage:tempImageView.image.CIImage];
        //3. 获取扫描结果
        for (CIQRCodeFeature *qrCodeFeature in features) {
            NSString *scannedResult = qrCodeFeature.messageString;
            NSLog(@"%@",scannedResult);
        }
//        CIQRCodeFeature *feature = [features objectAtIndex:0];
//        
//        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:scannedResult delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
    }else {
        
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:@"您还没有生成二维码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}


// 保存图片
- (void)saveImage
{
    int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
    UIImageView *currentImageView = _scrollView.subviews[index];
    
    UIImageWriteToSavedPhotosAlbum(currentImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.center;
    _indicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    [_indicatorView removeFromSuperview];
    
//    UILabel *label = [[UILabel alloc] init];
//    label.textColor = [UIColor whiteColor];
//    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
//    label.layer.cornerRadius = 5;
//    label.clipsToBounds = YES;
//    label.bounds = CGRectMake(0, 0, 150, 30);
//    label.center = self.center;
//    label.textAlignment = NSTextAlignmentCenter;
//    label.font = [UIFont boldSystemFontOfSize:17];
//    [[UIApplication sharedApplication].keyWindow addSubview:label];
//    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
    if (error) {
//        label.text = SDPhotoBrowserSaveImageFailText;
        [LCProgressHUD showFailureText:@"保存失败"];
    }   else {
        [LCProgressHUD showSuccessText:@"保存到系统相册"];
//        label.text = SDPhotoBrowserSaveImageSuccessText;
    }
//    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}

- (void)setupScrollView
{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    [self addSubview:_scrollView];
    
    for (int i = 0; i < self.imageCount; i++) {
        SDBrowserImageView *imageView = [[SDBrowserImageView alloc] init];
        imageView.tag = i;

        // 单击图片
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoClick:)];
        
        // 双击放大图片
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDoubleTaped:)];
        doubleTap.numberOfTapsRequired = 2;
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
//        if (_type != 1) { // 收藏专用
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressPhoto:)];
        [imageView addGestureRecognizer:_longPressGesture];
//        }
        
        [imageView addGestureRecognizer:singleTap];
        [imageView addGestureRecognizer:doubleTap];
        
        [_scrollView addSubview:imageView];
    }
    
    [self setupImageOfImageViewForIndex:self.currentImageIndex];
    
}

// 加载图片
- (void)setupImageOfImageViewForIndex:(NSInteger)index
{
    SDBrowserImageView *imageView = _scrollView.subviews[index];
    self.currentImageIndex = index;
    if (imageView.hasLoadedImage) return;
    if ([self highQualityImageURLForIndex:index]) {
        [imageView setImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:[self placeholderImageForIndex:index]];
    } else {
        imageView.image = [self placeholderImageForIndex:index];
    }
    imageView.hasLoadedImage = YES;
}

- (void)photoClick:(UITapGestureRecognizer *)recognizer
{
    _scrollView.hidden = YES;
    _willDisappear = YES;
    
    SDBrowserImageView *currentImageView = (SDBrowserImageView *)recognizer.view;
    NSInteger currentIndex = currentImageView.tag;
    
    UIView *sourceView = self.sourceImagesContainerView.subviews[currentIndex];
    CGRect targetTemp = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.contentMode = sourceView.contentMode;
    tempView.clipsToBounds = YES;
    tempView.image = currentImageView.image;
    CGFloat h = (self.bounds.size.width / currentImageView.image.size.width) * currentImageView.image.size.height;
    
    if (!currentImageView.image) { // 防止 因imageview的image加载失败 导致 崩溃
        h = self.bounds.size.height;
    }
    
    tempView.bounds = CGRectMake(0, 0, self.bounds.size.width, h);
    tempView.center = self.center;
    
    [self addSubview:tempView];

    _saveButton.hidden = YES;
    [UIView animateWithDuration:SDPhotoBrowserHideImageAnimationDuration animations:^{
        if (self.isChat) {
//            tempView.frame = CGRectMake(ScreenWidth/2, ScreenHeight/2, 0, 0);
            
//            tempView.frameSize = CGSizeMake(tempView.frameSize.width*1.5, tempView.frameSize.height*1.5);
//            tempView.center = self.center;
            tempView.alpha = 0;

        }else{
            tempView.frame = targetTemp;
        }
        self.backgroundColor = [UIColor clearColor];
        _indexLabel.alpha = 0.1;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];

        if (self.isChat && [self.delegate respondsToSelector:@selector(finishedWatch)]) {
            [self.delegate finishedWatch];
        }
    }];
}

- (void)imageViewDoubleTaped:(UITapGestureRecognizer *)recognizer
{
    SDBrowserImageView *imageView = (SDBrowserImageView *)recognizer.view;
    CGFloat scale;
    if (imageView.isScaled) {
        scale = 1.0;
    } else {
        scale = 2.0;
    }
    
    SDBrowserImageView *view = (SDBrowserImageView *)recognizer.view;

    [view doubleTapToZommWithScale:scale];
}


- (void)longPressPhoto:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        KXActionSheet *sheet;
        if (self.type == 0) {
            sheet = [[KXActionSheet alloc] initWithTitle:@"" cancellTitle:@"取消" andOtherButtonTitles:@[@"转发给朋友", @"保存图片",@"收藏"]];
            sheet.tag = 10;
        } else {
            sheet = [[KXActionSheet alloc] initWithTitle:@"" cancellTitle:@"取消" andOtherButtonTitles:@[@"转发给朋友", @"保存图片"]];
            sheet.tag = 100;
        }
        
        sheet.delegate = self;
        [sheet show];
    }
}


- (void)KXActionSheet:(KXActionSheet *)sheet andIndex:(NSInteger)buttonIndex {
    if (sheet.tag == 10) {
        if (buttonIndex == 0) {   //转发给朋友
            int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"imageUrl"] = [[self highQualityImageURLForIndex:index] absoluteString];
            [[NSNotificationCenter defaultCenter] postNotificationName:K_ForwardPhotoNotifation object:nil userInfo:params];
        } else if (buttonIndex == 1) { // 保存图片
            [self saveImage];
        } else if (buttonIndex == 2) { // 收藏图片
            [self collectionImage];
        } else if (buttonIndex == 3) { // 取消
            
        }
    } else if (sheet.tag == 100){
        if (buttonIndex == 0) {   //转发给朋友
            int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"imageUrl"] = [[self highQualityImageURLForIndex:index] absoluteString];
            [[NSNotificationCenter defaultCenter] postNotificationName:K_ForwardPhotoNotifation object:nil userInfo:params];
        } else if (buttonIndex == 1) { // 保存图片
            [self saveImage];
        } else if (buttonIndex == 2) { // 
            
        }
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.size.width += SDPhotoBrowserImageViewMargin * 2;
    
    _scrollView.bounds = rect;
    _scrollView.center = self.center;
    
    CGFloat y = 0;
    CGFloat w = _scrollView.frame.size.width - SDPhotoBrowserImageViewMargin * 2;
    CGFloat h = _scrollView.frame.size.height;
    
    
    
    [_scrollView.subviews enumerateObjectsUsingBlock:^(SDBrowserImageView *obj, NSUInteger idx, BOOL *stop) {
        CGFloat x = SDPhotoBrowserImageViewMargin + idx * (SDPhotoBrowserImageViewMargin * 2 + w);
        obj.frame = CGRectMake(x, y, w, h);
    }];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.subviews.count * _scrollView.frame.size.width, 0);
    _scrollView.contentOffset = CGPointMake(self.currentImageIndex * _scrollView.frame.size.width, 0);
    
    
    if (!_hasShowedFistView) {
        [self showFirstImage];
    }
    
    _indexLabel.center = CGPointMake(self.bounds.size.width * 0.5, 35);
    _saveButton.frame = CGRectMake(30, self.bounds.size.height - 70, 50, 25);
}

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.frame = window.bounds;
    [window addObserver:self forKeyPath:@"frame" options:0 context:nil];
    [window addSubview:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIView *)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        self.frame = object.bounds;
        SDBrowserImageView *currentImageView = _scrollView.subviews[_currentImageIndex];
        if ([currentImageView isKindOfClass:[SDBrowserImageView class]]) {
            [currentImageView clear];
        }
    }
}

- (void)showFirstImage
{
    UIView *sourceView = self.sourceImagesContainerView.subviews[self.currentImageIndex];
    CGRect rect = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.image = [self placeholderImageForIndex:self.currentImageIndex];
    
    [self addSubview:tempView];
    
    CGRect targetTemp = [_scrollView.subviews[self.currentImageIndex] bounds];
    
    tempView.frame = rect;
    tempView.contentMode = [_scrollView.subviews[self.currentImageIndex] contentMode];
    _scrollView.hidden = YES;
    
    
    [UIView animateWithDuration:SDPhotoBrowserShowImageAnimationDuration animations:^{
        tempView.center = self.center;
        tempView.bounds = (CGRect){CGPointZero, targetTemp.size};
    } completion:^(BOOL finished) {
        _hasShowedFistView = YES;
        [tempView removeFromSuperview];
        _scrollView.hidden = NO;
    }];
}

- (UIImage *)placeholderImageForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [self.delegate photoBrowser:self placeholderImageForIndex:index];
    }
    return nil;
}

- (NSURL *)highQualityImageURLForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)]) {
        return [self.delegate photoBrowser:self highQualityImageURLForIndex:index];
    }
    return nil;
}

#pragma mark - scrollview代理方法

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = (scrollView.contentOffset.x + _scrollView.bounds.size.width * 0.5) / _scrollView.bounds.size.width;
    
    // 有过缩放的图片在拖动一定距离后清除缩放
    CGFloat margin = 150;
    CGFloat x = scrollView.contentOffset.x;
    if ((x - index * self.bounds.size.width) > margin || (x - index * self.bounds.size.width) < - margin) {
        SDBrowserImageView *imageView = _scrollView.subviews[index];
        if (imageView.isScaled) {
            [UIView animateWithDuration:0.5 animations:^{
                imageView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [imageView eliminateScale];
            }];
        }
    }
    
    
    if (!_willDisappear) {
        _indexLabel.text = [NSString stringWithFormat:@"%d/%ld", index + 1, (long)self.imageCount];
    }
    [self setupImageOfImageViewForIndex:index];
}



@end
