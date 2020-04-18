#import <Foundation/Foundation.h>

#import "ProtocolBuffer.h"

#ifndef MediaRemote_h
#define MediaRemote_h

@interface _MRNowPlayingClientProtobuf : PBCodable <NSCopying> {
    NSString* _bundleIdentifier;
    NSString* _displayName;
    int _nowPlayingVisibility;
    NSString* _parentApplicationBundleIdentifier;
    int _processIdentifier;
    int _processUserIdentifier;
//    _MRColorProtobuf* _tintColor;
    struct {
        unsigned int nowPlayingVisibility:1;
        unsigned int processIdentifier:1;
        unsigned int processUserIdentifier:1;
        unsigned int isEmptyDeprecated:1;
    } _has;
}

@property (assign, nonatomic) bool hasProcessIdentifier;
@property (assign, nonatomic) int processIdentifier; //@synthesize processIdentifier=_processIdentifier - In the implementation block
@property (nonatomic, readonly) bool hasBundleIdentifier;
@property (nonatomic, readonly, retain) NSString* bundleIdentifier; //@synthesize bundleIdentifier=_bundleIdentifier - In the implementation block
@property (nonatomic, readonly) bool hasParentApplicationBundleIdentifier;
@property (nonatomic, readonly, retain) NSString* parentApplicationBundleIdentifier; //@synthesize parentApplicationBundleIdentifier=_parentApplicationBundleIdentifier - In the implementation block
@property (assign, nonatomic) bool hasProcessUserIdentifier;
@property (assign, nonatomic) int processUserIdentifier; //@synthesize processUserIdentifier=_processUserIdentifier - In the implementation block
@property (assign, nonatomic) bool hasNowPlayingVisibility;
@property (assign, nonatomic) int nowPlayingVisibility; //@synthesize nowPlayingVisibility=_nowPlayingVisibility - In the implementation block
@property (nonatomic, readonly) bool hasTintColor;
//@property (nonatomic,retain) _MRColorProtobuf* tintColor; //@synthesize tintColor=_tintColor - In the implementation block
@property (nonatomic, readonly) bool hasDisplayName;
@property (nonatomic, readonly, retain) NSString* displayName; //@synthesize displayName=_displayName - In the implementation block

-(bool)readFrom:(id)arg1;
-(void)writeTo:(id)arg1;
-(void)copyTo:(id)arg1;
-(void)mergeFrom:(id)arg1;
-(bool)hasDisplayName;
-(void)setDisplayName:(id)arg1;
-(bool)hasBundleIdentifier;
-(void)dealloc;
-(bool)isEqual:(id)arg1;
-(unsigned long long)hash;
-(id)description;
-(id)bundleIdentifier;
-(id)tintColor;
-(void)setTintColor:(id)arg1 ;
-(id)copyWithZone:(NSZone *)arg1;
-(id)dictionaryRepresentation;
-(void)setBundleIdentifier:(id)arg1;
-(id)displayName;
-(int)processIdentifier;
-(void)setParentApplicationBundleIdentifier:(id)arg1;
-(void)setHasProcessIdentifier:(bool)arg1;
-(bool)hasProcessIdentifier;
-(bool)hasParentApplicationBundleIdentifier;
-(void)setProcessUserIdentifier:(int)arg1;
-(void)setHasProcessUserIdentifier:(bool)arg1;
-(bool)hasProcessUserIdentifier;
-(int)nowPlayingVisibility;
-(void)setNowPlayingVisibility:(int)arg1;
-(void)setHasNowPlayingVisibility:(bool)arg1;
-(bool)hasNowPlayingVisibility;
-(id)nowPlayingVisibilityAsString:(int)arg1;
-(int)StringAsNowPlayingVisibility:(id)arg1;
-(bool)hasTintColor;
-(id)parentApplicationBundleIdentifier;
-(int)processUserIdentifier;
-(void)setProcessIdentifier:(int)arg1;

@end

typedef void (^MRMediaRemoteGetNowPlayingInfoBlock)(NSDictionary *info);
typedef void (^MRMediaRemoteGetNowPlayingClientBlock)(_MRNowPlayingClientProtobuf *clientObj);
typedef void (^MRMediaRemoteGetNowPlayingApplicationIsPlayingBlock)(BOOL playing);

