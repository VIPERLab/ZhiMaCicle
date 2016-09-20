//
//  YiKeyBoardView.h
//  YiIM_iOS
//
//  Created by admin on 16/5/17.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YiKeyBoardView;

@protocol YiKeyBoardViewDelegate <NSObject>

@optional
- (void)KeyBoardView:(YiKeyBoardView *)keyboardView settingBtn:(UIButton *)settingBtn;
- (void)KeyBoardView:(YiKeyBoardView *)keyboardView callBtn:(UIButton *)callBtn;
- (void)KeyBoardView:(YiKeyBoardView *)keyboardView addToCallRecall:(UIButton *)addToCallRecall;
- (void)KeyBoardView:(YiKeyBoardView *)keyboardView jump2Setting:(UIButton *)Btn0;

@end

@interface YiKeyBoardView : UIView

+ (instancetype)keyBoardView;
- (IBAction)btn1Click:(id)sender;
- (IBAction)btn2Click:(id)sender;
- (IBAction)btn3Click:(id)sender;
- (IBAction)btn4Click:(id)sender;
- (IBAction)btn6Click:(id)sender;
- (IBAction)btn5Click:(id)sender;
- (IBAction)btn7Click:(id)sender;
- (IBAction)btn8Click:(id)sender;
- (IBAction)btn9Click:(id)sender;
- (IBAction)btn0Click:(id)sender;
- (IBAction)settingClick:(id)sender;
- (IBAction)deleteClick:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *button0;
@property (nonatomic, strong) UITextField *numberTextField;     //存储输入号码

@property (nonatomic,weak)id <YiKeyBoardViewDelegate>delegate;


@end
