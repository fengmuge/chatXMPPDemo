//
//  ImagePickerManager.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/6.
//

#import <Foundation/Foundation.h>

typedef void (^kDidFinishPickingPhotosWithInfosHandle)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto,NSArray<NSDictionary *> *infos);

NS_ASSUME_NONNULL_BEGIN

@interface ImagePickerManager : NSObject

@property (nonatomic, weak) UIViewController *presentingViewController;

+ (ImagePickerManager *)sharedInstance;

- (void)getPhotoFrom:(UIViewController *)controller withComplete:(kDidFinishPickingPhotosWithInfosHandle)handler;

@end

NS_ASSUME_NONNULL_END
