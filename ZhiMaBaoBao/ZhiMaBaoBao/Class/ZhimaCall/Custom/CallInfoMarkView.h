//
//  CallInfoMarkView.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/13.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneContact.h"

@protocol CallInfoMarkViewDelegate <NSObject>

- (void)stateChange:(BOOL)isSelected;
- (void)call;

@end

@interface CallInfoMarkView : UIView

@property (nonatomic, strong) UILabel*nameLabel; //名字label
@property (nonatomic, strong) UILabel*phoneLabel; //电话号码label
@property (nonatomic, strong) UIButton*stateBtn; //状态按钮
@property (nonatomic, weak) id<CallInfoMarkViewDelegate>delegate;

- (void)changeBtnState;
- (void)changeStateWithContact:(PhoneContact*)conteact;
- (void)setColorWithString:(NSString*)string;

@end
