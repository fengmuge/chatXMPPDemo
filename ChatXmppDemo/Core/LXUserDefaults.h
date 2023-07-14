//
//  LXUserDefaults.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXUserDefaults : NSObject

+ (void)setValue:(id)value key:(NSString *)key;

+ (id)getValue:(NSString *)key;

+ (void)setObject:(id)obj key:(NSString *)key;

+ (id)getObject:(NSString *)key;

+ (void)removeValue:(NSString *)key;

@end

NS_ASSUME_NONNULL_END

