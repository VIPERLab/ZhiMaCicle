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
#import "SDPhotoBrowser.h"

#import "IMChatTableViewCell.h"
#import "BaseChatTableViewCell.h"
#import "IMMorePictureTableViewCell.h"
#import "IMChatVoiceTableViewCell.h"

#import "SocketManager.h"

//语音相关头文件
#import "MLAudioRecorder.h"
#import "CafRecordWriter.h"
#import "AmrRecordWriter.h"
#import "Mp3RecordWriter.h"
#import <AVFoundation/AVFoundation.h>
#import "MLAudioMeterObserver.h"
#import "MLAudioPlayer.h"
#import "AmrPlayerReader.h"


@interface ChatController ()<UITableViewDelegate,UITableViewDataSource,ChatKeyBoardDelegate,ChatKeyBoardDataSource, BaseChatTableViewCellDelegate, CDCelldelegate,VoiceCelldelegate,SDPhotoBrowserDelegate>
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

@property (nonatomic, strong) NSIndexPath *currentPlayAudioIndexPath; //当前下在播放语音的cell indexpath;


@property (nonatomic, strong) NSMutableArray *messages;  //聊天消息
@property (nonatomic, strong) NSMutableArray *subviews;  //所有的imageView

@end

static NSString *const reuseIdentifier = @"messageCell";
@implementation ChatController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self addSubviews];
    //初始化录音
    [self initAudioRecorder];
    [self requestChatRecord];
    
//    //播放按钮
//    UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(125, 400, 70, 50)];
//    [playBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
//    [playBtn setTitle:@"播放" forState:UIControlStateNormal];
//    [self.view insertSubview:playBtn aboveSubview:self.tableView];
//    [playBtn addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addSubviews{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, self.view.bounds.size.height - kChatToolBarHeight) style:UITableViewStylePlain];
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
    
    /**
     *  读取消息列表
     */
//    FMDBManager* shareManager = [FMDBManager shareManager];
//    self.messages = [[shareManager getMessageDataWithConverseID:@""] mutableCopy];
    
    for (int i=0; i<7; i++) {
        LGMessage*msg = [[LGMessage alloc]init];
        
        switch (i) {
            case 0:
                msg.type = MessageTypeText;
                msg.text = @"😄可是房价会更😄😄😄😄快的房价回归😄😄😄考试辅导和公司开发😄😄😄的受到法国开发的计划过";
                msg.fromUid = USERINFO.userID;

                break;
            case 1:
                msg.type = MessageTypeAudio;
                msg.text = @"额锐鳄鱼肉贴如意贴一个的房间号公开";
                msg.fromUid = @"1234";
                msg.is_read = @"1";
                break;
            case 2:
                msg.type = MessageTypeImage;
                msg.text = @"http://app.zhima11.com:8080/upload/headPhoto/headPhoto1474962299468.jpg";
                msg.fromUid = USERINFO.userID;
                break;
            case 3:
                msg.type = MessageTypeText;
                msg.text = @"是否客观合理分工合理的开发规划及类似的风格及婚礼上的开发规划了深刻的分工合理的恢复过来看大家分工合理开发和公司的来访客户给老师";
                msg.fromUid = @"1234";
                break;
            case 4:
                msg.type = MessageTypeText;
                msg.text = @"SD卡付款时间都符合双方";
                msg.fromUid = USERINFO.userID;
                break;
            case 5:
                msg.type = MessageTypeImage;
                msg.text = @"http://app.zhima11.com:8080//upload/headPhoto/headPhoto1473843925435.jpg";
                msg.fromUid = @"1234";
                break;
            case 6:
                msg.type = MessageTypeImage;
                msg.text = @"http://app.zhima11.com:8080/upload/headPhoto/headPhoto1474950185153.jpg";
                msg.fromUid = USERINFO.userID;
                break;
                
            default:
                break;
        }
        
        [self.messages addObject:msg];
        
    }
    [self.tableView reloadData];
    // tableview 滑到底端
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height -self.tableView.bounds.size.height + 64) animated:YES];
}

