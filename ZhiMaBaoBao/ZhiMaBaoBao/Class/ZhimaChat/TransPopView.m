//
//  TransPopView.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/9.
//  Copyright © 2016年 liugang. All rights reserved.
//  转发消息时弹出的试图

#define pop_margin 20
#define pop_height 300      //popView的高度

#import "TransPopView.h"
#import "ZhiMaFriendModel.h"
#import "POP.h"
#import "ConverseModel.h"

@interface TransPopView ()
@property (nonatomic, strong) LGMessage *transMsg;  //转发消息
@property (nonatomic, strong) NSString *toUserId;   //消息转发uid
@property (nonatomic, strong) UIView *containerView;    //容器试图
@end

@implementation TransPopView

- (instancetype)initWithMessage:(LGMessage *)message toUserId:(NSString *)userId isGroup:(BOOL)isGroup{
    
    
    self = [[TransPopView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.backgroundColor = [UIColor clearColor];
    
    self.transMsg = message;
    self.toUserId = userId;
    
    UIView *blackView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    blackView.backgroundColor = [UIColor blackColor];
    blackView.alpha = .6f;
    [self addSubview:blackView];
    
    //容器试图
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 4.f;
    containerView.userInteractionEnabled = YES;
    containerView.width = DEVICEWITH - pop_margin * 2;
    containerView.height = pop_height;
    containerView.x = pop_margin;
    containerView.y = (DEVICEHIGHT - pop_height)/2;
    [self addSubview:containerView];
    self.containerView = containerView;
    
    //设置所有子试图
    [self setupSubviews:message toUserId:userId isGroup:isGroup];
    return self;
}

- (void)setupSubviews:(LGMessage *)message toUserId:(NSString *)userId isGroup:(BOOL)isGroup{
    
    //头像url
    NSString *avtarUrl = nil;
    //好友昵称或者群名称
    NSString *name = nil;
    
    if (isGroup) {
        //从会话列表拿群会话
        ConverseModel *groupModel = [FMDBShareManager searchConverseWithConverseID:userId andConverseType:YES];
        avtarUrl = groupModel.converseHead_photo;
        name = groupModel.converseName;
    }else{
        //通过uid查询好友资料
        ZhiMaFriendModel *model = [FMDBShareManager getUserMessageByUserID:userId];
        avtarUrl = model.user_Head_photo;
        name = model.displayName;
    }
    

    CGFloat avtarS = 40;    //头像大小
    CGFloat padding = 10;    //内边距
    
    //头像，昵称
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"发送给：";
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.frame = CGRectMake(pop_margin, pop_margin, 100, 30);
    [self.containerView addSubview:titleLabel];
    
    UIImageView *avtar = [[UIImageView alloc] init];
    [avtar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,avtarUrl]] placeholderImage:[UIImage imageNamed:@"defaultContact"]];
    avtar.size = CGSizeMake(avtarS, avtarS);
    avtar.x = pop_margin;
    avtar.y = CGRectGetMaxY(titleLabel.frame) + padding;
    [self.containerView addSubview:avtar];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = name;
    nameLabel.font = MAINFONT;
    nameLabel.frame = CGRectMake(pop_margin + avtarS + padding, avtar.y, self.containerView.width - pop_margin*2 + avtarS + padding, avtarS);
    [self.containerView addSubview:nameLabel];
    
    UIView *separtor = [[UIView alloc] init];
    separtor.backgroundColor = SEPARTORCOLOR;
    separtor.frame = CGRectMake(pop_margin, CGRectGetMaxY(avtar.frame) + padding *2, self.containerView.width - pop_margin *2, 0.5);
    [self.containerView addSubview:separtor];
    
    //存放转发内容的试图
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.x = 0;
    contentView.y = CGRectGetMaxY(separtor.frame);
    contentView.width = DEVICEWITH;
    [self.containerView addSubview:contentView];
    if (message.type == MessageTypeText) {
        //消息内容文本
        UILabel *contentLabel = [[UILabel alloc] init];
        contentLabel.text = message.text;
        contentLabel.numberOfLines = 2;
        contentLabel.textColor = GRAYCOLOR;
        contentLabel.font = [UIFont systemFontOfSize:15];
        contentLabel.frame = CGRectMake(pop_margin, 0, self.containerView.width - pop_margin *2, 60);
        [contentView addSubview:contentLabel];
        contentView.height = CGRectGetMaxY(contentLabel.frame);

    }else if (message.type == MessageTypeImage){
        //图片
        UIImageView *imageview = [[UIImageView alloc] init];
        imageview.layer.cornerRadius = 5.f;
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        imageview.clipsToBounds = YES;
        [imageview sd_setImageWithURL:[NSURL URLWithString:message.text]];
        imageview.size = CGSizeMake(100, 100);
        imageview.x = (self.containerView.width - 100)/2;
        imageview.y = 10;
        [contentView addSubview:imageview];
        contentView.height = CGRectGetMaxY(imageview.frame);
    }
    
    
    UIView *separtor1 = [[UIView alloc] init];
    separtor1.backgroundColor = SEPARTORCOLOR;
    separtor1.frame = CGRectMake(0, CGRectGetMaxY(contentView.frame)+10, self.containerView.width, .5);
    [self.containerView addSubview:separtor1];
    
    //取消、发送按钮
    UIButton *cancelBtn = [[UIButton alloc] init];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:BLACKCOLOR forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelTransAction) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.size = CGSizeMake(self.containerView.width/2, 50);
    cancelBtn.x = 0;
    cancelBtn.y = CGRectGetMaxY(separtor1.frame);
    [self.containerView addSubview:cancelBtn];
    
    UIView *separtor2 = [[UIView alloc] init];
    separtor2.backgroundColor = SEPARTORCOLOR;
    separtor2.frame = CGRectMake(CGRectGetMaxX(cancelBtn.frame), cancelBtn.y, 0.5,50);
    [self.containerView addSubview:separtor2];
    
    UIButton *sendBtn = [[UIButton alloc] init];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendTransAction) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.size = CGSizeMake(self.containerView.width/2 - 0.5, 50);
    sendBtn.x = CGRectGetMaxX(separtor2.frame);
    sendBtn.y = cancelBtn.y;
    [self.containerView addSubview:sendBtn];
    
    
    self.containerView.height = CGRectGetMaxY(sendBtn.frame);
    self.containerView.y = (DEVICEHIGHT - self.containerView.height)/2;

}

//发送
- (void)sendTransAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(transformMessage:toUserId:)]) {
        [self.delegate transformMessage:self.transMsg toUserId:self.toUserId];
        [self removeFromSuperview];
    }
}

//取消
- (void)cancelTransAction{
    [self removeFromSuperview];
}

- (void)show{
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];

}



@end
