#import <ScriptingBridge/ScriptingBridge.h>

#import "ProtocolBuffer.h"
#import "MediaRemote.h"

#import "GlobalState.h"

#import "NSData+MD5.h"

#import "Spotify.h"

#import "Constants.h"

#if __MAC_OS_X_VERSION_MIN_REQUIRED <= __MAC_10_14
enum {
    errAEEventWouldRequireUserConsent = -1744,
};
#endif

const struct GlobalStateNotificationStruct GlobalStateNotification = {
    .infoDidChange = @"InfoDidChangeNotification",
    .isPlayingDidChange = @"IsPlayingDidChangeNotification",
};

@implementation GlobalState {
    SpotifyApplication * _Nullable spotifyApp;
    SBApplication * _Nullable tidalApp;
}

- (void)initialize {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(appDidChange:)
                                               name:kMRMediaRemoteNowPlayingApplicationDidChangeNotification
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(infoDidChange:)
                                               name:kMRMediaRemoteNowPlayingInfoDidChangeNotification
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(isPlayingDidChange:)
                                               name:kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification
                                             object:nil];
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    MRMediaRemoteRegisterForNowPlayingNotifications(queue);
    
    MRMediaRemoteGetNowPlayingApplicationIsPlaying(queue, ^(BOOL isPlaying) {
        self.isPlaying = isPlaying;
    });

    [self getNowPlayingInfo];
}

- (NSImage * _Nullable)getAlbumArtworkFromSpotify {
    if (spotifyApp == nil) {
        if (@available(macOS 10.14, *)) {
            NSAppleEventDescriptor *targetAppEventDescriptor = [NSAppleEventDescriptor descriptorWithBundleIdentifier:spotifyBundleIdentifier];
            OSStatus error = AEDeterminePermissionToAutomateTarget([targetAppEventDescriptor aeDesc], typeWildCard, typeWildCard, YES);
            
            if (error == errAEEventWouldRequireUserConsent || error == errAEEventNotPermitted) {
                return spotifyRequestPermissionsAlbumArtwork;
            }
        }
        spotifyApp = (id)[[SBApplication alloc] initWithBundleIdentifier:spotifyBundleIdentifier];
        if (spotifyApp == nil) return nil;
    }
    SpotifyTrack *track = spotifyApp.currentTrack;
    return [[NSImage alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:track.artworkUrl]];
}

- (void)getNowPlayingInfo {
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(NSDictionary *info) {
        if (info == nil) {
            self.artist = nil;
            self.title = nil;
            self.album = nil;
            self.albumArtwork = nil;
            self.albumArtworkChecksum = nil;
            self.timestamp = nil;
            self.duration = 0;
            self->_elapsedTime = 0;
        } else {
            self.artist = [info objectForKey:kMRMediaRemoteNowPlayingInfoArtist];
            self.title = [info objectForKey:kMRMediaRemoteNowPlayingInfoTitle];
            self.album = [info objectForKey:kMRMediaRemoteNowPlayingInfoAlbum];

            _MRNowPlayingClientProtobuf *client = [[_MRNowPlayingClientProtobuf alloc] initWithData:[info objectForKey:kMRMediaRemoteNowPlayingInfoClientPropertiesData]];
            NSData *mediaRemoteArtwork = [info objectForKey:kMRMediaRemoteNowPlayingInfoArtworkData];
            NSString *albumArtworkChecksum = mediaRemoteArtwork == nil ? nil :[ mediaRemoteArtwork MD5];
            NSLog(@"%@ %@", self.albumArtworkChecksum, albumArtworkChecksum);
            if (self.albumArtworkChecksum != albumArtworkChecksum) {
                self.albumArtwork = mediaRemoteArtwork != nil
                    ? [[NSImage alloc] initWithData:mediaRemoteArtwork]
                    : [client.bundleIdentifier isEqualToString:spotifyBundleIdentifier]
                        ? [self getAlbumArtworkFromSpotify]
                        : nil;
                self.albumArtworkChecksum = albumArtworkChecksum;
            }

            self.timestamp = [info objectForKey:kMRMediaRemoteNowPlayingInfoTimestamp];
            NSNumber *duration = [info objectForKey:kMRMediaRemoteNowPlayingInfoDuration];
            self.duration = duration == nil ? 0 : duration.doubleValue;
            self->_elapsedTime = [[info objectForKey:kMRMediaRemoteNowPlayingInfoElapsedTime] doubleValue];
        }
        
        [NSNotificationCenter.defaultCenter postNotificationName:GlobalStateNotification.infoDidChange object:nil];
    });
}

#pragma mark - NSObject methods

- (instancetype)init {
    self = [super init];
    if (self) [self initialize];
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    MRMediaRemoteUnregisterForNowPlayingNotifications();
}

#pragma mark - Notification handlers

- (void)isPlayingDidChange:(NSNotification *)notification {
    self.isPlaying = [[notification.userInfo objectForKey:kMRMediaRemoteNowPlayingApplicationIsPlayingUserInfoKey] boolValue];
    
    [NSNotificationCenter.defaultCenter postNotificationName:GlobalStateNotification.isPlayingDidChange object:nil];
    
    [self getNowPlayingInfo];
}

- (void)infoDidChange:(NSNotification *)notification {
    [self getNowPlayingInfo];
}

- (void)appDidChange:(NSNotification *)notification {
    [self getNowPlayingInfo];
}

#pragma mark - Actions

- (void)togglePlayPause {
    MRMediaRemoteSendCommand(MRMediaRemoteCommandTogglePlayPause, nil);
}

- (void)previous {
    MRMediaRemoteSendCommand(MRMediaRemoteCommandPreviousTrack, nil);
}

- (void)next {
    MRMediaRemoteSendCommand(MRMediaRemoteCommandNextTrack, nil);
}

- (void)setElapsedTime:(double)elapsedTime {
    _elapsedTime = elapsedTime;
    MRMediaRemoteSetElapsedTime(elapsedTime);
}

@end
