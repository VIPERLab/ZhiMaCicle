//
//  PanelBottomView.m
//  FaceKeyboard

//  Company：     SunEee
//  Blog:        devcai.com
//  Communicate: 2581502433@qq.com

//  Created by ruofei on 16/3/31.
//  Copyright © 2016年 ruofei. All rights reserved.
//

#import "PanelBottomView.h"
#import "FaceThemeModel.h"
#import "ChatKeyBoardMacroDefine.h"

@implementation PanelBottomView
{
    UIButton        *_addBtn;
    UIScrollView    *_facePickerView;
    UIButton        *_sendBtn;
    UIButton        *_setBtn;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    //添加按钮 暂时隐藏。 显示出来的时候记得改下面_facePickerView的frame
//    _addBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
//    _addBtn.frame = CGRectMake(0, 0, kFacePanelBottomToolBarHeight, kFacePanelBottomToolBarHeight);
//    [_addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:_addBtn];
    
//    _facePickerView = [[UIScrollView alloc] initWithFrame:CGRectMake(kFacePanelBottomToolBarHeight, 0, kScreenWidth-2*kFacePanelBottomToolBarHeight, kFacePanelBottomToolBarHeight)];
    _facePickerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-kFacePanelBottomToolBarHeight-5, kFacePanelBottomToolBarHeight)];
    _facePickerView.backgroundColor = WHITECOLOR;
    [self addSubview:_facePickerView];
    
    _sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _sendBtn.frame = CGRectMake(kScreenWidth-kFacePanelBottomToolBarHeight-5, 0, kFacePanelBottomToolBarHeight+5, kFacePanelBottomToolBarHeight);
    [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    _sendBtn.backgroundColor = WHITECOLOR;
    [_sendBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [_sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sendBtn];
    
    
    _setBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _setBtn.frame = _sendBtn.frame;
    [_setBtn setTitle:@"发送" forState:UIControlStateNormal];
    [_setBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    _setBtn.hidden = YES;
    _setBtn.backgroundColor = WHITECOLOR;
    [_setBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_setBtn];
}


- (void)loadfaceThemePickerSource:(NSArray *)pickerSource
{
    for (int i = 0; i<pickerSource.count; i++) {
        FaceThemeModel *themeM = pickerSource[i];
        UIButton *btn = [[UIButton alloc]init];
        if (i == 0) {
            btn.selected = YES;
        }
        btn.tag = i+100;
//        [btn setTitle:themeM.themeDecribe forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:themeM.themeIcon] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:themeM.themeIconSelected] forState:UIControlStateSelected];

//        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];

//        [btn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
//        [btn setTintColor:THEMECOLOR];


        [btn addTarget:self action:@selector(subjectPicBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(i*kFacePanelBottomWidth, 0, kFacePanelBottomWidth, kFacePanelBottomToolBarHeight);
        [_facePickerView addSubview:btn];
        
        if (i == pickerSource.count - 1) {
             NSInteger pages = CGRectGetMaxX(btn.frame) / CGRectGetWidth(_facePickerView.frame) + 1;
            _facePickerView.contentSize = CGSizeMake(pages*CGRectGetWidth(_facePickerView.frame), 0);
        }
    }
}

- (void)changeFaceSubjectIndex:(NSInteger)subjectIndex
{
//    [_facePickerView setContentOffset:CGPointMake(subjectIndex*kFacePanelBottomWidth, 0) animated:YES];
    
    for (UIView *sub in _facePickerView.subviews) {
        if ([sub isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)sub;
            if (btn.tag-100 == subjectIndex) {
                btn.selected = YES;
            }else {
                btn.selected = NO;
            }
        }
    }
    
    if (subjectIndex > 0) {
        _setBtn.hidden = NO;
        _sendBtn.hidden = YES;
    }else {
        _setBtn.hidden = YES;
        _sendBtn.hidden = NO;
    }
    
}

#pragma mark -- 点击事件

- (void)addBtnClick:(UIButton *)sender
{
    if (self.addAction) {
        self.addAction();
    }
}

- (void)sendBtnClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(panelBottomViewSendAction:)]) {
        [self.delegate panelBottomViewSendAction:self];
    }
}

- (void)setBtnClick:(UIButton *)sender
{
    if (self.setAction) {
        self.setAction();
    }
}

- (void)subjectPicBtnClick:(UIButton *)sender
{
//    for (UIView *sub in _facePickerView.subviews) {
//        if ([sub isKindOfClass:[UIButton class]]) {
//            UIButton *btn = (UIButton *)sub;
//            if (btn == sender) {
//                sender.selected = YES;
//            }else {
//                btn.selected = NO;
//            }
//        }
//    }
//    
//    if (sender.tag-100 > 0) {
//        _setBtn.hidden = NO;
//        _sendBtn.hidden = YES;
//    }else {
//        _setBtn.hidden = YES;
//        _sendBtn.hidden = NO;
//    }
    
    if ([self.delegate respondsToSelector:@selector(panelBottomView:didPickerFaceSubjectIndex:)]) {
        [self.delegate panelBottomView:self didPickerFaceSubjectIndex:sender.tag-100];
    }
}


@end
