//
//  LGPickerView.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/21.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "LGPickerView.h"

@interface LGPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, strong) UILabel *titleLabel;   //标题
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) MoreInfoModel *selectedModel;     //选定的数据模型
@property (nonatomic, assign) NSInteger selectedRow;
@end

@implementation LGPickerView

static LGPickerView *picker = nil;

+ (instancetype)pickerView{
    if (!picker) {
        picker = [[self alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 160)];
    }
    return picker;
}


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = WHITECOLOR;
        self.rowHeight = 40;
        self.componentWidth = DEVICEWITH;
        [self addAllsubviews];
    }
    return self;
}

- (void)addAllsubviews{
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 40)];
    topBar.backgroundColor = WHITECOLOR;
    [self addSubview:topBar];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(14, 0, 50, 40)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:BLACKCOLOR forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:cancelBtn];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((DEVICEWITH - 150)/2, 0, 150, 40)];
    title.font = [UIFont systemFontOfSize:17];
    title.textAlignment = NSTextAlignmentCenter;
    [topBar addSubview:title];
    self.titleLabel = title;

    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(DEVICEWITH - 50 - 14, 0, 50, 40)];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [sureBtn addTarget:self action:@selector(sureaction) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:sureBtn];


    UIView *separtor = [[UIView alloc] initWithFrame:CGRectMake(0, topBar.height - 0.5, DEVICEWITH, 0.5)];
    separtor.backgroundColor = RGB(200, 200, 200);
    [topBar addSubview:separtor];
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topBar.frame), DEVICEWITH, self.height - 40)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    [self addSubview:pickerView];
    self.pickerView = pickerView;
}

- (void)setDataArr:(NSArray *)dataArr{
    _dataArr = dataArr;
    //默认选中第一个
    self.selectedModel = dataArr[0];
    [self.pickerView reloadAllComponents];
    //设置默认选中第一个
    [self.pickerView selectRow:0 inComponent:0 animated:NO];
}

- (void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = title;
}

#pragma maek - UIPickerView datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.dataArr.count;
}

#pragma maek - UIPickerView delegate
//列宽
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return self.componentWidth;
}
//行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return self.rowHeight;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view{
    MoreInfoModel *infoModel = self.dataArr[row];
    UIView *rowView = view;
    if (!rowView) {
        rowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 40)];
        rowView.backgroundColor = WHITECOLOR;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 40)];
        label.font = MAINFONT;
        label.text = infoModel.item_name;
        label.textAlignment = NSTextAlignmentCenter;
        [rowView addSubview:label];
    }
    return rowView;
}

//选定每一行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    MoreInfoModel *infoModel = self.dataArr[row];
    self.selectedModel = infoModel;
}

- (void)show{
    [self.pickerView reloadAllComponents];
    self.y = DEVICEHIGHT;
    [UIView animateWithDuration:.3 animations:^{
        self.y = DEVICEHIGHT - self.height;
    } completion:nil];
}

//取消
- (void)cancelAction{
    [UIView animateWithDuration:.3 animations:^{
        picker.y = DEVICEHIGHT;
    } completion:^(BOOL finished) {
        [picker removeFromSuperview];
        picker = nil;
    }];
}

//确定
- (void)sureaction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedRow:andModel:)]) {
        [self.delegate selectedRow:self.selectedRow andModel:self.selectedModel];
    }
    //移除
    [self cancelAction];
}

- (void)dismiss{
    [self cancelAction];
}

@end
