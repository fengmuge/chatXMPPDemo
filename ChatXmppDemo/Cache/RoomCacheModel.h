//
//  RoomCacheModel.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomCacheModel : NSObject

- (nullable id)getValueWith:(nonnull NSString *)key;

- (void)putValue:(id)value withKey:(nonnull NSString *)key;

- (void)removeValueWith:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
