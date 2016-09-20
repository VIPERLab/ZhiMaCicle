//
//  KXPersonalCenterCell.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KXPersonalCenterCell : UITableViewCell

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *subName;
/**
 *  M是男性 、 F是女性
 */
@property (nonatomic, copy) NSString *Sex;

@end
