//
//  ZMRecordShortVideoView.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZMRecordShortVideoDelegate <NSObject>

- (void)didFinishRecordingToOutputFilePath:(NSString *)outputFilePath;
- (void)hiddenVideoView;

- (void)playVideoWithPath:(NSString*)path image:(UIImage*)image;

@end

@interface ZMRecordShortVideoView : UIView

@property (nonatomic, assign) NSTimeInterval videoMaximumDuration;
@property (nonatomic, assign) NSTimeInterval videoMinimumDuration;
@property (nonatomic, weak) id<ZMRecordShortVideoDelegate> delegate;

//- (instancetype)initWithOutputFilePath:(NSString *)outputFilePath outputSize:(CGSize)outputSize themeColor:(UIColor *)themeColor;

@end
