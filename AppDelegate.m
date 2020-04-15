@import ReactiveCocoa;
@import Squirrel;
@import Sentry;
@import UserNotifications;

#import "AppDelegate.h"

#import "NSString+StatusItemLength.h"

#import "UserDefaultsKeys.h"

#import "GlobalState.h"

void (^handleError)(NSError * _Nullable) = ^(NSError * _Nullable error) {
    if (error != nil) {
        [SentrySDK captureError:error];
    }
};

@interface AppDelegate ()

@property (weak) IBOutlet GlobalState *globalState;

@property (weak) IBOutlet NSUserDefaults *userDefaults;

@property (strong) NSStatusItem *statusItem;

@property (weak) IBOutlet NSPopover *popover;

@property (weak) IBOutlet NSMenu *menu;

@property (weak) IBOutlet NSWindow *positioningWindow;
@property (weak) IBOutlet NSView *positioningView;

@property (strong) NSWindowController *preferencesController;

@property BOOL showArtist;
@property BOOL showTitle;
@property BOOL showAlbum;
@property BOOL hideTextWhenPaused;
@property (strong) NSString *icon;
@property (strong) NSString *iconWhilePlaying;
@property NSInteger maximumWidth;

@property (strong) SQRLUpdater *updater;
@property (strong) RACDisposable *interval;

@end

@implementation AppDelegate

- (void)showPopover:(NSStatusBarButton *)sender {
    if (self.popover.isShown) return;
    
    if (NSApp.currentEvent.type == NSEventTypeRightMouseUp) {
        [self.statusItem popUpStatusItemMenu:self.menu];
        return;
    }

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
    [self.positioningWindow orderOut:self];
}

- (void)loadUserDefaults {
    self.showArtist = [self.userDefaults boolForKey:ShowArtistUserDefaultsKey];
    self.showTitle = [self.userDefaults boolForKey:ShowTitleUserDefaultsKey];
    self.showAlbum = [self.userDefaults boolForKey:ShowAlbumUserDefaultsKey];
    self.hideTextWhenPaused = [self.userDefaults boolForKey:HideTextWhenPausedUserDefaultsKey];
    self.icon = [self.userDefaults stringForKey:IconUserDefaultsKey];
    self.iconWhilePlaying = [self.userDefaults stringForKey:IconWhilePlayingUserDefaultsKey];
    self.maximumWidth = [self.userDefaults integerForKey:MaximumWidthUserDefaultsKey];
    
    if ([self.userDefaults boolForKey:EnableAutomaticUpdatesUserDefaultsKey]) {
        [self turnOnAutomaticUpdates];
    } else {
        [self turnOffAutomaticUpdates];
    }
}

- (void)turnOffAutomaticUpdates {
    if (self.updater == nil) return;
    
    [self.interval dispose];
    self.updater = nil;
}

- (void)turnOnAutomaticUpdates {
#ifdef DEBUG
    return;
#else
    if (self.updater != nil) return;
        
    NSURLComponents *components = [[NSURLComponents alloc] init];

    components.scheme = @"https";
    components.host = @"raw.githubusercontent.com";
    components.path = @"/dimitarnestorov/MusicBar/update/stable.json";
    
    self.updater = [[SQRLUpdater alloc] initWithUpdateRequest:[NSURLRequest requestWithURL:components.URL] forVersion:[NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"]];

    if (@available(macOS 10.14, *)) {
        void (^completionHandler)(BOOL, NSError * _Nullable) = ^(BOOL granted, NSError * _Nullable error) {
            if (error != nil) {
                [SentrySDK captureError:error];
                return;
            }
        };
        [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert completionHandler:completionHandler];

        [self.updater.updates subscribeNext:^(SQRLDownloadedUpdate *downloadedUpdate) {
            [UNUserNotificationCenter.currentNotificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined || settings.authorizationStatus == UNAuthorizationStatusDenied) return;
                
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.title = @"A new update is ready to install";
                content.subtitle = @"Click here to restart MusicBar";
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"MBNewUpdateAvailable" content:content trigger:nil];
                [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request
                                                                     withCompletionHandler:handleError];
            }];
        }];
    }
    
    self.interval = [self.updater startAutomaticChecksWithInterval:60 * 60 * 4];
    [self.updater.checkForUpdatesCommand execute:nil];
