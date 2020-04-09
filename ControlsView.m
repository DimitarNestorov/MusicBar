@import QuartzCore;

#import "ControlsView.h"

float duration = 0.25;

@interface ControlsView ()

@property (strong) NSTrackingArea *trackingArea;

@end

@implementation ControlsView

- (void)mouseEntered:(NSEvent *)event {
    NSAnimationContext.currentContext.duration = duration;
    NSAnimationContext.currentContext.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    self.animator.alphaValue = 1;
}

- (void)mouseExited:(NSEvent *)event {
    NSAnimationContext.currentContext.duration = duration;
    NSAnimationContext.currentContext.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    self.animator.alphaValue = 0;
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];

    if (self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
    }

    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

@end
