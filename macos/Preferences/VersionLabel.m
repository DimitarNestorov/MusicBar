#import "VersionLabel.h"

@implementation VersionLabel

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self != nil) {
        self.stringValue = [NSString stringWithFormat:@"Version %@", [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    }
    return self;
}

@end
