//
//  PermissionsManager.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/6.
//

#import "PermissionsManager.h"
#import <Photos/Photos.h>
#import <Contacts/Contacts.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <UserNotifications/UserNotifications.h>

@implementation BasePermissionModel

- (void)fetchStatusWithComplete:(kPermissionStatusHandler)handler {
    NSLog(@"%s", __func__);
}
- (void)requestWithComplete:(kPermissionStatusHandler)handler {
    NSLog(@"%s", __func__);
}

@end

@implementation CameraPermission

- (PermissionStatus)perStatus {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    NSUInteger statusRawValue = (NSUInteger)status;
    return (PermissionStatus)statusRawValue;
}

- (void)fetchStatusWithComplete:(kPermissionStatusHandler)handler {
    handler(self.perStatus);
}

- (void)requestWithComplete:(kPermissionStatusHandler)handler {
    __weak typeof(self) weakSelf = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        __strong typeof(self) strongSelf = weakSelf;
        handler(strongSelf.perStatus);
    }];
}

@end

@implementation MicrophonePermission

- (PermissionStatus)perStatus {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    NSUInteger statusRawValue = (NSUInteger)status;
    return (PermissionStatus)statusRawValue;
}

- (void)fetchStatusWithComplete:(kPermissionStatusHandler)handler {
    handler(self.perStatus);
}

- (void)requestWithComplete:(kPermissionStatusHandler)handler {
    __weak typeof(self) weakSelf = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        __strong typeof(self) strongSelf = weakSelf;
        handler(strongSelf.perStatus);
    }];
}


@end

@interface LocationPermission () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) kPermissionStatusHandler requestHandler;
@property (nonatomic, assign, readwrite) LocationPermissionStatus lpStatus;

@end

@implementation LocationPermission

- (instancetype)initWithPermissionStatus:(LocationPermissionStatus)lpStatus {
    if (self = [super init]) {
        self.lpStatus = lpStatus;
    }
    return self;
}

- (PermissionStatus)perStatus {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    return [self sortStatus:status];
}

- (PermissionStatus)sortStatus:(CLAuthorizationStatus)status {
    NSUInteger statusValue = (NSUInteger)status < (NSUInteger)PermissionAuthorized ? (NSUInteger)status : (NSUInteger)PermissionAuthorized;
    return (PermissionStatus)statusValue;
}

- (void)fetchStatusWithComplete:(kPermissionStatusHandler)handler {
    handler(self.perStatus);
}

- (void)requestWithComplete:(kPermissionStatusHandler)handler {
    self.requestHandler = handler;
    
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    switch (self.lpStatus) {
        case LocationPermissionWhenInUse:
            [manager requestWhenInUseAuthorization];
            break;
        default:
            [manager requestAlwaysAuthorization];
            break;
    }
    self.locationManager = manager;
}

#pragma mark --CLLocationManagerDelegate--
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusNotDetermined) {
        return;
    }
    if (self.requestHandler) {
        PermissionStatus sortedStatus = [self sortStatus:status];
        self.requestHandler(sortedStatus);
        self.requestHandler = nil;
    }
    if (self.locationManager) {
        self.locationManager.delegate = nil;
        self.locationManager = nil;
    }
}

@end

@implementation NotificationPermission

- (instancetype)init {
    if (self = [super init]) {
        self.perStatus = PermissionNotDetermined;
    }
    return self;
}

- (void)fetchStatusWithComplete:(kPermissionStatusHandler)handler {
    __weak typeof(self) weakSelf = self;
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        __strong typeof(self) strongSelf = weakSelf;
        switch (settings.authorizationStatus) {
            case UNAuthorizationStatusNotDetermined:
                strongSelf.perStatus = PermissionNotDetermined;
                break;
            case UNAuthorizationStatusDenied:
                strongSelf.perStatus = PermissionDenied;
                break;
            default:
                strongSelf.perStatus = PermissionAuthorized;
                break;
        }
        handler(strongSelf.perStatus);
    }];
}

- (void)requestWithComplete:(kPermissionStatusHandler)handler {
    __weak typeof(self) weakSelf = self;
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        PermissionStatus result = granted ? PermissionAuthorized : PermissionDenied;
        strongSelf.perStatus = result;
        handler(result);
    }];
}

