//
//  PersonalSettingCell.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/20.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalSettingCell : UITableViewCell

/**
 *  是否显示用户头像
 */
@property (nonatomic, assign,getter=isShowImage) BOOL showImage;

/**
 *  是否显示二维码
 */
@property (nonatomic, assign,getter=isShoeQRCode) BOOL showQRCode;

/**
 *  标题名字
 */
@property (nonatomic, copy) NSString *titleName;


/**
 *  副标题
 */
@property (nonatomic, copy) NSString *subTitle;

/**
 *  图片的文字
 */
@property (nonatomic, copy) NSString *imageName;



@end
