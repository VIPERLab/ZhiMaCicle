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

#import "ChatRoomInfoController.h" // 聊天室详情
#import "GroupChatRoomInfoController.h" // 群聊天室详情

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

#import "ForwardMsgController.h"    //消息转发控制器
#import "BaseNavigationController.h"
#import "FriendProfilecontroller.h"
#import "ConverseModel.h"   //会话模型
#import "KXActionSheet.h"

//相册相关头文件
#import <AssetsLibrary/AssetsLibrary.h>
#import "DNImagePickerController.h"
#import "DNAsset.h"
#import "NSURL+DNIMagePickerUrlEqual.h"


@interface ChatController ()<UITableViewDelegate,UITableViewDataSource,ChatKeyBoardDelegate,ChatKeyBoardDataSource, BaseChatTableViewCellDelegate, CDCelldelegate,VoiceCelldelegate,SDPhotoBrowserDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,DNImagePickerControllerDelegate,KXActionSheetDelegate>

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
@property (nonatomic, strong) NSMutableArray *subviews;  //所有的imageView（浏览图片时用）
@property (nonatomic, copy) NSString * audioName;         //最新语音文件后缀名

@property (nonatomic, assign)BOOL isTimeOut; //录音时间超过60秒

@property (nonatomic, assign)int currentPage;


@property (nonatomic, strong) NSMutableArray *imagesArray; // 选择的图片数组（发送图片用）

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;   //保存选中行
@property (nonatomic, strong) NSString *currentPicUrl;   //当前选中的图片浏览路径


@end

static NSString *const reuseIdentifier = @"messageCell";


@implementation ChatController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setupNavRightItem];
    [self addSubviews];
    //初始化录音
    [self initAudioRecorder];
    [self requestChatRecord];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievedNewMessage:) name:kRecieveNewMessage object:nil];
    //监听消息发送状态回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMsgStatuescall:) name:kSendMessageStateCall object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //通过id查数据库最新会话名->设置为标题
    //1.先通过id查会话
    if (!self.converseType) {   //单聊
        ZhiMaFriendModel *friendModel = [FMDBShareManager getUserMessageByUserID:self.conversionId];
        [self setCustomTitle:friendModel.displayName];
    } else {
        GroupChatModel *groupModel = [FMDBShareManager getGroupChatMessageByGroupId:self.conversionId];
        [self setCustomTitle:groupModel.groupName];
    }

}

//设置导航栏右侧按钮
- (void)setupNavRightItem{
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"redContant"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(lookConversionInfo) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}

//查看会话详情 ->
- (void)lookConversionInfo{
    if (!self.converseType) {  // 单聊
        ChatRoomInfoController *vc = [[ChatRoomInfoController alloc] init];
        vc.userId = self.conversionId;
        vc.displayName = self.conversionName;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    // 群聊
    GroupChatRoomInfoController *vc = [[GroupChatRoomInfoController alloc] init];
    vc.converseId = self.conversionId;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  收到新消息
 */
- (void)recievedNewMessage:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    LGMessage *message  = userInfo[@"message"];
    
    //如果收到的消息为当前会话者发送 ， 直接插入数据源数组
    if ([message.fromUid isEqualToString:self.conversionId]) {
        [self.messages addObject:message];
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
        NSArray *indexPaths = @[indexpath];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

    }
}
//消息发送状态回调
- (void)sendMsgStatuescall:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    LGMessage *message  = userInfo[@"message"];
    message.isSending = NO;
    NSInteger row = 100000;
    
    //通过判断，排除转发给他人的消息插入数据源
    if ([message.fromUid isEqualToString:self.conversionId] || [message.toUidOrGroupId isEqualToString:self.conversionId]) {
        for (LGMessage *msg  in self.messages) {
            if ([msg.msgid isEqualToString:message.msgid]) {
                row = [self.messages indexOfObject:message];
            }
        }
        
        if (row != 100000) {
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:row inSection:0];
            NSArray *indexPaths = @[indexpath];
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }else{
            [self.messages addObject:message];
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
            NSArray *indexPaths = @[indexpath];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
    


//    NSInteger row = [self.messages indexOfObject:message];

//

    
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
    
    self.currentPage = 1;
    
    MJRefreshNormalHeader*header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshAction)];
    header.stateLabel.text = @"Loading";
    header.lastUpdatedTimeLabel.hidden = YES;
    [header setTitle:@"下拉加载更多" forState:MJRefreshStateIdle];
    [header setTitle:@"松开立即加载" forState:MJRefreshStatePulling];
    self.tableView.mj_header = header;

}

