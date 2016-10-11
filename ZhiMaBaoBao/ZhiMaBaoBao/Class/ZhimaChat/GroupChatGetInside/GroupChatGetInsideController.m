//
//  GroupChatGetInsideController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/11.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "GroupChatGetInsideController.h"
#import "GroupChatModel.h"


@interface GroupChatGetInsideController ()
@property (nonatomic, weak) GroupChatModel *groupChatModel;
@end

@implementation GroupChatGetInsideController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setGroupModel];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setGroupModel {
    //根据id 查询群信息
    [LGNetWorking getGroupInfo:USERINFO.sessionId groupId:self.groupId success:^(ResponseData *responseData) {
        
        if (responseData.code != 0) {
            [LCProgressHUD showFailureText:responseData.msg];
        }
        
        //生成群聊数据模型
        [GroupChatModel mj_setupObjectClassInArray:^NSDictionary *{
            return @{
                     @"groupUserVos":@"GroupUserModel"
                     };
        }];
        GroupChatModel *groupChatModel = [GroupChatModel mj_objectWithKeyValues:responseData.data];
        self.groupChatModel = groupChatModel;
        self.groupChatModel.myGroupName = USERINFO.username;
        
        [self setupView];
        
    } failure:^(ErrorData *error) {
        
    }];

}


- (void)setupView {
    
    UIView *firstView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, 180)];
    firstView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:firstView];
    
    CGFloat imageW = 65;
    CGFloat imageH = imageW;
    CGFloat imageX = (ScreenWidth - imageW) * 0.5;
    CGFloat imageY = (CGRectGetHeight(firstView.frame) - imageH) * 0.5 - 20;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,self.groupChatModel.groupAvtar]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
    [firstView addSubview:imageView];
    
    UILabel *groupNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 10, ScreenWidth, 20)];
    groupNameLabel.textAlignment = NSTextAlignmentCenter;
    groupNameLabel.font = [UIFont systemFontOfSize:17];
    groupNameLabel.text = self.groupChatModel.groupName;
    [firstView addSubview:groupNameLabel];
    
    UILabel *groupCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(groupNameLabel.frame)+10, ScreenWidth, 15)];
    [firstView addSubview:groupCountLabel];
    groupCountLabel.textColor = [UIColor colorFormHexRGB:@"888888"];
    groupCountLabel.textAlignment = NSTextAlignmentCenter;
    groupCountLabel.font = [UIFont systemFontOfSize:12];
    groupCountLabel.text = [NSString stringWithFormat:@"(共%zd人)",self.groupChatModel.groupUserVos.count];
    
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(firstView.frame) + 30, ScreenWidth, 50)];
    tipsLabel.text = @"确认加入群聊";
    tipsLabel.font = [UIFont systemFontOfSize:20];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipsLabel];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((ScreenWidth - 200) * 0.5, CGRectGetMaxY(tipsLabel.frame) + 10, 200, 40)];
    [button setTitle:@"加入该群聊" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addToGroup) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = THEMECOLOR;
    button.layer.cornerRadius = 5;
    [self.view addSubview:button];
    
}


- (void)addToGroup {
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
