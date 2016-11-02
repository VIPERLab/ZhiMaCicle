//
//  DetailInfoCell.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/11/2.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailInfoCell : UITableViewCell
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, copy) NSString *titleText;    //标题
@property (nonatomic, copy) NSString *subTitleText; //副标题

@end
