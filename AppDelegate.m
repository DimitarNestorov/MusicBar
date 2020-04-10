#import "AppDelegate.h"

#import "GlobalState.h"

@interface AppDelegate ()

@property (weak) IBOutlet GlobalState *globalState;

@property (strong) NSStatusItem *statusItem;

@property (weak) IBOutlet NSPopover *popover;

@property (weak) IBOutlet NSWindow *positioningWindow;
@property (weak) IBOutlet NSView *positioningView;

@end

@implementation AppDelegate

- (void)showPopover:(NSStatusBarButton *)sender {
    if (self.popover.isShown) return;

    NSRect rect = [sender.window convertRectToScreen:sender.frame];
    CGFloat xOffset = CGRectGetMidX(self.positioningWindow.contentView.frame) - CGRectGetMidX(sender.frame);
    CGFloat x = rect.origin.x - xOffset;
    CGFloat y = rect.origin.y;
    [self.positioningWindow setFrameOrigin:NSMakePoint(x, y)];
    [self.positioningWindow makeKeyAndOrderFront:self];
    [self.popover showRelativeToRect:self.positioningView.bounds ofView:self.positioningView preferredEdge:NSMinYEdge];
    self.positioningView.bounds = CGRectOffset(self.positioningView.bounds, 0, 22);
    
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)popoverDidClose:(NSNotification *)notification {
    self.positioningView.bounds = CGRectOffset(self.positioningView.bounds, 0, -22);
}

#pragma mark - Application delegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(infoDidChange:)
                                               name:GlobalStateNotification.infoDidChange
                                             object:nil];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(popoverDidClose:)
                                               name:NSPopoverDidCloseNotification
                                             object:nil];
    
    self.statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.target = self;
    self.statusItem.action = @selector(showPopover:);
    self.statusItem.highlightMode = YES;
    
    self.statusItem.button.image = [NSImage imageNamed:@"Note"];
    
    self.positioningWindow.opaque = YES;
    self.positioningWindow.backgroundColor = NSColor.clearColor;
    self.positioningWindow.level = kCGMaximumWindowLevel | kCGFloatingWindowLevel;
    self.positioningWindow.ignoresMouseEvents = YES;
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    [self.popover close];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification handlers

- (void)infoDidChange:(NSNotification *)notification {
    if (self.globalState.artist == nil) {
        if (self.globalState.title == nil) {
            self.statusItem.title = @"";
        } else {
            self.statusItem.title = self.globalState.title;
        }
    } else if (self.globalState.title == nil) {
        self.statusItem.title = self.globalState.artist;
    } else {
        self.statusItem.title = [NSString stringWithFormat:@"%@ - %@", self.globalState.artist, self.globalState.title];
    }
}

@end
