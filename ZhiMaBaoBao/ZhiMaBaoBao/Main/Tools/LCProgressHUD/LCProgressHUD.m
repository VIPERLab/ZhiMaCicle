//
//  Created by 刘超 on 15/4/14.
//  Copyright (c) 2015年 Leo. All rights reserved.
//
//  Email : leoios@sina.com
//  GitHub: http://github.com/LeoiOS
//  如有问题或建议请给我发Email, 或在该项目的GitHub主页lssues我, 谢谢:)
//
//  活动指示器

#import "LCProgressHUD.h"

// 背景视图的宽度/高度
#define BGVIEW_WIDTH 80.0f
// 文字大小
#define TEXT_SIZE 16.0f

@implementation LCProgressHUD

+ (instancetype)sharedHUD {
    
    static LCProgressHUD *hud;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        hud = [[LCProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
        hud.contentColor = WHITECOLOR;
    });
    return hud;
}

+ (void)showStatus:(LCProgressHUDStatus)status text:(NSString *)text {
    
    LCProgressHUD *hud = [LCProgressHUD sharedHUD];
    [hud showAnimated:YES];
    hud.label.text = text;
    hud.label.font = [UIFont boldSystemFontOfSize:TEXT_SIZE];
    [hud setRemoveFromSuperViewOnHide:YES];
    [hud setMinSize:CGSizeMake(BGVIEW_WIDTH, BGVIEW_WIDTH)];

    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    
    switch (status) {
            
        case LCProgressHUDStatusSuccess: {
            
            hud.mode = MBProgressHUDModeCustomView;
            UIImageView *sucView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud_success"]];
            hud.customView = sucView;
            [hud hideAnimated:YES afterDelay:1.3f];
        }
            break;
            
        case LCProgressHUDStatusError: {
            
            hud.mode = MBProgressHUDModeCustomView;
            UIImageView *errView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud_error"]];
            hud.customView = errView;
            [hud hideAnimated:YES afterDelay:1.3f];
        }
            break;
            
        case LCProgressHUDStatusWaitting: {
            
            hud.mode = MBProgressHUDModeIndeterminate;
        }
            break;
            
        case LCProgressHUDStatusInfo: {
            
            hud.mode = MBProgressHUDModeCustomView;
            UIImageView *errView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud_info"]];
            hud.customView = errView;
            [hud hideAnimated:YES afterDelay:1.3f];
        }
            break;
            
        default:
            break;
    }
}

+ (void)show:(UIView *)view
{
    LCProgressHUD *hud = [LCProgressHUD sharedHUD];
    [hud showAnimated:YES];
    hud.label.text = @"";
    hud.label.font = [UIFont boldSystemFontOfSize:TEXT_SIZE];
    [hud setRemoveFromSuperViewOnHide:YES];
    [hud setMinSize:CGSizeMake(BGVIEW_WIDTH, BGVIEW_WIDTH)];
    hud.mode = MBProgressHUDModeIndeterminate;
    [view addSubview:hud];
    
}

+ (void)showText:(NSString *)text {
    
    LCProgressHUD *hud = [LCProgressHUD sharedHUD];
    [hud showAnimated:YES];
    hud.label.text = text;
    hud.label.font = [UIFont boldSystemFontOfSize:TEXT_SIZE];
    [hud setMinSize:CGSizeZero];
    [hud setMode:MBProgressHUDModeText];
    [hud setRemoveFromSuperViewOnHide:YES];
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    [hud hideAnimated:YES afterDelay:1.0f];
}

+ (void)showInfoText:(NSString *)text {
    
    [self showStatus:LCProgressHUDStatusInfo text:text];
}

+ (void)showFailureText:(NSString *)text {
    
    [self showStatus:LCProgressHUDStatusError text:text];
}

+ (void)showSuccessText:(NSString *)text {
    
    [self showStatus:LCProgressHUDStatusSuccess text:text];
}

+ (void)showLoadingText:(NSString *)text {
    
    [self showStatus:LCProgressHUDStatusWaitting text:text];
}

+ (void)hide {
    
    [[LCProgressHUD sharedHUD] hideAnimated:YES];
}

@end
