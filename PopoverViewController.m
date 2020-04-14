@import QuartzCore;

#import "PopoverViewController.h"

#import "NSImage+ProportionalScaling.h"
#import "NSString+FormatTime.h"

#import "GlobalState.h"

@interface PopoverViewController ()

@property (weak) IBOutlet GlobalState *globalState;

@property (weak) IBOutlet NSPopover *popover;

@property (weak) IBOutlet NSView *albumArtwork;
@property (weak) IBOutlet NSView *maskedAlbumArtwork;

@property (weak) IBOutlet NSView *progressBackground;

@property (weak) IBOutlet NSButton *playPauseButton;

@property (weak) IBOutlet NSTextField *elapsedTimeLabel;
@property (weak) IBOutlet NSTextField *durationRemainingTimeLabel;

@property (weak) IBOutlet NSView *progress;
@property (weak) IBOutlet NSLayoutConstraint *progressWidthConstraint;
@property (weak) IBOutlet NSView *thumb;

@property NSTimer *timer;

@property BOOL showRemainingTime;

@end

@implementation PopoverViewController

- (void)handleTickWithElapsedTime:(double)elapsedTime {
    self.elapsedTimeLabel.stringValue = [NSString formatSecondsWithDouble:elapsedTime];
    
    double duration = self.globalState.duration.doubleValue;
    self.progressWidthConstraint.constant = self.progress.superview.bounds.size.width * (elapsedTime / duration);

    if (self.showRemainingTime) {
        NSString *formattedTime = [NSString formatSecondsWithDouble:duration - elapsedTime];
        self.durationRemainingTimeLabel.stringValue = [NSString stringWithFormat:@"-%@", formattedTime];
    }
}

- (void)handleTick {
    if (self.globalState.timestamp == nil) return;

    double elapsedTimeAtTimestamp = self.globalState.elapsedTime;
    double elapsedTime = self.globalState.isPlaying ? elapsedTimeAtTimestamp + [NSDate.date timeIntervalSinceDate:self.globalState.timestamp] : elapsedTimeAtTimestamp;
    
    [self handleTickWithElapsedTime:elapsedTime];
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
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - View controller

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
    
    self.progressBackground.layer.backgroundColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:0.5].CGColor;
    self.progressBackground.layer.cornerRadius = 2;
    self.progress.layer.backgroundColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:0.9].CGColor;
    self.thumb.layer.backgroundColor = NSColor.whiteColor.CGColor;
    self.thumb.layer.cornerRadius = 4;
    NSShadow *thumbShadow = [[NSShadow alloc] init];
    thumbShadow.shadowOffset = NSMakeSize(0, -1);
    thumbShadow.shadowColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    thumbShadow.shadowBlurRadius = 2.0;
    self.thumb.shadow = thumbShadow;
}

#pragma mark - Notification handlers

- (void)stateDidChange:(NSNotification *)notification {
    if (self.popover.isShown) {
        [self updatePopover];
    }
}

#pragma mark - Actions

- (IBAction)playPauseAction:(NSButton *)sender {
    [self.globalState togglePlayPause];
}

- (IBAction)previousAction:(NSButton *)sender {
    [self.globalState previous];
}

- (IBAction)nextAction:(NSButton *)sender {
    [self.globalState next];
}

- (IBAction)durationRemainingTimeClickGestureRecognizerAction:(NSClickGestureRecognizer *)sender {
    self.showRemainingTime = !self.showRemainingTime;
    [NSUserDefaults.standardUserDefaults setBool:self.showRemainingTime forKey:@"showRemainingTime"];
    
    [self updatePopover];
}

- (IBAction)progressContainerAction:(NSControl *)sender {
    BOOL dragActive = YES;
    NSPoint location = NSZeroPoint;
    NSEvent* event = NULL;
    NSWindow *targetWindow = sender.window;
    double elapsedTime = 0;
    double duration = self.globalState.duration.doubleValue;
    CGFloat width = sender.bounds.size.width;
    double newConstant = 0;
    
    @autoreleasepool {
        while (dragActive) {
            event = [targetWindow nextEventMatchingMask:(NSEventMaskLeftMouseDragged | NSEventMaskLeftMouseUp)
                                              untilDate:[NSDate distantFuture]
                                                 inMode:NSEventTrackingRunLoopMode
                                                dequeue:YES];
            if (!event) continue;
            location = [sender convertPoint:event.locationInWindow fromView:nil];
            switch (event.type) {
                case NSEventTypeLeftMouseUp:
                    dragActive = NO;
                case NSEventTypeLeftMouseDragged:
                    newConstant = MIN(MAX(location.x, 0), width);
                    self.progressWidthConstraint.constant = newConstant;
                    elapsedTime = (newConstant / width) * duration;
                    [self handleTickWithElapsedTime:elapsedTime];
                    break;
                default:
                    break;
            }
        }
    }

    self.globalState.elapsedTime = elapsedTime;
}

#pragma mark - Popover delegate

- (void)popoverWillShow:(NSNotification *)notification {
    [self updatePopover];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTick) userInfo:nil repeats:YES];
}

- (void)popoverWillClose:(NSNotification *)notification {
    [self.timer invalidate];
    self.timer = nil;
}

@end
