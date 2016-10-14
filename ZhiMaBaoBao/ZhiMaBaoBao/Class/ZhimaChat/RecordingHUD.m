//
//  RecordingView.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/22.
//  Copyright © 2016年 liugang. All rights reserved.
//  录音时显示的HUD

#import "RecordingHUD.h"

static RecordingHUD *recordHUD = nil;

@interface RecordingHUD()
@property (nonatomic, strong) UIImageView *macImgView;
@property (nonatomic, strong) UIImageView *voiceImgView;
@property (nonatomic, strong) UIImageView *cancelImgView;
@property (nonatomic, strong) UILabel *noticeLabel;

@end

@implementation RecordingHUD

+ (instancetype)recording{
    if (!recordHUD) {
        //屏幕中央
        CGRect rect  = CGRectMake((DEVICEWITH - 180)/2, (DEVICEHIGHT - 190)/2, 180, 190);
        recordHUD = [[self alloc] initWithFrame:rect];
    }
    return recordHUD;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews{
    //背景
    self.image = [UIImage imageNamed:@"record_bg"];
    
    //取消视图
    UIImageView *cancelImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RecordCancel"]];
    cancelImgView.left = 40;
    cancelImgView.top = 30;
    [self addSubview:cancelImgView];
    self.cancelImgView = cancelImgView;
    self.cancelImgView.hidden = YES;
    
    //麦克风试图
    UIImageView *macImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RecordingBkg"]];
    macImgView.left = 40;
    macImgView.top = 30;
    [self addSubview:macImgView];
    self.macImgView = macImgView;
    
    //音量试图
    UIImageView *voiceImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RecordingSignal001"]];
    voiceImgView.top = 57;
    voiceImgView.left = 105;
    [self addSubview:voiceImgView];
    self.voiceImgView = voiceImgView;
    
    //提示文字
    UILabel *noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 145, 150, 30)];
    noticeLabel.text = @"手指上滑，取消发送";
    noticeLabel.textColor = WHITECOLOR;
    noticeLabel.layer.cornerRadius = 4.f;
    noticeLabel.clipsToBounds = YES;
    noticeLabel.font = [UIFont systemFontOfSize:14];
    noticeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:noticeLabel];
    self.noticeLabel = noticeLabel;
}
+ (void)show{
    recordHUD  = [RecordingHUD recording];
    
    //添加到windows上面
    UIWindow *keywindow = [UIApplication sharedApplication].keyWindow;
    [keywindow addSubview:recordHUD];
}

//显示录音时间太短
+ (void)showRecordShort{
    recordHUD = [RecordingHUD recording];
    
    recordHUD.macImgView.hidden = YES;
    recordHUD.voiceImgView.hidden = YES;
    recordHUD.cancelImgView.hidden = NO;
    recordHUD.cancelImgView.image = [UIImage imageNamed:@"RecordShort"];
    recordHUD.noticeLabel.text = @"说话时间太短";
    
    //添加到windows上面
    UIWindow *keywindow = [UIApplication sharedApplication].keyWindow;
    [keywindow addSubview:recordHUD];
}

+ (void)dismiss{
    [recordHUD removeFromSuperview];
    recordHUD = nil;
}

//更改显示内容
+ (void)updateStatues:(RecordHUDStatus)statues value:(double)volum{
    recordHUD  = [RecordingHUD recording];
    
    //取消发送
    if (statues == RecordHUDStatusCancel) {
        recordHUD.cancelImgView.hidden = NO;
        recordHUD.macImgView.hidden = YES;
        recordHUD.voiceImgView.hidden = YES;
        recordHUD.noticeLabel.text = @"松开手指，取消发送";
        recordHUD.noticeLabel.backgroundColor = THEMECOLOR;
    }
    //继续发送
    else if (statues == RecordHUDStatusContinue){
        recordHUD.cancelImgView.hidden = YES;
        recordHUD.macImgView.hidden = NO;
        recordHUD.voiceImgView.hidden = NO;
        recordHUD.noticeLabel.text = @"手指上滑，取消发送";
        recordHUD.noticeLabel.backgroundColor = [UIColor clearColor];
    }
    //音量改变
    else if (statues == RecordHUDStatusVoiceChange){
        //音量图片名下标
        NSInteger count = 1;
        if (volum < 0.1) {
            count = 1;
        }else if (volum >= 0.1 && volum < 0.15){
            count = 2;
        }else if (volum >= 0.15 && volum < 0.3){
            count = 3;
        }else if (volum >= 0.3 && volum < 0.4){
            count = 4;
        }else if (volum >= 0.4 && volum < 0.55){
            count = 5;
        }else if (volum >= 0.55 && volum < 0.6){
            count = 6;
        }else if (volum >= 0.6 && volum < 0.7){
            count = 7;
        }else if (volum >= 0.7 && volum <=1.0){
            count = 8;
        }
        
        NSString *imageName = [NSString stringWithFormat:@"RecordingSignal00%ld",(long)count];
        recordHUD.voiceImgView.image = [UIImage imageNamed:imageName];
    }
}

@end
