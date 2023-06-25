//
//  LXRefresh.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/25.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    LXRefreshTypeDropDown, // 只支持下拉
    LXRefreshTypeDropUp, // 只支持上拉
    LXRefreshTypeDropBoth, // 支持上下拉
} LXRefreshType;

typedef void(^lxRefreshCompletionHandler) (BOOL isDropDown);

NS_ASSUME_NONNULL_BEGIN

@interface LXRefresh : NSObject

- (instancetype)initWith:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