// 计算 cell 的高度
- (CGFloat)calculateRowHeightAccordingChat:(LGMessage *)ch indexPath:(NSIndexPath *)ip
{
    MessageType ft = ch.type;;
    CGFloat rowHeight = 44.0f;
    
    BOOL needShowTime = NO;
    
    NSString *time = nil;
    
//    if (ip.row > 0) {
//        
//        Chat *preChat = self.tableViewSource[ip.row - 1]; //前一条聊天记录]
//        Chat *curChat = self.tableViewSource[ip.row];
//        needShowTime = [CommenMethod needShowTime:preChat.send_time time2:curChat.send_time];
//        
//        if (needShowTime) {
//            //            NSDate *date = [ch.send_time dateWithDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//            //            time = [date stringWithDateFormat:@"MM-dd HH:mm"];
//        }
//    }
//    else
//    {
//        
//        //        NSDate *date = [ch.send_time dateWithDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        //        time = [date stringWithDateFormat:@"MM-dd HH:mm"];
//        
//    }
    switch (ft) {
        case MessageTypeText: {
            rowHeight = [IMChatTableViewCell getHeightWithMessage:ch.text topText:time nickName:nil] + 10;
            
            break;
        }

        case MessageTypeImage : {
//            rowHeight = [IMMorePictureTableViewCell getHeightWithChat:ch TopText:time nickName:nil];
            rowHeight = 140;
            
            break;
        }
        case MessageTypeAudio: {
            rowHeight = [IMChatVoiceTableViewCell getHeightWithTopText:time nickName:nil];
            break;
        }

        default:
            break;
    }
    
    return  rowHeight;
}

#pragma mark - ——----------浏览图片
- (void)chat_browseChoosePicture:(UIGestureRecognizer *)grz
{
    
    NSLog(@"图片点击");
    [self.subviews removeAllObjects];
    UIView *imageView = grz.view;
    [self.subviews addObject:imageView];
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.currentImageIndex = 0;
    browser.sourceImagesContainerView = grz.view.superview;
    browser.imageCount = self.subviews.count;
    browser.delegate = self;
    [browser show];
    
}

#pragma mark - SDPhotoBrowserDelegate

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    LGMessage *msg = self.messages[index];
    NSURL *url = [NSURL URLWithString:msg.text];
    return url;
}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    UIImageView *imageView = self.subviews[index];
    return imageView.image;
}

#pragma mark - tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
//    cell.message = self.messages[indexPath.row];
//    return cell;
    
    LGMessage *message = self.messages[indexPath.row];
    MessageType fileType = message.type;
    BOOL isMe = [message.fromUid isEqualToString:USERINFO.userID];
    
    NSString *resuseIdentifierString = [NSString stringWithFormat:@"chatCellIdentifier_%ld", (long)fileType];

    BaseChatTableViewCell *baseChatCell = nil;
    NSString *headPortraitUrlStr = nil;
    NSString *uniqueFlagStr = nil;
