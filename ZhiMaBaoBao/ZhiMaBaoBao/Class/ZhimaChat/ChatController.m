//
//  ChatController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/21.
//  Copyright © 2016年 liugang. All rights reserved.
//  聊天页面

#import "ChatController.h"
#import "ChatKeyBoard.h"
#import "MessageCell.h"
#import "LGMessage.h"
#import "FaceSourceManager.h"
#import "RecordingHUD.h"

//语音相关头文件
#import "MLAudioRecorder.h"
#import "CafRecordWriter.h"
#import "AmrRecordWriter.h"
#import "Mp3RecordWriter.h"
#import <AVFoundation/AVFoundation.h>
#import "MLAudioMeterObserver.h"
#import "MLAudioPlayer.h"
#import "AmrPlayerReader.h"

@interface ChatController ()<UITableViewDelegate,UITableViewDataSource,ChatKeyBoardDelegate,ChatKeyBoardDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ChatKeyBoard *keyboard;

//语音相关
@property (nonatomic, strong) MLAudioRecorder *recorder;
@property (nonatomic, strong) CafRecordWriter *cafWriter;
@property (nonatomic, strong) AmrRecordWriter *amrWriter;
@property (nonatomic, strong) Mp3RecordWriter *mp3Writer;

@property (nonatomic, strong) MLAudioPlayer *player;
@property (nonatomic, strong) AmrPlayerReader *amrReader;
@property (nonatomic, strong) MLAudioMeterObserver *meterObserver;
@property (nonatomic, strong) AVAudioPlayer *avAudioPlayer;
@property (nonatomic, copy) NSString *filePath;


@property (nonatomic, strong) NSMutableArray *messages;  //聊天消息
@end

static NSString *const reuseIdentifier = @"messageCell";
@implementation ChatController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self addSubviews];
    //初始化录音
    [self initAudioRecorder];
    [self requestChatRecord];
    
    //播放按钮
    UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(125, 400, 70, 50)];
    [playBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [self.view insertSubview:playBtn aboveSubview:self.tableView];
    [playBtn addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addSubviews{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, self.view.bounds.size.height - kChatKeyBoardHeight) style:UITableViewStylePlain];
    [tableView registerClass:[MessageCell class] forCellReuseIdentifier:reuseIdentifier];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    //初始化键盘
    ChatKeyBoard *keyboard = [ChatKeyBoard keyBoard];
    keyboard.delegate = self;
    keyboard.dataSource = self;
    keyboard.associateTableView = self.tableView;
    [self.view addSubview:keyboard];
    self.keyboard = keyboard;

}
//初始化录音
- (void)initAudioRecorder{
#warning 以后拼接用户uid
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //获取当前时间字符串
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd-hh-mm-ss-SSS";
    NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
    
    
    CafRecordWriter *writer = [[CafRecordWriter alloc]init];
    writer.filePath = [path stringByAppendingPathComponent:@"record1.caf"];
    self.cafWriter = writer;
    
    AmrRecordWriter *amrWriter = [[AmrRecordWriter alloc]init];
    amrWriter.filePath = [path stringByAppendingPathComponent:@"record1.amr"];
    amrWriter.maxSecondCount = 60;
    amrWriter.maxFileSize = 1024*256;
    self.amrWriter = amrWriter;
    
    Mp3RecordWriter *mp3Writer = [[Mp3RecordWriter alloc]init];
    mp3Writer.filePath = [path stringByAppendingPathComponent:@"record1.mp3"];
    mp3Writer.maxSecondCount = 60;
    mp3Writer.maxFileSize = 1024*256;
    self.mp3Writer = mp3Writer;
    
    //监听录音时音量大小
    MLAudioMeterObserver *meterObserver = [[MLAudioMeterObserver alloc]init];
    meterObserver.actionBlock = ^(NSArray *levelMeterStates,MLAudioMeterObserver *meterObserver){
        NSLog(@"volume:%f",[MLAudioMeterObserver volumeForLevelMeterStates:levelMeterStates]);
        //更新hud音量显示
        [RecordingHUD updateStatues:RecordHUDStatusVoiceChange value:[MLAudioMeterObserver volumeForLevelMeterStates:levelMeterStates]];
    };
    meterObserver.errorBlock = ^(NSError *error,MLAudioMeterObserver *meterObserver){
        [[[UIAlertView alloc]initWithTitle:@"错误" message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil]show];
    };
    self.meterObserver = meterObserver;
    
    MLAudioRecorder *recorder = [[MLAudioRecorder alloc]init];
    __weak __typeof(self)weakSelf = self;
    recorder.receiveStoppedBlock = ^{
        NSLog(@"收到语音录制完成回调");
        weakSelf.meterObserver.audioQueue = nil;

    };
    recorder.receiveErrorBlock = ^(NSError *error){
        
        weakSelf.meterObserver.audioQueue = nil;
        
        [[[UIAlertView alloc]initWithTitle:@"错误" message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil]show];
    };
    
    
    //caf
//            recorder.fileWriterDelegate = writer;
//            self.filePath = writer.filePath;
    //mp3
//        recorder.fileWriterDelegate = mp3Writer;
//        self.filePath = mp3Writer.filePath;
    
    //amr
    recorder.bufferDurationSeconds = 0.25;
    recorder.fileWriterDelegate = self.amrWriter;
    
    self.recorder = recorder;
    
    
    
    
    MLAudioPlayer *player = [[MLAudioPlayer alloc]init];
    AmrPlayerReader *amrReader = [[AmrPlayerReader alloc]init];
    
    player.fileReaderDelegate = amrReader;
    player.receiveErrorBlock = ^(NSError *error){
        
        [[[UIAlertView alloc]initWithTitle:@"错误" message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil]show];
    };
    player.receiveStoppedBlock = ^{
        NSLog(@"收到语音播放完成回调");
    };
    self.player = player;
    self.amrReader = amrReader;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionDidChangeInterruptionType:)
                                                 name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];

}

