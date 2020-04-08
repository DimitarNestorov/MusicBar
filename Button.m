#import "Button.h"

@interface Button ()

@end

@implementation Button

- (BOOL)acceptsFirstResponder {
    return NO;
}

- (void)mouseDown:(NSEvent *)event {
    self.alphaValue = 0.9;
    [super mouseDown:event];
    self.alphaValue = 0.7;
}

@end
