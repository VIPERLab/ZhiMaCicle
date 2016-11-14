//
//  CallDismissAnimation.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/11/14.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "CallDismissAnimation.h"

@implementation CallDismissAnimation

//动画的时间
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 1.2f;
}

//在进行切换的时候将调用该方法，我们对于切换时的UIView的设置和动画都在这个方法中完成。
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    //toView
    UIViewController * toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController * fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    fromVC.view.alpha = 1.0f;
    
    //获取rect
    CGRect finailRect = [transitionContext finalFrameForViewController:fromVC];
    NSLog(@"%@",NSStringFromCGRect(finailRect));
    
    
    
    //中转view
    UIView * tempView = [transitionContext containerView];
    [tempView addSubview:toVC.view];
    [tempView bringSubviewToFront:fromVC.view];
    
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        fromVC.view.frame = finailRect;
        fromVC.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:YES];
        
    }];
}

@end
