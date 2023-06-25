//
//  UserManager.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/9.
//

#import "UserManager.h"
#import "User.h"
#import "Subscription.h"

@interface UserManager() {
    User *_user;
    XMPPJID *_jid;
    NSMutableArray <Subscription *>* _subscribes;
}
@end

@implementation UserManager
@synthesize user = _user;
@synthesize subscribes = _subscribes;

static UserManager *_sharedInstance;
+ (UserManager *)sharedInstance {
    return [[self alloc] init];
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super init];
    });
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super allocWithZone:zone];
    });
    return _sharedInstance;
}


- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return _sharedInstance;
}

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    return _sharedInstance;
}

- (void)clearAll {
    self.user = nil;
    [self.contacts removeAllObjects];
    self.contacts = nil;
    [self.availableContacts removeAllObjects];
    self.availableContacts = nil;
    [self.subscribes removeAllObjects];
    self.subscribes = nil;
}

- (XMPPJID *)jid {
    return self.user.jid;
}

- (void)setJid:(XMPPJID *)jid {
    self.user.jid = jid;
}

- (NSString *)password {
    return self.user.password;
}

- (void)setPassword:(NSString *)password {
    self.user.password = password;
}

- (NSMutableArray *)contacts {
    if (!_contacts) {
        _contacts = [[NSMutableArray alloc] init];
    }
    return _contacts;
}

- (NSMutableArray<XMPPJID *> *)availableContacts {
    if (!_availableContacts) {
        _availableContacts = [[NSMutableArray alloc] init];
    }
    return _availableContacts;
}

// 同样保存在本地
- (NSMutableArray<Subscription *> *)subscribes {
    if (!_subscribes) {
        // 先判断本地有没有
#warning mark  --测试数据，本应该是从服务端拿到的数据加以缓存和保存--
        _subscribes = [[NSMutableArray alloc] init];
    }
    return _subscribes;
}

- (void)setSubscribes:(NSMutableArray<Subscription *> *)subscribes {
    _subscribes = subscribes;
    // 保存到本地
}

- (void)setUser:(User *)user {
    _user = user;
    // 将新数据保存到本地，替换老数据
}

- (User *)user {
    if (!_user) {
        // 先判断本地数据由没有，有则赋值，没有则为nil
    }
    return _user;
}

// 配置jid和password
- (void)configWithUsername:(NSString *)username password:(NSString *)password {
#warning mark  --测试数据，本应该是从服务端拿到的数据加以缓存和保存--
    self.user = [[User alloc] init];
    
    // 设置jid和password
    self.jid = [XMPPJID lxJidWithUsername:username];
    self.password = password;
}

// 用本地数据判断
- (bool)isLogin {
    return self.user != nil;
}

// 添加在线好友
- (void)addAvailableContacts:(XMPPJID *)jid {
    // 如果添加的是已经存在的联系人或者是用户自己，不予理会
    if ([self isLegalAvailableContact:jid] ||
        [jid isMy]) {
        return;
    }
    [self.availableContacts addObject:jid];
}

// 移除在线好友
- (void)removeAvailableContacts:(XMPPJID *)jid {
    if ([jid isMy]) {
        return;
    }
    XMPPJID *item = [self isLegalAvailableContact:jid];
    if (!item) {
        return;
    }
    [self.availableContacts removeObject:item];
}

// 针对在线联系人: 检测是否是已经存在的联系人
- (XMPPJID *)isLegalAvailableContact:(XMPPJID *)jid {
    for (XMPPJID *item in self.availableContacts) {
        if (![jid.user isEqualToString:item.user] ||
            ![jid.domain isEqualToString:item.domain])
        {
            continue;
        }
        return item;
    }
    return nil;
}

// 修改在线联系人信息
- (void)changeAvailabelContactsWith:(XMPPJID *)jid isAvailable:(bool)available {
    if (!available) {
        [self removeAvailableContacts:jid];
    } else {
        [self addAvailableContacts:jid];
    }
}

// 联系人available改变
- (bool)changeContactWithJID:(XMPPJID *)jid isAvailable:(bool)available {
    // 将联系人状态缓存起来
    [self changeAvailabelContactsWith:jid isAvailable:available];
    // 遍历查找是否是已经保存的联系人
    User *contact = [self getUserFromContactsWith:jid];
    if (!contact) {
        return NO;
    }
    contact.isAvailable = available;
    // 发动通知
    [[NSNotificationCenter defaultCenter]postNotificationName:kXMPP_CONECT_AVAILABLE_CHANGE object:contact];
    return YES;
}

