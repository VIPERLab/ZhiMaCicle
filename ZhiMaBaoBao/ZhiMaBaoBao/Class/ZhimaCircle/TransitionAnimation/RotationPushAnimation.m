//
//  RotationPushAnimation.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/11/10.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "RotationPushAnimation.h"

@implementation RotationPushAnimation

//动画的时间
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 1.5f;
}


//在进行切换的时候将调用该方法，我们对于切换时的UIView的设置和动画都在这个方法中完成。
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    //toView
    UIViewController *toView = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toView.view.alpha = 0.0f;
    
    
    //获取rect
    CGRect finailRect = [transitionContext finalFrameForViewController:toView];
    NSLog(@"%@",NSStringFromCGRect(finailRect));
    
    toView.view.frame = CGRectOffset(finailRect, [UIScreen mainScreen].bounds.size.width, 0);
    
    
    //中转view
    [[transitionContext containerView] addSubview:toView.view];
    
    [UIView animateWithDuration:0.6 animations:^{
        toView.view.frame = CGRectMake(0, 0, finailRect.size.width, finailRect.size.height);
        toView.view.alpha = 1.0f;
        toView.tabBarController.tabBar.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
    
//    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
//        
//        
//    } completion:^(BOOL finished) {
//        
//        
//        
//    }];
}

@end
