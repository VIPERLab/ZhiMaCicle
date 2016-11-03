//
//  WebViewController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/15.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import "KXActionSheet.h"
//#import "WebViewJavascriptBridge.h"
#import "LGShareToolBar.h"

@interface WebViewController () <KXActionSheetDelegate,LGShareBarDelegate,WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@property WebViewJavascriptBridge *bridge;

@end

@implementation WebViewController {
    NSString *_urlStr;
    WKUserContentController *_userCC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCustomTitle:@""];
    [self setupNav];
    [self setupViews];
    
    //添加js脚本
    [_userCC addScriptMessageHandler:self name:@"showMobile"];
}

- (void)setupViews{
    _userCC = [[WKUserContentController alloc] init];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = _userCC;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    [self.view addSubview:webView];
    self.webView = webView;
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, DEVICEWITH, 5)];
    progressView.progressTintColor = THEMECOLOR;
    [self.view insertSubview:progressView aboveSubview:self.webView];
    self.progressView = progressView;
    
    _urlStr = self.urlStr;
    NSRange rang = [_urlStr rangeOfString:@"http"];
    if (rang.length == 0) {
        _urlStr = [@"http://" stringByAppendingString:_urlStr];
    }
    
    NSLog(@"加载的网址是 --  %@",_urlStr);
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]]];
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)setupNav {
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_more"] style:UIBarButtonItemStylePlain target:self action:@selector(rightItemDidClick)];
    self.navigationItem.rightBarButtonItem = right;
    
}

<<<<<<< HEAD
=======
// 在代理方法中处理对应事件  (js调用原生)
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
}

//导航栏右侧按钮点击方法
- (void)rightItemDidClick {
//    KXActionSheet *sheet = [[KXActionSheet alloc] initWithTitle:@"" cancellTitle:@"取消" andOtherButtonTitles:@[@"在浏览器中打开"]];
//    sheet.delegate = self;
//    [sheet show];
    
    LGShareToolBar *shareBar = [LGShareToolBar shareInstance];
    shareBar.delegate = self;
    [shareBar show];
}


- (void)KXActionSheet:(KXActionSheet *)sheet andIndex:(NSInteger)index {
    if (index == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_urlStr]];
    }
}


#pragma mark - 分享栏工具代理方法
- (void)shareAction:(ShareButtonType)btnType{
    
}

//加载进度条和标题代理方法
>>>>>>> liugang
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        
        if (object == self.webView) {
            
            [self.progressView setAlpha:1.0f];
            [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
            
            if(self.webView.estimatedProgress >= 1.0f) {
                
                [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.progressView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [self.progressView setProgress:0.0f animated:NO];
                }];
                
                [self.webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '40%'" completionHandler:nil];
            }
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
        
    }
    else if ([keyPath isEqualToString:@"title"])
    {
        if (object == self.webView) {
            [self setCustomTitle:self.webView.title];
            
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
            
        }
    }
    else {
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
}

@end
