//
//  LXGroupAvatar.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/11.
//

#import "LXGroupAvatar.h"

@implementation LXGroupAvatar

// 根据groupJid获取成员头像数据
+ (void)fetchGroupAvatars:(NSString *)groupJid placeHolder:(UIImage *)placeHolder completion:(void(^)(BOOL success, UIImage *image, NSString *groupJid))hander {
    
}
// 因为目前服务端未提供接口获取头像，因此从缓存的群列表中去获取群用户头像
+ (void)sortGroupAvatars:(NSString *)groupJid placeHolder:(UIImage *)placeHolder completion:(void(^)(BOOL success, UIImage *image, NSString *groupJid))handler {
    
}
// 根据群成员头像地址创建群组头像
+ (void)createGroupAvatarWityUrls:(NSArray *)groupAvatarUrls completion:(void(^)(UIImage *groupAvatar))handler {
    
}
// 根据群成员头像image创建群头像
+ (void)createGroupAvatarWithImages:(NSArray *)groupAvatarImages completion:(void(^)(UIImage *groupAvatar))handler {
    
}
// 缓存群头像
+ (void)cacheGroupAvatar:(UIImage *)avatar number:(UInt32)num groupJid:(NSString *)groupJid {
    
}
// 异步获取群头像缓存，会请求网络 --- 暂时没有接口
+ (void)asyncGetCacheGroupAvatar:(NSString *)groupJid completion:(void(^)(UIImage *groupAvatar))handler {
    
}
// 从本地获取群头像缓存，不请求网络
+ (void)getCacheAvatar:(NSString *)groupJid number:(UInt32)num {
    
}

@end
