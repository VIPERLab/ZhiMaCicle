//
//  IMChatVideoTableViewCell.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseChatTableViewCell.h"
#import "PKFullScreenPlayerView.h"
#import "HKPieChartView.h"

@protocol VideoCellDelegate <NSObject>

- (void)goToDownloadVideo:(NSIndexPath*)index;

@end

@interface IMChatVideoTableViewCell : BaseChatTableViewCell{
    BOOL _isMe;
}

@property (nonatomic, strong) PKFullScreenPlayerView * playView; //视频播放view
@property (nonatomic, strong) UIButton *playBtn; // 播放按钮
@property (nonatomic, strong) HKPieChartView *progressView; // 进度圈
@property (nonatomic, strong) UIImageView *holderIV; // 视频未下载前显示视频的第一帧图片
@property (nonatomic, weak) id<VideoCellDelegate>VDelegate;

- (void)reloadData:(LGMessage *)chat isMySelf:(BOOL)isMySelf tapVideoTarget:(id)target action:(SEL)action;
- (void)setProgressWithContent:(CGFloat)progress;

@end
