//
//  DetailInfoCell.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/11/2.
//  Copyright © 2016年 liugang. All rights reserved.
//

#define LeftMargin 14
#define TopMargin 12
#define CellH 45

#import "DetailInfoCell.h"

@interface DetailInfoCell(){
    UILabel *_title;
    UILabel *_subTitle;
    UISwitch *_switch;
}

@end

@implementation DetailInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

//设置子试图
- (void)setupView{
    _title = [[UILabel alloc] init];
    _title.font = MAINFONT;
    _title.textColor = BLACKCOLOR;
    [self.contentView addSubview:_title];
    
    _subTitle = [[UILabel alloc] init];
    _subTitle.font = [UIFont systemFontOfSize:15];
    _subTitle.textColor = RGB(136, 136, 136);
    _subTitle.hidden = YES;
    _subTitle.numberOfLines = 0;
    [self.contentView addSubview:_subTitle];
    
    _switch = [[UISwitch alloc] init];
    _switch.onTintColor = THEMECOLOR;
    _switch.hidden = YES;
    [_switch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_switch];
}

- (void)setAcceptMsg:(BOOL)acceptMsg{
    
    _switch.on = acceptMsg;
    _switch.hidden = NO;
}

- (void)setTopChat:(BOOL)topChat{
    _switch.on = topChat;
    _switch.hidden = NO;
}

- (void)setTitleText:(NSString *)titleText{
    _titleText = titleText;
    
    _title.text = titleText;
}

- (void)setSubTitleText:(NSString *)subTitleText{
    _subTitleText = subTitleText;
    
    _subTitle.text = subTitleText;
    _subTitle.hidden = NO;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat titleX = LeftMargin;
    CGFloat titleY = TopMargin;
    CGFloat titleH = 21;
    CGFloat titleW = [self.titleText sizeWithFont:[UIFont systemFontOfSize:16] maxSize:CGSizeMake(MAXFLOAT, 21)].width;
    _title.frame = CGRectMake(titleX, titleY, titleW, titleH);
    
    CGFloat subTitleX = CGRectGetMaxX(_title.frame) + 2*TopMargin;
    CGFloat subTitleW = DEVICEWITH - 2*TopMargin - 2*LeftMargin - titleW;
    CGFloat subTitleH = [self.subTitleText sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(subTitleW, MAXFLOAT)].height;

    _subTitle.frame = CGRectMake(subTitleX, titleY + 1, subTitleW, subTitleH);
    
    CGFloat switchW = 51;
    CGFloat switchH = 31;
    CGFloat switchX = DEVICEWITH - LeftMargin - switchW;
    CGFloat switchY = (CellH - switchH)/2;
    _switch.frame = CGRectMake(switchX, switchY, switchW, switchH);
}

//switch开关点击方法
- (void)valueChanged:(UISwitch *)mSwitch{
    if (self.indexPath.row == 0) {  //接收消息
        
    }else{  //置顶公众号
        
    }
}

@end
