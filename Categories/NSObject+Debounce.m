#import "NSObject+Debounce.h"

@implementation NSObject (Debounce)

- (void)debounce:(SEL)action delay:(NSTimeInterval)delay {
    __unsafe_unretained typeof(self) weakSelf = self;
    [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:action object:nil];
    [weakSelf performSelector:action withObject:nil afterDelay:delay];
}

@end