//录音时，系统中断
- (void)audioSessionDidChangeInterruptionType:(NSNotification *)notification
{
    AVAudioSessionInterruptionType interruptionType = [[[notification userInfo]
                                                        objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (AVAudioSessionInterruptionTypeBegan == interruptionType)
    {
        NSLog(@"系统中断begin");
    }
    else if (AVAudioSessionInterruptionTypeEnded == interruptionType)
    {
        NSLog(@"系统中断end");
    }
}

//加载聊天数据
- (void)requestChatRecord{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"FakeData" ofType:@"plist"];
    NSArray *chatData = [NSMutableArray arrayWithContentsOfFile:path];
    self.messages = [LGMessage mj_objectArrayWithKeyValuesArray:chatData];
    [self.tableView reloadData];
}

#pragma mark - tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    cell.message = self.messages[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    LGMessage *message = self.messages[indexPath.row];
    return message.buddleHeight + 2 * MSG_PADDING;
}

#pragma mark - tableview delegate
//点击单元格收起键盘
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.keyboard keyboardDown];
}

//滑动tableview,收起键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.keyboard keyboardDown];
}

#pragma mark - chatKeyboard delegate
//发送文本
- (void)chatKeyBoardSendText:(NSString *)text{
    LGMessage *message = [[LGMessage alloc] init];
    message.body = text;
    message.from = @"15171225855";
    message.to = @"111";
    [self.messages addObject:message];
    
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
    NSArray *indexPaths = @[indexpath];
//    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - 语音代理方法
//开始录音
- (void)chatKeyBoardDidStartRecording:(ChatKeyBoard *)chatKeyBoard{
    [self.recorder startRecording];
    self.meterObserver.audioQueue = self.recorder->_audioQueue;

}
//取消录音
- (void)chatKeyBoardDidCancelRecording:(ChatKeyBoard *)chatKeyBoard{
    [self.recorder stopRecording];
    
    //删除录音文件
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = self.amrWriter.filePath;
    NSError *error;
    if ([manager fileExistsAtPath:path]) {
        BOOL res = [manager removeItemAtPath:path error:&error];
        if (res) {
            NSLog(@"删除语音文件成功");
        }else{
            NSLog(@"删除语音文件失败%@",error.localizedDescription);
        }
    }
}
//完成录音
- (void)chatKeyBoardDidFinishRecoding:(ChatKeyBoard *)chatKeyBoard{
    [self.recorder stopRecording];

    //通过文件时长判断是否文件是否创建成功 -- 创建失败弹出提示框（录音时间太短）
    CGFloat fileLength = [AmrPlayerReader durationOfAmrFilePath:self.amrWriter.filePath];
    if (fileLength == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [RecordingHUD showRecordShort];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [RecordingHUD dismiss];
            });
        });
    }
}
//将要取消录音
- (void)chatKeyBoardWillCancelRecoding:(ChatKeyBoard *)chatKeyBoard{

}
//继续录音
- (void)chatKeyBoardContineRecording:(ChatKeyBoard *)chatKeyBoard{

}

- (void)playAudio:(UIButton *)sender{
    self.amrReader.filePath = self.amrWriter.filePath;
    NSLog(@"文件时长%f",[AmrPlayerReader durationOfAmrFilePath:self.amrReader.filePath]);

    if (self.player.isPlaying) {
        [self.player stopPlaying];
    }else{
        [sender setTitle:@"停止" forState:UIControlStateNormal];
        [self.player startPlaying];
    }
}


#pragma mark - chatKeyboard datasource
- (NSArray<MoreItem *> *)chatKeyBoardMorePanelItems
{
    MoreItem *item1 = [MoreItem moreItemWithPicName:@"sharemore_location" highLightPicName:nil itemName:@"位置"];
    MoreItem *item2 = [MoreItem moreItemWithPicName:@"sharemore_pic" highLightPicName:nil itemName:@"图片"];
    MoreItem *item3 = [MoreItem moreItemWithPicName:@"sharemore_video" highLightPicName:nil itemName:@"拍照"];

    return @[item1, item2, item3];
}
- (NSArray<ChatToolBarItem *> *)chatKeyBoardToolbarItems
{
    ChatToolBarItem *item1 = [ChatToolBarItem barItemWithKind:kBarItemFace normal:@"face" high:@"face_HL" select:@"keyboard"];
    
    ChatToolBarItem *item2 = [ChatToolBarItem barItemWithKind:kBarItemVoice normal:@"voice" high:@"voice_HL" select:@"keyboard"];
    
    ChatToolBarItem *item3 = [ChatToolBarItem barItemWithKind:kBarItemMore normal:@"more_ios" high:@"more_ios_HL" select:nil];
    
    ChatToolBarItem *item4 = [ChatToolBarItem barItemWithKind:kBarItemSwitchBar normal:@"switchDown" high:nil select:nil];
    
    return @[item1, item2, item3, item4];
}

- (NSArray<FaceThemeModel *> *)chatKeyBoardFacePanelSubjectItems
{
    return [FaceSourceManager loadFaceSource];
}

- (void)dealloc{
    //音谱检测关联着录音类，录音类要停止了。所以要设置其audioQueue为nil
    self.meterObserver.audioQueue = nil;
    [self.recorder stopRecording];
    
    [self.player stopPlaying];
}

#pragma mark - lazy
- (NSMutableArray *)messages{
    if (!_messages) {
        _messages = [NSMutableArray array];
    }
    return _messages;
}

@end
