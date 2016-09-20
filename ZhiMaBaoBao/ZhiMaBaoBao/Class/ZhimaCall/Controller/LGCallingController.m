//
//  LGCallingControllerViewController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/9.
//  Copyright © 2016年 ikantech. All rights reserved.
//  正在通话页

#import "LGCallingController.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "LYVoIP.h"
#import "LYResponseModel.h"
#import "NSString+MD5.h"
#import "LGCallingController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface LGCallingController ()
@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, strong) UIButton *noVoice;
@property (nonatomic, strong) UIButton *voice;
@property (nonatomic, strong) UILabel *noVoiceL;
@property (nonatomic, strong) UILabel *voiceL;
@property (nonatomic, strong) UIImageView *smallAvtar;
@property (nonatomic, strong) UIImageView *point;
@property (nonatomic, strong) UIImageView *phoneIcon;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *bigLabel;

@property (nonatomic, strong) CTCallCenter *callCenter;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) long long startTime; //通话开始时间戳
@property (nonatomic, assign) long long endTime;   //通话结束时间戳

@end

@implementation LGCallingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = BGCOLOR;

    NSURL *audioUrl = [[NSBundle mainBundle] URLForResource:@"ring.mp3" withExtension:nil];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:nil];
    [self.player prepareToPlay];
    
    self.callCenter = [[CTCallCenter alloc] init];
    __weak LGCallingController *weakSelf = self;
    __weak AVAudioPlayer *weakPlayer = self.player;

    self.callCenter.callEventHandler = ^(CTCall *call){
        NSLog(@"call:%@",call.description);
        if ([call.callState isEqualToString:@"CTCallStateDialing"]) {
            
            //正在呼叫状态
        }
        else if ([call.callState isEqualToString:@"CTCallStateDisconnected"]) {
            //断开连接状态
            
            //执行挂断操作
            [weakSelf handUpDo];

        }
        else if([call.callState isEqualToString:CTCallStateIncoming])
        {
            //来电话了
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            [weakPlayer stop];
            //计算开始时间
            NSDate *date = [NSDate date];
            weakSelf.startTime = date.timeIntervalSince1970*1000;

        }
    };
    

    //背景
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgView.userInteractionEnabled = YES;
    bgView.image = [UIImage imageNamed:@"callbg2"];
    [self.view addSubview:bgView];
    self.bgView = bgView;
    
    //头像
    UIImageView *avtar = [[UIImageView alloc] initWithFrame:CGRectMake((DEVICEWITH - 90)/2, 39, 90, 90)];
    avtar.image = [UIImage imageNamed:@"形状-1@3x"];
    [self.view addSubview:avtar];
    
    //姓名
    UILabel *name = [[UILabel alloc] init];
    name.textAlignment = NSTextAlignmentCenter;
    name.textColor = WHITECOLOR;
    name.font = MAINFONT;
    name.text = self.name;
    [self.view addSubview:name];
    
    [name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(avtar.mas_bottom).mas_offset(42);
    }];
    
    //电话
    UILabel *phone = [[UILabel alloc] init];
    phone.textAlignment = NSTextAlignmentCenter;
    phone.textColor = WHITECOLOR;
    phone.font = MAINFONT;
    phone.text = self.phoneNum;
    [self.view addSubview:phone];
    
    [phone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(name.mas_bottom).mas_offset(18);
    }];
    
    //静音
    UIButton *noVoice = [[UIButton alloc] init];
    [noVoice setImage:[UIImage imageNamed:@"静音"] forState:UIControlStateNormal];
    [noVoice addTarget:self action:@selector(noVoiceAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:noVoice];
    self.noVoice = noVoice;
    
    UILabel *noVoiceL = [[UILabel alloc] init];
    noVoiceL.text = @"静音";
    noVoiceL.textColor = WHITECOLOR;
    noVoiceL.textAlignment = NSTextAlignmentCenter;
    noVoiceL.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:noVoiceL];
    self.noVoiceL = noVoiceL;
    
    //免提
    UIButton *voice = [[UIButton alloc] init];
    [voice setImage:[UIImage imageNamed:@"椭圆-3-拷贝"] forState:UIControlStateNormal];
    [voice addTarget:self action:@selector(voiceAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:voice];
    self.voice = voice;
    
    UILabel *voiceL = [[UILabel alloc] init];
    voiceL.text = @"免提";
    voiceL.textColor = WHITECOLOR;
    voiceL.textAlignment = NSTextAlignmentCenter;
    voiceL.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:voiceL];
    self.voiceL = voiceL;
    
    //挂断
    UIButton *cancel = [[UIButton alloc] init];
    [cancel setImage:[UIImage imageNamed:@"接通中_挂断"] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancel];
    
    
    //电话接通中的三个控件
    UIImageView *smallAvtar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"联系人-拷贝"]];
    [self.view addSubview:smallAvtar];
    self.smallAvtar = smallAvtar;
    
    UIImageView *point = [[UIImageView alloc] init];
    [self.view addSubview:point];
    self.point = point;
    UIImage *image1 = [UIImage imageNamed:@"point1"];
    UIImage *image2 = [UIImage imageNamed:@"point2"];
    UIImage *image3 = [UIImage imageNamed:@"point3"];
    NSArray *images = @[image1,image2,image3];
    [self.point setAnimationImages:images];
    [self.point setAnimationDuration:1];
    [self.point startAnimating];

    
    UIImageView *phoneIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"手机"]];
    [self.view addSubview:phoneIcon];
    self.phoneIcon = phoneIcon;
    
    //新增电话连接状态
    UILabel *statusLabel = [[UILabel alloc] init];
    statusLabel.text = @"正在建立连接";
    statusLabel.textColor = WHITECOLOR;
    statusLabel.font = [UIFont systemFontOfSize:15];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:statusLabel];
    self.statusLabel = statusLabel;
    
    UILabel *bigLabel = [[UILabel alloc] init];
    bigLabel.text = @"请接听来电";
    bigLabel.textColor = WHITECOLOR;
    bigLabel.font = [UIFont systemFontOfSize:20];
    bigLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:bigLabel];
    self.bigLabel = bigLabel;
    self.bigLabel.hidden = YES;
    
    
    //设置显示状态
    self.noVoice.hidden = YES;
    self.noVoiceL.hidden = YES;
    self.voice.hidden = YES;
    self.voiceL.hidden = YES;
    
    [point mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(phone.mas_bottom).mas_offset(50);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(5);
    }];
    
    [smallAvtar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(point.mas_left).mas_offset(-23);
        make.centerY.mas_equalTo(point.mas_centerY);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
    }];
    
    [phoneIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(point.mas_right).mas_offset(30);
        make.centerY.mas_equalTo(point.mas_centerY);
        make.width.mas_equalTo(23);
        make.height.mas_equalTo(38);
    }];
    
    [statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(phoneIcon.mas_bottom).mas_offset(10);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    
    [bigLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(statusLabel.mas_bottom).mas_offset(10);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    
    [cancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(70);
        make.bottom.mas_equalTo(-48);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    
    [noVoice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(42);
        make.height.mas_equalTo(42);
        make.right.mas_equalTo(cancel.mas_left).mas_offset(-46);
        make.centerY.mas_equalTo(cancel.mas_centerY);
    }];
    
    [noVoiceL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(noVoice.mas_centerX);
        make.top.mas_equalTo(noVoice.mas_bottom).mas_offset(6);
    }];
    
    [voice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(42);
        make.height.mas_equalTo(42);
        make.left.mas_equalTo(cancel.mas_right).mas_offset(46);
        make.centerY.mas_equalTo(cancel.mas_centerY);
    }];
    
    [voiceL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(voice.mas_centerX);
        make.top.mas_equalTo(voice.mas_bottom).mas_offset(6);
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //播放等待提示音、开始查询余额、然后拨打电话
    [self.player play];
    [self checkAmountAndCall:self.phoneNum name:self.name];
}

