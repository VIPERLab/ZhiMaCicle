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

@interface WebViewController () <KXActionSheetDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation WebViewController {
    NSString *_urlStr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCustomTitle:@""];
    [self setupNav];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
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

- (void)rightItemDidClick {
    KXActionSheet *sheet = [[KXActionSheet alloc] initWithTitle:@"" cancellTitle:@"取消" andOtherButtonTitles:@[@"在浏览器中打开"]];
    sheet.delegate = self;
    [sheet show];
}

- (void)KXActionSheet:(KXActionSheet *)sheet andIndex:(NSInteger)index {
    if (index == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_urlStr]];
    }
}

- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
}

@end
