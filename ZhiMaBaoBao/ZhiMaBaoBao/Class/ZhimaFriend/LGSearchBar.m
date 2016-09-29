//
//  LGSearchBar.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/28.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "LGSearchBar.h"
@interface LGSearchBar()
@property (nonatomic, strong) UITextField *textField;
@end

static LGSearchBar *searchBar = nil;

@implementation LGSearchBar

+ (instancetype)searchBar{
    searchBar = [[LGSearchBar alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 50)];
    return searchBar;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //搜索图片
        UIImageView *seachImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lsearch"]];
        seachImage.frame = CGRectMake(26, 14, 19, 21);
        [self addSubview:seachImage];
        //输入框
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(55, 10, 200, 30)];
        textField.font = MAINFONT;
        [self addSubview:textField];
        self.textField = textField;
        //搜索按钮
        UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(DEVICEWITH - 50 - 12, 10, 50, 30)];
        [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
        [searchBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
        searchBtn.titleLabel.font = MAINFONT;
        searchBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [searchBtn addTarget:self action:@selector(searchBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:searchBtn];
        //分割线
        UIView *separtor = [[UIView alloc] initWithFrame:CGRectMake(14, 43, DEVICEWITH - 28, 0.5)];
        separtor.backgroundColor = RGB(235, 235, 235);
        [self addSubview:separtor];
    }
    return self;
}

//搜索
- (void)searchBtnAction{
    [self.textField resignFirstResponder];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchAction:)]) {
        [self.delegate searchAction:self.content];
    }
}

- (NSString *)content{
    return self.textField.text;
}

- (void)setPlaceholder:(NSString *)placeholder{
    _placeholder = placeholder;
    
    self.textField.placeholder = placeholder;
}
@end
