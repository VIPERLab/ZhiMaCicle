//
//  IMMorePictureTableViewCell.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/9/27.
//  Copyright © 2016年 liugang. All rights reserved.
//

//图片cell

#import "BaseChatTableViewCell.h"
#import "LGMessage.h"
#import "ZMImageView.h"


@protocol pictureCellDelegate <NSObject>

- (void)pictureCellHeightChange:(CGFloat)height indexPath:(NSIndexPath*)index;

@end

@interface IMMorePictureTableViewCell : BaseChatTableViewCell{
    BOOL _isMe;
}

@property (nonatomic, strong) UIButton      *mainView;
@property (nonatomic, strong) ZMImageView   *picturesView;
@property (nonatomic, strong) UILabel       *botLabel;

@property (nonatomic, weak)id<pictureCellDelegate>pDelegate;

//聊天界面1V1
- (void)reloadData:(LGMessage *)chat isMySelf:(BOOL)isMySelf chousePicTarget:(id)target action:(SEL)action;

////群聊里面的
//- (void)reloadGroupData:(ChatGroup *)chatGroup isMySelf:(BOOL)isMySelf chousePicTarget:(id)target action:(SEL)action;

//+ (CGFloat)getHeightWithChat:(LGMessage *)chat TopText:(NSString *)topText nickName:(NSString *)nickName;

@end
