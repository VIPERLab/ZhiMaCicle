//
//  LGQueryCell.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/31.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGQueryCell.h"
#import "UIImageView+WebCache.h"


@interface LGQueryCell()

@property (nonatomic, strong) UIImageView *avtar;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UIButton *flagBtn;
@property (nonatomic, strong) UILabel *zhimaName;

@end

@implementation LGQueryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    CGFloat rowH = 53;
    CGFloat imgH = 43;
    CGFloat margin = 14;
    CGFloat padding = 10;
    CGFloat btnW = 60;
    CGFloat btnH = 28;
    
    self.avtar = [[UIImageView alloc] initWithFrame:CGRectMake(margin, (rowH - imgH)/2, imgH, imgH)];
    [self.contentView addSubview:self.avtar];
    
    self.name = [[UILabel alloc] initWithFrame:CGRectMake(margin+imgH+padding, (rowH - imgH)/2, 200, 21)];
    self.name.font = [UIFont systemFontOfSize:15];;
    [self.contentView addSubview:self.name];
    
    self.zhimaName = [[UILabel alloc] initWithFrame:CGRectMake(margin+imgH+padding, CGRectGetMaxY(self.name.frame), 200, 21)];
    self.zhimaName.font = [UIFont systemFontOfSize:14];
    self.zhimaName.textColor = GRAYCOLOR;
    [self.contentView addSubview:self.zhimaName];
    
    self.flagBtn = [[UIButton alloc] initWithFrame:CGRectMake(DEVICEWITH - btnW - margin, (rowH - btnH)/2, btnW, btnH)];
    [self.flagBtn setTitle:@"添加" forState:UIControlStateNormal];
    [self.flagBtn setBackgroundColor:THEMECOLOR];
    [self.flagBtn setTitleColor:WHITECOLOR forState:UIControlStateNormal];
    self.flagBtn.layer.cornerRadius = 5.f;
    self.flagBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.flagBtn addTarget:self action:@selector(addBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.flagBtn setTitle:@"已添加" forState:UIControlStateSelected];
    [self.flagBtn setTitleColor:GRAYCOLOR forState:UIControlStateSelected];
    
    [self.contentView addSubview:self.flagBtn];
}

- (void)setModel:(LGQueryResModel *)model{
    _model = model;
    
    [self.avtar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.headphoto]] placeholderImage:[UIImage imageNamed:@"defaultContact@3x"]];
    self.name.text = model.phonename;
    self.zhimaName.text = [NSString stringWithFormat:@"芝麻宝宝：%@",model.username];
    
    if (model.isadd == 0) {
        self.flagBtn.selected = NO;
    }else{
        self.flagBtn.selected = YES;
        self.flagBtn.backgroundColor = [UIColor clearColor];
        if (model.isadd == 2) {
            [self.flagBtn setTitle:@"等待验证" forState:UIControlStateSelected];
        }
    }
}


- (void)addBtnAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(addNewFriend:)]) {
        [sender setTitle:@"等待验证" forState:UIControlStateSelected];
        sender.backgroundColor = [UIColor clearColor];
        sender.selected = YES;
        sender.userInteractionEnabled = NO;
        [self.delegate addNewFriend:self.row];
    }
}

@end
