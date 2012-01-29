//
//  MGScore.h
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 12/20/11.
//  Copyright (c) 2011 Princeton University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGPart.h"
#import "MGTimeSignature.h"
#import "MidiFile.h"

/* A part contains a string of notes/chords. It is a single instrument,
 voice, or piano (one or both hands) */
@interface MGScore : NSObject {
    NSString *_fileName;     /** The full Midi file path */
    NSMutableArray *_partsArray;   /** of MGParts */
    MGTimeSignature *_timeSignature;
    u_short _trackMode;       /** 0 (single track), 1 (simultaneous tracks) 2 (independent tracks) */
    int _quarterNote;         /** The number of pulses per quarter note */
    int _totalPulses;         /** The total length of the song, in pulses */
    BOOL trackPerChannel;    /** True if we've split each channel into a track */
}
@property(nonatomic,assign) NSString *fileName;
@property(nonatomic,assign) NSMutableArray *partsArray;
@property(nonatomic,assign) MGTimeSignature *timeSignature;
@property(nonatomic,assign) u_short trackMode;
@property(nonatomic,assign) int quarterNote; //redundant with time signature
@property(nonatomic,assign) int totalPulses;

/** Initialization functions */
-(id)initWithCapacity: (NSInteger)capacity
     andTimeSignature: (MGTimeSignature *)timeSignature;
-(id)initWithCapacity: (NSInteger)capacity;
-(id)initWithTimeSignature:(MGTimeSignature *)timeSignature;

-(void)add:             (MGPart *)part; 

-(id)initWithMidiFile: (MidiFile *)midiFile;
-(id)initWithFileName: (NSString *)fileName;

/** Instance methods */
-(int)totalMeasures; /** Returns total number of measures in the score */


@end