#endif
}

#pragma mark - User notification center delegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(macos(10.14)) {
    if ([response.notification.request.identifier isEqualToString:@"MBNewUpdateAvailable"] && [response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
        [[self.updater relaunchToInstallUpdate] subscribeError:handleError];
    }
    
    completionHandler();
}

#pragma mark - Application delegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(infoDidChange)
                                               name:GlobalStateNotification.infoDidChange
                                             object:nil];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(popoverDidClose:)
                                               name:NSPopoverDidCloseNotification
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(userDefaultsDidChange:)
                                               name:NSUserDefaultsDidChangeNotification
                                             object:nil];
    
    [self loadUserDefaults];
    
    self.statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.button.title = self.icon;
    self.statusItem.button.lineBreakMode = NSLineBreakByTruncatingTail;
    self.statusItem.button.target = self;
    self.statusItem.button.action = @selector(showPopover:);
    [self.statusItem.button sendActionOn:NSEventMaskLeftMouseUp | NSEventMaskRightMouseUp];
    
    self.positioningWindow.opaque = YES;
    self.positioningWindow.backgroundColor = NSColor.clearColor;
    self.positioningWindow.level = kCGMaximumWindowLevel | kCGFloatingWindowLevel;
    self.positioningWindow.ignoresMouseEvents = YES;
    
    if (@available(macOS 10.14, *)) {
        UNUserNotificationCenter.currentNotificationCenter.delegate = self;
        [UNUserNotificationCenter.currentNotificationCenter removeDeliveredNotificationsWithIdentifiers:@[@"MBNewUpdateAvailable"]];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    [self.popover close];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification handlers

- (void)userDefaultsDidChange:(NSNotification *)notification {
    if (notification != nil && notification.object == NSUserDefaults.standardUserDefaults) return;
    
    [self loadUserDefaults];
    [self infoDidChange];
}

- (void)infoDidChange {
    NSMutableString *title = [[NSMutableString alloc] init];
    if (self.icon.length > 0) {
        [title appendFormat:@"%@ ", self.icon];
    }
    
    if (self.iconWhilePlaying.length > 0 && self.globalState.isPlaying) {
        [title appendFormat:@"%@ ", self.iconWhilePlaying];
    }
    
    if (self.globalState.isPlaying || !self.hideTextWhenPaused) {
        NSMutableArray<NSString *> *artistTitleAlbum = [[NSMutableArray alloc] initWithCapacity:3];
        
        if (self.globalState.artist != nil && self.showArtist) [artistTitleAlbum addObject:self.globalState.artist];
        if (self.globalState.title != nil && self.showTitle) [artistTitleAlbum addObject:self.globalState.title];
        if (self.globalState.album != nil && self.showAlbum) [artistTitleAlbum addObject:self.globalState.album];

        if (artistTitleAlbum.count == 1) {
            [title appendString:[artistTitleAlbum objectAtIndex:0]];
        } else if (artistTitleAlbum.count == 2) {
            [title appendFormat:@"%@ - %@", [artistTitleAlbum objectAtIndex:0], [artistTitleAlbum objectAtIndex:1]];
        } else if (artistTitleAlbum.count == 3) {
            [title appendFormat:@"%@ - %@ - %@", [artistTitleAlbum objectAtIndex:0], [artistTitleAlbum objectAtIndex:1], [artistTitleAlbum objectAtIndex:2]];
        }
    }
    
    CGFloat newStatusItemLength = title.statusItemLengthWithSelf;
    CGFloat newLength = MIN(newStatusItemLength, self.maximumWidth);
    CGFloat padding = 10;
    CGFloat newLengthWithPadding = newLength + padding;
    self.statusItem.length = newLengthWithPadding;
    self.statusItem.button.title = title;
    self.statusItem.button.frame = NSMakeRect(padding / 2, 0, newLength, 22);
    self.statusItem.button.frame = NSMakeRect(0, 0, newLengthWithPadding, 22);
}

#pragma mark - Actions

- (IBAction)preferencesAction:(NSMenuItem *)sender {
    if (self.preferencesController == nil) {
        NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Preferences" bundle:nil];
        self.preferencesController = [storyboard instantiateInitialController];
    }
    
    [self.preferencesController showWindow:self];
    [self.preferencesController.window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

@end
