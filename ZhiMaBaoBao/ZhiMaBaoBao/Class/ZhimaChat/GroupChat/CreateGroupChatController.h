//
//  CreateGroupChatController.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseViewController.h"

@interface CreateGroupChatController : BaseViewController

@property (nonatomic, assign) BOOL isPushFromTrans; //从转发控制器push (用来判断不同的导航栏返回方法)
@property (nonatomic, assign) BOOL hideFirstSection;    //是否隐藏第一组 "选择一个群"


@end
