//
//  ZhiMaCollectionDetailController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/7.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZhiMaCollectionDetailController.h"
#import "ZhiMaCollectionModel.h"
#import "SDWebImageManager.h"
#import "KXActionSheet.h"

#import "ForwardMsgController.h"

@interface ZhiMaCollectionDetailController () <KXActionSheetDelegate>

@end

@implementation ZhiMaCollectionDetailController {
    UIScrollView *_scrollView;
    UIView *_bottomLineView;
    UIImageView *_picView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNav];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNav {
    [self setCustomTitle:@"详情"];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_more"] style:UIBarButtonItemStylePlain target:self action:@selector(rightItemDidClick)];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)setupView {
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_scrollView];
    _scrollView.backgroundColor = [UIColor colorFormHexRGB:@"efeff4"];
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 18, 45, 45)];
    iconView.layer.cornerRadius = 5;
    iconView.clipsToBounds = YES;
    [iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,self.model.head]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
    [_scrollView addSubview:iconView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconView.frame) + 8, CGRectGetMinY(iconView.frame) + 3, ScreenWidth - CGRectGetMaxX(iconView.frame) - 8, 20)];
    nameLabel.text = self.model.name;
    nameLabel.font = [UIFont systemFontOfSize:17];
    [_scrollView addSubview:nameLabel];
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(iconView.frame) + 11, ScreenWidth - 40, 0.5)];
    bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"d9d9d9"];
    _bottomLineView = bottomLineView;
    [_scrollView addSubview:bottomLineView];
    
    UIView *lastView;
    if (self.model.type == 1) { // 纯文字
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(bottomLineView.frame) + 11, ScreenWidth - 20, [self.model.content sizeWithFont:[UIFont systemFontOfSize:17] maxSize:CGSizeMake(ScreenWidth - 40, MAXFLOAT)].height)];
        contentLabel.text = self.model.content;
        contentLabel.numberOfLines = 0;
        [_scrollView addSubview:contentLabel];
        lastView = contentLabel;
        
        UILabel *collectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(lastView.frame) + 20, ScreenWidth - 40, 30)];
        collectionLabel.textColor = [UIColor colorFormHexRGB:@"bcbcbc"];
        collectionLabel.font = [UIFont systemFontOfSize:12];
        collectionLabel.text = [NSString stringWithFormat:@"收藏于%@",self.model.time];
        [_scrollView addSubview:collectionLabel];
        _scrollView.contentSize = CGSizeMake(ScreenWidth, CGRectGetMaxY(collectionLabel.frame));
    } else if (self.model.type == 3) { // 图片
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,self.model.photoUrl]] options:0 progress:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            [self setupPicWithImage:image];
        }];
        
    }
}


- (void)setupPicWithImage:(UIImage *)image {
    if (image == nil) {
        return;
    }
    CGFloat scale = image.size.width / (ScreenWidth - 40);
    CGFloat picW = image.size.width > (ScreenWidth - 40) ? (ScreenWidth - 40) : image.size.width;
    CGFloat picH = image.size.height / scale;
    CGFloat picX = 20;
    CGFloat picY = CGRectGetMaxY(_bottomLineView.frame) + 11;
    UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(picX, picY, picW, picH)];
    [_scrollView addSubview:picView];
    picView.image = image;
    _picView = picView;
    
    UILabel *collectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_picView.frame) + 20, ScreenWidth - 40, 30)];
    collectionLabel.textColor = [UIColor colorFormHexRGB:@"bcbcbc"];
    collectionLabel.font = [UIFont systemFontOfSize:15];
    collectionLabel.text = [NSString stringWithFormat:@"收藏于%@",self.model.time];
    [_scrollView addSubview:collectionLabel];
    
    CGFloat height = CGRectGetMaxY(collectionLabel.frame) > ScreenHeight ? CGRectGetMaxY(collectionLabel.frame) : (ScreenHeight - 64);
    _scrollView.contentSize = CGSizeMake(ScreenWidth, height);
}


- (void)rightItemDidClick {
    KXActionSheet *sheet = [[KXActionSheet alloc] initWithTitle:@"" cancellTitle:@"取消" andOtherButtonTitles:@[@"发给朋友",@"删除"]];
    sheet.delegate = self;
    [sheet show];
}


- (void)KXActionSheet:(KXActionSheet *)sheet andIndex:(NSInteger)index {
    if (index == 0) {
        // 发给朋友
        LGMessage *message = [[LGMessage alloc] init];
        message.msgid = [NSString generateMessageID];
        
        if (self.model.content.length) {
            message.type = MessageTypeText;
            message.text = self.model.content;
        } else {
            message.type = MessageTypeImage;
            message.text = [NSString stringWithFormat:@"%@%@",DFAPIURL,self.model.photoUrl];
            message.picUrl = [NSString stringWithFormat:@"%@%@",DFAPIURL,self.model.photoUrl];
        }
        
        ForwardMsgController *vc = [[ForwardMsgController alloc] init];
        vc.message = message;
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
    } else if (index == 1) {
        // 删除
        [LGNetWorking deletedCircleCollectionWithSessionId:USERINFO.sessionId andCollectionId:self.model.ID success:^(ResponseData *responseData) {
            
            if (responseData.code != 0) {
                return ;
            }
            
            [LCProgressHUD showSuccessText:@"删除成功"];
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(ErrorData *error) {
            
        }];
    }
}



@end
