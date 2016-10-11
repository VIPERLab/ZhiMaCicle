//
//  SystemChatCell.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/10.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "SystemChatCell.h"

@implementation SystemChatCell

#define DEFAULT_CHAT_FONT_SIZE      13  //系统labelde字体
#define DEFAULT_CHAT_MESSAGE_MAX_WIDTH      150.0  //系统label的最大宽度


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self customInit];
        
        self.userInteractionEnabled = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = WHITECOLOR;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)customInit
{
    _systemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, DEVICEWITH - 120, 20)];
    _systemLabel.backgroundColor = RGB(206, 206, 206);
    _systemLabel.font = [UIFont systemFontOfSize:13];;
    _systemLabel.textColor = WHITECOLOR;
    _systemLabel.textAlignment = 1;
    _systemLabel.numberOfLines = 0;
    _systemLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_systemLabel];
    
    _topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 0, 0)];
    _topLabel.textColor = [UIColor whiteColor];
    _topLabel.font = SUBFONT;
    _topLabel.backgroundColor= RGB(206, 206, 206);
    _topLabel.textAlignment = 1;
    [self.contentView addSubview:_topLabel];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _topLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [_topLabel sizeToFit];
    _topLabel.width += 10;
    _topLabel.height += 3;
    [_topLabel centerAlignHorizontalForSuperView];

    CGSize size = [_systemLabel sizeThatFits:CGSizeMake(_systemLabel.frame.size.width, MAXFLOAT)];
    _systemLabel.frame = CGRectMake(_systemLabel.frame.origin.x, _systemLabel.frame.origin.y, _systemLabel.frame.size.width, size.height);
    
    if (_topLabel.text) {
        [_systemLabel setFrameOriginYBelowView:_topLabel offset:10];
    }else{
        _systemLabel.frame = CGRectMake(_systemLabel.frame.origin.x, 10, _systemLabel.frame.size.width, size.height);
    }
    
    [_systemLabel centerAlignHorizontalForSuperView];
    [_systemLabel sizeToFit];
    _systemLabel.width += 10;
    _systemLabel.height += 10;
    [_systemLabel centerAlignHorizontalForSuperView];
    
    _systemLabel.layer.cornerRadius = 3;
    _systemLabel.layer.masksToBounds = YES;
    
    _topLabel.layer.cornerRadius = 5;
    _topLabel.layer.masksToBounds = YES;
 

}


+ (CGFloat)getHeightWithMessage:(NSString *)message topText:(NSString *)topText nickName:(NSString *)nickName
{
 
//    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH - 120, 20)];
//    label.font = [UIFont systemFontOfSize:13];;
//    label.numberOfLines = 0;
//    label.lineBreakMode = NSLineBreakByWordWrapping;
//    label.text = message;
//    CGSize size = [label sizeThatFits:CGSizeMake(label.frame.size.width, MAXFLOAT)];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:13],NSFontAttributeName, nil];
    CGSize size = [message boundingRectWithSize:CGSizeMake( DEVICEWITH - 120, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:dic context:nil].size;
    CGFloat height = topText ? size.height + 30 + 30 : size.height + 30 ;
    return  height;
}


@end
