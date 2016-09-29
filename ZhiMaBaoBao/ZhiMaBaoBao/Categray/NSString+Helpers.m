//
//  NSString+Helpers.m

//
//  Created by Reejo Samuel on 8/2/13.
//  Copyright (c) 2013 Reejo Samuel | m[at]reejosamuel.com All rights reserved.
//

#import "NSString+Helpers.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Helpers)

- (NSString *)MD5 {
    const char *str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}


-(NSString *)sha1 {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
	NSData *data 	 = [NSData dataWithBytes:cstr length:self.length];
    
	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
	CC_SHA1(data.bytes, data.length, digest);
    
	NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
	for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x", digest[i]];
    
	return output;
}



-(NSString *)reverse {
	NSInteger length = [self length];
	unichar *buffer = calloc(length, sizeof(unichar));
    
	// TODO(gabe): Apparently getCharacters: is really slow
	[self getCharacters:buffer range:NSMakeRange(0, length)];
    
    
	for(int i = 0, mid = ceil(length/2.0); i < mid; i++) {
		unichar c = buffer[i];
		buffer[i] = buffer[length-i-1];
		buffer[length-i-1] = c;
	}
    
	NSString *s = [[NSString alloc] initWithCharacters:buffer length:length];
    
    free(buffer);
    buffer = NULL;
	return s;
}


-(NSUInteger)countWords {

    __block NSUInteger wordCount = 0;
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length)
                               options:NSStringEnumerationByWords
                            usingBlock:^(NSString *character, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                wordCount++;
                            }];
    return wordCount;
}

-(NSString *)stringByStrippingWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)substringFrom:(NSInteger)from to:(NSInteger)to {
    NSString *rightPart = [self substringFromIndex:from];
    return [rightPart substringToIndex:to-from];
}


-(NSString *)URLEncode {
    
    CFStringRef encoded = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                  (__bridge CFStringRef)self,
                                                                  NULL,
                                                                  CFSTR(":/?#[]@!$&'()*+,;="),
                                                                  kCFStringEncodingUTF8);
    return [NSString stringWithString:(__bridge_transfer NSString *)encoded];
}

-(NSString *)URLDecode {
    
    CFStringRef decoded = CFURLCreateStringByReplacingPercentEscapes( kCFAllocatorDefault,
                                                                     (__bridge CFStringRef)self,
                                                                     CFSTR(":/?#[]@!$&'()*+,;=") );
    return [NSString stringWithString:(__bridge_transfer NSString *)decoded];
}



-(NSString *)CamelCaseToUnderscores:(NSString *)input {
    
    NSMutableString *output = [NSMutableString string];
    NSCharacterSet *uppercase = [NSCharacterSet uppercaseLetterCharacterSet];
    for (NSInteger idx = 0; idx < [input length]; idx += 1) {
        unichar c = [input characterAtIndex:idx];
        if ([uppercase characterIsMember:c]) {
            [output appendFormat:@"%s%C", (idx == 0 ? "" : "_"), (unichar)(c ^ 32)];
        } else {
            [output appendFormat:@"%C", c];
        }
    }
    return output;
}

-(NSString *)UnderscoresToCamelCase:(NSString*)underscores {
    
    NSMutableString *output = [NSMutableString string];
    BOOL makeNextCharacterUpperCase = NO;
    for (NSInteger idx = 0; idx < [underscores length]; idx += 1) {
        unichar c = [underscores characterAtIndex:idx];
        if (c == '_') {
            makeNextCharacterUpperCase = YES;
        } else if (makeNextCharacterUpperCase) {
            [output appendString:[[NSString stringWithCharacters:&c length:1] uppercaseString]];
            makeNextCharacterUpperCase = NO;
        } else {
            [output appendFormat:@"%C", c];
        }
    }
    return output;
}

-(NSString *)CapitalizeFirst:(NSString *)source {
    
    if ([source length] == 0) {
        return source;
    }
    return [source stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                           withString:[[source substringWithRange:NSMakeRange(0, 1)] capitalizedString]];
}






#pragma mark - Boolean Helpers

-(BOOL)isBlank
{
    if([[self stringByStrippingWhitespace] length] == 0)
    {
        return YES;
    }
    
    return NO;
//    if (self == nil || self == NULL) {
//        return YES;
//    }
//    if ([self isKindOfClass:[NSNull class]]) {
//        return YES;
//    }
//    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
//        return YES;
//    }
//    return NO;
}
//- (NSString *)isHttp
//{
//
//    if([[self stringByStrippingWhitespace] length] > 0){
//        
//        if (![[self substringToIndex:4] isEqualToString:@"http"]) {
//            return  [BaseImageUrl stringByAppendingFormat:@"%@",self];
//        }
//    }
//    
//    return self;
//}
-(BOOL)contains:(NSString *)string {
    NSRange range = [self rangeOfString:string];
    return (range.location != NSNotFound);
}

- (BOOL)checkNameInput
{
    NSString *nameStr = @"^[\u4e00-\u9fa5A-Za-z]{2,10}$";
    NSPredicate *regextName = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",nameStr];
    return [regextName evaluateWithObject:self];
}

- (BOOL)checkIDCard
{
    NSString *IDCard = @"^[a-zA-Z0-9]+$";
    NSPredicate *regextName = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",IDCard];
    return [regextName evaluateWithObject:self];
}

- (BOOL)checkPasswordInput
{
    NSString *passwordStr = @"^[a-zA-Z0-9_]{6,16}$";
    NSPredicate *regextNumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passwordStr];
    return [regextNumber evaluateWithObject:self];
}

