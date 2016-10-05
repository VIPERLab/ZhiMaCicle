//
//  ChatInfoCell.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ChatInfoCell.h"

@implementation ChatInfoCell {
    UILabel *_titleLabel;
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
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.textColor = [UIColor blackColor];
    [self addSubview:_titleLabel];
    
    self.statusSwitch = [UISwitch new];
    _statusSwitch.hidden = YES;
    _statusSwitch.onTintColor = THEMECOLOR;
    [_statusSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_statusSwitch];
    
    _bottomLineView = [UIView new];
    _bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"dedede"];
    [self addSubview:_bottomLineView];
    
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setShowSwitch:(BOOL)showSwitch {
    _showSwitch = showSwitch;
    if (showSwitch) {
        _statusSwitch.hidden = NO;
    } else {
        _statusSwitch.hidden = YES;
    }
}


- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
}


- (void)switchChange:(UISwitch *)statusSwitch {
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_Converse_Table];
    NSString *option1 = [NSString string];
    NSString *option2 = [NSString stringWithFormat:@"converseId = %@",self.converseID];
    if (self.indexPath.row == 0) {
        // 新消息提醒 disturb
        option1 = [NSString stringWithFormat:@"disturb = '%zd'",!statusSwitch.on];
        
    } else if (self.indexPath.row == 1) {
        // 消息置顶 topChat
        option1 = [NSString stringWithFormat:@"topChat = '%zd'",statusSwitch.on];
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


- (void)layoutSubviews {
    CGFloat titleX = 10;
    CGFloat titleY = 0;
    CGFloat titleW = [_titleLabel.text sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(MAXFLOAT, 15)].width;
    CGFloat titleH = CGRectGetHeight(self.frame);
    _titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    
    CGFloat switchW = 51;
    CGFloat switchH = 31;
    CGFloat switchX = CGRectGetWidth(self.frame) - switchW - 20;
    CGFloat switchY = (CGRectGetHeight(self.frame) - switchH)* 0.5;
    _statusSwitch.frame = CGRectMake(switchX, switchY, switchW, switchH);
    
    _bottomLineView.frame = CGRectMake(titleX, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame) - titleX, 0.5);
}



@end
