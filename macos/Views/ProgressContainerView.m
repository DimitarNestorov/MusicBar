#import "ProgressContainerView.h"

@implementation ProgressContainerView

- (void)mouseDown:(NSEvent *)event {
    [NSApp sendAction:self.action to:self.target from:self];
}

@end
