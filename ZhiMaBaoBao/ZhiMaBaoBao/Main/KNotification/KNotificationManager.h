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


//                    ------ 朋友圈消息通知 --------
// ----  点击了点赞人的名字的通知  富文本通知
#define KUserNameLabelNotification @"KUserNameLabelNotification"

// ---- 评论别人的通知
#define KCommentOtherNotification @"KCommentOtherNotification"

// ---- 朋友圈长按文字文本通知
// info :  @"contentLabel" : 文本控件
#define KDiscoverLongPressContentNotification @"KDiscoverLongPressContentNotification"
#define KDiscoverDisLongPressContentNotificaion @"KDiscoverDisLongPressContentNotificaion"


//                    ------ 发布朋友圈通知 --------
// ---- 唤起ImagePicker通知
#define K_NewDiscoverPhotoPickerNotifcation @"KNewDiscoverPhotoPickerNotifcation"

// ---- 取消响应通知
#define K_NewDiscoverPhotoClickNotifcation @"KNewDiscoverPhotoClickNotifcation"





//                    ------ 登录通知 --------
//登录成功，跳转到主控制器
#define LOGIN_SUCCESS @"login_success"

//退出登录成功
#define LOGOUT_SUCCESS @"clearLoginState"

//弹出登录框的通知
#define Show_Login @"shouldLogin"


#endif /* KNotificationManager_h */