// 添加联系人
- (void)addContactWith:(XMPPJID *)jid {
    if ([self getUserFromContactsWith:jid]) {
        return;
    }
    if ([jid isEqualToJID:self.user.jid]) {
        return;
    }    
    XMPPvCardTemp *vCard = [[ChatManager sharedInstance].cardTempModule vCardTempForJID:jid shouldFetch:YES];
    // 到服务器请求联系人名片信息
//    [[ChatManager sharedInstance].cardTempModule fetchvCardTempForJID:jid];
    // 请求联系人名片信息，如果数据库有就不请求，否则发送名片请求
    [[ChatManager sharedInstance].cardTempModule fetchvCardTempForJID:jid ignoreStorage:YES];
    // 获取联系人名片信息，。如果数据库有就返回，没有就返回空，并到服务器抓取
//    [[ChatManager sharedInstance].cardTempModule vCardTempForJID:jid shouldFetch:YES];

    User *item = [[User alloc] init];
    item.jid = jid;
    item.vCard = vCard;
    item.isAvailable = ([self isLegalAvailableContact:jid] != nil);
    [self.contacts addObject:item];
}

// 删除联系人
- (void)removeContactWith:(XMPPJID *)jid {
    if ([jid isEqualToJID:self.user.jid]) {
        return;
    }
    // 获取当前联系人
    User *item = [self getUserFromContactsWith:jid];
    if (!item) {
        return;
    }
    [self.contacts removeObject:item];
}

// 根据jid获取联系人
- (User *)getUserFromContactsWith:(XMPPJID *)jid {
    if ([jid isEqualToJID:self.user.jid]) {
        return nil;
    }
    for (User *item in self.contacts) {
        if (![item.jid.user isEqualToString:jid.user]) {
            continue;
        }
        return item;
    }
    return nil;
}

// 联系人按照拼音首字母分组
- (NSDictionary *)sortContactsWithTitle {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    for (User *item in self.contacts) {
        NSString *title = [item.vCard.nickname getTitleWithUppercase];
        if (!title) {
            title = [item.jid.user getTitleWithUppercase];
        }
        if (result[title] == nil) {
            NSMutableArray *sectionArray = [[NSMutableArray alloc] init];
            [sectionArray addObject:item];
            [result setValue:sectionArray forKey:title];
        } else {
            NSMutableArray *sectionArray = [result valueForKey:title];
            [sectionArray addObject:item];
        }
    }
    return [result copy];
}
// 更新联系人或自己的名片
- (void)didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp forJID:(XMPPJID *)jid {
    if ([jid isEqualToJID:self.jid]) {
        self.user.vCard = vCardTemp;
    } else {
        User *item = [self getUserFromContactsWith:jid];
        if (item) {
            item.vCard = vCardTemp;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_VCARDTEMPMODULE_DIDRECEIVE_VCARDTEMP
                                                        object:[NSNumber numberWithBool:YES]
                                                      userInfo:@{@"jid": jid}];
}

// 更新联系人或自己的头像
- (void)didReceivePhoto:(UIImage *)photo forJID:(XMPPJID *)jid {
    if ([jid isEqualToJID:self.jid]) {
        self.user.vCard.photo = [photo toData];
        // 目前不知道服务端提不提供头像，和xmpp本身的一致不一致，所以，也同步上
        self.user.avatar = photo;
    } else {
        User *item = [self getUserFromContactsWith:jid];
        if (item) {
            item.vCard.photo = [photo toData];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_AVATAR_DIDRECEIVE_PHOTO
                                                        object:jid];
}

// 是否是重复的订阅请求
- (bool)isRepeatedSubscribeWith:(XMPPJID *)jid {
    for (XMPPJID *subscribeJID in self.subscribes) {
        if (![jid.user isEqualToString:subscribeJID.user] ||
            ![jid.domain isEqualToString:subscribeJID.domain]) {
            continue;
        }
        return YES;
    }
    return NO;
}

// 添加订阅请求
- (void)addSubscribesWith:(XMPPJID *)jid {
    if ([self isRepeatedSubscribeWith:jid]) {
        return;
    }
#warning mark - 这里暂时先用数量判断，也可以根据日期进行判断,LRU不适合这里
    if (self.subscribes.count > 29) {
        self.subscribes = [[self.subscribes subarrayWithRange:NSMakeRange(0, 29)] mutableCopy];
    }
    // 将最新的插到最前面
    [self.subscribes insertObject:[[Subscription alloc] initWithJid:jid] atIndex:0];
    // 通知，有新的订阅信息
    [[NSNotificationCenter defaultCenter]postNotificationName:kXMPP_ADD_SUBSCRIPTION object:nil];
}

// 删除订阅请求
- (void)removeSubscribesWith:(XMPPJID *)jid {
    Subscription *item;
    for (Subscription *subItem in self.subscribes) {
        if ([subItem.jid isEqualToJID:jid]) {
            item = subItem;
            break;
        }
    }
    if (!item) {
        return;
    }
    [self.subscribes removeObject:item];
}

@end