- (NSString*)audioPathWithUid:(NSString*)uid{

    //获取当前时间字符串
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd-hh-mm-ss-SSS";
    NSString *path = [dateFormatter stringFromDate:[NSDate date]];
    path = [path stringByAppendingString:[NSString stringWithFormat:@"-%@",uid]];
    
    self.audioName = [NSString stringWithFormat:@"/%@.amr",path];
    NSLog(@"注册时候的时间 = %@",self.audioName);
    
    return path;
}

//初始化录音
- (void)initAudioRecorder{
//#warning 以后拼接用户uid
    
//    NSString *path = AUVIOPATH;

    
//    CafRecordWriter *writer = [[CafRecordWriter alloc]init];
//    writer.filePath = [path stringByAppendingPathComponent:@".caf"];
//    self.cafWriter = writer;
    
    [self initAmrRecordWriter];
    
//    Mp3RecordWriter *mp3Writer = [[Mp3RecordWriter alloc]init];
//    mp3Writer.filePath = [path stringByAppendingPathComponent:@".mp3"];
//    mp3Writer.maxSecondCount = 60;
//    mp3Writer.maxFileSize = 1024*256;
//    self.mp3Writer = mp3Writer;
    
//    //监听录音时音量大小
//    MLAudioMeterObserver *meterObserver = [[MLAudioMeterObserver alloc]init];
//    meterObserver.actionBlock = ^(NSArray *levelMeterStates,MLAudioMeterObserver *meterObserver){
//        NSLog(@"volume:%f",[MLAudioMeterObserver volumeForLevelMeterStates:levelMeterStates]);
//        //更新hud音量显示
//        [RecordingHUD updateStatues:RecordHUDStatusVoiceChange value:[MLAudioMeterObserver volumeForLevelMeterStates:levelMeterStates]];
//    };
//    meterObserver.errorBlock = ^(NSError *error,MLAudioMeterObserver *meterObserver){
//        [[[UIAlertView alloc]initWithTitle:@"错误" message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil]show];
//    };
//    self.meterObserver = meterObserver;
//    
//    MLAudioRecorder *recorder = [[MLAudioRecorder alloc]init];
//    __weak __typeof(self)weakSelf = self;
//    recorder.receiveStoppedBlock = ^{
//        NSLog(@"收到语音录制完成回调");
//        weakSelf.meterObserver.audioQueue = nil;
//
//    };
//    recorder.receiveErrorBlock = ^(NSError *error){
//        
//        weakSelf.meterObserver.audioQueue = nil;
//        
//        [[[UIAlertView alloc]initWithTitle:@"错误" message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil]show];
//    };
//    
//    
//    //caf
////            recorder.fileWriterDelegate = writer;
////            self.filePath = writer.filePath;
//    //mp3
////        recorder.fileWriterDelegate = mp3Writer;
////        self.filePath = mp3Writer.filePath;
//    
//    //amr
//    recorder.bufferDurationSeconds = 0.25;
//    recorder.fileWriterDelegate = self.amrWriter;
//    
//    self.recorder = recorder;
    
    [self initAudioPlayAndReader];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionDidChangeInterruptionType:)
                                                 name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];

}

