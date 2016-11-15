//
//  RotationPushAnimation.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/11/10.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "CallPresendAnimation.h"

@implementation CallPresendAnimation

//动画的时间
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.8f;
}


//在进行切换的时候将调用该方法，我们对于切换时的UIView的设置和动画都在这个方法中完成。
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    //toView
    UIViewController *toView = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toView.view.alpha = 0.0f;
    
    //获取rect
    CGRect finailRect = [transitionContext finalFrameForViewController:toView];
    
    toView.view.frame = CGRectOffset(finailRect, 0, [UIScreen mainScreen].bounds.size.height * 0.5 );
    
    //中转view
    [[transitionContext containerView] addSubview:toView.view];
    
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        toView.view.frame = finailRect;
        toView.view.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:YES];
        
    }];
}

@end
