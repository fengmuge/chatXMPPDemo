//
//  ImagePickerManager.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/6.
//

#import "ImagePickerManager.h"
#import "PermissionsManager.h"
#import <TZImagePickerController.h>

#define kMaxPickerCount 9
@interface ImagePickerManager () <
TZImagePickerControllerDelegate
>

@property (nonatomic, copy) kDidFinishPickingPhotosWithInfosHandle finishPickingPhotoHandler;

@end

@implementation ImagePickerManager

static ImagePickerManager *_sharedInstance;

+ (ImagePickerManager *)sharedInstance {
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

- (void)getPhotoFrom:(UIViewController *)controller withComplete:(kDidFinishPickingPhotosWithInfosHandle)handler {
    self.finishPickingPhotoHandler = handler;
    TZImagePickerController *pickerController = [self getImagePickerControllerWith:1];
    pickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [controller presentViewController:pickerController
                             animated:YES
                           completion:nil];
}

// 简单写一下，其实可以根据需求扩展出多个方法进行定制
- (TZImagePickerController *)getImagePickerControllerWith:(NSInteger)maxCount {
    TZImagePickerController *pickerController = [[TZImagePickerController alloc] initWithMaxImagesCount:maxCount
                                                                                               delegate:self];
    pickerController.allowPickingVideo = NO; // 不允许选择视频
    pickerController.allowTakeVideo = NO;    // 不允许拍摄视频
    pickerController.allowTakePicture = NO;  // 不允许拍照
    pickerController.showPhotoCannotSelectLayer = YES;
    return pickerController;
}

#pragma mark --TZImagePickerControllerDelegate 都是可选回调--

// The picker should dismiss itself; when it dismissed these callback will be called.
// You can also set autoDismiss to NO, then the picker don't dismiss itself.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 你也可以设置autoDismiss属性为NO，选择器就不会自己dismis了
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它

#warning mark --- 以下两个回调二选一 ---
//- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
//
//}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    self.finishPickingPhotoHandler(photos, assets, isSelectOriginalPhoto, infos);
    
    NSLog(@"%s \n didFinishPickingPhotos: %@ \n sourceAssets: %@ \n isSelectOriginalPhoto: %@ \n infos: %@", __func__, photos, assets, [NSNumber numberWithBool:isSelectOriginalPhoto], infos);
}

// 已经取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    NSLog(@"%s", __func__);
}

/// 如果用户选择了某张照片下面的代理方法会被执行
/// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
/// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
- (void)imagePickerController:(TZImagePickerController *)picker didSelectAsset:(PHAsset *)asset photo:(UIImage *)photo isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
}

/// 如果用户取消选择了某张照片下面的代理方法会被执行
/// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
/// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
- (void)imagePickerController:(TZImagePickerController *)picker didDeselectAsset:(PHAsset *)asset photo:(UIImage *)photo isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
}

//// If user picking a video and allowPickingMultipleVideo is NO, this callback will be called.
//// If allowPickingMultipleVideo is YES, will call imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
//// 如果用户选择了一个视频且allowPickingMultipleVideo是NO，下面的代理方法会被执行
//// 如果allowPickingMultipleVideo是YES，将会调用imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
//- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset {
//
//}
//
//// If allowEditVideo is YES and allowPickingMultipleVideo is NO, When user picking a video, this callback will be called.
//// If allowPickingMultipleVideo is YES, video editing is not supported, will call imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
//// 当allowEditVideo是YES且allowPickingMultipleVideo是NO是，如果用户选择了一个视频，下面的代理方法会被执行
//// 如果allowPickingMultipleVideo是YES，则不支持编辑视频，将会调用imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
//- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingAndEditingVideo:(UIImage *)coverImage outputPath:(NSString *)outputPath error:(NSString *)errorMsg {
//
//}
//
//// When saving the edited video to the album fails, this callback will be called.
//// 编辑后的视频自动保存到相册失败时，下面的代理方法会被执行
//- (void)imagePickerController:(TZImagePickerController *)picker didFailToSaveEditedVideoWithError:(NSError *)error {
//
//}
//
//// If user picking a gif image and allowPickingMultipleVideo is NO, this callback will be called.
//// If allowPickingMultipleVideo is YES, will call imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
//// 如果用户选择了一个gif图片且allowPickingMultipleVideo是NO，下面的代理方法会被执行
//// 如果allowPickingMultipleVideo是YES，将会调用imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
//- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(PHAsset *)asset {
//
//}
//
//// Decide album show or not't
//// 决定相册显示与否 albumName:相册名字 result:相册原始数据
//- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(PHFetchResult *)result {
//    return YES;
//}
//
//- (BOOL)isAssetCanBeDisplayed:(PHAsset *)asset {
//    return YES;
//}
//
//// Decide asset can be selected
//// 决定照片能否被选中
//- (BOOL)isAssetCanBeSelected:(PHAsset *)asset {
//    return YES;
//}

@end