- (void)initAmrRecordWriter
{
    self.amrWriter = nil;
    self.meterObserver = nil;
    self.recorder = nil;
    
    NSString *pathName = [self audioPathWithUid:USERINFO.userID];
    AmrRecordWriter *amrWriter = [[AmrRecordWriter alloc]init];
    amrWriter.filePath = [AUDIOPATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.amr",pathName]];
    amrWriter.maxSecondCount = 60;
    amrWriter.maxFileSize = 1024*256;
    self.amrWriter = amrWriter;
    
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
        if (weakSelf.recorder.isTimeOut) {

            self.isTimeOut = YES;
            [RecordingHUD dismiss];
            [weakSelf.keyboard setButtonStateWithNormal];
            [weakSelf sendAudioMessage];
//            [weakSelf chatKeyBoardDidFinishRecoding:weakSelf.keyboard];
        }else{
        
            self.isTimeOut = NO;
        }
        weakSelf.meterObserver.audioQueue = nil;
        
    };
    recorder.receiveErrorBlock = ^(NSError *error){
        
        weakSelf.meterObserver.audioQueue = nil;
        
        [[[UIAlertView alloc]initWithTitle:@"错误" message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil]show];
    };
    recorder.bufferDurationSeconds = 0.25;
    recorder.fileWriterDelegate = self.amrWriter;
    
    self.recorder = recorder;
}

- (void)initAudioPlayAndReader
{
    self.player = nil;
    self.amrReader = nil;
    
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

#pragma mark - 下拉刷新

- (void)refreshAction {
    
    self.currentPage ++;
    
    FMDBManager* shareManager = [FMDBManager shareManager];
    NSMutableArray*marr = [[shareManager getMessageDataWithConverseID:self.conversionId andPageNumber:self.currentPage] mutableCopy];

    for (int i=0; i<marr.count; i++) {
        [self.messages insertObject:marr[i] atIndex:0];
    }
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
}

/**
 *  读取消息列表
 */
- (void)requestChatRecord{

    FMDBManager* shareManager = [FMDBManager shareManager];
//    [shareManager deleteMessageFormMessageTableByConverseID:self.conversionId];
    self.messages = [[shareManager getMessageDataWithConverseID:self.conversionId andPageNumber:self.currentPage] mutableCopy];
    self.messages = (NSMutableArray *)[[self.messages reverseObjectEnumerator] allObjects];
    
    [self.tableView reloadData];
    // tableview 滑到底端
    if (self.tableView.contentSize.height > self.tableView.bounds.size.height+64) {
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height -self.tableView.bounds.size.height + 64) animated:YES];
    }
    
}

- (BOOL)needShowTime:(NSInteger)time1 time2:(NSInteger)time2
{
    NSInteger num = time2 - time1;
    BOOL needShowTime = YES;
    needShowTime = num >= DiffTimeThreeMins*60;
    return needShowTime;
}

