//
//  IMChatVideoTableViewCell.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseChatTableViewCell.h"
#import "PKFullScreenPlayerView.h"

@interface IMChatVideoTableViewCell : BaseChatTableViewCell{
    BOOL _isMe;
}

@property (nonatomic, strong) PKFullScreenPlayerView * playView; //视频播放view
@property (nonatomic, strong) UIButton *playBtn; // 播放按钮

- (void)reloadData:(LGMessage *)chat isMySelf:(BOOL)isMySelf tapVideoTarget:(id)target action:(SEL)action;

@end
