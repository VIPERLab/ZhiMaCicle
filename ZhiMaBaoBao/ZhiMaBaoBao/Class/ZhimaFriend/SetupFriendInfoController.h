//
//  SetupFriendInfoController.h
//  YiIM_iOS
//
//  Created by liugang on 16/8/13.
//  Copyright © 2016年 ikantech. All rights reserved.
//  设置好友资料

#import "BaseViewController.h"
#import "ZhiMaFriendModel.h"

@interface SetupFriendInfoController : BaseViewController

@property (nonatomic, copy) NSString *nickNametext;

@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (nonatomic, copy) NSString *jid;


@property (nonatomic, assign) BOOL isFromSearch;
@property (nonatomic, strong) ZhiMaFriendModel *friendModel;

@end
