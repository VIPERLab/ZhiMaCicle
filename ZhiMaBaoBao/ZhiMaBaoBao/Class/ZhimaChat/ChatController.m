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

@interface ChatController ()<UITableViewDelegate,UITableViewDataSource,ChatKeyBoardDelegate,ChatKeyBoardDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ChatKeyBoard *keyboard;

@property (nonatomic, strong) NSMutableArray *messages;  //聊天消息
@end

static NSString *const reuseIdentifier = @"messageCell";
@implementation ChatController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self addSubviews];
    [self requestChatRecord];
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

//tableview滚动到底部


#pragma mark - chatKeyboard datasource
- (NSArray<MoreItem *> *)chatKeyBoardMorePanelItems
{
    MoreItem *item1 = [MoreItem moreItemWithPicName:@"sharemore_location" highLightPicName:nil itemName:@"位置"];
    MoreItem *item2 = [MoreItem moreItemWithPicName:@"sharemore_pic" highLightPicName:nil itemName:@"图片"];
    MoreItem *item3 = [MoreItem moreItemWithPicName:@"sharemore_video" highLightPicName:nil itemName:@"拍照"];
    MoreItem *item4 = [MoreItem moreItemWithPicName:@"sharemore_location" highLightPicName:nil itemName:@"位置"];
    MoreItem *item5 = [MoreItem moreItemWithPicName:@"sharemore_pic" highLightPicName:nil itemName:@"图片"];
    MoreItem *item6 = [MoreItem moreItemWithPicName:@"sharemore_video" highLightPicName:nil itemName:@"拍照"];
    MoreItem *item7 = [MoreItem moreItemWithPicName:@"sharemore_location" highLightPicName:nil itemName:@"位置"];
    MoreItem *item8 = [MoreItem moreItemWithPicName:@"sharemore_pic" highLightPicName:nil itemName:@"图片"];
    MoreItem *item9 = [MoreItem moreItemWithPicName:@"sharemore_video" highLightPicName:nil itemName:@"拍照"];
    return @[item1, item2, item3, item4, item5, item6, item7, item8, item9];
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


#pragma mark - lazy
- (NSMutableArray *)messages{
    if (!_messages) {
        _messages = [NSMutableArray array];
    }
    return _messages;
}

@end