#pragma mark--MessageTypeText
    if(fileType == MessageTypeText) {
        IMChatTableViewCell *textChatCell = [tableView dequeueReusableCellWithIdentifier:resuseIdentifierString];
        if(!textChatCell) {
            textChatCell = [[IMChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resuseIdentifierString];
        }
        
        baseChatCell = textChatCell;
        
        textChatCell.isMe = isMe;
        textChatCell.chatMessageView.text = message.text;
//        textChatCell.topLabel.text = time;
        textChatCell.delegate = self;
        textChatCell.indexPath = indexPath;
        
        //  以下内容判断是否发送失败
        if (message.sendStatus == IMRequestFaile) {
            textChatCell.sendAgain.hidden = NO;
            [textChatCell.sending stopAnimating];
            textChatCell.resendBlock = ^(BaseChatTableViewCell *theCell) {
                
                LGMessage *chat = [self.messages objectAtIndex:theCell.indexPath.row];
                chat.sendStatus = IMRequesting;
                [self.messages replaceObjectAtIndex:theCell.indexPath.row withObject:chat];
//                NSString *messageId = chat.timestamp;
//                NSIndexPath *indexPath = theCell.indexPath;
//                
//                [self chat_updateTableView:@[indexPath] pattern:1];
//                
//                [DataBaseManager updateChatColumnValueByID:StringFromInt(DVRequesting) column:@"messageSendStatus" messageId:messageId];
//                
//                [[XMPPManager defaultInstance] sendMessageToUser:self.chatFriend
//                                                            body:chat.message
//                                                          myInfo:[GlobalCommen CurrentUser]
//                                                         content:nil
//                                                         subject:kFileText
//                                                       messageId:messageId
//                 
//                 ];
            };
        } else {
            textChatCell.sendAgain.hidden = YES;
            if (message.sendStatus == IMRequesting) {
                [textChatCell.sending startAnimating];
            } else {
                [textChatCell.sending stopAnimating];
            }
        }
        
    }
    
#pragma mark--MessageTypeImage
    else if(fileType == MessageTypeImage) {
        IMMorePictureTableViewCell *picChatCell = [tableView dequeueReusableCellWithIdentifier:resuseIdentifierString];
        if(!picChatCell) {
            picChatCell = [[IMMorePictureTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resuseIdentifierString];
            
            picChatCell.backgroundColor = WHITECOLOR;
        }
        
        baseChatCell = picChatCell;
        
        picChatCell.isMe = isMe;
        picChatCell.delegate=self;
//        picChatCell.topLabel.text = time;
        picChatCell.indexPath = indexPath;
        
        
        [picChatCell reloadData:message isMySelf:isMe chousePicTarget:self action:@selector(chat_browseChoosePicture:)];
        
//        if (![self.subviews containsObject: picChatCell.picturesView]) {
//            [self.subviews addObject:picChatCell.picturesView];
//            picChatCell.picturesView.tag = [self.subviews indexOfObject:picChatCell.picturesView];
//
//        }

        
//        if (message.sendStatus == IMRequestFaile) {
//            picChatCell.sendAgain.hidden = NO;
//            [picChatCell.sending stopAnimating];
//            picChatCell.resendBlock = ^(BaseChatTableViewCell *theCell) {
//                Chat *chat = [tableViewSource objectAtIndex:theCell.indexPath.row];
//                chat.modelStatus = DVRequesting;
//                [tableViewSource replaceObjectAtIndex:theCell.indexPath.row withObject:chat];
//                NSIndexPath *indexPath = theCell.indexPath;
//                [self chat_updateTableView:@[indexPath] pattern:1];
//                [DataBaseManager updateChatColumnValueByID:StringFromInt(DVRequesting) column:@"messageSendStatus" messageId:chat.timestamp];
//                
//                //上传成功发送失败
//                if ([chat.message hasPrefix:@"/upload"]) {
//                    
//                    [[XMPPManager defaultInstance] sendMessageToUser:self.chatFriend
//                                                                body:chat.message
//                                                              myInfo:[GlobalCommen CurrentUser]
//                                                             content:chat.content
//                                                             subject:kFilePicture
//                                                           messageId:chat.timestamp];
//                } else {
//                    
//                    [self uploadImages:[chat.message componentsSeparatedByString:@","] remark:chat.content messageId:chat.timestamp];
//                }
//                
//            };
//        } else {
//            picChatCell.sendAgain.hidden = YES;
//            if (message.sendStatus == IMRequesting) {
//                [picChatCell.sending startAnimating];
//            } else {
//                [picChatCell.sending stopAnimating];
//            }
//        }
        
    }
#pragma mark--MessageTypeAudio
    else if(fileType == MessageTypeAudio) {
        IMChatVoiceTableViewCell *voiceChatCell = [tableView dequeueReusableCellWithIdentifier:resuseIdentifierString];
        if(!voiceChatCell) {
            voiceChatCell = [[IMChatVoiceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resuseIdentifierString];
        }
        
        baseChatCell = voiceChatCell;
        
        
        voiceChatCell.delegate = self;
        voiceChatCell.voiceDelegate = self;
        voiceChatCell.isMe = isMe;
        voiceChatCell.voiceTimeLength = message.text;
//        voiceChatCell.topLabel.text = time;
        voiceChatCell.indexPath = indexPath;
        
        
        short isRead = message.is_read.intValue;
        if(!isMe) {
            
            if ([message.is_read isEqualToString:@"2"]) { //[chat.isReadContent isEqualToString:@"2"]
                voiceChatCell.isReadVoice = YES;
            } else {
                voiceChatCell.isReadVoice = NO;
            }

            if(isRead == 1) {

                //这里为什么要设成已读呢？？？？？？
                //chat.is_read = @"2";
                
//                [self.messages replaceObjectAtIndex:voiceChatCell.indexPath.row withObject:message];
//                [self performSelector:@selector(chat_updateChatForRead:) withObject:message afterDelay:0];
                
                
//                TentinetFile *tentinetFile = [[TentinetFile alloc] init];
//                tentinetFile.identity = chat.timestamp;
//                tentinetFile.requestURL = [NSString stringWithFormat:@"%@%@",FileServerAddress, chat.message];
//                
//                
//                __weak typeof(TentinetFile) *weakFile = tentinetFile;
//                tentinetFile.requestResults = ^(AFHTTPRequestOperation *operation,id results, NSError *error){
//                    
//                    if (!error) {
//                        [VoiceConverter upload_download_successArmToWav:results];
//                        NSString *messageId = weakFile.identity;
//                        NSLog(@"messageId  %@", messageId);
//                        
//                        NSInteger index = [self getMessageIndexByMessageId:messageId];
//                        if (index > -1) {
//                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//                            [self chat_updateTableView:@[indexPath] pattern:1];
//                        }
//                        
//                        voiceChatCell.btnBg.enabled = YES;
//                        
//                    } else {
//                        
//                    }
                };
//
//                NSString *filePath  = [[[BYDProductionObject defaultProduction] createDocumentSpecifiedFile:StoreVoicesChat] stringByAppendingPathComponent:[[chat.message componentsSeparatedByString:@"/"] lastObject]];
//                
//                [tentinetFile downloadFileWithBlock:filePath];
//                
//            } else {
//                NSString *folderpath = [[BYDProductionObject defaultProduction] createDocumentSpecifiedFile:StoreVoicesChat];
//                NSString *savepath    = [folderpath stringByAppendingPathComponent:[[chat.message componentsSeparatedByString:@"/"] lastObject]];
//                
//                NSLog(@"savepath=========:%@",savepath);
//                if(![[NSFileManager defaultManager ]fileExistsAtPath:savepath])
//                {
//                    
//                    TentinetFile *tentinetFile = [[TentinetFile alloc] init];
//                    tentinetFile.identity = chat.timestamp;
//                    tentinetFile.requestURL = [NSString stringWithFormat:@"%@%@",FileServerAddress, chat.message];
//                    
//                    
//                    __weak typeof(TentinetFile) *weakFile = tentinetFile;
//                    tentinetFile.requestResults = ^(AFHTTPRequestOperation *operation,id results, NSError *error){
//                        
//                        if (!error) {
//                            [VoiceConverter upload_download_successArmToWav:results];
//                            NSString *messageId = weakFile.identity;
//                            NSLog(@"messageId  %@", messageId);
//                            
//                            NSInteger index = [self getMessageIndexByMessageId:messageId];
//                            if (index > -1) {
//                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//                                [self chat_updateTableView:@[indexPath] pattern:1];
//                            }
//                            
//                        } else {
//                            
//                        }
//                    };
//                    
//                    NSString *filePath  = [[[BYDProductionObject defaultProduction] createDocumentSpecifiedFile:StoreVoicesChat] stringByAppendingPathComponent:[[chat.message componentsSeparatedByString:@"/"] lastObject]];
//                    
//                    [tentinetFile downloadFileWithBlock:filePath];
//                } else {
//                    voiceChatCell.btnBg.enabled = YES;
//                }
//            }
//        }
//        else{
//            voiceChatCell.isReadVoice = YES;
//            if(isRead == 1) {
//                //上传
//                chat.is_read = @"2";
//                [self performSelector:@selector(chat_updateChatForRead:) withObject:chat afterDelay:0];
//                
//            } else {
//                voiceChatCell.btnBg.enabled = YES;
//            }
//        }
//        
//        if (message.sendStatus == IMRequestFaile) {
//            voiceChatCell.sendAgain.hidden = NO;
//            [voiceChatCell.sending stopAnimating];
//            voiceChatCell.resendBlock = ^(BaseChatTableViewCell *theCell) {
//                Chat *chat = [tableViewSource objectAtIndex:theCell.indexPath.row];
//                chat.modelStatus = DVRequesting;
//                [tableViewSource replaceObjectAtIndex:theCell.indexPath.row withObject:chat];
//                NSIndexPath *indexPath = theCell.indexPath;
//                [self chat_updateTableView:@[indexPath] pattern:1];
//                
//                [DataBaseManager updateChatColumnValueByID:StringFromInt(DVRequesting) column:@"messageSendStatus" messageId:chat.timestamp];
//                
//                [self uploadVoice:chat.message durationTime:chat.content messageId:chat.timestamp];
//            };
//        } else {
//            voiceChatCell.sendAgain.hidden = YES;
//            if (message.sendStatus == IMRequesting) {
//                [voiceChatCell.sending startAnimating];
//            } else {
//                [voiceChatCell.sending stopAnimating];
//            }
        }
        
    }

    
//        //头像图片显示问题
//        headPortraitUrlStr = nil;
//        uniqueFlagStr = nil;
        if (baseChatCell.isMe){
            
            [baseChatCell.userIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,USERINFO.head_photo]]];
            
        }else{
//            headPortraitUrlStr = chat.chat_object_portrait;
//            uniqueFlagStr = chat.dixun_number;
        }
//
//        //头像
//        if (![headPortraitUrlStr contains:@"1000000000"]) {
//            [baseChatCell.userIcon setImageWithURL:[NSURL URLWithString:headPortraitUrlStr] placeholderImage:[UIFactory createOtherUserDefaultHeadPortraitWith:uniqueFlagStr]];
//        }else{
//            baseChatCell.userIcon.image = [UIFactory createOtherUserDefaultHeadPortraitWith:uniqueFlagStr];
//        }
    
//    baseChatCell.backgroundColor = indexPath.row%2 == 0 ? [UIColor orangeColor]:[UIColor lightGrayColor];
    
        return baseChatCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    LGMessage *message = self.messages[indexPath.row];
//    return message.buddleHeight + 2 * MSG_PADDING;
    
    LGMessage * chat = [self.messages objectAtIndex:indexPath.row];
    return [self calculateRowHeightAccordingChat:chat indexPath:indexPath];
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

#pragma mark - BaseChatTableViewCell delegate

- (void)userIconTappedWithIndexPath:(NSIndexPath *)indexPath
{
}

- (void)deleteButtonTappedWithIndexPath:(NSIndexPath *)indexPath
{

}

- (void)deleteTextComplete
{

}

- (void)copyButtonTappedWithIndexPath:(NSIndexPath *)indexPath
{

}

- (void)showMyDetailsInfo:(id)sender
{
    
}

- (void)showUserInfoWithDixinNumber:(NSString *)dixinNumber
{
    
}

#pragma mark - 声音cell代理_________________________IMChatVoiceCell delegate

- (void)onPlayBtn:(id)sender
{
    [self chat_playMusic:sender];
    NSLog(@"播放声音");
    
}

- (void)chat_playMusic:(UIButton *)sender{
    
    UIView *view = sender.superview;
    while(![view isKindOfClass:[IMChatVoiceTableViewCell class]]) {
        view = [view superview];
    }
    
    NSIndexPath* ip = [self.tableView indexPathForCell:(IMChatVoiceTableViewCell *)view];
    
    if([self.player isPlaying]) {
        
        [self.player stopPlaying];
//        [myTimer invalidate];
        
        
        
//        NSLog(@"当前VC的内存地址是——————————%p—————soundIp =%d———", self, soundIp);
        
//        NSIndexPath *index = [NSIndexPath indexPathForRow:soundIp inSection:0];
        
        
        NSIndexPath *index = self.currentPlayAudioIndexPath;
        
        
        IMChatVoiceTableViewCell *cell = (IMChatVoiceTableViewCell*)[self.tableView cellForRowAtIndexPath:index];
        
//        NSLog(@"_____table__________%p", self.chatTableView);
//        NSLog(@"____cell.btnBg______%p__", cell.btnBg);
//        NSLog(@"____cell______%p__", cell);
        
        NSString *imageName;

        if (cell.isMe) {
            imageName = [NSString stringWithFormat:@"chat_voice_sender"];
        }else{
            imageName = [NSString stringWithFormat:@"chat_voice_reciever"];
        }
        [cell.btnBg setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        
        //如果当前cell 的语音正在播放，那么结束播放
        if (self.currentPlayAudioIndexPath.row == ip.row) {
            return;
        }
        
    }
    
    
    LGMessage *message = [self.messages objectAtIndex:ip.row];
    if (![message.is_read isEqualToString:@"2"]) {  //![chat.isReadContent isEqualToString:@"2"]
        message.is_read = @"2";

        /**
         *  1、更改数据库里面该message的状态，同时刷新cell
         */
//        [DataBaseManager updateChatColumnValueByID:@"2" column:@"is_read_content" theId:chat.theId.integerValue];
//        [DataBaseManager closeDataBase];
//        [self chat_updateTableView:@[ip] pattern:1];
         [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];

    }
    /**
     *  2、根据路径获取到音频内容，然后播放
     */
//    NSString *voice = [[chat.message componentsSeparatedByString:@"/"] lastObject];
//    NSString *url = [[[BYDProductionObject defaultProduction] createDocumentSpecifiedFile:StoreVoicesChat] stringByAppendingPathComponent:voice];
//    NSError *err = nil;
//    self.player = nil;
//    NSURL *playUrl = [NSURL fileURLWithPath:url];
//    if(!playUrl) {
//        [[GeneralToolClass defaultInstance] popUpWarningView:[CommenMethod localizationString:@"InvalidFile"]];
//    }
//    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:playUrl error:&err];
//    self.voicePlayer.delegate = self;
//    soundLocation = sender.center.x;
//    soundIp = ip.row;
    
//    NSLog(@"shichang:%f",self.voicePlayer.duration);
//    myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(playPic) userInfo:nil repeats:YES];
//    [myTimer fire];
//    if (err) {
//        NSLog(@"voice error:%@",err);
//    }
//    if(self.voicePlayer) {
//        [self.voicePlayer prepareToPlay];
//        [self.voicePlayer play];
//    } else {
//        self.voicePlayer = [[AVAudioPlayer alloc] initWithData:[IMNetworkRequest fetchFileFromLocal:voice folder:StoreVoicesChat] error:&err];
//        self.voicePlayer.delegate = self;
//        [self.voicePlayer prepareToPlay];
//        [self.voicePlayer play];
//    }
    
    self.currentPlayAudioIndexPath = ip;
}


#pragma mark - chatKeyboard delegate ：发送文本消息
//发送文本
- (void)chatKeyBoardSendText:(NSString *)text{
    
    LGMessage *message = [[LGMessage alloc] init];
    message.text = text;
    message.toUidOrGroupId = @"11594";
    message.fromUid = USERINFO.userID;
    message.type = MessageTypeText;
    message.msgid = [NSString stringWithFormat:@"%@12345678",USERINFO.userID];
    message.isGroup = NO;
    message.timeStamp = [NSDate currentTimeStamp];
    
    [self.messages addObject:message];
    

    
    SocketManager* socket = [SocketManager shareInstance];
    [socket sendMessage:message];
    
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

- (void)playAudio:(id)sender{
    
    self.amrReader.filePath = self.amrWriter.filePath;
    NSLog(@"文件时长%f",[AmrPlayerReader durationOfAmrFilePath:self.amrReader.filePath]);

    if (self.player.isPlaying) {
        [self.player stopPlaying];
    }else{

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

- (NSMutableArray *)subviews{
    if (!_subviews) {
        _subviews = [NSMutableArray array];
    }
    return _subviews;
}

@end
