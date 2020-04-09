#import "MediaRemote.h"

#import "GlobalState.h"

const struct GlobalStateNotificationStruct GlobalStateNotification = {
    .infoDidChange = @"InfoDidChangeNotification",
    .isPlayingDidChange = @"IsPlayingDidChangeNotification",
};

@implementation GlobalState

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

- (instancetype)init {
    self = [super init];
    if (self) [self initialize];
    return self;
}

- (void)dealloc {
    MRMediaRemoteUnregisterForNowPlayingNotifications();
}

- (void)getNowPlayingInfo {
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(NSDictionary *info) {
        if (info == nil) {
            self.artist = nil;
            self.title = nil;
            self.albumArtwork = nil;
            self.timestamp = nil;
            self.duration = nil;
            self->_elapsedTime = 0;
        } else {
            self.artist = [info objectForKey:kMRMediaRemoteNowPlayingInfoArtist];
            self.title = [info objectForKey:kMRMediaRemoteNowPlayingInfoTitle];
            self.albumArtwork = [info objectForKey:kMRMediaRemoteNowPlayingInfoArtworkData];
            self.timestamp = [info objectForKey:kMRMediaRemoteNowPlayingInfoTimestamp];
            self.duration = [info objectForKey:kMRMediaRemoteNowPlayingInfoDuration];
            self->_elapsedTime = [[info objectForKey:kMRMediaRemoteNowPlayingInfoElapsedTime] doubleValue];
        }
        
        [NSNotificationCenter.defaultCenter postNotificationName:GlobalStateNotification.infoDidChange object:nil];
    });
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
