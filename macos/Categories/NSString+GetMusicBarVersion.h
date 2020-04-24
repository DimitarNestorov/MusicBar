#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    AboutVersionUseCase,
    UpdatesVersionUseCase,
} VersionUseCase;

@interface NSString (GetMusicBarVersion)

+ (NSString *)getMusicBarVersionFor:(VersionUseCase)useCase;

@end

NS_ASSUME_NONNULL_END