//电话结束操作 -- 上传通话时长
- (void)handUpDo{
    NSDate *date = [NSDate date];
    self.endTime = date.timeIntervalSince1970*1000;
    
    [LGNetWorking saveCallTime:USERINFO.sessionId toPhone:self.phoneNum callTime:0 CallId:self.recordId startTime:self.startTime endTime:self.endTime block:^(ResponseData *responseData) {
        
        [self dismissViewControllerAnimated:YES completion:nil];

        if (responseData.code == 0) {
            
            //清除存储时间数据
            self.endTime = 0;
            self.startTime = 0;
            
        }else{
            [LCProgressHUD showFailureText:responseData.msg];
        }
    }];
}


/**
 *  拨打电话
 */
- (void)makeCall:(NSString *)phone name:(NSString *)name{
    
    //拨打电话  caller主叫方电话  called被叫方电话
    [[LYVoIP shareInstance] voipCallBackWithCaller:USERINFO.uphone Called:phone success:^(LYResponseModel *responseModel) {
        if (responseModel) {
            if (responseModel.code==2000){
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.statusLabel.text = @"正在呼叫";
                    self.bigLabel.hidden = NO;
                });
                //呼叫成功 //添加通话记录
                [LGNetWorking addCallRecord:USERINFO.sessionId toPhone:phone block:^(ResponseData *responseData) {
                    if (responseData.code == 0) {
                        //记录通话id
                        NSNumber *recordID = responseData.data;
                        self.recordId = [recordID integerValue];
                    }
                }];
            }
            else{
                [LCProgressHUD showFailureText:responseModel.msg];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }
            
            //添加本地通话日志
            [LGNetWorking addCallLog:USERINFO.sessionId fromPhone:USERINFO.uphone toPhone:phone status:responseModel.code errorInfo:responseModel.msg block:^(ResponseData *responseData) {
                if (responseData.code == 0) {
                    NSLog(@"添加日志成功");
                }
            }];
        }else{
            //添加本地通话日志
            [LGNetWorking addCallLog:USERINFO.sessionId fromPhone:USERINFO.uphone toPhone:phone status:-1 errorInfo:@"服务端无返回数据" block:^(ResponseData *responseData) {
                if (responseData.code == 0) {
                    NSLog(@"添加日志成功");
                }
            }];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
        
    } failure:^(NSError *error) {
        [LCProgressHUD showFailureText:error.description];
        
        //添加本地通话日志
        [LGNetWorking addCallLog:USERINFO.sessionId fromPhone:USERINFO.uphone toPhone:phone status:-1 errorInfo:error.description block:^(ResponseData *responseData) {
            if (responseData.code == 0) {
                NSLog(@"添加日志成功");
            }
            
        }];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

//检查用户是否还有通话余额 - 然后拨打电话
- (void)checkAmountAndCall:(NSString *)phone name:(NSString *)name {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 30.f;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    
#warning TODO:查询账户余额
    /*
    NSString *sign = [NSString stringWithFormat:@"openfireaccount=%@&apikey=%@",USERINFO.openfireAccount,RECHAPPKEY];
    NSString *md5Sign = [NSString md5:sign];
    
    md5Sign = [md5Sign uppercaseString];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"openfireaccount"] = USERINFO.openfireAccount;
    params[@"sign"] = md5Sign;
    
    
    [manager POST:[NSString stringWithFormat:@"%@/Api/Index/getuser",DFAPIURLTEST] parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        
        if ([responseObject[@"code"] integerValue] == 8888) {
            
            //有话费余额，拨打电话
            if ([responseObject[@"phoneusetime"] integerValue] >= 0) {
                [self makeCall:phone name:name];
                
            }else{
                [LCProgressHUD showFailureText:responseObject[@"msg"]];
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }
        }else{
            [LCProgressHUD showFailureText:responseObject[@"msg"]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
            
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [LCProgressHUD showFailureText:error.description];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }];
     */
    
}

/**
 *  静音按钮点击
 */
- (void)noVoiceAction:(UIButton *)sender{
    
}

/**
 *  扬声器
 */
- (void)voiceAction:(UIButton *)sender{
    
}

/**
 *  挂断电话
 */
- (void)cancelAction:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  根据通话状态切换展示
 */
- (void)changeCallingState{
    self.bgView.image = [UIImage imageNamed:@"callbg1"];
    
    self.noVoice.hidden = NO;
    self.noVoiceL.hidden = NO;
    self.voice.hidden = NO;
    self.voiceL.hidden = NO;
    
    self.smallAvtar.hidden = YES;
    self.point.hidden = YES;
    self.phoneIcon.hidden = YES;
}


@end
