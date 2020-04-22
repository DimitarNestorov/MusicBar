@import Cocoa;
@import Sentry;

#import "UserDefaultsKeys.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        __block BOOL shouldSend = NO;
        [SentrySDK startWithOptions:@{
            @"dsn": [NSBundle.mainBundle.infoDictionary objectForKey:@"MBSentryDSN"],
            @"beforeSend": ^(SentryEvent *event) {
                if (shouldSend) return event;
                return (SentryEvent *)nil;
            },
        }];
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        [userDefaults registerDefaults:[NSDictionary dictionaryWithContentsOfURL:[NSBundle.mainBundle URLForResource:@"DefaultPreferences" withExtension:@"plist"]]];
        
        void (^updateShouldSend)(NSNotification *)  = ^(NSNotification *notification) {
            if (notification != nil && notification.object == NSUserDefaults.standardUserDefaults) return;
            shouldSend = [[userDefaults objectForKey:EnableErrorReportingUserDefaultsKey] boolValue];
        };
        
        updateShouldSend(nil);
        
        [NSNotificationCenter.defaultCenter addObserverForName:NSUserDefaultsDidChangeNotification
                                                        object:nil
                                                         queue:nil
                                                    usingBlock:updateShouldSend];
    }
    return NSApplicationMain(argc, argv);
}
