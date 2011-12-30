//
//  MGTimeSignature.h
//  MetroGnomeiPad
//
//  Created by Zander on 10/15/11.
//  Copyright 2011 MetroGnome, LLC. All rights reserved.
//

/** The possible note durations */
typedef enum {
    ThirtySecond, Sixteenth, Triplet, Eighth,
    DottedEighth, Quarter, DottedQuarter,
    Half, DottedHalf, Whole
} NoteDuration;


@interface MGTimeSignature : NSObject {
    int _numerator;      /* Numerator of the time signature */
    int _denominator;    /* Denominator of the time signature */
    int _quarter;        /* Number of pulses per quarter note */
    int _measure;        /* Number of pulses per measure */
    int _tempo;          /* Number of microseconds per quarter note */
}
@property(readwrite,assign) int numerator;
@property(readwrite,assign) int denominator;
@property(readwrite,assign) int quarter;
@property(readwrite,assign) int measure;
@property(readwrite,assign) int tempo;

+(id)commonTime;

-(void)dealloc;
-(id)initWithNumerator:(int)num andDenominator:(int)d andQuarter:(int)q andTempo:(int)t;

-(int)getMeasureForTime:(int)time;
-(NoteDuration)getNoteDuration:(int)pulses;
-(int)durationToTime:(NoteDuration)duration;
-(id)copyWithZone:(NSZone*)zone;
-(NSString*)description;
+(NSString*)durationString:(int)dur;
@end

/************************************************/
/* Old MGTimeSignature
@interface MGTimeSignature : NSObject {
    NSUInteger  _numerator;
    NSUInteger  _denominator;
    NSUInteger  _tempo;
}
@property(nonatomic,assign) NSUInteger  numerator;
@property(nonatomic,assign) NSUInteger  denominator;
@property(nonatomic,assign) NSUInteger  tempo;

+(id)commonTime;
+(id)threeFourTime;

-(id)initWithNumerator:(NSUInteger)value
        overDenominator:(NSUInteger)bpm
              andTempo:(NSUInteger)atempo; 
-(NSUInteger)beatsPerMeasure;
-(NSUInteger)beatValue;


@end
 */
