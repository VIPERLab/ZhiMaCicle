//
//  DiscoverDetailController.h
//  DemoDiscover
//
//  Created by kit on 16/8/21.
//  Copyright © 2016年 kit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef void(^DeletedBlock)();

@protocol DiscoverDetailControllerDelegate <NSObject>

@optional
- (void)DiscoverDetailControllerDeletedButtonDidClick:(NSIndexPath *)indexPath;

@end

@interface DiscoverDetailController : BaseViewController

@property (nonatomic, copy) NSString *ID; //要查看的朋友圈ID
@property (nonatomic, weak) NSIndexPath *indexPath;
@property (nonatomic, copy) NSString *sessionId;  //用户ID

@property (nonatomic, weak) id <DiscoverDetailControllerDelegate> delegate;

@property (nonatomic, copy) DeletedBlock deletedBlock;

@end
