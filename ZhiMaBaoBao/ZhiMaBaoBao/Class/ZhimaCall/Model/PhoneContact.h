//
//  PhoneContact.h
//  YiIM_iOS
//
//  Created by liugang on 16/8/23.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneContact : NSObject

@property (nonatomic, copy) NSString *name;         //联系人姓名
@property (nonatomic, copy) NSString *phoneNumber;  //电话号码
@property (nonatomic, copy) NSString *pinyin;   //姓氏首字母
@property (nonatomic, strong) NSData *avtar;        //联系人头像

@property (nonatomic, strong) NSArray *allPhones;   //联系人全部电话号码
@end
