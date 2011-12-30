//
//  MGMidiFile.h
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 12/29/11.
//  Copyright (c) 2011 Princeton University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGTimeSignature.h"


@interface MGMidiFile : NSObject {
    NSString* _filename;      /** The Midi file name */
    NSMutableArray *_events;  /** Array< Array<MidiEvent>> : the raw midi events */
    NSMutableArray *_tracks;  /** The tracks (MidiTrack) of the midifile that have notes */
    u_short trackmode;        /** 0 (single track), 1 (simultaneous tracks) 2 (independent tracks) */
    MGTimeSignature *_timeSignature;  /** The time signature */
    int quarternote;         /** The number of pulses per quarter note */
    int totalpulses;         /** The total length of the song, in pulses */
    BOOL trackPerChannel;    /** True if we've split each channel into a track */
}
@property(nonatomic,assign) NSString *filename;
@property(nonatomic,retain) NSMutableArray *events;
@property(nonatomic,retain) NSMutableArray *tracks;
@property(nonatomic,assign) MGTimeSignature *timeSignature;

//-(id)initWithFile:(NSString*)path;
//-(Array*)readTrack:(MidiFileReader*)file;
/*-(NSMutableArray*)tracks;
-(MGTimeSignature*)time;
-(NSString*)filename;
-(NSString*)description;
-(int)totalpulses;
-(IntArray*)guessMeasureLength;
-(BOOL)changeSound:(MidiSoundOptions *)options toFile:(NSString*)filename;
-(BOOL)changeSoundPerChannel:(MidiSoundOptions *)options toFile:(NSString*)filename;
-(Array*)changeSheetMusicOptions:(SheetMusicOptions*)options;

+(void)findHighLowNotes:(Array*)notes withMeasure:(int)measurelen startIndex:(int)startindex
              fromStart:(int)starttime toEnd:(int)endtime withHigh:(int*)high
                 andLow:(int*)low;

+(void)findExactHighLowNotes:(Array*)notes startIndex:(int)startindex
                   withStart:(int)starttime withHigh:(int*)high
                      andLow:(int*)low; 

+(Array*)splitTrack:(MidiTrack *)track withMeasure:(int)measurelen;
+(Array*)splitChannels:(MidiTrack *)track withEvents:(Array*)events;
+(MidiTrack*) combineToSingleTrack:(Array *)tracks;

+(Array*) combineToTwoTracks:(Array *)tracks withMeasure:(int)measurelen;
+(void)checkStartTimes:(Array *)tracks;
+(void)roundStartTimes:(Array *)tracks toInterval:(int)millisec  withTime:(MGTimeSignature*)time;
+(void)roundDurations:(Array *)tracks withQuarter:(int)quarternote;
+(void)shiftTime:(Array*)tracks byAmount:(int)amount;
+(void)transpose:(Array*)tracks byAmount:(int)amount;
+(BOOL)hasMultipleChannels:(MidiTrack*) track;
+(NSArray*) instrumentNames;

+(int)getTrackLength:(Array*)events;
+(BOOL)writeMidiFile:(NSString*)filename withEvents:(Array*)events andMode:(int)mode andQuarter:(int)quarter;
+(Array*)cloneMidiEvents:(Array*)origlist;
+(void) addTempoEvent:(Array*)eventlist withTempo:(int)tempo;
+(Array*)startAtPauseTime:(int)pauseTime withEvents:(Array*)list;
*/
@end