//
//  KXKeyBoardView.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KXKeyBoardViewDelegate <NSObject>

- (void)KXKeyBoardViewDidClickNum:(NSString *)number;

@end

@interface KXKeyBoardView : UIView

@property (nonatomic, assign) int type;

@property (nonatomic, weak) id <KXKeyBoardViewDelegate> delegate;

- (void)showAnimation;

- (void)hideAnimation;

@end
