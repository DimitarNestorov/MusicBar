#import <Foundation/Foundation.h>

#ifndef ProtocolBuffer_h
#define ProtocolBuffer_h

@interface PBMutableData : NSMutableData {
    char* p;
    char* buffer;
    char* end;
}

-(void)dealloc;
-(unsigned long long)length;
-(const void*)bytes;
-(id)initWithCapacity:(unsigned long long)arg1;
-(void*)mutableBytes;
-(void)setLength:(unsigned long long)arg1;
-(void)_pb_growCapacityBy:(unsigned long long)arg1;

@end

@interface PBCodable : NSObject <NSSecureCoding>

@property (nonatomic, readonly) PBMutableData * data;

+(bool)supportsSecureCoding;
+(id)options;
-(void)setClientMetricsIfSupported:(id)arg1;
-(bool)readFrom:(id)arg1;
-(void)writeTo:(id)arg1;
-(id)formattedText;
-(id)init;
-(id)initWithCoder:(id)arg1;
-(void)encodeWithCoder:(id)arg1;
-(PBMutableData *)data;
-(id)initWithData:(PBMutableData *)arg1;
-(id)dictionaryRepresentation;

@end

#endif /* ProtocolBuffer_h */
