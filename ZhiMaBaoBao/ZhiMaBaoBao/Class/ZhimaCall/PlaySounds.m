//
//  PlaySounds.m
//
//  Created by Apple on 16/6/2.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "PlaySounds.h"
#import <AVFoundation/AVFoundation.h>

@implementation PlaySounds

static NSMutableDictionary *_soundIDs;

+ (void)initialize
{
    _soundIDs = [NSMutableDictionary dictionary];
}

+ (void)playSoundsWithSoundName:(NSString *)soundName
{
    
    SystemSoundID soundID = 0;
    
    soundID = [_soundIDs[soundName] unsignedIntValue];
    if (soundID == 0) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:soundName withExtension:nil];
        CFURLRef urlRef = (__bridge CFURLRef)(url);
        
        if (urlRef == NULL) {
            return;
        }
        
        AudioServicesCreateSystemSoundID(urlRef, &soundID);
        
        [_soundIDs setObject:@(soundID) forKey:soundName];
        
    }
    // 不会震动
    AudioServicesPlaySystemSound(soundID);
    // 会震动
//    AudioServicesPlayAlertSound(soundID);
}

@end






