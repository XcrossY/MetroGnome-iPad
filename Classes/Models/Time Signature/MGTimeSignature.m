//
//  MGTimeSignature.m
//  MetroGnomeiPad
//
//  Created by Zander on 10/15/11.
//  Copyright 2011 MetroGnome, LLC. All rights reserved.
//

#import "MGTimeSignature.h"
#import "MidiFile.h"

/** @class MGTimeSignature
 * The MGTimeSignature class represents
 * - The time signature of the song, such as 4/4, 3/4, or 6/8 time, and
 * - The number of pulses per quarter note
 * - The number of microseconds per quarter note
 *
 * In midi files, all time is measured in "pulses".  Each note has
 * a start time (measured in pulses), and a duration (measured in 
 * pulses).  This class is used mainly to convert pulse durations
 * (like 120, 240, etc) into note durations (half, quarter, eighth, etc).
 */

@implementation MGTimeSignature
@synthesize numerator   = _numerator;
@synthesize denominator = _denominator;
@synthesize quarter     = _quarter;
@synthesize measure     = _measure;
@synthesize tempo       = _tempo; 

//Rewrite to include accurate quarter and tempo
+(id)commonTime {
    return [[[MGTimeSignature alloc]initWithNumerator:4
                                       andDenominator:4 
                                           andQuarter:240
                                             andTempo:600] autorelease];
}

-(void)dealloc {
    [super dealloc];
}

/** Create a new time signature, with the given numerator,
 * denominator, pulses per quarter note, and tempo.
 */
-(id)initWithNumerator:(int)n andDenominator:(int)d andQuarter:(int)q andTempo:(int)t {
    int beat;
    
    if (n <= 0 || d <= 0 || q <= 0 || t <= 0) {
        NSLog(@"MGTimeSignature: attempted invalid init call");
    }
    
    self.numerator = n;
    self.denominator = d;
    self.quarter = q;
    self.tempo = t;
    
    /* Midi File gives wrong time signature sometimes */
    if (self.numerator == 5) {
        self.numerator = 4;
    }
    
    if (self.denominator == 2)
        beat = self.quarter * 2;
    else
        beat = self.quarter / (self.denominator/4);
    
    self.measure = self.numerator * beat;
    return self;
}

/** Return which measure the given time (in pulses) belongs to. */
-(int)getMeasureForTime:(int)time {
    return time / self.measure;
}

/** Given a duration in pulses, return the closest note duration. */
-(NoteDuration)getNoteDuration:(int)duration {
    int whole = self.quarter * 4;
    
    /**
     1       = 32/32
     3/4     = 24/32
     1/2     = 16/32
     3/8     = 12/32
     1/4     =  8/32
     3/16    =  6/32
     1/8     =  4/32 =    8/64
     triplet         = 5.33/64
     1/16    =  2/32 =    4/64
     1/32    =  1/32 =    2/64
     **/ 
    
    if      (duration >= 28*whole/32)
        return Whole;
    else if (duration >= 20*whole/32) 
        return DottedHalf;
    else if (duration >= 14*whole/32)
        return Half;
    else if (duration >= 10*whole/32)
        return DottedQuarter;
    else if (duration >=  7*whole/32)
        return Quarter;
    else if (duration >=  5*whole/32)
        return DottedEighth;
    else if (duration >=  6*whole/64)
        return Eighth;
    else if (duration >=  5*whole/64)
        return Triplet;
    else if (duration >=  3*whole/64)
        return Sixteenth;
    else
        return ThirtySecond;
}


/** Return the time period (in pulses) the the given duration spans */
- (int)durationToTime:(NoteDuration)dur {
    int eighth = self.quarter/2;
    int sixteenth = eighth/2;
    
    switch (dur) {
        case Whole:         return self.quarter * 4; 
        case DottedHalf:    return self.quarter * 3; 
        case Half:          return self.quarter * 2; 
        case DottedQuarter: return 3*eighth; 
        case Quarter:       return self.quarter; 
        case DottedEighth:  return 3*sixteenth;
        case Eighth:        return eighth;
        case Triplet:       return self.quarter/3; 
        case Sixteenth:     return sixteenth;
        case ThirtySecond:  return sixteenth/2; 
        default:            return 0;
    }
}

/* Return a copy of this time signature */
- (id)copyWithZone:(NSZone*)zone {
    MGTimeSignature *t = [[MGTimeSignature alloc]
                        initWithNumerator:self.numerator 
                        andDenominator:self.denominator 
                        andQuarter:self.quarter 
                        andTempo:self.tempo];
    return t;
}

- (NSString*) description {
    NSString *s = [NSString stringWithFormat:
                   @"TimeSignature=%d/%d quarter=%d tempo=%d", 
                   self.numerator, self.denominator, 
                   self.quarter, self.tempo ];
    return s;
}

/** Return the given duration as a string */
+ (NSString*) durationString:(int)dur {
    NSString *names[] = { 
        @"ThirtySecond", @"Sixteenth", @"Triplet", @"Eighth",
        @"DottedEighth", @"Quarter", @"DottedQuarter",
        @"Half", @"DottedHalf", @"Whole"
    };
    if (dur < 0 || dur > 9) {
        return @"";
    }
    return names[dur];
}

@end
/* Old implementation
@implementation MGTimeSignature
@synthesize numerator = _numerator;
@synthesize denominator = _denominator;
@synthesize tempo = _tempo;

+(id)commonTime {
    return [[[MGTimeSignature alloc]initWithNumerator:4
                                      overDenominator:4 
                                            andTempo:60] autorelease];
}
+(id)threeFourTime {
    return [[[MGTimeSignature alloc]initWithNumerator:3
                                      overDenominator:4 
                                            andTempo:60] autorelease];
}

-(void)dealloc {
    [super dealloc];
}

-(id)initWithNumerator:(NSUInteger)value
        overDenominator:(NSUInteger)bpm
              andTempo:(NSUInteger)atempo {
 if (self = [super init]) {
     self.numerator     = value;
     self.denominator   = bpm;
     self.tempo         = atempo;
 }   
    return self;
}

-(NSUInteger)beatValue {
    return self.numerator;
}

-(NSUInteger)beatsPerMeasure {
    return self.denominator;
}


    
@end
*/