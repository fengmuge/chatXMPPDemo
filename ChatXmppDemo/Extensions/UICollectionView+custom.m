//
//  UICollectionView+custom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/19.
//

#import "UICollectionView+custom.h"

@implementation UICollectionView (custom)

- (void)scrollToBottom:(bool)animated {
    CGFloat collectionViewContentHeight = self.collectionViewLayout.collectionViewContentSize.height;
    
    __weak typeof(self) weakSelf = self;
    [self performBatchUpdates:^{
    } completion:^(BOOL finished) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf scrollRectToVisible:CGRectMake(0, collectionViewContentHeight - 1.0, 1.0, 1.0) animated:animated];
    }];
}

@end
