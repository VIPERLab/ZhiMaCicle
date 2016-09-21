//
//  DiscoverCurrentLocationController.h
//  YiIM_iOS
//
//  Created by mac on 16/8/31.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "BaseViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import "KXCurrentLocationModel.h"

typedef void(^ComplitedBlock)(KXCurrentLocationModel *model);

@interface DiscoverCurrentLocationController : BaseViewController

@property (nonatomic, copy) ComplitedBlock complitedBlock;

@end
