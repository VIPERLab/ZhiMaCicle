//
//  LGSearchBar.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/28.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LGSearchBarDelegate <NSObject>

- (void)searchAction:(NSString *)content;

@end

@interface LGSearchBar : UIView
@property (nonatomic, assign) id<LGSearchBarDelegate> delegate;

@property (nonatomic, copy) NSString *placeholder;
 /** 搜索内容*/
@property (nonatomic, copy) NSString *content;
//自定义一个searchbar
+ (instancetype)searchBar;

@end