@end

@implementation ContactPermission

- (PermissionStatus)perStatus {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    NSUInteger statusValue = (NSUInteger)status;
    return (PermissionStatus)statusValue;
}

- (void)fetchStatusWithComplete:(kPermissionStatusHandler)handler {
    handler(self.perStatus);
}

- (void)requestWithComplete:(kPermissionStatusHandler)handler {
    CNContactStore *store = [[CNContactStore alloc] init];
    __weak typeof(self) weakSelf = self;
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        PermissionStatus result = granted ? PermissionAuthorized : PermissionDenied;
        strongSelf.perStatus = result;
        handler(result);
    }];
}

@end

@implementation PhotoPermission

- (PermissionStatus)perStatus {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    NSUInteger statusValue = (NSUInteger)status;
    return (PermissionStatus)statusValue;
}

- (void)fetchStatusWithComplete:(kPermissionStatusHandler)handler {
    handler(self.perStatus);
}

- (void)requestWithComplete:(kPermissionStatusHandler)handler {
    __weak typeof(self) weakSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        __strong typeof(self) strongSelf = weakSelf;
        NSUInteger statusValue = (NSUInteger)status;
        strongSelf.perStatus = (PermissionStatus)statusValue;
        handler(strongSelf.perStatus);
    }];
}

@end

@interface PermissionsManager ()

@property (nonatomic, strong) CameraPermission *cameraPer;
@property (nonatomic, strong) MicrophonePermission *microphonePer;
@property (nonatomic, strong) LocationPermission *locationPer;
@property (nonatomic, strong) NotificationPermission *notificationPer;
@property (nonatomic, strong) ContactPermission *contactsPer;
@property (nonatomic, strong) PhotoPermission *photoPer;

@end

@implementation PermissionsManager

static PermissionsManager *_sharedInstance;

+ (PermissionsManager *)sharedInstance {
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

- (BasePermissionModel *)managerFor:(PermissionType)type {
    switch (type) {
        case PermissionCamera:
            return self.cameraPer;
        case PermissionMicrophone:
            return self.microphonePer;
        case PermissionLocation:
            return self.locationPer;
        case PermissionNotifications:
            return self.notificationPer;
        case PermissionContacts:
            return self.contactsPer;
        default:
            return self.photoPer;
    }
}

- (void)fetchStatusFor:(PermissionType)type withComplete:(kPermissionStatusHandler)handler {
    BasePermissionModel *manager = [self managerFor:type];
    [manager fetchStatusWithComplete:^(PermissionStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(status);
        });
    }];
}

- (void)requestFor:(PermissionType)type withComplete:(kPermissionStatusHandler)handler {
    BasePermissionModel *manager = [self managerFor:type];
    [manager requestWithComplete:^(PermissionStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(status);
        });
    }];
}

- (PermissionStatus)statusFor:(PermissionType)type {
    BasePermissionModel *manager = [self managerFor:type];
    return manager.perStatus;
}

- (BOOL)isAuthorizedFor:(PermissionType)type {
    PermissionStatus status = [self statusFor:type];
    return status == PermissionAuthorized;
}

- (CameraPermission *)cameraPer {
    if (!_cameraPer) {
        _cameraPer = [[CameraPermission alloc] init];
    }
    return _cameraPer;
}

- (MicrophonePermission *)microphonePer {
    if (!_microphonePer) {
        _microphonePer = [[MicrophonePermission alloc] init];
    }
    return _microphonePer;
}

- (LocationPermission *)locationPer {
    if (!_locationPer) {
        _locationPer = [[LocationPermission alloc] init];
    }
    return _locationPer;
}

- (NotificationPermission *)notificationPer {
    if (!_notificationPer) {
        _notificationPer = [[NotificationPermission alloc] init];
    }
    return _notificationPer;
}

- (ContactPermission *)contactsPer {
    if (!_contactsPer) {
        _contactsPer = [[ContactPermission alloc] init];
    }
    return _contactsPer;
}

- (PhotoPermission *)photoPer {
    if (!_photoPer) {
        _photoPer = [[PhotoPermission alloc] init];
    }
    return _photoPer;
}

@end
