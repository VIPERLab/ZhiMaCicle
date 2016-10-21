//
//  SocketManager.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/22.
//  Copyright © 2016年 liugang. All rights reserved.
//

//static NSString *HOST = @"192.168.1.248"; //socket
//static NSString *HOST = @"192.168.1.249"; //测试环境
//static NSString *HOST = @"112.74.143.151"; //测试环境

static NSString *HOST = @"im.zhimabaobao.com"; //正式环境
static const uint16_t PORT = 9093;

//消息操作类型  --  用来生成发送给socket数据包
typedef NS_OPTIONS(NSUInteger, RequestType) {
    RequestTypeLogin    = 0,   //登录
    RequestTypeHeart,          //心跳包
    RequestTypeMessage,        //接收，发送普通消息
    RequestTypeUndo,           //撤销消息
    RequestTypeCreateGroup,     //建群
    RequestTypeNotLookCircle
};

//群操作类型  --  用来生成发送给socket数据包
typedef NS_OPTIONS(NSUInteger, GroupActType) {
    GroupActTypeCreate   = 0,   //建群
    GroupActTypeAddUser,        //邀请用户到群
    GroupActTypeDelUser,        //从群组删除用户
    GroupActTypeDelGroup,       //删除群组
    GroupActTypeReName,         //重命名群
    GroupActTypeUpdateName      //群组成员更新昵称
};

//好友操作类型  --  用来生成发送给socket数据包
typedef NS_OPTIONS(NSUInteger, FriendActType) {
    FriendActTypeAdd   = 0,     //添加好友
    FriendActTypeAgreee,        //同意好友请求
    FriendActTypeBlack,         //加入黑名单
    FriendActTypeUpdate         //好友资料更新
};


#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "LGMessage.h"

@protocol SocketManagerDelegate <NSObject>

@optional
- (void)recievedMessage:(LGMessage *)message;

@end


@interface SocketManager : NSObject

@property (nonatomic, assign) id<SocketManagerDelegate> delegate;

+ (instancetype)shareInstance;

/**
 *  连接服务器
 */
- (void)connect;

/**
 *  断开连接
 */
- (void)disconnect;

/**
 *  发送消息
 *
 *  @param message 消息数据模型
 */
- (void)sendMessage:(LGMessage *)message;

/**
 *  重新发送消息
 */
- (void)reSendMessage:(LGMessage *)message;

/**
 *  删除消息
 */
- (void)deleteMessage:(LGMessage *)message;

/**
 *  撤销消息
 */
- (void)undoMessage:(LGMessage *)message;

#pragma mark - 群相关操作

/**
 *  建群
 *  @param groupId 群id  （调用https接口获取群id）
 *  @param uids    群成员id （用逗号拼接）
 */
- (void)createGtoup:(NSString *)groupId uids:(NSString *)uids;

/**
 *  邀请用户到群
 */
- (void)addUserToGroup:(NSString *)groupId uids:(NSString *)uids;

/**
 *  从群组删除用户
 *  @param groupId 群id
 *  @param uids    群成员id  (删除群组：传uid, 群重命名：传新的群名称)
 */
- (void)delUserFromGroup:(NSString *)groupId uids:(NSString *)uids;

/**
 *  删除群组（退出群）
 *
 *  @param groupId 群id
 *  @param uid     用户id
 */
- (void)delGroup:(NSString *)groupId uid:(NSString *)uid;

/**
 *  群重命名
 *
 *  @param groupId 群id
 *  @param name    群名称
 */
- (void)renameGroup:(NSString *)groupId name:(NSString *)name;

/**
 *  群用户更新昵称
 *
 *  @param name    新的群昵称
 *  @param groupId 群id
 */
- (void)groupUserUpdateName:(NSString *)name groupId:(NSString *)groupId;

#pragma mark - 好友相关操作
/**
 *  添加好友
 *
 *  @param friendId 好友id
 */
- (void)addFriend:(NSString *)friendId;

/**
 *  同意好友请求
 *
 *  @param friendId 好友id
 */
- (void)agreeFriendRequest:(NSString *)friendId;

//直接调用https接口
///**
// *  删除好友
// *
// *  @param friendId 好友id
// */
//- (void)delFriend:(NSString *)friendId;

/**
 *  加入黑名单
 *
 *  @param friendId 好友id
 */
- (void)dragToBlack:(NSString *)friendId;

/**
 *  不让对方看自己的朋友圈
 *
 *  @param friendId 好友id
 */
- (void)notAllowFriendCircle:(NSString *)friendId;


@end
