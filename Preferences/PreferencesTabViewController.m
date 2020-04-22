#import "PreferencesTabViewController.h"

@interface PreferencesTabViewController ()

@end

@implementation PreferencesTabViewController

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    NSArray<NSToolbarItemIdentifier> *defaultItems = [super toolbarDefaultItemIdentifiers:toolbar];
    return @[[defaultItems objectAtIndex:0], NSToolbarFlexibleSpaceItemIdentifier, [defaultItems objectAtIndex:2], [defaultItems objectAtIndex:1]];
}

@end
