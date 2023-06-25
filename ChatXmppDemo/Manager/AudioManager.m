//
//  AudioManager.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/19.
//

#import "AudioManager.h"

#define kRecordAudioFile @"audioMessageRecorder.wav"

@interface AudioManager () <AVAudioPlayerDelegate, AVAudioRecorderDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;

@end

@implementation AudioManager

static AudioManager *_sharedInstance;
+ (AudioManager *)sharedInstance {
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
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    [self.audioRecorder stop];
    self.audioRecorder = nil;
}

- (AVAudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        NSURL *url = [self getSavePath];
        NSDictionary *setting = [self getAudioSetting];
        NSError *error;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate = self;
        if (error) {
            NSLog(@"创建录音对象时候发生错误: %@", [error localizedDescription]);
        }
    }
    return _audioRecorder;
}

- (NSURL *)getSavePath {
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr = [urlStr stringByAppendingPathComponent:kRecordAudioFile];
    return [NSURL URLWithString:urlStr];
}

// 录音文件设置
- (NSDictionary *)getAudioSetting {
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    // 设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    // 设置录音采样率,8000是电话采样率,对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    // 设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    // 每个采样点位数,分别为8,16,24,32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    // 是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    // ...其他设置
    return dicM;
}

- (void)setAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    // 设置为播放和录音状态,方便在录音完成后播放录音
    NSError *setCategoryError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&setCategoryError];
    if (setCategoryError) {
        NSLog(@"AVAudioSession setCategory失败: %@", [setCategoryError localizedDescription]);
    }
    
    NSError *setActiveError;
    [session setActive:YES error:&setActiveError];
    if (setActiveError) {
        NSLog(@"AVAudioSession激活失败: %@", [setActiveError localizedDescription]);
    }
    NSError *error;
    BOOL success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if (!success) {
        NSLog(@"AVAudioSession overrideOutputAudioPort失败: %@", [error localizedDescription]);
    }
}

- (void)stopAudioRecordWith:(kAudioManagerStopRecordHandler)handler {
    NSTimeInterval time = self.audioRecorder.currentTime;
    if (time < 1.5) {
        [self stopRecord:YES];
        handler(nil, 0, @"录制时长不能低于1.5s");
    } else if (time > 60) {
        [self stopRecord:YES];
        handler(nil, 0, @"录制市场不能超过60s");
    } else {
        [self stopRecord:NO];
        
        NSURL *saveUrl = [self getSavePath];
        NSData *audioData = [NSData dataWithContentsOfFile:saveUrl.absoluteString];
        
        handler(audioData, time, nil);
    }
}

- (void)playAudio:(NSData *)audioData withHandler:(nonnull kAudioManagerWillPlayHandler)handler{
    if (!audioData) {
        NSError *error = [[NSError alloc] initWithDomain:@"音频文件为空，无法播放"
                                                    code:0
                                                userInfo:nil];
        handler(error);
        return;
    }
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer stop];
    }
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
    if (error) {
        handler(error);
        return;
    }
    self.audioPlayer.delegate = self;
    [self.audioPlayer play];
}

- (void)record {
    [self.audioRecorder record];
}

- (void)stopRecord:(BOOL)willDelete {
    [self.audioRecorder stop];
    if (!willDelete) {
        return;
    }
    [self.audioRecorder deleteRecording];
}

@end
