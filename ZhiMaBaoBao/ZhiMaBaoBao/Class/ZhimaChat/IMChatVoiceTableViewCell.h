//
//  IMChatVoiceTableViewCell.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/9/27.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseChatTableViewCell.h"

#define BubbleMaxWidth   145

@protocol VoiceCelldelegate <NSObject>

- (void)deleteTextComplete;
- (void)onPlayBtn:(id)sender;

@end

@interface IMChatVoiceTableViewCell : BaseChatTableViewCell

@property (nonatomic, retain) UIButton  *btnBg;
@property (nonatomic, retain) UILabel   *lblTime;
@property (nonatomic, retain) NSString  *lblDownloadAdd;
@property (nonatomic, retain) NSString  *lblPlayAdd;
@property (nonatomic, strong) NSString  *voiceTimeLength;   //语音时长
@property (nonatomic, strong) UILabel   *voiceLengthLabel;  //语音时长的Label
@property (nonatomic, strong) UIView    *badgedView;        //标记是否已读：红色点点
@property (nonatomic, strong) UIButton  *playVoiceBtn;      //播放按钮

@property (nonatomic, assign) BOOL      isReadVoice;        //语音是否已阅

@property (assign,nonatomic)id <VoiceCelldelegate> voiceDelegate;

+ (CGFloat)getHeightWithTopText:(NSString *)topText nickName:(NSString *)nickName;


@end
