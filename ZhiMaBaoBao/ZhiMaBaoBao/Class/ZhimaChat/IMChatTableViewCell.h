//
//  ChatCell.h
//  BYD
//
//  Created by YuanFromTentinet on 13-10-15.
//  Copyright (c) 2013年 Tentinet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQRichTextView.h"
#import "BaseChatTableViewCell.h"

@protocol CDCelldelegate <NSObject>

@optional
-(void)copyTextComplete;
-(void)deleteTextComplete;
-(void)onClicked_others_ivHead_Complete;

-(void)jumpToWebViewWithUrlStr:(NSString*)urlStr;

@end

@interface IMChatTableViewCell : BaseChatTableViewCell

@property (nonatomic, strong) TQRichTextView *chatMessageView;  //可以显示表情的
@property (nonatomic,   weak) id<CDCelldelegate>cdDelegate;

+ (CGFloat)getHeightWithMessage:(NSString *)message topText:(NSString *)topText nickName:(NSString *)nickName;

@end
