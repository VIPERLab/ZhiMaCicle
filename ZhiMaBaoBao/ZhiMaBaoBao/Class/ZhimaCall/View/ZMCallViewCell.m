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

@end

@implementation ZMCallViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (void)setModel:(LGCallRecordModel *)model{
    _model = model;
    
    //来电
    if (model.call_type == 2) {
        self.phoneNum.text = model.from_phone;
        if (model.from_weuser.length) {
            self.distruct.text = model.from_weuser;
        }else{
            //没有名字显示归属地
            self.distruct.text = model.from_phone;
        }
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
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
