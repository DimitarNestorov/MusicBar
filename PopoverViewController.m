#import <QuartzCore/QuartzCore.h>

#import "PopoverViewController.h"

#import "NSImage+ProportionalScaling.h"
#import "NSString+FormatTime.h"

#import "GlobalState.h"

@interface PopoverViewController ()

@property (weak) IBOutlet GlobalState *globalState;

@property (weak) IBOutlet NSPopover *popover;

@property (weak) IBOutlet NSView *albumArtwork;
@property (weak) IBOutlet NSView *maskedAlbumArtwork;

@property (weak) IBOutlet NSView *seekContainer;

@property (weak) IBOutlet NSButton *playPauseButton;

@property (weak) IBOutlet NSTextField *elapsedTimeLabel;
@property (weak) IBOutlet NSTextField *durationRemainingTimeLabel;

@property NSTimer *timer;

@property BOOL showRemainingTime;

@end

@implementation PopoverViewController

- (void)handleTick {
    if (self.globalState.timestamp != nil) {
        double elapsedTimeAtTimestamp = self.globalState.elapsedTime.doubleValue;
        double elapsedTime = self.globalState.isPlaying ? elapsedTimeAtTimestamp + [NSDate.date timeIntervalSinceDate:self.globalState.timestamp] : elapsedTimeAtTimestamp;
        self.elapsedTimeLabel.stringValue = [NSString formatSecondsWithDouble:elapsedTime];

        if (self.showRemainingTime) {
            NSString *formattedTime = [NSString formatSecondsWithDouble:self.globalState.duration.doubleValue - elapsedTime];
            self.durationRemainingTimeLabel.stringValue = [NSString stringWithFormat:@"-%@", formattedTime];
        }
    }
    
}

- (void)updatePopover {
    NSImage *albumArtwork = [[[NSImage alloc] initWithData:self.globalState.albumArtwork] imageByScalingProportionallyToSize:NSMakeSize(300, 300)];
    self.albumArtwork.layer.contents = albumArtwork;
    self.maskedAlbumArtwork.layer.contents = albumArtwork;
    self.playPauseButton.image = [NSImage imageNamed:self.globalState.isPlaying ? @"Pause" : @"Play"];
    
    if (!self.showRemainingTime && self.globalState.duration != nil) {
        self.durationRemainingTimeLabel.stringValue = [NSString formatSeconds:self.globalState.duration];
    }

    [self handleTick];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark View controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showRemainingTime = [NSUserDefaults.standardUserDefaults boolForKey:@"showRemainingTime"];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(stateDidChange:) name:GlobalStateNotification.infoDidChange object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(stateDidChange:) name:GlobalStateNotification.isPlayingDidChange object:nil];
    
    self.view.layer.backgroundColor = NSColor.windowBackgroundColor.CGColor;
    
    // Setting up mask
    CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
    gradient.frame = self.maskedAlbumArtwork.bounds;
    id clear = (id)NSColor.clearColor.CGColor;
    id black = (id)NSColor.blackColor.CGColor;
    gradient.colors = @[clear, clear, black, black];
    gradient.locations = @[@0.0, @0.2, @0.9, @1.0];
    self.maskedAlbumArtwork.layer.mask = gradient;
    
    self.seekContainer.layer.backgroundColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:0.7].CGColor;
    self.seekContainer.layer.cornerRadius = 2;
    
    NSClickGestureRecognizer *click = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(clickGestureRecognizerAction)];
    [self.durationRemainingTimeLabel addGestureRecognizer:click];
}

#pragma mark Notification handlers

- (void)stateDidChange:(NSNotification *)notification {
    if (self.popover.isShown) {
        [self updatePopover];
    }
}

#pragma mark Actions

- (IBAction)playPauseAction:(NSButton *)sender {
    [self.globalState togglePlayPause];
}

- (IBAction)previousAction:(NSButton *)sender {
    [self.globalState previous];
}

- (IBAction)nextAction:(NSButton *)sender {
    [self.globalState next];
}

- (void)clickGestureRecognizerAction {
    self.showRemainingTime = !self.showRemainingTime;
    [NSUserDefaults.standardUserDefaults setBool:self.showRemainingTime forKey:@"showRemainingTime"];
    
    [self updatePopover];
}

#pragma mark Popover delegate

- (void)popoverWillShow:(NSNotification *)notification {
    [self updatePopover];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTick) userInfo:nil repeats:YES];
}

- (void)popoverWillClose:(NSNotification *)notification {
    [self.timer invalidate];
    self.timer = nil;
}

@end
