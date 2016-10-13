//
//  TQRichTextEmojiRun.m
//  TQRichTextViewDemo
//
//  Created by fuqiang on 13-9-21.
//  Copyright (c) 2013年 fuqiang. All rights reserved.
//

#import "TQRichTextEmojiRun.h"
#import "FaceThemeModel.h"

@implementation TQRichTextEmojiRun

- (id)init
{
    self = [super init];
    if (self) {
        self.type = richTextEmojiRunType;
        self.isResponseTouch = NO;
    }
    return self;
}

- (BOOL)drawRunWithRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
//    NSString * emotionImageName=[self.originalText stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]];
//    NSString *emojiString = [NSString stringWithFormat:@"%@.png",emotionImageName];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"face" ofType:@"plist"];
    NSDictionary *faceDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString*faceName = [faceDic objectForKey:self.originalText];
  
    NSString *emojiString = [NSString stringWithFormat:@"%@.png",faceName];

    UIImage *image = [UIImage imageNamed:emojiString];
    if (image)
    {
        CGContextDrawImage(context, rect, image.CGImage);
    }
    return YES;
}

+(NSString*) matchPattern
{
    return  @"\\[emoji_\\d{3}\\]";
}

+ (NSString *)analyzeText:(NSString *)string runsArray:(NSMutableArray **)runArray
{
    NSString *markL = @"[";
    NSString *markR = @"]";
    NSMutableArray *stack = [[NSMutableArray alloc] init];
    NSMutableString *newString = [[NSMutableString alloc] initWithCapacity:string.length];
    
    //偏移索引 由于会把长度大于1的字符串替换成一个空白字符。这里要记录每次的偏移了索引。以便简历下一次替换的正确索引
    int offsetIndex = 0;
    
    for (int i = 0; i < string.length; i++)
    {
        NSString *s = [string substringWithRange:NSMakeRange(i, 1)];
        
        if (([s isEqualToString:markL]) || ((stack.count > 0) && [stack[0] isEqualToString:markL]))
        {
            if (([s isEqualToString:markL]) && ((stack.count > 0) && [stack[0] isEqualToString:markL]))
            {
                for (NSString *c in stack)
                {
                    [newString appendString:c];
                }
                [stack removeAllObjects];
            }
            
            [stack addObject:s];
            
            if ([s isEqualToString:markR] || (i == string.length - 1))
            {
                NSMutableString *emojiStr = [[NSMutableString alloc] init];
                for (NSString *c in stack)
                {
                    [emojiStr appendString:c];
                }
                
//                NSString * tmpEmotionResult = [emojiStr itemForPatter:[TQRichTextEmojiRun matchPattern]];
//                if (tmpEmotionResult.length>0)
//                {
//                    if (*runArray)
//                    {
//                        TQRichTextEmojiRun *emoji = [[TQRichTextEmojiRun alloc] init];
//                        emoji.range = NSMakeRange(i + 1 - emojiStr.length - offsetIndex, 1);
//                        emoji.originalText = emojiStr;
//                        [*runArray addObject:emoji];
//                    }
//                    [newString appendString:@" "];
//                    
//                    offsetIndex += emojiStr.length - 1;
//                }
                if ([[TQRichTextEmojiRun emojiStringArray] containsObject:emojiStr])
                {
                    TQRichTextEmojiRun *emoji = [[TQRichTextEmojiRun alloc] init];
                    emoji.range = NSMakeRange(i + 1 - emojiStr.length - offsetIndex, 1);
                    emoji.originalText = emojiStr;
                    [*runArray addObject:emoji];
                    [newString appendString:@" "];
                    
                    offsetIndex += emojiStr.length - 1;
                }
                else
                {
                    [newString appendString:emojiStr];
                }
                
                [stack removeAllObjects];
            }
        }
        else
        {
            [newString appendString:s];
        }
    }

    return newString;
}

+ (NSArray *) emojiStringArray
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"face" ofType:@"plist"];
    NSDictionary *faceDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray *allkeys = faceDic.allKeys;
    
//    FaceThemeModel *themeM = [[FaceThemeModel alloc] init];

    NSMutableArray *modelsArr = [NSMutableArray array];
    
    for (int i = 0; i < allkeys.count; ++i) {
        NSString *name = allkeys[i];
        FaceModel *fm = [[FaceModel alloc] init];
        fm.faceTitle = name;
//        fm.faceIcon = [faceDic objectForKey:name];
        [modelsArr addObject:fm.faceTitle];
    }

    
    return modelsArr;//[NSArray arrayWithObjects:@"[smile]",@"[cry]",nil];
}
@end
