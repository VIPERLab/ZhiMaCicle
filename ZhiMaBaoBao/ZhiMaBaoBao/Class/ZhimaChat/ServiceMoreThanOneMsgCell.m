//
//  ServiceMoreThanOneMsgCell.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/31.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ServiceMoreThanOneMsgCell.h"
#import "ServiceMsgCell.h"

@interface ServiceMoreThanOneMsgCell ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *messages;

@end

@implementation ServiceMoreThanOneMsgCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


#pragma mark - init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.messages = [NSMutableArray array];
        self.userInteractionEnabled = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = WHITECOLOR;
        [self customInit];

    }
    return self;
}

- (void)customInit
{
    CGFloat width = DEVICEWITH-36;
    
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(18, 15, width, 20)];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = SUBFONT;
    self.timeLabel.backgroundColor= RGB(206, 206, 206);
    self.timeLabel.textAlignment = 1;
    self.timeLabel.layer.cornerRadius = 3;
    self.timeLabel.layer.masksToBounds = YES;
    self.timeLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self.contentView addSubview:self.timeLabel];
    
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(18, self.timeLabel.frameMaxY+15, width, 510)];
    self.tableview.layer.cornerRadius = 5;
    self.tableview.layer.borderWidth = 1;
    self.tableview.layer.borderColor = htmlColor(@"d9d9d9").CGColor;
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.scrollEnabled = NO;
    [self.contentView addSubview:self.tableview];
    
    [self initHeadView:width];

}

- (void)initHeadView:(CGFloat)width
{
    UIView*headview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 205)];
    
    self.headIV = [[UIImageView alloc]initWithFrame:CGRectMake(12, 12, width-24, 205-24)];
//    self.headIV.backgroundColor = 
    self.headIV.contentMode =  UIViewContentModeScaleAspectFill;
    self.headIV.clipsToBounds  = YES;
    [headview addSubview:self.headIV];
    
    UIView*bgView = [[UIView alloc]initWithFrame:CGRectMake(12, 205-30-12, width-24, 30)];
    bgView.backgroundColor = BLACKCOLOR;
    bgView.alpha = 0.6;
    [headview addSubview:bgView];
    
    self.headLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 205-30-12, width-30, 30)];
    self.headLabel.backgroundColor = [UIColor clearColor];
    self.headLabel.textColor = WHITECOLOR;
    self.headLabel.font = [UIFont systemFontOfSize:17];
    [headview addSubview:self.headLabel];
    
    UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    headview.userInteractionEnabled = YES;
    [headview addGestureRecognizer:tap];
    
    self.tableview.tableHeaderView = headview;
}

#pragma mark - data

- (void)setMessage:(ZMServiceMessage *)message
{
//    self.messages = [message.msgArr mutableCopy];
//    ZMServiceMessage*msg = self.messages[0];
//    [self.headIV sd_setImageWithURL:[NSURL URLWithString:msg.msgPicUrl]];
//    self.headLabel.text = msg.msgTitle;
    
    NSString*timeStr = [NSDate dateStrFromCstampTime:message.timeStamp withDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.timeLabel.text = [NSString timeStringChangeToZMTimeString:timeStr];
    [self.timeLabel sizeToFit];
    self.timeLabel.width += 10;
    self.timeLabel.center = CGPointMake(DEVICEWITH/2, 15+10);
    
    self.tableview.frameSizeHeight = 205+(self.messages.count-1)*50;
    
    [self.tableview reloadData];
}

#pragma mark - action

- (void)tapAction
{
    if ([self.delegate respondsToSelector:@selector(havetouchCell:)]) {
        [self.delegate havetouchCell:self.messages[0]];
    }
}

#pragma mark - tableviewDelegae

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ServiceMsgCell *serviceMsgCell = [tableView dequeueReusableCellWithIdentifier:@"ServiceMsgCell"];
    if(!serviceMsgCell) {
        serviceMsgCell = [[ServiceMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ServiceMsgCell"];
    }
    ZMServiceMessage*msg = self.messages[indexPath.row+1];
    serviceMsgCell.message = msg;
    
    return serviceMsgCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.messages.count -1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(havetouchCell:)]) {
        [self.delegate havetouchCell:self.messages[indexPath.row + 1]];
    }
}

@end
