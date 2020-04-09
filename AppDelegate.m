#import "AppDelegate.h"

#import "GlobalState.h"

@interface AppDelegate ()

@property (weak) IBOutlet GlobalState *globalState;

@property (strong) NSStatusItem *statusItem;

@property (weak) IBOutlet NSPopover *popover;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(infoDidChange:) name:GlobalStateNotification.infoDidChange object:nil];
    
    self.statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.target = self;
    self.statusItem.action = @selector(showPopover:);
    self.statusItem.highlightMode = YES;
    
    self.statusItem.button.image = [NSImage imageNamed:@"Note"];
}

- (void)showPopover:(NSStatusBarButton *)sender {
    [self.popover showRelativeToRect:sender.frame ofView:sender preferredEdge:NSMaxYEdge];
    
    [NSApp activateIgnoringOtherApps:YES];
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
