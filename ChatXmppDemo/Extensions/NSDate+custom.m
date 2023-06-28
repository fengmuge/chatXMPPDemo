//
//  NSDate+custom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/25.
//

#import "NSDate+custom.h"

@implementation NSDate (custom)

+ (NSString *)transformCurrentDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd'T'HH:mm:ss"];
    NSString *currentTimeStr = [formatter stringFromDate:[NSDate date]];
    return currentTimeStr;
}

- (NSString *)transformWithFormat:(NSString *)format {
    NSString *tempFormat = format ?: @"yyyy-MM-dd HH:mm:ss";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: tempFormat];
    NSString *currentTimeStr = [formatter stringFromDate: self];
    return currentTimeStr;
}

@end
