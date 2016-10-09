//
//  GroupChatInfoCell.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "GroupChatInfoCell.h"

@implementation GroupChatInfoCell {
    UILabel *_titleLabel;
    UILabel *_subTitleLabel;
    UIImageView *_subImageView;
    UIView *_bottomLineView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _titleLabel = [UILabel new];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:_titleLabel];
    
    _subTitleLabel = [UILabel new];
    _subTitleLabel.textAlignment = NSTextAlignmentRight;
    _subTitleLabel.font = [UIFont systemFontOfSize:15];
    _subTitleLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:_subTitleLabel];
    
    _subImageView = [UIImageView new];
    _subImageView.hidden = YES;
    [self addSubview:_subImageView];
    
    _bottomLineView = [UIView new];
    _bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"dedede"];
    [self addSubview:_bottomLineView];
    
    self.statusSwitch = [UISwitch new];
    _statusSwitch.onTintColor = THEMECOLOR;
    [_statusSwitch addTarget:self action:@selector(statusValueChange:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_statusSwitch];
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setSubTitle:(NSString *)subTitle {
    _subTitle = subTitle;
    _subTitleLabel.hidden = NO;
    _subTitleLabel.text = subTitle;
    _subImageView.hidden = YES;
    _statusSwitch.hidden = YES;
}


- (void)setImageName:(NSString *)imageName {
    _subImageView.hidden = NO;
    _subImageView.image = [UIImage imageNamed:imageName];
    _subTitleLabel.hidden = YES;
    _statusSwitch.hidden = YES;
}

- (void)setShowStatuSwitch:(BOOL)showStatuSwitch {
    _subTitleLabel.hidden = YES;
    _subImageView.hidden = YES;
    _statusSwitch.hidden = NO;
}

- (void)statusValueChange:(UISwitch *)statusSwitch {
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_Converse_Table];
    NSString *option1 = [NSString string];
    NSString *option2 = [NSString stringWithFormat:@"converseId = %@",self.converseId];
    if (self.indexPath.section == 2 && self.indexPath.row == 0) {
        // 设置消息免打扰
        option1 = [NSString stringWithFormat:@"disturb = '%zd'",!statusSwitch.on];
    } else if (self.indexPath.section == 2 && self.indexPath.row == 1) {
        // 设置消息置顶
        option1 = [NSString stringWithFormat:@"topChat = '%zd'",statusSwitch.on];
    } else if (self.indexPath.section == 2 && self.indexPath.row == 2) {
        // 设置保存到通讯录
        
        [self saveToMailListRequest:statusSwitch.on];
        
        return;
    } else if (self.indexPath.section == 3 && self.indexPath.row == 1) {
        // 显示群名称
        option1 = [NSString stringWithFormat:@"showMemberName = '%zd'",statusSwitch.on];
        [self setupOptionInGroupMessageTable:option1];
        return;
    }
    
    NSString *opeartionStr = [FMDBShareManager alterTable:ZhiMa_Chat_Converse_Table withOpton1:option1 andOption2:option2];
    [queue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:opeartionStr];
        if (success) {
            NSLog(@"修改会话成功");
        } else {
            NSLog(@"修改会话失败");
        }
    }];
}

//(void)setupGroup:(NSString *)sessionId groupId:(NSString *)groupId functionName:(NSString *)functionName value:(NSString *)value success:(SuccessfulBlock)success failure:(FailureBlock)failure;
//  保存通讯录接口
- (void)saveToMailListRequest:(int)value {
    [LGNetWorking setupGroup:USERINFO.sessionId groupId:self.converseId functionName:@"save_to_contacts" value:[NSString stringWithFormat:@"%zd",value] success:^(ResponseData *responseData) {
        
        if (responseData.code != 0) {
            NSLog(@"%@",responseData.msg);
            return ;
        }
        
        
        NSString * option1 = [NSString stringWithFormat:@"saveToMailList = '%zd'",value];
        [self setupOptionInGroupMessageTable:option1];
        
    } failure:^(ErrorData *error) {
        
    }];
}


- (void)setupOptionInGroupMessageTable:(NSString *)option {
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_GroupChat_GroupMessage_Table];
    NSString *optionStr = [FMDBShareManager alterTable:ZhiMa_GroupChat_GroupMessage_Table withOpton1:option andOption2:[NSString stringWithFormat:@"groupId = '%@'",self.converseId]];
    [queue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:optionStr];
        if (success) {
            NSLog(@"修改会话成功");
        } else {
            NSLog(@"修改会话失败");
        }
        
    }];
    
    
}




- (void)layoutSubviews {
    CGFloat titleX = 10;
    CGFloat titleY = 0;
    CGFloat titleH = CGRectGetHeight(self.frame);
    CGFloat titleW = [_titleLabel.text sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(MAXFLOAT, 15)].width;
    _titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    
    CGFloat subTitleW = [_subTitleLabel.text sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(ScreenWidth * 0.5 , 15)].width;
    CGFloat subTitleH = CGRectGetHeight(self.frame);
    CGFloat subTitleX = CGRectGetWidth(self.frame) - subTitleW - 20;
    CGFloat subTitleY = 0;
    _subTitleLabel.frame = CGRectMake(subTitleX, subTitleY, subTitleW, subTitleH);
    

    
    CGFloat imageW = 20;
    CGFloat imageH = imageW;
    CGFloat imageX = CGRectGetWidth(self.frame) - imageW - 20;
    CGFloat imageY = (CGRectGetHeight(self.frame) - imageH) * 0.5;
    _subImageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
    
    CGFloat switchW = 51;
    CGFloat switchH = 31;
    CGFloat switchX = CGRectGetWidth(self.frame) - switchW - 20;
    CGFloat switchY = (CGRectGetHeight(self.frame) - switchH) * 0.5;
    _statusSwitch.frame = CGRectMake(switchX, switchY, switchW, switchH);
    
    _bottomLineView.frame = CGRectMake(titleX, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame) - titleX, 0.5);
}

@end