- (BOOL)checkUsernameInput_NO_chongwen
{
    
    if([self IsChinese:self])
    {
        return YES;
    }
    
    NSString *usernameStr = @"^[A-Za-z0-9]{4,20}$";// @"^[\u4e00-\u9fa5]{2,10}$|^[A-Za-z0-9]{4,20}$"; //  ^[0-9A-Za-z]  a-zA-Z0-9
    NSPredicate *regextNumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",usernameStr];
    return [regextNumber evaluateWithObject:self];
}

- (BOOL)checkUsernameInput
{
    NSString *usernameStr = @"^[a-zA-Z0-9\u4e00-\u9fa5]+$";
   // @"^[\u4e00-\u9fa5]{2,10}$|^[\u4e00-\u9fa5A-Za-z0-9]{4,10}$|^[A-Za-z0-9]{4,20}$";
    // @"^[\u4e00-\u9fa5]{2,10}$|^[A-Za-z0-9]{4,20}$";
    //  ^[0-9A-Za-z]  a-zA-Z0-9
    
    //计算字符，中英混用
    NSInteger count = [self convertToInt];
    NSLog(@"_______%@________%d_______", self,count);
    
    if (count<4 || count >20) {
        return NO;
    }
    NSPredicate *regextNumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",usernameStr];
    return [regextNumber evaluateWithObject:self];
}

- (BOOL)checkNumberInput
{
    NSString *numberStr = @"^[0-9]*$";
    NSPredicate *regextNumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",numberStr];
    return [regextNumber evaluateWithObject:self];
}

- (BOOL)checkQQnumberInput
{
    NSString *qqNum = @"^[1-9](\\d){4,9}$";
    NSPredicate *regextestQQ = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",qqNum];
    return [regextestQQ evaluateWithObject:self];
    
}

-(BOOL)NewCheckPhoneNumInput{
    
//    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
//    
//    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
//    
//    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
//    
//    NSString * CT = @"^1((33|53|8[019])[0-9]|349)\\d{7}$"; //^1((33|53|8[09])[0-9]|349)\\d{7}
//    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
//    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
//    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
//    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
//    BOOL res1 = [regextestmobile evaluateWithObject:self];
//    BOOL res2 = [regextestcm evaluateWithObject:self];
//    BOOL res3 = [regextestcu evaluateWithObject:self];
//    BOOL res4 = [regextestct evaluateWithObject:self];
    
    /**
     * 移动号段正则表达式
     */
    NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
    /**
     * 联通号段正则表达式
     */
    NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
    /**
     * 电信号段正则表达式
     */
    NSString *CT_NUM = @"^((133)|(153)|(177)|(178)|(18[0,1,9]))\\d{8}$";//(178)是我自己加进去的
    
    

    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
    
    BOOL res2 = [regextestcm evaluateWithObject:self];
    BOOL res3 = [regextestcu evaluateWithObject:self];
    BOOL res4 = [regextestct evaluateWithObject:self];
    
    if (res2 || res3 || res4 )//res1 || res2 || res3 || res4
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}
- (BOOL)checkOrgnizNameInput
{
    NSString *OrgnizName = @"^[a-zA-Z\u4e00-\u9fa5]{2,12}+$";
    NSPredicate *regextNumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",OrgnizName];
    return [regextNumber evaluateWithObject:self];
}



//判断是否有中文
- (BOOL)IsChinese:(NSString *)str {
    for(int i=0; i< [str length];i++){
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
        {
            return YES;
        }
    }
    return NO;
}

//计算中英文字数
- (int)countWord:(NSString *)s
{
    int i,n=[s length],l=0,a=0,b=0;
    unichar c;
    for(i=0;i<n;i++){
        c=[s characterAtIndex:i];
        if(isblank(c)){
            b++;
        }else if(isascii(c)){
            a++;
        }else{
            l++;
        }
    }
    if(a==0 && l==0) return 0;
    return l+(int)ceilf((float)(a+b)/2.0);
}

-  (NSInteger)convertToInt
//:(NSString*)strtemp
{
    
    NSInteger strlength = 0;
    char* p = (char*)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
    
}


+ (NSString*)timeStringChangeToZMTimeString:(NSString*)time{
    
    NSCalendar *calendar2 = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *components = [calendar2 components:unitFlags fromDate:[NSDate date]];
    NSInteger iCurDay = [components day];
    NSInteger iCurY = [components year];
    NSInteger iCurM = [components month];
    
    NSArray*timeAry1 = [time componentsSeparatedByString:@" "];
    NSArray*dayAry = [timeAry1[0] componentsSeparatedByString:@"-"];
    NSArray*minAry = [timeAry1[1] componentsSeparatedByString:@":"];
    NSString*min = [NSString stringWithFormat:@"%@:%@",minAry[0],minAry[1]];
    
    //昨天
    NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:-(24*60*60)];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *  locationString=[dateformatter stringFromDate:yesterday];
    NSArray*yesAry = [locationString componentsSeparatedByString:@"-"];
    
    if ([dayAry[0] integerValue] == iCurY&&[dayAry[1] integerValue] == iCurM&&[dayAry[2] integerValue] == iCurDay) {
        return  [NSString stringWithFormat:@"%@",min];
    }else if ([dayAry[0] isEqualToString:yesAry[0]]&&[dayAry[1] isEqualToString:yesAry[1]]&&[dayAry[2] isEqualToString:yesAry[2]]) {
        
        return  [NSString stringWithFormat:@"昨天 %@",min];
        
    }else{
        
        return  [NSString stringWithFormat:@"%@ %@",timeAry1[0],min];
    }
    
}


@end
