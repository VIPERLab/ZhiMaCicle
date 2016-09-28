//
//  NSString+Helpers.h

//
//  Created by Reejo Samuel on 8/2/13.
//  Copyright (c) 2013 Reejo Samuel | m[at]reejosamuel.com All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helpers)

-(NSString *)MD5;
-(NSString *)sha1;
-(NSString *)reverse;
-(NSString *)URLEncode;
-(NSString *)URLDecode;
-(NSString *)stringByStrippingWhitespace;
-(NSString *)substringFrom:(NSInteger)from to:(NSInteger)to;
-(NSString *)CapitalizeFirst:(NSString *)source;
-(NSString *)UnderscoresToCamelCase:(NSString*)underscores;
-(NSString *)CamelCaseToUnderscores:(NSString *)input;

-(NSUInteger)countWords;


-(BOOL)contains:(NSString *)string;
-(BOOL)isBlank;
- (BOOL)checkNameInput;
- (BOOL)checkIDCard;
- (BOOL)checkOrgnizNameInput;

//检查密码
- (BOOL)checkPasswordInput;
//检查用户名
- (BOOL)checkUsernameInput_NO_chongwen;
- (BOOL)checkUsernameInput;
//检查是否纯数字
- (BOOL)checkNumberInput;
//检查QQ号码
- (BOOL)checkQQnumberInput;
//检查电话号码
-(BOOL)NewCheckPhoneNumInput;

-(NSString *)isHttp;



@end
