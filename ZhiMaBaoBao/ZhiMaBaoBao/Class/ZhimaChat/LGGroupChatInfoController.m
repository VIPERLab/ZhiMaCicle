//
//  LGGroupChatInfoController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/22.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGGroupChatInfoController.h"
//#import "LGGroupInfoHeaderCell.h"
//#import "TitleAndSwitchCell.h"
//#import "TitleAndPictureCell.h"
//#import "TitleAndSubTitleCell.h"

@interface LGGroupChatInfoController ()
@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NSArray *lastTitleArr;

@property (nonatomic, copy) NSString *roomName; //群聊名称
@property (nonatomic, copy) NSString *myName;   //我的群昵称
@property (nonatomic, copy) NSString *groupCode;    //群聊二维码地址


@end

@implementation LGGroupChatInfoController

- (NSArray *)titleArr{
    if (!_titleArr) {
        _titleArr = @[@"新消息提醒",@"置顶聊天",@"显示群昵称"];
    }
    return _titleArr;
}

- (NSArray *)lastTitleArr{
    if (!_lastTitleArr) {
        _lastTitleArr = @[@"查找聊天记录",@"清空聊天记录"];
    }
    return _lastTitleArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCustomTitle:@"聊天信息"];
    self.view.backgroundColor = BGCOLOR;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

//设置房间信息
- (void)setupRoomInfo{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    else if (section == 1 || section == 2){
        return 3;
    }
    else{
        return 2;
    }
    
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    

    
    if (indexPath.section == 0) {  //成员相册
        LGGroupInfoHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"headerCell"];
        if (!cell) {
            cell = [[LGGroupInfoHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"headerCell"];
        }
        return cell;
    }
    else if (indexPath.section == 1){
        if (indexPath.row == 2) {   //群二维码
            TitleAndPictureCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QRcodeCell"];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"TitleAndPictureCell" owner:nil options:nil] lastObject];
            }
            cell.mTitle.text = @"群二维码";
            return cell;
        }
        else{
            TitleAndSubTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"subTitleCell"];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"TitleAndSubTitleCell" owner:nil options:nil] lastObject];
            }
            if (indexPath.row == 0) {
                cell.mTitle.text = @"群聊名称";
                cell.mSubTitle.text = self.roomName;
            }
            else{
                cell.mTitle.text = @"我的群昵称";
                cell.mSubTitle.text = self.myName;
            }
            return cell;
        }
    }
    else if (indexPath.section == 2){
        TitleAndSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"switchCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"TitleAndSwitchCell" owner:nil options:nil] lastObject];
        }
        cell.mTitle.text = self.titleArr[indexPath.row];
        return cell;
    }
    else{
        TitleAndSubTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"TitleAndSubTitleCell" owner:nil options:nil] lastObject];
        }
        cell.mTitle.text = self.lastTitleArr[indexPath.row];
        return cell;
    }
 
  
}
*/

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 3) {
        UIView *footer = [self setupFooterView];
        return footer;
    }
    else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 3) {
        return 135;
    }else{
        return 0.1;
    }
}

- (UIView *)setupFooterView{
    
   //展示删除按钮
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 135)];
    footerView.backgroundColor = BGCOLOR;
    
    UIButton *sendMsg = [[UIButton alloc] initWithFrame:CGRectMake(14, 20, DEVICEWITH - 28, 48)];
    sendMsg.backgroundColor = THEMECOLOR;
    sendMsg.layer.cornerRadius = 5;
    sendMsg.titleLabel.font = MAINFONT;
    [sendMsg setTitle:@"删除并退出" forState:UIControlStateNormal];
    [sendMsg setTitleColor:WHITECOLOR forState:UIControlStateNormal];
    [sendMsg addTarget:self action:@selector(deleteAndLogout) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:sendMsg];
    return footerView;
}

//删除并退出按钮点击方法
- (void)deleteAndLogout{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

@end
