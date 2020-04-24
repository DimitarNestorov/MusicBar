#import "VersionLabel.h"

#import "NSString+GetMusicBarVersion.h"

@implementation VersionLabel

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self != nil) {
        self.stringValue = [NSString stringWithFormat:@"Version %@", [NSString getMusicBarVersionFor:AboutVersionUseCase]];
    }
    return self;
}

@end
