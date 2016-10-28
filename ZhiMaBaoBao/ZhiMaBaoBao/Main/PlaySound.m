//
//  PlaySound.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/28.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "PlaySound.h"

@implementation PlaySound

- (instancetype)initForPlayingVibrate{
    self = [super init];
    if (self) {
        soundID = kSystemSoundID_Vibrate;
    }
    return self;
}

- (instancetype)initForPlayingSystemSoundEffectWith:(NSString *)resourceName ofType:(NSString *)type{
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] pathForResource:@"sms-received1" ofType:@"caf"];
        if (path) {
            SystemSoundID theSoundID;
            OSStatus error =  AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &theSoundID);
            if (error == kAudioServicesNoError) {
                soundID = theSoundID;
            }else {
                NSLog(@"Failed to create sound ");
            }
        }
    }
    return self;
}

- (instancetype)initForPlayingSoundEffectWith:(NSString *)filename{
    self = [super init];
    if (self) {
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
        if (fileURL != nil) {
            SystemSoundID theSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &theSoundID);
            if (error == kAudioServicesNoError){
               soundID = theSoundID;
            }else {
                NSLog(@"Failed to create sound ");
            }
        }
    }
    return self;
}

- (void)play{
    AudioServicesPlaySystemSound(soundID);
}

- (void)dealloc{
    AudioServicesDisposeSystemSoundID(soundID);
}
@end
