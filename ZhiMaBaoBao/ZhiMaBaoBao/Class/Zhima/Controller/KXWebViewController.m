//
//  KXAboutUsController.m
//  YiIM_iOS
//
//  Created by mac on 16/8/29.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "KXWebViewController.h"

@interface KXWebViewController () <UIWebViewDelegate>
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressPan;

@end

@implementation KXWebViewController {
    UIWebView *_webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self setCustomTitle:_navTitleName];
    [self setupNav];
    self.view.backgroundColor = BGCOLOR;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _webView = webView;
    webView.delegate = self;
    [self.view addSubview:webView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"userProtocal" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_htmlURL]];
    [webView loadRequest:request];
    
    //拦截webview手势
    self.longPressPan = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpress)];
    self.longPressPan.minimumPressDuration = 0.3;
    [webView addGestureRecognizer:self.longPressPan];
    
    UITapGestureRecognizer *twice = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(longpress)];
    twice.numberOfTapsRequired = 2;
    twice.numberOfTouchesRequired = 2;
    [webView addGestureRecognizer:twice];

}

- (void)longpress{
    
}

- (void)setupNav {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    titleLabel.text = self.navTitleName;
    titleLabel.textColor = THEMECOLOR;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:17];
    self.navigationItem.titleView = titleLabel;
    
    //自定义返回按钮
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backBtn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
}


- (void)backAction {
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

@end
