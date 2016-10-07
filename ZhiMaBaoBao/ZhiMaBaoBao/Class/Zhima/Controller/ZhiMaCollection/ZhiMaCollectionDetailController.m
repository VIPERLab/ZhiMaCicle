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

@interface ZhiMaCollectionDetailController () <KXActionSheetDelegate>

@end

@implementation ZhiMaCollectionDetailController {
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
    self.view.backgroundColor = [UIColor colorFormHexRGB:@"efeff4"];
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 64 + 18, 45, 45)];
    iconView.layer.cornerRadius = 10;
    iconView.image = [UIImage imageNamed:self.model.head];
    [self.view addSubview:iconView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconView.frame) + 8, CGRectGetMinY(iconView.frame) + 3, ScreenWidth - CGRectGetMaxX(iconView.frame) - 8, 20)];
    nameLabel.text = self.model.name;
    nameLabel.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:nameLabel];
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(iconView.frame) + 11, ScreenWidth - 40, 0.5)];
    bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"d9d9d9"];
    _bottomLineView = bottomLineView;
    [self.view addSubview:bottomLineView];
    
    UIView *lastView;
    if (self.model.type == 1) { // 纯文字
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(bottomLineView.frame) + 15, ScreenWidth - 20, [self.model.content sizeWithFont:[UIFont systemFontOfSize:17] maxSize:CGSizeMake(ScreenWidth - 40, MAXFLOAT)].height)];
        contentLabel.text = self.model.content;
        contentLabel.numberOfLines = 0;
        [self.view addSubview:contentLabel];
        lastView = contentLabel;
        
        UILabel *collectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(lastView.frame) + 20, ScreenWidth - 40, 30)];
        collectionLabel.textColor = [UIColor colorFormHexRGB:@"bcbcbc"];
        collectionLabel.font = [UIFont systemFontOfSize:15];
        collectionLabel.text = [NSString stringWithFormat:@"收藏于%@",self.model.time];
        [self.view addSubview:collectionLabel];
    } else if (self.model.type == 2) { // 图片
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:@"http://images.17173.com/2012/news/2012/07/02/gxy0702dp05s.jpg"] options:0 progress:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
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
    CGFloat picY = CGRectGetMaxY(_bottomLineView.frame) + 20;
    UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(picX, picY, picW, picH)];
    [self.view addSubview:picView];
    picView.image = image;
    _picView = picView;
    
    UILabel *collectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_picView.frame) + 20, ScreenWidth - 40, 30)];
    collectionLabel.textColor = [UIColor colorFormHexRGB:@"bcbcbc"];
    collectionLabel.font = [UIFont systemFontOfSize:15];
    collectionLabel.text = [NSString stringWithFormat:@"收藏于%@",self.model.time];
    [self.view addSubview:collectionLabel];
}


- (void)rightItemDidClick {
    KXActionSheet *sheet = [[KXActionSheet alloc] initWithTitle:@"" cancellTitle:@"取消" andOtherButtonTitles:@[@"发给朋友",@"删除"]];
    sheet.delegate = self;
    [sheet show];
}


@end