// 计算 cell 的高度
- (CGFloat)calculateRowHeightAccordingChat:(LGMessage *)ch indexPath:(NSIndexPath *)ip
{
    MessageType ft = ch.type;;
    CGFloat rowHeight = 44.0f;
    
    BOOL needShowTime = NO;
    
    NSString *time = nil;
    
    if (ip.row > 0) {
        LGMessage *msg1 = self.messages[ip.row - 1]; //前一条聊天记录]
        LGMessage *msg2 = self.messages[ip.row];
        needShowTime = [self needShowTime:msg1.timeStamp time2:msg2.timeStamp];
        
        if (needShowTime) {
            time = [NSString stringWithFormat:@"%ld",ch.timeStamp];
        }
    }
    else
    {
        time = [NSString stringWithFormat:@"%ld",ch.timeStamp];
    }
    switch (ft) {
        case MessageTypeText: {
            rowHeight = [IMChatTableViewCell getHeightWithMessage:ch.text topText:time nickName:nil] + 10;
            
            break;
        }

        case MessageTypeImage : {
//            rowHeight = [IMMorePictureTableViewCell getHeightWithChat:ch TopText:time nickName:nil];
            rowHeight = needShowTime ? 140+20 : 140;
            
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
    
    LGMessage *msg = self.messages[imageView.tag];
    if (msg.text) {
        self.currentPicUrl = [msg.text stringByReplacingOccurrencesOfString:@"s_" withString:@""];
    }else{
        self.currentPicUrl = nil;
    }
    
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
//    LGMessage *msg = self.messages[index];
//    NSString*urlStr = [msg.text stringByReplacingOccurrencesOfString:@"s_" withString:@""];
    NSURL *url = [NSURL URLWithString:self.currentPicUrl];
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

    LGMessage *message = self.messages[indexPath.row];
    MessageType fileType = message.type;
    BOOL isMe = [message.fromUid isEqualToString:USERINFO.userID];
    
    NSString *resuseIdentifierString = [NSString stringWithFormat:@"chatCellIdentifier_%ld", (long)fileType];

    BaseChatTableViewCell *baseChatCell = nil;
//    NSString *headPortraitUrlStr = nil;
//    NSString *uniqueFlagStr = nil;
    
#pragma mark--MessageTypeText
    if(fileType == MessageTypeText) {
        IMChatTableViewCell *textChatCell = [tableView dequeueReusableCellWithIdentifier:resuseIdentifierString];
        if(!textChatCell) {
            textChatCell = [[IMChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resuseIdentifierString];
        }
        
        baseChatCell = textChatCell;
        
        textChatCell.isMe = isMe;
        textChatCell.chatMessageView.text = message.text;
        textChatCell.delegate = self;
        textChatCell.indexPath = indexPath;
        
        if (message.isSending && isMe) {
            [textChatCell.sending startAnimating];
            textChatCell.sendAgain.hidden = YES;
            
        }else{
            
            //  以下内容判断是否发送失败
            if (message.sendStatus == 0) {
                textChatCell.sendAgain.hidden = NO;
                [textChatCell.sending stopAnimating];
                textChatCell.resendBlock = ^(BaseChatTableViewCell *theCell) {
                    
                    LGMessage *chat = [self.messages objectAtIndex:theCell.indexPath.row];
                    SocketManager* socket = [SocketManager shareInstance];
                    [socket reSendMessage:chat];
                    
                    //                    chat.isSending = YES;
                    //                    [self.messages replaceObjectAtIndex:theCell.indexPath.row withObject:chat];
                    //                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                };
            } else {
                textChatCell.sendAgain.hidden = YES;
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
        picChatCell.indexPath = indexPath;
        picChatCell.picturesView.tag = indexPath.row;
    
        [picChatCell reloadData:message isMySelf:isMe chousePicTarget:self action:@selector(chat_browseChoosePicture:)];
        

        if (message.isSending && isMe) {
            [picChatCell.sending startAnimating];
            picChatCell.sendAgain.hidden = YES;
            
        }else{
            
            //  以下内容判断是否发送失败
            if (message.sendStatus == 0) {
                picChatCell.sendAgain.hidden = NO;
                [picChatCell.sending stopAnimating];
                picChatCell.resendBlock = ^(BaseChatTableViewCell *theCell) {
                    
                    LGMessage *chat = [self.messages objectAtIndex:theCell.indexPath.row];
                    
                    if (chat.text) { // 推送失败的情况
                        SocketManager* socket = [SocketManager shareInstance];
                        [socket reSendMessage:chat];
                        
                    }else{  // 图片发送服务器失败的情况
                    
                        //重新发送图片给服务器
                    
                    }

                    
                };
            } else {
                picChatCell.sendAgain.hidden = YES;
                [picChatCell.sending stopAnimating];
            }
        }

        
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
        voiceChatCell.voiceTimeLength = [NSString stringWithFormat:@"%.2f",[AmrPlayerReader durationOfAmrFilePath:[NSString stringWithFormat:@"%@/%@",AUDIOPATH,message.text]]];
        voiceChatCell.indexPath = indexPath;
        
        if(!isMe) {
            
            if (message.is_read) {
                voiceChatCell.isReadVoice = YES;
            } else {
                voiceChatCell.isReadVoice = NO;
            }

            
        }else{
        
            //  以下内容判断是否发送失败
            if (message.sendStatus == 0) {
                voiceChatCell.sendAgain.hidden = NO;
                [voiceChatCell.sending stopAnimating];
                voiceChatCell.resendBlock = ^(BaseChatTableViewCell *theCell) {
                    
                    LGMessage *chat = [self.messages objectAtIndex:theCell.indexPath.row];
                    SocketManager* socket = [SocketManager shareInstance];
                    [socket reSendMessage:chat];
                    
                };
            } else {
                voiceChatCell.sendAgain.hidden = YES;
                [voiceChatCell.sending stopAnimating];
            }
            
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
    
    BOOL needShowTime = NO;
    
    if (indexPath.row > 0) {
        LGMessage *msg1 = self.messages[indexPath.row - 1]; //前一条聊天记录]
        LGMessage *msg2 = self.messages[indexPath.row];
        needShowTime = [self needShowTime:msg1.timeStamp time2:msg2.timeStamp];
        if (!needShowTime) {
            baseChatCell.topLabel.hidden = YES;
            baseChatCell.topLabel.text = nil;

        }else{
            
            baseChatCell.topLabel.hidden = NO;
            NSString*timeStr = [NSDate dateStrFromCstampTime:message.timeStamp withDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            baseChatCell.topLabel.text = [NSString timeStringChangeToZMTimeString:timeStr];
            
        }
    }else{
        
        baseChatCell.topLabel.hidden = NO;
        NSString*timeStr = [NSDate dateStrFromCstampTime:message.timeStamp withDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        baseChatCell.topLabel.text = [NSString timeStringChangeToZMTimeString:timeStr];
        
    }
    
//    baseChatCell.backgroundColor = indexPath.row%2 == 0 ? [UIColor orangeColor]:[UIColor lightGrayColor];
    baseChatCell.message = message;
    baseChatCell.delegate = self;
    
        return baseChatCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    LGMessage *message = self.messages[indexPath.row];
//    return message.buddleHeight + 2 * MSG_PADDING;
    
    LGMessage * chat = [self.messages objectAtIndex:indexPath.row];
    return [self calculateRowHeightAccordingChat:chat indexPath:indexPath];
}

#pragma mark - 消息转发、撤回、删除等操作
//转发
- (void)transMessageWithIndexPath:(NSIndexPath *)indexPath{
    LGMessage *message = self.messages[indexPath.row];
    ForwardMsgController *vc = [[ForwardMsgController alloc] init];
    vc.message = message;
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

//收藏
- (void)keepMessageWithIndexPath:(NSIndexPath *)indecPath{
    
}

//删除
- (void)deleteMessageWithIndexPath:(NSIndexPath *)indexPath{
    self.selectedIndexPath = indexPath;

    KXActionSheet *actionSheet = [[KXActionSheet alloc] initWithTitle:@"是否删除该条消息?" cancellTitle:@"取消" andOtherButtonTitles:@[@"确定"]];
    actionSheet.delegate = self;
    [actionSheet show];
}

- (void)KXActionSheet:(KXActionSheet *)sheet andIndex:(NSInteger)index;{
    if (index == 0) {
        LGMessage *message = self.messages[self.selectedIndexPath.row];
        
        //从数据库删除该条消息
        [[SocketManager shareInstance] deleteMessage:message];
        
        BOOL isLast = NO;
        
        if (self.selectedIndexPath.row + 1 == self.messages.count) {
            isLast = YES;
        }
        
        if (isLast) {
            NSString *lastConverseText = [NSString string];
            if (self.selectedIndexPath.row - 1 >= 0) {
                LGMessage *lastMessage = self.messages[self.selectedIndexPath.row - 1];
                if (lastMessage.type == 0 || lastMessage.type == MessageTypeSystem) {
                    lastConverseText = lastMessage.text;
                } else if (lastMessage.type == MessageTypeImage) {
                    lastConverseText = @"[图片]";
                } else if (lastMessage.type == MessageTypeAudio) {
                    lastConverseText = @"[语音]";
                }
            } else {
                lastConverseText = @" ";
            }
            
            FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_Converse_Table];
            NSString *optionStr1 = [NSString stringWithFormat:@"converseContent = '%@'",lastConverseText];
            NSString *upDataStr = [FMDBShareManager alterTable:ZhiMa_Chat_Converse_Table withOpton1:optionStr1 andOption2:[NSString stringWithFormat:@"converseId = '%@'",self.conversionId]];
            [queue inDatabase:^(FMDatabase *db) {
                BOOL success = [db executeUpdate:upDataStr];
                if (success) {
                    NSLog(@"更新会话成功");
                } else {
                    NSLog(@"更新会话失败");
                }
            }];
        }
        
        
        [self.messages removeObjectAtIndex:self.selectedIndexPath.row];
        //    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView reloadData];
    }
}

//撤回
- (void)undoMessageWithIndexPath:(NSIndexPath *)indecPath{
    [LCProgressHUD showLoadingText:@"消息撤回中..."];
    //socket发送消息撤回
    LGMessage *message = self.messages[indecPath.row];
    [[SocketManager shareInstance] undoMessage:message];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [LCProgressHUD hide];
        //从数据库删除该条消息
        [self deleteMessageWithIndexPath:indecPath];
    });
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
    FriendProfilecontroller *vc = [[FriendProfilecontroller alloc] init];
    LGMessage * message = [self.messages objectAtIndex:indexPath.row];
    vc.userId = message.fromUid;
    [self.navigationController pushViewController:vc animated:YES];
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
    IMChatVoiceTableViewCell *currentCell = (IMChatVoiceTableViewCell *)view;
    
    if([self.player isPlaying]) {
        
        [self.player stopPlaying];
//        [myTimer invalidate];
        
        NSIndexPath *index = self.currentPlayAudioIndexPath;
        
        IMChatVoiceTableViewCell *cell = (IMChatVoiceTableViewCell*)[self.tableView cellForRowAtIndexPath:index];
        
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
    
    [self initAudioPlayAndReader];
    
    LGMessage *message = [self.messages objectAtIndex:ip.row];
    self.amrReader.filePath = [NSString stringWithFormat:@"%@/%@",AUDIOPATH,message.text];
    [self.player startPlaying];
    
    if (message.is_read != YES && !currentCell.isMe) {  //![chat.isReadContent isEqualToString:@"2"]
        message.is_read = YES;
        
        [FMDBShareManager upDataMessageStatusWithMessage:message];
        
        if (message.is_read != YES && !currentCell.isMe) {  //![chat.isReadContent isEqualToString:@"2"]
            message.is_read = 1;
            
            FMDBManager* shareManager = [FMDBManager shareManager];
            [shareManager upDataMessageStatusWithMessage:message];
            
            [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
        [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }

    
    self.currentPlayAudioIndexPath = ip;
}

#pragma mark - chatKeyboard delegate ：发送文本消息
//发送文本
- (void)chatKeyBoardSendText:(NSString *)text{
    
    LGMessage *message = [[LGMessage alloc] init];
    message.text = text;
//    message.toUidOrGroupId =  @"12790";//self.conversionId;
    message.toUidOrGroupId =  self.conversionId;
    message.fromUid = USERINFO.userID;
    message.type = MessageTypeText;
    message.msgid = [NSString stringWithFormat:@"%@%@",USERINFO.userID,[self generateMessageID]];
    message.isGroup = self.converseType;
    message.timeStamp = [NSDate currentTimeStamp];
    message.isSending = YES;
    
//    [self.messages addObject:message];
//    
//    
//    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
//    NSArray *indexPaths = @[indexpath];
//    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
//    [self.tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    SocketManager* socket = [SocketManager shareInstance];
    [socket sendMessage:message];


    
}

/** 生成随机messageID */
- (NSString *)generateMessageID
{
    static int kNumber = 8;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned int)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

#pragma mark - 语音代理方法
//开始录音
- (void)chatKeyBoardDidStartRecording:(ChatKeyBoard *)chatKeyBoard{
    [self.recorder startRecording];
    self.meterObserver.audioQueue = self.recorder->_audioQueue;

}
//取消录音
- (void)chatKeyBoardDidCancelRecording:(ChatKeyBoard *)chatKeyBoard{
    
    if (self.recorder.isRecording) {
        [self.recorder stopRecording];

    }
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

#pragma mark - 录音完成      ：   发送语音

- (void)sendAudioMessage
{
//    NSData* auvioData = [NSData dataWithContentsOfFile:self.amrWriter.filePath];
//    NSLog(@"语音内容 = %@",auvioData);
    
    LGMessage *message = [[LGMessage alloc] init];
    message.text = self.audioName;
    message.toUidOrGroupId = self.conversionId;
    message.fromUid = USERINFO.userID;
    message.type = MessageTypeAudio;
    message.msgid = [NSString stringWithFormat:@"%@%@",USERINFO.userID,[self generateMessageID]];
    message.isGroup = NO;
    message.timeStamp = [NSDate currentTimeStamp];
    message.isSending = YES;
    
    [self.messages addObject:message];
    
    NSLog(@"发送的时间2 = %@",self.audioName);
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
    NSArray *indexPaths = @[indexpath];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    SocketManager* socket = [SocketManager shareInstance];
    [socket sendMessage:message];

}

//完成录音
- (void)chatKeyBoardDidFinishRecoding:(ChatKeyBoard *)chatKeyBoard{
    
    if (self.recorder.isRecording) {
        [self.recorder stopRecording];
        
    }

    //通过文件时长判断是否文件是否创建成功 -- 创建失败弹出提示框（录音时间太短）
    CGFloat fileLength = [AmrPlayerReader durationOfAmrFilePath:self.amrWriter.filePath];
    if (fileLength == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [RecordingHUD showRecordShort];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [RecordingHUD dismiss];
            });
        });
    }else{
    
        if (!self.isTimeOut) {

            [self sendAudioMessage];
        }
    }
    
    [self initAmrRecordWriter];
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

#pragma mark - chatKeyboard  键盘更多按钮代理

- (void)chatKeyBoard:(ChatKeyBoard *)chatKeyBoard didSelectMorePanelItemIndex:(NSInteger)index
{
    NSLog(@"点击了index = %ld",index);
    switch (index) {
        case 0: // 图片
        {
            DNImagePickerController *imagePicker = [[DNImagePickerController alloc] init];
            imagePicker.imagePickerDelegate = self;
            imagePicker.kDNImageFlowMaxSeletedNumber = 9;
            imagePicker.filterType = DNImagePickerFilterTypePhotos;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
            break;
        case 1: // 拍照
        {
            [self.imagesArray removeAllObjects];

            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self.navigationController presentViewController:picker animated:YES completion:nil];
            
        }
            break;
            
        default:
            break;
    }
}


// 读取拍照图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    UIImageOrientation imageOrientation=image.imageOrientation;
    if(imageOrientation!=UIImageOrientationUp) {

        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        // 调整图片角度完毕
    }


    [self.imagesArray addObject:image];

    [self sendImages:[self getImageSavePath:image]];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 发送图片前先保存到沙盒
- (NSString*)getImageSavePath:(UIImage*)image{

    NSString*photoName = [NSString stringWithFormat:@"/%ld",[NSDate currentTimeStamp]];
    NSString *imageDocPath = [AUDIOPATH stringByAppendingPathComponent:photoName];
    
    NSData *data = UIImageJPEGRepresentation(image, 1);
    [[NSFileManager defaultManager] createFileAtPath:imageDocPath contents:data attributes:nil];
    
    return photoName;

}

#pragma mark - 发送图片

- (void)sendImages:(NSString*)imagePath
{
    
    UIImage *image = self.imagesArray[0];
    
    LGMessage *message = [[LGMessage alloc] init];
    message.toUidOrGroupId = self.conversionId;
    message.fromUid = USERINFO.userID;
    message.type = MessageTypeImage;
    message.msgid = [NSString stringWithFormat:@"%@%@",USERINFO.userID,[self generateMessageID]];
    message.isGroup = NO;
    message.timeStamp = [NSDate currentTimeStamp];
    message.isSending = YES;
    message.picUrl = imagePath;
    [self.messages addObject:message];
    
    static NSInteger num;
    num = self.messages.count - 1;
    
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:num inSection:0];
    NSArray *indexPaths = @[indexpath];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    //图片压缩
    NSData *imageData = UIImageJPEGRepresentation(image, 0.3);
    
    //上传图片到服务器  获取返回的图片路径然后socket推送出去
    [LGNetWorking chatUploadPhoto:nil image:imageData fileName:[NSString stringWithFormat:@"%ld",[NSDate currentTimeStamp]] andFuctionName:nil block:^(NSDictionary *obj) {

        NSLog(@"obj ===== %@",obj);
        LGMessage *message = self.messages[num];
        message.isSending = NO;
        
        if ([obj[@"code"] integerValue] == 8888) {
            message.sendStatus = 1;
            message.text = obj[@"url"];
            SocketManager* socket = [SocketManager shareInstance];
            [socket sendMessage:message];
            
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@",AUDIOPATH,message.picUrl] error:nil];

        }else{
            // 发送报错
            message.sendStatus = 0;

        }
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:num inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];

    }failure:^(NSError *error) {
        
        // 发送失败
        LGMessage *message = self.messages[num];
        message.isSending = NO;
        message.sendStatus = 0;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:num inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }];

}

#pragma mark - SGMAlbumViewControllerDelegate
- (void)dnImagePickerController:(DNImagePickerController *)imagePickerController sendImages:(NSArray *)imageAssets isFullImage:(BOOL)fullImage {
    
    ALAssetsLibrary *lib = [ALAssetsLibrary new];

    //不是更换图片  ---  解析图片
    for (NSInteger index = 0; index < imageAssets.count; index++) {
        DNAsset *dnasset = imageAssets[index];
        [lib assetForURL:dnasset.url resultBlock:^(ALAsset *asset) {
            
            UIImage *image;
            
            if (fullImage) {
                image = [UIImage imageWithCGImage:asset.thumbnail];
            } else {

                image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:1 orientation:UIImageOrientationUp];
            }
            
            if (self.imagesArray.count > 8) {
                return ;
            }
            
            // 调整图片方向
            UIImageOrientation imageOrientation=image.imageOrientation;
            if(imageOrientation!=UIImageOrientationUp) {
                UIGraphicsBeginImageContext(image.size);
                [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
         
            [self.imagesArray removeAllObjects];
            [self.imagesArray addObject:image];
          
            [self sendImages:[self getImageSavePath:image]];
            
        } failureBlock:^(NSError *error) {
            
        }];
    }
    
    [imagePickerController dismissViewControllerAnimated:YES completion:^{
        self.tabBarController.tabBar.hidden = YES;
    }];
}


- (void)dnImagePickerControllerDidCancel:(DNImagePickerController *)imagePicker {
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        self.tabBarController.tabBar.hidden = YES;
    }];
    
}

#pragma mark - chatKeyboard datasource
- (NSArray<MoreItem *> *)chatKeyBoardMorePanelItems
{
//    MoreItem *item1 = [MoreItem moreItemWithPicName:@"sharemore_location" highLightPicName:nil itemName:@"位置"];
    MoreItem *item2 = [MoreItem moreItemWithPicName:@"sharemore_pic" highLightPicName:nil itemName:@"图片"];
    MoreItem *item3 = [MoreItem moreItemWithPicName:@"sharemore_video" highLightPicName:nil itemName:@"拍照"];

//    return @[item1, item2, item3];
    return @[item2, item3];

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


- (void)backAction {
    [FMDBShareManager setConverseUnReadCountZero:self.conversionId];
    [self.navigationController popViewControllerAnimated:YES];
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

- (NSMutableArray *)imagesArray {
    if (!_imagesArray) {
        _imagesArray = [NSMutableArray array];
    }
    return _imagesArray;
}


@end
