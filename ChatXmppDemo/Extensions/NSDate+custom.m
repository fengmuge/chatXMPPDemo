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
    [formatter setDateFormat:@"YYYY-MM-dd&HH:mm:ss"];
    NSString *currentTimeStr = [formatter stringFromDate:[NSDate date]];
    return currentTimeStr;
}

@end
