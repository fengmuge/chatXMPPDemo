//
//  NSDate+custom.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (custom)

+ (NSString *)transformCurrentDate;

- (NSString *)transformWithFormat:(nullable NSString *)format;

@end

NS_ASSUME_NONNULL_END
