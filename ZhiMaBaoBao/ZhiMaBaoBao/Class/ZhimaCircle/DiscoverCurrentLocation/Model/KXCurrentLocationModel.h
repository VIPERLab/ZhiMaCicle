//
//  KXCurrentLocationModel.h
//  YiIM_iOS
//
//  Created by mac on 16/8/31.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KXCurrentLocationModel : NSObject

//@property (nonatomic, copy) NSString *SubLocality;  //区名
//@property (nonatomic, copy) NSString *Street;       //街道
//@property (nonatomic, copy) NSString *State;        //省份
//@property (nonatomic, copy) NSString *Name;         //地名
//@property (nonatomic, copy) NSString *FormattedAddressLines; //全称
//@property (nonatomic, copy) NSString *City;         //市名

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *city;

//是否显示打钩图片
@property (nonatomic, assign) BOOL isShowTick;

@end
