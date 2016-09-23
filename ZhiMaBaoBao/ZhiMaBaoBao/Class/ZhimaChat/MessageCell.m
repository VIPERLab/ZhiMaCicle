//
//  MessageCell.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/21.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "MessageCell.h"

@interface MessageCell ()
@property (nonatomic, strong) UILabel *timeLabel;       //时间
@property (nonatomic, strong) UIImageView *avtar;       //头像
@property (nonatomic, strong) UIImageView *bulldeView;  //消息容器
@property (nonatomic, strong) UILabel *msgLabel;        //消息文本label
@end

@implementation MessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews{
    //时间
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.backgroundColor = [UIColor colorFormHexRGB:@"#cecece"];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.layer.cornerRadius = 4.0f;
    timeLabel.clipsToBounds = YES;
    timeLabel.textColor = WHITECOLOR;
    [self.contentView addSubview:timeLabel];
    
    //头像
    UIImageView *avtar = [[UIImageView alloc] init];
    [self.contentView addSubview:avtar];
    self.avtar = avtar;
    
    //消息容器试图
    UIImageView *bulldeView = [[UIImageView alloc] init];
    [self.contentView addSubview:bulldeView];
    self.bulldeView = bulldeView;
    
    //消息文本
    UILabel *msglabel = [[UILabel alloc] init];
    msglabel.numberOfLines = 0;
    msglabel.font = MSG_FONT;
    msglabel.textAlignment = NSTextAlignmentLeft;
    [self.bulldeView addSubview:msglabel];
    self.msgLabel = msglabel;
}

- (void)setMessage:(LGMessage *)message{
    _message = message;
    
    self.avtar.image = [UIImage imageNamed:@"defaultContact"];
    self.msgLabel.text = message.body;
    self.timeLabel.text = message.time;
}

- (void)layoutSubviews{
    
    //设置时间的frame

    //用户自己
    if (_message.isUser) {
        self.avtar.frame = CGRectMake(DEVICEWITH - MSG_AVTAR_SIZE - MSG_MARGIN, MSG_PADDING , MSG_AVTAR_SIZE, MSG_AVTAR_SIZE);
        self.bulldeView.image = [UIImage imageNamed:@"chat_bg_sender"];
        self.bulldeView.frame = CGRectMake(DEVICEWITH - MSG_AVTAR_SIZE - MSG_MARGIN - _message.textWH.width - 3 * MSG_MARGIN, MSG_PADDING, _message.textWH.width + 3 * MSG_MARGIN, _message.buddleHeight);
        self.msgLabel.frame = CGRectMake(MSG_MARGIN, MSG_MARGIN, _message.textWH.width, _message.textWH.height);

    }else{
        self.avtar.frame = CGRectMake(MSG_MARGIN, MSG_PADDING , MSG_AVTAR_SIZE, MSG_AVTAR_SIZE);
        self.bulldeView.image = [UIImage imageNamed:@"chat_bg_reciever"];
        self.bulldeView.frame = CGRectMake(MSG_AVTAR_SIZE + MSG_MARGIN , MSG_PADDING, _message.textWH.width + 3 * MSG_MARGIN, _message.buddleHeight);
        self.msgLabel.frame = CGRectMake(MSG_MARGIN * 2, MSG_MARGIN, _message.textWH.width, _message.textWH.height);

    }
    

}

@end
