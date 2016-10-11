//
//  CreateGroupChatController.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//  发起群聊-> 只需要展示好友列表   转发创建聊天-> 展示选择一个群

#import "BaseViewController.h"
#import "LGMessage.h"

@interface CreateGroupChatController : BaseViewController

@property (nonatomic, assign) BOOL isPushFromTrans; //从转发控制器push (用来判断不同的导航栏返回方法)
@property (nonatomic, assign) BOOL hideFirstSection;    //是否隐藏第一组 "选择一个群"
@property (nonatomic, assign) BOOL hideFlagBtn;     //是否隐藏左侧选择框

@property (nonatomic, strong) LGMessage *transMsg;      //待转发的message
@end
