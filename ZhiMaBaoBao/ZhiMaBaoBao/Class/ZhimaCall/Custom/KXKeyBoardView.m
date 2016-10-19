//
//  KXKeyBoardView.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "KXKeyBoardView.h"
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import "PlaySounds.h"

@interface KXKeyBoardView ()

@property (nonatomic, strong) NSMutableArray *buttonArray;

@end

@implementation KXKeyBoardView {
    NSString *_numberText;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    _numberText = [NSString string];
    for (NSInteger index = 0; index < 12; index++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = index;
        [self.buttonArray addObject:button];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%zd",index +1 ]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%zd_selected",index +1 ]] forState:UIControlStateHighlighted];
        [self addSubview:button];
        
        if (index == 10) {
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%zd",0 ]] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%zd_selected",0 ]] forState:UIControlStateHighlighted];
        }
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    CGFloat sss = 624.0/750.0; //键盘的款高比
    CGFloat height = DEVICEWITH*sss;
    
    for (UIButton *button in self.buttonArray) {
        int index = (int)button.tag;
        
        NSInteger row =  index % 3;  //行
        NSInteger line = index / 3;  //列
        //        NSLog(@"行%zd --  列%zd",line,row);
        
        CGFloat buttonW = ScreenWidth / 3;
        CGFloat buttonHeight = height / 4;
        CGFloat buttonX = buttonW * row;
        CGFloat buttonY = buttonHeight * line + ScreenHeight * 0.5;
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonHeight);
    }
    
}


- (void)buttonDidClick:(UIButton *)sender {
    if (sender.tag == 9 || sender.tag == 11) { // 最后一行有2个不需要操作
        return;
    }
    
    [self labelShowNumber:[NSString stringWithFormat:@"%zd",sender.tag + 1]];
}

- (void)layoutSubviews {
    
}

- (void)labelShowNumber:(NSString *)num {
    
    if (USERINFO.isKeyboardShake)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    if (USERINFO.isKeyboardVoice)
    {
        if ([num isEqualToString:@"0"]){
            [PlaySounds playSoundsWithSoundName:@"dtmf-0.aif"];
        }
        
        else if ([num isEqualToString:@"1"]){
            [PlaySounds playSoundsWithSoundName:@"dtmf-1.aif"];
        }
        else if ([num isEqualToString:@"2"]){
            [PlaySounds playSoundsWithSoundName:@"dtmf-2.aif"];
        }
        else if ([num isEqualToString:@"3"]){
            [PlaySounds playSoundsWithSoundName:@"dtmf-3.aif"];
        }
        else if ([num isEqualToString:@"4"]){
            [PlaySounds playSoundsWithSoundName:@"dtmf-4.aif"];
        }
        else if ([num isEqualToString:@"5"]){
            [PlaySounds playSoundsWithSoundName:@"dtmf-5.aif"];
        }
        else if ([num isEqualToString:@"6"]){
            [PlaySounds playSoundsWithSoundName:@"dtmf-6.aif"];
        }
        else if ([num isEqualToString:@"7"]){
            [PlaySounds playSoundsWithSoundName:@"dtmf-7.aif"];
        }
        else if ([num isEqualToString:@"8"]){
            [PlaySounds playSoundsWithSoundName:@"dtmf-8.aif"];
        }
        else if ([num isEqualToString:@"9"]){
            [PlaySounds playSoundsWithSoundName:@"dtmf-9.aif"];
        }
        else if ([num isEqualToString:@"*"]){
            [PlaySounds playSoundsWithSoundName:@"dtmf-1.aif"];
        }
        else if ([num isEqualToString:@"#"]){
            [PlaySounds playSoundsWithSoundName:@"dtmf-1.aif"];
        }
    }
    
    
    if ([self.delegate respondsToSelector:@selector(KXKeyBoardViewDidClickNum:)]) {
        [self.delegate KXKeyBoardViewDidClickNum:num];
    }
}

- (void)showAnimation {
    for (UIButton *button in self.buttonArray) {
        CGRect rect = button.frame;
        [UIView animateWithDuration:0.3 delay:button.tag * 0.05 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            button.frame = CGRectMake(rect.origin.x, rect.origin.y - ScreenHeight * 0.5, rect.size.width, rect.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)hideAnimation {
    for (NSInteger index = self.buttonArray.count - 1; index < 0; index--) {
        UIButton *button = self.buttonArray[index];
        CGRect rect = button.frame;
        [UIView animateWithDuration:0.2 delay:button.tag * 0.05 options:UIViewAnimationOptionCurveEaseOut animations:^{
            button.frame = CGRectMake(rect.origin.x, rect.origin.y + ScreenHeight * 0.5, rect.size.width, rect.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (NSMutableArray *)buttonArray {
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}

@end
