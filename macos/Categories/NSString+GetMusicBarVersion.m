#import "NSString+GetMusicBarVersion.h"

@implementation NSString (GetMusicBarVersion)

+ (NSString *)getMusicBarVersionFor:(VersionUseCase)useCase {
#ifdef DEBUG
    NSString *fourthComponent = @"1";
    NSString *fifthComponent = @"0";
#else
    NSArray<NSString *> *buildNumberComponents = [[NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleVersion"] componentsSeparatedByString:@"."];
    NSString *fourthComponent = [buildNumberComponents objectAtIndex:3];
    NSString *fifthComponent = [buildNumberComponents objectAtIndex:4];
#endif
    
    NSString *marketingVersion = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
    if ([@"1" isEqualToString:fourthComponent]) {
        if (useCase == AboutVersionUseCase) {
            return marketingVersion;
        } else {
            return @"stable";
        }
    } else {
        if (useCase == AboutVersionUseCase) {
            return [NSString stringWithFormat:@"%@-beta.%@", marketingVersion, fifthComponent];
        } else {
            return [NSString stringWithFormat:@"beta-%@", marketingVersion];
        }
    }
}

@end
