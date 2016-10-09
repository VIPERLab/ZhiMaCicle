//
//  GroupChatChangeNoticeController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/9.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "GroupChatChangeNoticeController.h"
#import "GroupChatModel.h"
@interface GroupChatChangeNoticeController ()

@property (nonatomic, weak) UITextView *textView;

@end

@implementation GroupChatChangeNoticeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setNav];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self.textView becomeFirstResponder];
}

- (void)setNav {
    [self setCustomTitle:@"群公告"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonDidClick)];
}

- (void)setupView {
    self.view.backgroundColor = [UIColor whiteColor];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 64 + 20, ScreenWidth - 20, ScreenHeight * 0.5)];
    self.textView = textView;
    textView.font = [UIFont systemFontOfSize:18];
    textView.text = self.groupModel.notice;
    textView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:textView];
    
}


- (void)saveButtonDidClick {
    
    if ([self.textView.text isEqualToString:@""]) {
        NSLog(@"公告不能为空");
        return;
    }
    
    self.groupModel.notice = self.textView.text;
    
    [FMDBShareManager saveGroupChatMessage:self.groupModel andConverseID:self.groupModel.groupId];
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)dealloc {
    self.automaticallyAdjustsScrollViewInsets = YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
