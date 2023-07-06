//
//  PermissionsManager.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/6.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    PermissionNotDetermined,
    PermissionNotAvailable,
    PermissionDenied,
    PermissionAuthorized
} PermissionStatus;

typedef enum : NSUInteger {
    PermissionCamera,
    PermissionMicrophone,
    PermissionLocation,
    PermissionNotifications,
    PermissionContacts,
    PermissionPhotos
} PermissionType;

NS_ASSUME_NONNULL_BEGIN

typedef void(^kPermissionStatusHandler)(PermissionStatus status);

@interface BasePermissionModel : NSObject

@property (nonatomic, assign) PermissionStatus perStatus;

- (void)fetchStatusWithComplete:(kPermissionStatusHandler)handler;
- (void)requestWithComplete:(kPermissionStatusHandler)handler;

@end

@interface CameraPermission : BasePermissionModel

@end

@interface MicrophonePermission : BasePermissionModel

@end

typedef enum : NSUInteger {
    LocationPermissionAlways,
    LocationPermissionWhenInUse,
} LocationPermissionStatus;

@interface LocationPermission : BasePermissionModel

@property (nonatomic, assign, readonly) LocationPermissionStatus lpStatus;

- (instancetype)initWithPermissionStatus:(LocationPermissionStatus)lpStatus;

@end

@interface NotificationPermission : BasePermissionModel

@end

@interface ContactPermission : BasePermissionModel

@end

@interface PhotoPermission : BasePermissionModel

@end

@interface PermissionsManager : NSObject

+ (PermissionsManager *)sharedInstance;

- (void)fetchStatusFor:(PermissionType)type withComplete:(kPermissionStatusHandler)handler;
- (void)requestFor:(PermissionType)type withComplete:(kPermissionStatusHandler)handler;
- (PermissionStatus)statusFor:(PermissionType)type;
- (BOOL)isAuthorizedFor:(PermissionType)type;

@end

NS_ASSUME_NONNULL_END
