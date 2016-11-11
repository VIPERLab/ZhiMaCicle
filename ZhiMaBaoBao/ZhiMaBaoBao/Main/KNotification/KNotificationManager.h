//
//  KNotificationManager.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/20.
//  Copyright © 2016年 liugang. All rights reserved.
//

#ifndef KNotificationManager_h
#define KNotificationManager_h


// --   进入前台的通知
#define KEnteryForeground_Notification @"KEnteryForeground_Notification"


//                    ------ 网络状态通知 --------
// 没有网络
#define K_WithoutNetWorkNotification @"KWithoutNetwrokingNotification"
// 网络恢复
#define K_NetworkRecoveryNotification @"KNetworkRecoveryNotification"



//                    ------ 朋友圈未读消息通知 --------
/**
 *  通知appDelegate更新未读消息
 */
#define K_UpdataUnReadNotification @"UpdataUnReadNotification"
/**
 *  未读消息的通知
 *  info @{count : 未读消息数 , headphoto : 未读消息的头像}
 */
#define K_UpDataUnReadCountNotification @"KUpDataUnReadCountNotification"
/**
 *  未读朋友圈
 *  info @{ circleheadphoto : 未读朋友圈的头像 }
 */
#define K_UpDataHeaderPhotoNotification @"KUpDataHeaderPhotoNotification"




#pragma mark - 朋友圈消息通知
//                    ------ 朋友圈消息通知 --------
// 更新朋友圈通知
#define K_UpDataCircleDataNotification @"KUpDataCircleDataNotification"


/**
 更新朋友圈数据源通知
 info @{ circleModel : 新的朋友圈数据模型 }
 */
#define K_ReFreshCircleDataNotification @"KReFreshCircleDataNotification"

/**
 点击了用户的名字的通知
 info @{ userId : 点击的用户的userId }
 */
#define KUserNameLabelNotification @"K_UserNameLabelNotification"

/*
 * 评论框点击了链接
 * info @{ linkValue : 网址路径 }
 */
#define KDiscoverCommentURLNotification @"K_DiscoverCommentURLNotification"


/* 不让对方看自己的朋友圈
 * info @{deleteUid : 需要删除的朋友圈}
 */
#define K_NotLookMyCircleNotification @"K_NotLookMyCircleNotification"


/**
 删除自己的某条朋友圈
 
 info @{ circleId : 要删除的朋友圈id }
 */
#define K_DelMyCircleNotification @"KDelMyCircleNotification"



// ---- 评论别人的通知
#define KCommentOtherNotification @"KCommentOtherNotification"

/**
 朋友圈长按文字文本通知

 info @{ contentLabel : 文本控件,  cell : 当前文本所在的cell}
 */
#define KDiscoverLongPressContentNotification @"K_DiscoverLongPressContentNotification"

#define KDiscoverDisLongPressContentNotificaion @"K_DiscoverDisLongPressContentNotificaion"

#define KDiscoverCommentViewClickNotification @"K_DiscoverCommentViewClickNotification"


#pragma mark - 发布新朋友圈通知
//                    ------ 发布朋友圈通知 --------
// ---- 取消响应通知
// userInfo : { CurrentSelectedButton : 当前选中的按钮 }
#define K_NewDiscoverPhotoClickNotifcation @"KNewDiscoverPhotoClickNotifcation"

//  图片转发通知
//  userInfo = @{imageContent = 要转发的图片}
#define K_ForwardPhotoNotifation @"KForwardPhotoNotifation"


#pragma mark - 登录通知
//                    ------ 登录通知 --------
//登录成功，跳转到主控制器
#define LOGIN_SUCCESS @"login_success"

//退出登录成功
#define LOGOUT_SUCCESS @"clearLoginState"

//弹出登录框的通知
#define Show_Login @"shouldLogin"


#pragma mark - 消息通知
//                    ------ 消息通知 --------
//相同的用户登录
#define kOtherLogin @"kOtherLogin"
//发送消息状态回调通知
#define kSendMessageStateCall @"kSendMessageStateCall"
//收到新消息
#define kRecieveNewMessage @"kRecieveNewMessage"
//新的好友请求
#define kNewFriendRequest @"kNewFriendRequest"
//收到活动推送消息
#define kRecieveActivityMsg @"kRecieveActivityMsg"

//更新未读消息
#define kUpdateUnReadMessage @"kUpdateUnReadMessage"

//对方同意我的好友请求
#define kOtherAgreeMyFrendRequest @"kOtherAgreeMyFrendRequest"

#define kRefreshConversionList @"kRefreshConversionList"

//离开聊天界面（停止播放视频）
#define kChatViewControllerPopOut @"kChatViewControllerPopOut"




#endif /* KNotificationManager_h */
