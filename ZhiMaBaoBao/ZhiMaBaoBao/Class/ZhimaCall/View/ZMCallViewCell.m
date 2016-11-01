//
//  ZMCallViewCell.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/13.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZMCallViewCell.h"

@interface ZMCallViewCell ()

//电话号码
@property (weak, nonatomic) IBOutlet UILabel *phoneNum;
//归属地
@property (weak, nonatomic) IBOutlet UILabel *distruct;

@property (weak, nonatomic) IBOutlet UIButton *moreInfoBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *callStateIV;

@end

@implementation ZMCallViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (void)setModel:(LGCallRecordModel *)model{
    _model = model;
    self.timeLabel.text =  [NSString timeStringChangeToZMTimeString: model.update_time];

    //来电
    if (model.call_type == 2) {
        self.phoneNum.text = model.from_phone;
        if (model.from_weuser.length) {
            self.distruct.text = model.from_weuser;
        }else{
            //没有名字显示归属地
            self.distruct.text = model.from_phone;
        }
        self.callStateIV.image = [UIImage imageNamed:@"icon-callIn"];
    }
    //去电
    else if (model.call_type == 1){
        if (model.to_weuser.length) {
            self.distruct.text = model.to_weuser;
        }else{
            //没有名字显示归属地
            self.distruct.text = model.to_phone;
        }
        self.phoneNum.text = model.to_phone;
        self.callStateIV.image = [UIImage imageNamed:@"icon-callOut"];
    }    //未接来电
    if (model.call_type == 3) {
        self.phoneNum.text = model.from_phone;
        if (model.from_weuser.length) {
            self.distruct.text = model.from_weuser;
        }else{
            //没有名字显示归属地
            self.distruct.text = model.from_phone;
        }
        self.callStateIV.image = [UIImage imageNamed:@"icon-callNo"];
    }
}
- (IBAction)infoAction:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(checkDetailInfoWithModel:)]) {
        [self.delegate checkDetailInfoWithModel:self.model];
    }
}

//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
//{
//    if (highlighted) {
//        self.contentView.backgroundColor = BGCOLOR;
//
//    }else{
//        self.contentView.backgroundColor = ClearColor;
//    }
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
