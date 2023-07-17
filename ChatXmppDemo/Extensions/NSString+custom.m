//
//  NSString+custom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/6.
//

#import "NSString+custom.h"
#import <CoreText/CoreText.h>

@implementation NSString (custom)

+ (BOOL)isNone:(NSString *)string {
    return string == nil
    || [string isKindOfClass:[NSNull class]]
    || ![string isKindOfClass:[NSString class]]
    || [string isEqualToString:@""];
}

+ (NSString *)filePathWithComponent:(NSString *)component extension:(NSString *)extension {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:component];
    if (extension) {
        path = [path stringByAppendingPathExtension:extension];
    }
    return path;
}

// 获取首字母, 不区分大小写
- (NSString *)getTitle {
    if ([NSString isNone:self]) {
        return nil;
    }
    NSMutableString *value = [self mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)value, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)value, NULL, kCFStringTransformStripCombiningMarks, NO);
    
    NSString *subValue = [value substringWithRange:NSMakeRange(0, 1)];
        
    if (![subValue isEnglishAlphabet] ||
        [subValue isDigit] ||
        [subValue isPureInt] ||
        [subValue isPureFloat])
    {
        return @"#";
    }
    return subValue;
}
// 获取大写的首字母
- (NSString *)getTitleWithUppercase {
    NSString *value = [self getTitle];
    if (value == nil || [value isEqualToString:@"#"]) {
        return value;
    }
    return [value uppercaseString];
}

// 判断是否是英文字母
- (bool)isEnglishAlphabet {
    NSString *regex = @"[a-zA-Z]*";
    return [self predicateWithFormat:regex];
}
// 判断是否是数字
- (bool)isDigit {
    NSString *regex = @"[0-9]*";
    return [self predicateWithFormat: regex];
}

// 是否为整型
- (bool)isPureInt {
    NSScanner *scanner = [NSScanner scannerWithString:self];
    int val;
    return [scanner scanInt:&val] && [scanner isAtEnd];
}

// 是否为浮点型
- (bool)isPureFloat {
    NSScanner *scanner = [NSScanner scannerWithString:self];
    float val;
    return [scanner scanFloat:&val] && [scanner isAtEnd];
}

// 判断是否是中文
- (bool)isChineseAlphabet {
    NSString *regex = @"[\u4e00-\u9fa5]+";
    return [self predicateWithFormat:regex];
}

// 正则，筛选
- (bool)predicateWithFormat:(NSString *)regex {
    NSPredicate *pred= [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([pred evaluateWithObject:self]) {
        return YES;
    }
    return NO;
}


// 用来判断是否包含emoji表情(系统表情)
- (BOOL)stringContainsEmoji{
    
    __block BOOL returnValue = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        
        const unichar hs = [substring characterAtIndex:0];
        if (0xd800 <= hs && hs <= 0xdbff){
            if (substring.length > 1){
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800)*0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    returnValue = YES;
                }
            }
        } else if (substring.length > 1) {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3) {
                returnValue = YES;
            }
            
        } else {
            // non surrogate
            if (0x2100 <= hs && hs <= 0x27ff) {
                returnValue = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                returnValue = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                returnValue = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                returnValue = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                returnValue = YES;
            }
        }
    }];
    
    return returnValue;
}

// 判断字符串中是否存在emoji(用于第三方键盘)
- (BOOL)tpStringContaionsEmoji{
    
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}

// 判断是否是九宫格输入，因为系统键盘九宫格输汉字，实际上是表情
- (BOOL)isNineKeyboard{
    
    NSString *other = @"➋➌➍➎➏➐➑➒";
    int len = (int)self.length;
    for(int i=0;i<len;i++)
    {
        if(!([other rangeOfString:self].location != NSNotFound))
            return NO;
    }
    return YES;
}

// 将文字内容进行整理，返回每一行文字组成的数组
- (NSArray *)getLinesContents:(CGFloat)maxWidth font:(UIFont *)font{
    
    if (self == nil) { return nil; }
    CTFontRef myFont = CTFontCreateWithName(( CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:self];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attStr.length)];
    [attStr addAttribute:(NSString *)kCTFontAttributeName
                   value:(__bridge  id)myFont
                   range:NSMakeRange(0, attStr.length)];
    CFRelease(myFont);
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(( CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,maxWidth,100000));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = ( NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    for (id line in lines) {
        CTLineRef lineRef = (__bridge  CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [self substringWithRange:range];
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr,
                                       lineRange,
                                       kCTKernAttributeName,
                                       (CFTypeRef)([NSNumber numberWithFloat:0.0]));
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr,
                                       lineRange,
                                       kCTKernAttributeName,
                                       (CFTypeRef)([NSNumber numberWithInt:0.0]));
        [linesArray addObject:lineString];
    }
    CGPathRelease(path);
    CFRelease(frame);
    CFRelease(frameSetter);
    return linesArray;
}


- (NSRange)getSubstringRange:(NSString *)subString{

    return [self rangeOfString:subString];
}

- (NSString *)getSubstring:(NSRange)range{
    return [self substringWithRange:range];
}

// 整理数字
- (NSString *)formatCountNumber{
    
    float numFloat = self.floatValue;
    NSString *expend = @"";
    if (numFloat >= 10000000){
        numFloat = numFloat/10000000;
        expend = @"千万";
    }else if (numFloat >= 10000){
        numFloat = numFloat/10000;
        expend = @"万";
    }
    BOOL isInt = numFloat == roundf(numFloat);
    return  [self stringFrom:numFloat isInt:isInt expend:expend];
}

- (NSString *)stringFrom:(float)num isInt:(BOOL)isInt expend:(NSString *)expend{
    
    if (isInt){
        return [NSString stringWithFormat:@"%.0f%@", num, expend];
    }else{
        return  [NSString stringWithFormat:@"%.1f%@", num, expend];
    }
}


// 从XMPPMessage中获取delay date
- (NSDate *)transformToDateForXmpp {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSArray *arr=[self componentsSeparatedByString:@"T"];
    NSString *dateStr=[arr objectAtIndex:0];
    NSString *timeStr=[[[arr objectAtIndex:1] componentsSeparatedByString:@"."] objectAtIndex:0];
    NSDate *delayDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@T%@+0000",dateStr,timeStr]];
    return delayDate;
}

//- (nonnull NSString *)sortOutStringWithContent:(nonnull NSString *)content Prefix:(nonnull NSString *)prefix suffix:(nonnull NSString *)suffix maxLine:(CGFloat)maxLineNumber font:(CGFloat)font width:(CGFloat)width {
//}

<<<<<<< HEAD
+ (NSString *)random {
    unsigned int random = arc4random_uniform(1000000001);
    
    return [NSString stringWithFormat:@"%06u", random];
}
=======
>>>>>>> 854b75d26cabd7d317d2b4ed108afde93654cb47

@end
