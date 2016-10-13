//
//  CallInfoMarkView.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/13.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "CallInfoMarkView.h"

@implementation CallInfoMarkView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {

        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, DEVICEWITH-60, 25)];
//    self
}

@end
