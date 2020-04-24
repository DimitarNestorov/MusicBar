@import ReactiveCocoa;
@import Squirrel;
@import Sentry;
@import UserNotifications;

#import "AppDelegate.h"

#import "Constants.h"

#import "GlobalState.h"

#define RETURN_VOID(EXP) { EXP; return; }

void (^handleError)(NSError * _Nullable) = ^(NSError * _Nullable error) {
    if (error != nil) {
        [SentrySDK captureError:error];
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
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

@property (strong) NSTimer *productHuntTimer;

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
        [self startProductHuntTimer];
    } else {
        [self turnOffAutomaticUpdates];
        [self stopProductHuntTimer];
    }
}

- (void)turnOffAutomaticUpdates {
    if (self.updater == nil) return;
    
    [self.interval dispose];
    self.updater = nil;
}

- (void)turnOnAutomaticUpdates {
#ifndef DEBUG
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

- (void)stopProductHuntTimer {
    if (self.productHuntTimer != nil) {
        [self.productHuntTimer invalidate];
        self.productHuntTimer = nil;
    }
}

- (void)startProductHuntTimer {
    if (self.productHuntTimer != nil) return;
    if ([self.userDefaults boolForKey:ProductHuntNotificationDisplayedUserDefaultsKey]) return;

    if (@available(macOS 10.14, *)) {
        self.productHuntTimer = [NSTimer scheduledTimerWithTimeInterval:60 * 60 target:self selector:@selector(checkForProductHuntRelease) userInfo:nil repeats:YES];
    }
}

- (void)checkForProductHuntRelease API_AVAILABLE(macos(10.14)) {
    if ([self.userDefaults boolForKey:ProductHuntNotificationDisplayedUserDefaultsKey]) return;

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/dimitarnestorov/MusicBar/product-hunt/release.json"]];

    #define ARGUMENT_TYPES NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable
    void (^completionHandler)(ARGUMENT_TYPES) = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) RETURN_VOID(handleError(error))
        
        NSError *parseError;
        id parsed = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        
        if (parseError != nil) RETURN_VOID(handleError(parseError))
        
        if (![parsed isKindOfClass:NSDictionary.class]) return;
        
        id url = [parsed objectForKey:@"url"];
        id date = [parsed objectForKey:@"date"];
        
        if (url == nil || date == nil) return;
        if (![url isKindOfClass:NSString.class] || ![date isKindOfClass:NSString.class]) return;
        
        NSTimeInterval timeInterval = [[[NSISO8601DateFormatter new] dateFromString:date] timeIntervalSinceNow];
        if (-timeInterval > 60 * 60 * 24) RETURN_VOID([self.userDefaults setBool:YES forKey:ProductHuntNotificationDisplayedUserDefaultsKey])

        [UNUserNotificationCenter.currentNotificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined || settings.authorizationStatus == UNAuthorizationStatusDenied) return;

            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            content.title = @"MusicBar is on Product Hunt!";
            content.subtitle = @"Click here to check it out";
            content.userInfo = @{ @"url": url };
            NSError *error;
            content.attachments = @[
                [UNNotificationAttachment attachmentWithIdentifier:@"ProductHuntLogo"
                                                               URL:[NSBundle.mainBundle URLForResource:@"product-hunt-logo-orange-240" withExtension:@"png"]
                                                           options:nil
                                                             error:&error]
            ];

            if (error != nil) {
                [SentrySDK captureError:error];
#ifdef DEBUG
                NSLog(@"%@", error);
#endif
                content.attachments = @[];
            }

            NSString *identifier = [NSString stringWithFormat:@"MBProductHuntRelease%@", [[NSUUID UUID] UUIDString]];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:nil];
            [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request
                                                                 withCompletionHandler:handleError];
            [self.userDefaults setBool:YES forKey:ProductHuntNotificationDisplayedUserDefaultsKey];
        }];
    };
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:completionHandler] resume];
}

