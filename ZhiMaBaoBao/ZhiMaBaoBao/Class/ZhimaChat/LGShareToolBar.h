//
//  LGShareToolBar.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/11/2.
//  Copyright © 2016年 liugang. All rights reserved.
//

//按钮类型
typedef NS_OPTIONS(NSUInteger, ShareButtonType){
    ShareButtonTypeToFriend = 0,       // 发送给朋友
    ShareButtonTypeToTimeLine ,        // 分享到朋友圈
    ShareButtonTypeKeep,               // 收藏
    ShareButtonTypeLookService,         //查看服务号
    ShareButtonTypeCopyLink,            //复制链接
    ShareButtonTypeAdjustFont,          //调整字体
    ShareButtonTypeComplaint            //投诉
};

#import <UIKit/UIKit.h>

@protocol LGShareBarDelegate <NSObject>

- (void)shareAction:(ShareButtonType)btnType;

@end

@interface LGShareToolBar : UIView

@property (nonatomic, assign) id<LGShareBarDelegate> delegate;

+ (instancetype)shareInstance;

- (void)show;
@end
