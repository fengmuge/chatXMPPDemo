//
//  NSString+custom.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (custom)

// 是否为空
+ (BOOL)isNone:(NSString * _Nullable)string;
// 路径处理
+ (NSString *)filePathWithComponent:(NSString *)component extension:(NSString * _Nullable)extension;
// 是否为整型
- (bool)isPureInt;
// 是否为浮点型
- (bool)isPureFloat;
// 获取首字母
- (NSString *)getTitle;
// 获取大写的首字母
- (NSString *)getTitleWithUppercase;
// 判断是否是英文
- (bool)isEnglishAlphabet;
// 判断是否是数字
- (bool)isDigit;
// 判断是否是中文
- (bool)isChineseAlphabet;
// 判断字符串中是否包含emoji
- (BOOL)stringContainsEmoji;
// 判断字符串中是否存在emoji --- 用于第三方键盘
- (BOOL)tpStringContaionsEmoji;
// 判断是否是九宫格输入，因为系统键盘九宫格输汉字，实际上是表情
- (BOOL)isNineKeyboard;
//// 对字符串添加前后缀
//- (NSString *)sortOutStringWithContent:(NSString *)content Prefix:(NSString *)prefix suffix:(NSString *)suffix maxLine:(CGFloat)maxLineNumber font:(CGFloat)font width:(CGFloat)width;

// 将文字内容进行整理，返回每一行文字组成的数组
- (NSArray *)getLinesContents:(CGFloat)maxWidth font:(UIFont *)font;

- (NSRange)getSubstringRange:(NSString *)subString;

- (NSString *)getSubstring:(NSRange)range;
// 整理数字
- (NSString *)formatCountNumber;

// 从XMPPMessage中获取delay date
- (NSDate *)getDelayDateFromMessageStamp;

@end

NS_ASSUME_NONNULL_END