#pragma mark - User notification center delegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(macos(10.14)) {
    if ([response.notification.request.identifier isEqualToString:@"MBNewUpdateAvailable"] && [response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
        [[self.updater relaunchToInstallUpdate] subscribeError:handleError];
    }

    if ([response.notification.request.identifier hasPrefix:@"MBProductHuntRelease"] && [response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
        [NSWorkspace.sharedWorkspace openURL:[[NSURL alloc] initWithString:[response.notification.request.content.userInfo objectForKey:@"url"]]];
    }
    
    completionHandler();
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(macos(10.14)) {
    completionHandler(0);
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
    
#ifdef DEBUG
    [self.userDefaults setBool:NO forKey:ProductHuntNotificationDisplayedUserDefaultsKey];
#endif
    
    if (@available(macOS 10.14, *)) {
        UNUserNotificationCenter.currentNotificationCenter.delegate = self;
        [UNUserNotificationCenter.currentNotificationCenter removeDeliveredNotificationsWithIdentifiers:@[@"MBNewUpdateAvailable"]];

        if ([self.userDefaults boolForKey:EnableAutomaticUpdatesUserDefaultsKey]) {
            [self checkForProductHuntRelease];
        }
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
    if ([NSThread isMainThread]) {
        [self infoDidChange];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self infoDidChange];
        });
    }
}

- (void)infoDidChange {
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
    if (self.icon.length > 0) {
        NSString *toAppend = [NSString stringWithFormat:@"%@ ", self.icon];
        [title.mutableString appendString:toAppend];
        [title addAttribute:NSFontAttributeName value:StatusItemIconFont range:NSMakeRange(0, self.icon.length)];
        [title addAttribute:NSFontAttributeName value:StatusItemTextFont range:NSMakeRange(self.icon.length, 1)];
    }
    
    if (self.iconWhilePlaying.length > 0 && self.globalState.isPlaying) {
        NSString *toAppend = [NSString stringWithFormat:@"%@ ", self.iconWhilePlaying];
        NSUInteger lengthBeforeAppend = title.mutableString.length;
        [title.mutableString appendString:toAppend];
        [title addAttribute:NSFontAttributeName value:StatusItemIconFont range:NSMakeRange(lengthBeforeAppend, self.iconWhilePlaying.length)];
        [title addAttribute:NSFontAttributeName value:StatusItemTextFont range:NSMakeRange(lengthBeforeAppend + self.iconWhilePlaying.length, 1)];
    }
    
    if (self.globalState.isPlaying || !self.hideTextWhenPaused) {
        NSMutableArray<NSString *> *artistTitleAlbum = [[NSMutableArray alloc] initWithCapacity:3];
        
        if (self.globalState.artist != nil && self.showArtist) [artistTitleAlbum addObject:self.globalState.artist];
        if (self.globalState.title != nil && self.showTitle) [artistTitleAlbum addObject:self.globalState.title];
        if (self.globalState.album != nil && self.showAlbum) [artistTitleAlbum addObject:self.globalState.album];

        if (artistTitleAlbum.count == 1) {
            NSString *toAppend = [artistTitleAlbum objectAtIndex:0];
            NSUInteger lengthBeforeAppend = title.mutableString.length;
            [title.mutableString appendString:toAppend];
            [title addAttribute:NSFontAttributeName value:StatusItemTextFont range:NSMakeRange(lengthBeforeAppend, toAppend.length)];
        } else if (artistTitleAlbum.count == 2) {
            NSString *toAppend = [NSString stringWithFormat:@"%@ - %@", [artistTitleAlbum objectAtIndex:0], [artistTitleAlbum objectAtIndex:1]];
            NSUInteger lengthBeforeAppend = title.mutableString.length;
            [title.mutableString appendString:toAppend];
            [title addAttribute:NSFontAttributeName value:StatusItemTextFont range:NSMakeRange(lengthBeforeAppend, toAppend.length)];
        } else if (artistTitleAlbum.count == 3) {
            NSString *toAppend = [NSString stringWithFormat:@"%@ - %@ - %@", [artistTitleAlbum objectAtIndex:0], [artistTitleAlbum objectAtIndex:1], [artistTitleAlbum objectAtIndex:2]];
            NSUInteger lengthBeforeAppend = title.mutableString.length;
            [title.mutableString appendString:toAppend];
            [title addAttribute:NSFontAttributeName value:StatusItemTextFont range:NSMakeRange(lengthBeforeAppend, toAppend.length)];
        }
    }
    
    self.statusItem.length = title.size.width > self.maximumWidth ? self.maximumWidth : NSVariableStatusItemLength;
    self.statusItem.button.attributedTitle = title;
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
