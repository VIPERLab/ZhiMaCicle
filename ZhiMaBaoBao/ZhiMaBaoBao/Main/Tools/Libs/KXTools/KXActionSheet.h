//
//  KXActionSheet.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/29.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KXActionSheet;
@protocol KXActionSheetDelegate <NSObject>

- (void)KXActionSheet:(KXActionSheet *)sheet andIndex:(NSInteger)index;

@end

@interface KXActionSheet : UIView


@property (nonatomic, weak) id <KXActionSheetDelegate> delegate;

@property (nonatomic, assign) NSInteger flag;

- (void)show;

- (instancetype)initWithTitle:(NSString *)titleName cancellTitle:(NSString *)cancelTitle andOtherButtonTitles:(NSArray *)titles;


@end
