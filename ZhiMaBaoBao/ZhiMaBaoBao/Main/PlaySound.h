//
//  PlaySound.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/28.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface PlaySound : NSObject{
    SystemSoundID soundID;
}

//播放震动初始化
- (instancetype)initForPlayingVibrate;

//播放系统声音初始化
- (instancetype)initForPlayingSystemSoundEffectWith:(NSString *)resourceName ofType:(NSString *)type;

//播放特定的音频文件声音初始化
- (instancetype)initForPlayingSoundEffectWith:(NSString *)filename;

//播放音效
- (void)play;
@end
