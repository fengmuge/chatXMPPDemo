//
//  AudioManager.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/19.
//

#import <Foundation/Foundation.h>

typedef void(^kAudioManagerStopRecordHandler) (NSData *__nullable audioData, NSTimeInterval duringTime, NSString *__nullable error);
typedef void(^kAudioManagerWillPlayHandler) (NSError *__nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface AudioManager : NSObject

+ (AudioManager *)sharedInstance;

- (void)record;

- (void)setAudioSession;

- (void)playAudio:(NSData *)audioData withHandler:(kAudioManagerWillPlayHandler)handler;

- (void)stopAudioRecordWith:(kAudioManagerStopRecordHandler)handler;

@end

NS_ASSUME_NONNULL_END
