//
//  UIViewx.h
//  MemoLite
//
//  Created by AllenMa on 11-10-3.
//  Copyright 2011年 AllenMa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (x)

+ (id) viewWithNib:(NSString*)nib owner:(id)owner;

- (void) offset:(CGPoint)point;

- (void) setPosition:(CGPoint)position;

- (void) setSize:(CGSize)size;

- (CGPoint) postion;

- (CGSize) size;

- (CGPoint) boundsCenter;

- (CGFloat)x;

- (CGFloat)y;

- (CGFloat)left;

- (CGFloat)top;

- (CGFloat)right;

- (CGFloat)bottom;

- (CGFloat)width;

- (CGFloat)height;

- (void)setY:(CGFloat)y;
- (void)setX:(CGFloat)x;

- (void)setWidth:(CGFloat)width;

- (void)setHeight:(CGFloat)height;

- (void)setLeft:(CGFloat)lef;

- (void)setRight:(CGFloat)right;

- (void)setTop:(CGFloat)top;

- (void)setBottom:(CGFloat)bottom;

- (void)clearSubviews;

- (void)replaceView:(UIView*)view atIndex:(int)index;

- (UIView*)viewAtIndex:(int)index;

- (void)removeViewAtIndex:(int)index;

- (void)transitionToAddSubview:(UIView*)view duration:(NSTimeInterval)duration;

- (void)transitionToRemoveFromSuperview:(NSTimeInterval)duration;

- (BOOL)pointInsideFrame:(CGPoint)location;

- (int)indexOfView:(UIView*)view;

- (UITapGestureRecognizer*)addTapGestureRecognizer:(id)target forAction:(SEL)action;

- (UILongPressGestureRecognizer*)addLongPressGestureRecognizer:(id)target forAction:(SEL)action;

- (NSString *)recursiveDescription;

- (void)layoutSubviewsInCenter;

- (id)findFirstResponder;
@end
