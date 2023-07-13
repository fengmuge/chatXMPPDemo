//
//  LXUserDefaults.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/11.
//

#import "LXUserDefaults.h"

#define kUSERDEFAULTS [NSUserDefaults standardUserDefaults]

@implementation LXUserDefaults

+ (void)setValue:(id)value key:(NSString *)key {
    if ([NSString isNone:key]) {
        return;
    }
    [kUSERDEFAULTS setValue:value forKey:key];
    [kUSERDEFAULTS synchronize];
}

+ (id)getValue:(NSString *)key {
    if ([NSString isNone:key]) {
        return nil;
    }
    return [kUSERDEFAULTS objectForKey:key];
}

+ (void)setObject:(id)obj key:(NSString *)key {
    if ([NSString isNone:key]) {
        return;
    }
    NSData *objData = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [kUSERDEFAULTS setValue:objData forKey:key];
    [kUSERDEFAULTS synchronize];
}

+ (id)getObject:(NSString *)key {
    if ([NSString isNone:key]) {
        return nil;
    }
    NSData *objData = [kUSERDEFAULTS objectForKey:key];
    return [NSKeyedUnarchiver unarchiveObjectWithData:objData];
}

+ (Class)getObject:(NSString *)key class:(Class)class {
    id object = [LXUserDefaults getObject:key];
    if ([object isMemberOfClass:class]) {
        return object;
    }
    return nil;
}

+ (void)removeValue:(NSString *)key {
    if ([NSString isNone:key]) {
        return;
    }
    [kUSERDEFAULTS removeObjectForKey:key];
    [kUSERDEFAULTS synchronize];
}

@end
