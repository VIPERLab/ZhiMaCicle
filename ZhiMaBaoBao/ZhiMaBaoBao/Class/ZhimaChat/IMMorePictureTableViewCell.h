//
//  IMMorePictureTableViewCell.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/9/27.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseChatTableViewCell.h"
#import "LGMessage.h"

@interface IMMorePictureTableViewCell : BaseChatTableViewCell{
    BOOL _isMe;
}

@property (nonatomic, strong) UIButton      *mainView;
@property (nonatomic, strong) UIImageView   *picturesView;
@property (nonatomic, strong) UILabel       *botLabel;

//聊天界面1V1
- (void)reloadData:(LGMessage *)chat isMySelf:(BOOL)isMySelf chousePicTarget:(id)target action:(SEL)action;

////群聊里面的
//- (void)reloadGroupData:(ChatGroup *)chatGroup isMySelf:(BOOL)isMySelf chousePicTarget:(id)target action:(SEL)action;

//+ (CGFloat)getHeightWithChat:(LGMessage *)chat TopText:(NSString *)topText nickName:(NSString *)nickName;

@end
