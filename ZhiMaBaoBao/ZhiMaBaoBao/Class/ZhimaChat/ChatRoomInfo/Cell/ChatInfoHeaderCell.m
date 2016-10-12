//
//  ChatInfoHeaderCell.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ChatInfoHeaderCell.h"
#import "UIButton+WebCache.h"

@interface ChatInfoHeaderCell ()


@property (nonatomic, weak) UIButton *iconView;

@property (nonatomic, weak) UILabel *titleLabel;


@end

@implementation ChatInfoHeaderCell

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
    for (NSInteger index = 0; index < 2; index++) {
        UIButton *iconView = [[UIButton alloc] init];
        [self addSubview:iconView];
        iconView.layer.cornerRadius = 5;
        iconView.clipsToBounds = YES;
        iconView.tag = index;
        CGFloat iconW = 55;
        CGFloat iconH = iconW;
        CGFloat iconX = (iconW + 20) * index + 20;
        CGFloat iconY = 15;
        iconView.frame = CGRectMake(iconX, iconY, iconW, iconH);
        
        [iconView addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.textColor = [UIColor lightGrayColor];
        titleLabel.frame = CGRectMake(iconX, CGRectGetMaxY(iconView.frame), iconW, 95 - CGRectGetMaxY(iconView.frame));
        [self addSubview:titleLabel];
        
        if (index == 1) {
            [iconView setBackgroundImage:[UIImage imageNamed:@"ChatAddMember"] forState:UIControlStateNormal];
            titleLabel.hidden = YES;
        }
#warning 临时用着而已
        else {
            self.iconView = iconView;
            self.titleLabel = titleLabel;
        }
    }
}


- (void)setIconName:(NSString *)iconName {
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,iconName]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
}

- (void)setUserName:(NSString *)userName {
    self.titleLabel.text = userName;
}


- (void)buttonDidClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(ChatInfoUserIconDidClick:)]) {
        [self.delegate ChatInfoUserIconDidClick:sender.tag];
    }
}


@end
