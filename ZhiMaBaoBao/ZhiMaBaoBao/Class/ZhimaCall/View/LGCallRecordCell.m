//
//  LGCallRecordCell.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/9.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGCallRecordCell.h"

@interface LGCallRecordCell()
//时间
@property (weak, nonatomic) IBOutlet UILabel *time;
//电话号码
@property (weak, nonatomic) IBOutlet UILabel *phoneNum;
//归属地
@property (weak, nonatomic) IBOutlet UILabel *distruct;
//来电去电标记
@property (weak, nonatomic) IBOutlet UIImageView *flagImage;

@end

@implementation LGCallRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setModel:(LGCallRecordModel *)model{
    _model = model;
    
    self.time.text = model.update_time;
    
    //来电
    if (model.call_type == 2) {
        self.flagImage.image = [UIImage imageNamed:@"call_recorde_red"];
        self.distruct.text = model.from_phone;
        if (model.from_weuser.length) {
            self.phoneNum.text = model.from_weuser;
        }else{
            //没有名字显示归属地
            self.phoneNum.text = model.from_phone;
        }
    }
    //去电
    else if (model.call_type == 1){
        if (model.to_weuser.length) {
            self.phoneNum.text = model.to_weuser;
        }else{
            //没有名字显示归属地
            self.phoneNum.text = model.to_phone;
        }
        self.distruct.text = model.to_phone;
        self.flagImage.image = [UIImage imageNamed:@"椭圆-3.png"];
    }
}

//信息按钮点击
- (IBAction)infoAction:(UIButton *)sender {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
