#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>

#ifndef Spotify_h
#define Spotify_h

@interface SpotifyTrack : SBObject

@property (copy, readonly) NSString * _Nullable artworkUrl;  // The URL of the track%apos;s album cover.
@property (copy, readonly) NSImage * _Nullable artwork;  // The property is deprecated and will never be set. Use the 'artwork url' instead.

@end

@interface SpotifyApplication : SBApplication

@property (copy, readonly) SpotifyTrack * _Nullable currentTrack;  // The current playing track.

@end


#endif /* Spotify_h */
