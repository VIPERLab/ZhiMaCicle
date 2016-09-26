//
//  RecordingView.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/22.
//  Copyright © 2016年 liugang. All rights reserved.
//

typedef NS_ENUM(NSInteger, RecordHUDStatus) {
    RecordHUDStatusCancel,          //取消发送
    RecordHUDStatusContinue,        //继续录音
    RecordHUDStatusVoiceChange      //音量改变
};

#import <UIKit/UIKit.h>

@interface RecordingHUD : UIImageView

+ (instancetype)recording;

+ (void)show;

+ (void)dismiss;

//显示录音时间太短
+ (void)showRecordShort;

//根据状态改变显示内容 value:音量大小（0~1)
+ (void)updateStatues:(RecordHUDStatus)statues value:(double)volum;

@end