void MRMediaRemoteRegisterForNowPlayingNotifications(dispatch_queue_t queue);
void MRMediaRemoteUnregisterForNowPlayingNotifications(void);
void MRMediaRemoteGetNowPlayingClient(dispatch_queue_t queue,
    MRMediaRemoteGetNowPlayingClientBlock block);
void MRMediaRemoteGetNowPlayingInfo(dispatch_queue_t queue,
    MRMediaRemoteGetNowPlayingInfoBlock block);
void MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_queue_t queue,
    MRMediaRemoteGetNowPlayingApplicationIsPlayingBlock block);
NSString *MRNowPlayingClientGetBundleIdentifier(id clientObj) __attribute__((warn_unused_result));
NSString *MRNowPlayingClientGetParentAppBundleIdentifier(id clientObj) __attribute__((warn_unused_result));
void MRMediaRemoteSetElapsedTime(double time);


extern NSString *kMRMediaRemoteNowPlayingInfoDidChangeNotification;
extern NSString *kMRMediaRemoteNowPlayingPlaybackQueueDidChangeNotification;
extern NSString *kMRMediaRemotePickableRoutesDidChangeNotification;
extern NSString *kMRMediaRemoteNowPlayingApplicationDidChangeNotification;
extern NSString *kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification;
extern NSString *kMRMediaRemoteRouteStatusDidChangeNotification;
extern NSString *kMRNowPlayingPlaybackQueueChangedNotification;
extern NSString *kMRPlaybackQueueContentItemsChangedNotification;

extern NSString *kMRMediaRemoteNowPlayingInfoArtist;
extern NSString *kMRMediaRemoteNowPlayingInfoTitle;
extern NSString *kMRMediaRemoteNowPlayingInfoAlbum;
extern NSString *kMRMediaRemoteNowPlayingInfoArtworkData;
extern NSString *kMRMediaRemoteNowPlayingInfoPlaybackRate;
extern NSString *kMRMediaRemoteNowPlayingInfoDuration;
extern NSString *kMRMediaRemoteNowPlayingInfoElapsedTime;
extern NSString *kMRMediaRemoteNowPlayingInfoTimestamp;
extern NSString *kMRMediaRemoteNowPlayingInfoClientPropertiesData;

extern NSString *kMRMediaRemoteNowPlayingApplicationIsPlayingUserInfoKey;


typedef enum {
    /*
     * Use nil for userInfo.
     */
    MRMediaRemoteCommandPlay,
    MRMediaRemoteCommandPause,
    MRMediaRemoteCommandTogglePlayPause,
    MRMediaRemoteCommandStop,
    MRMediaRemoteCommandNextTrack,
    MRMediaRemoteCommandPreviousTrack,
    MRMediaRemoteCommandAdvanceShuffleMode,
    MRMediaRemoteCommandAdvanceRepeatMode,
    MRMediaRemoteCommandBeginFastForward,
    MRMediaRemoteCommandEndFastForward,
    MRMediaRemoteCommandBeginRewind,
    MRMediaRemoteCommandEndRewind,
    MRMediaRemoteCommandRewind15Seconds,
    MRMediaRemoteCommandFastForward15Seconds,
    MRMediaRemoteCommandRewind30Seconds,
    MRMediaRemoteCommandFastForward30Seconds,
    MRMediaRemoteCommandToggleRecord,
    MRMediaRemoteCommandSkipForward,
    MRMediaRemoteCommandSkipBackward,
    MRMediaRemoteCommandChangePlaybackRate,

    /*
     * Use a NSDictionary for userInfo, which contains three keys:
     * kMRMediaRemoteOptionTrackID
     * kMRMediaRemoteOptionStationID
     * kMRMediaRemoteOptionStationHash
     */
    MRMediaRemoteCommandRateTrack,
    MRMediaRemoteCommandLikeTrack,
    MRMediaRemoteCommandDislikeTrack,
    MRMediaRemoteCommandBookmarkTrack,

    /*
     * Use nil for userInfo.
     */
    MRMediaRemoteCommandSeekToPlaybackPosition,
    MRMediaRemoteCommandChangeRepeatMode,
    MRMediaRemoteCommandChangeShuffleMode,
    MRMediaRemoteCommandEnableLanguageOption,
    MRMediaRemoteCommandDisableLanguageOption
} MRMediaRemoteCommand;

Boolean MRMediaRemoteSendCommand(MRMediaRemoteCommand command, NSDictionary *userInfo);

#endif /* MediaRemote_h */
