//
//  YiKeyBoardView.m
//  YiIM_iOS
//
//  Created by admin on 16/5/17.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "YiKeyBoardView.h"
//#import "Utility.h"
#import <AudioToolbox/AudioServices.h>
//#import "PlaySounds.h"
#import <AVFoundation/AVFoundation.h>

@interface YiKeyBoardView()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btn1;

@end

@implementation YiKeyBoardView

+ (instancetype)keyBoardView {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}

- (void)awakeFromNib {
    self.numberTextField = [[UITextField alloc] init];
    [self.numberTextField addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    self.clipsToBounds = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"text"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TextFieldValueChanged" object:self.numberTextField];
    }
}

- (void)dealloc {
    [self.numberTextField removeObserver:self forKeyPath:@"text"];
}

- (IBAction)btn1Click:(id)sender {
    [self labelShowNumber:@"1"];
}

- (IBAction)btn2Click:(id)sender {
    [self labelShowNumber:@"2"];
}

- (IBAction)btn3Click:(id)sender {
    [self labelShowNumber:@"3"];
}

- (IBAction)btn4Click:(id)sender {
    [self labelShowNumber:@"4"];
}

- (IBAction)btn6Click:(id)sender {
    [self labelShowNumber:@"6"];
}

- (IBAction)btn5Click:(id)sender {
    [self labelShowNumber:@"5"];
}

- (IBAction)btn7Click:(id)sender {
    [self labelShowNumber:@"7"];
}

- (IBAction)btn8Click:(id)sender {
    [self labelShowNumber:@"8"];
}

- (IBAction)btn9Click:(id)sender {
    [self labelShowNumber:@"9"];
}

- (IBAction)btn0Click:(id)sender {
    [self labelShowNumber:@"0"];
}

- (IBAction)settingClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(KeyBoardView:settingBtn:)]) {
        [self.delegate KeyBoardView:self settingBtn:sender];
    }
}


- (IBAction)deleteClick:(id)sender {
    if (self.numberTextField.text.length <= 11  )
    {
        self.numberTextField.text = [self.numberTextField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];;
    }
    if ( self.numberTextField.text.length > 0 )
    {
        self.numberTextField.text = [self.numberTextField.text substringToIndex:self.numberTextField.text.length-1];
    }
}
 

- (void)labelShowNumber:(NSString *)num {
    // 13
    if (self.numberTextField.text.length >= 13) {
        return;
    }
    self.numberTextField.text = [self.numberTextField.text stringByAppendingString:num];
    
    
    /*
    if ([[Utility shareInstance].u_keyboardShake isEqualToString:@"0"])
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    if ([[Utility shareInstance].u_keyboardVoice isEqualToString:@"0"])
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
     */
    
}



@end








