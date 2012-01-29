/*
 * Copyright (c) 2007-2011 Madhav Vaidyanathan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */

#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSZone.h>
#import <Foundation/NSException.h>

#import "Options.h"

#import "Array.h"
#import "MGTimeSignature.h"

@interface MidiFileException : NSException {
}
+(id)init:(NSString*)reason offset:(int)off;
@end


@interface MidiEvent : NSObject <NSCopying> {
    int     deltaTime;     /** The time between the previous event and this on */
    int     startTime;     /** The absolute time this event occurs */
    bool    hasEventflag;  /** False if this is using the previous eventflag */
    u_char  eventFlag;     /** NoteOn, NoteOff, etc.  Full list is in class MidiFile */
    u_char  channel;       /** The channel this event occurs on */

    u_char  notenumber;    /** The note number  */
    u_char  velocity;      /** The volume of the note */
    u_char  instrument;    /** The instrument */
    u_char  keyPressure;   /** The key pressure */
    u_char  chanPressure;  /** The channel pressure */
    u_char  controlNum;    /** The controller number */
    u_char  controlValue;  /** The controller value */
    u_short pitchBend;     /** The pitch bend value */
    u_char  numerator;     /** The numerator, for MGTimeSignature meta events */
    u_char  denominator;   /** The denominator, for MGTimeSignature meta events */
    int     tempo;         /** The tempo, for Tempo meta events */
    u_char  metaevent;     /** The metaevent, used if eventflag is MetaEvent */
    int     metalength;    /** The metaevent length  */
    u_char* metavalue;     /** The raw byte value, for Sysex and meta events */
}

-(BOOL)isNoteEvent; //Returns TRUE if event is NoteOn or NoteOff

-(id)init;
-(int)deltaTime;
-(int)startTime;
-(bool)hasEventflag;
-(u_char)eventFlag;
-(u_char)channel;
-(u_char)notenumber;
-(u_char)velocity;
-(u_char)instrument;
-(u_char)keyPressure;
-(u_char)chanPressure;
-(u_char)controlNum;
-(u_char)controlValue;
-(u_short)pitchBend;
-(int)numerator;
-(int)denominator;
-(int)tempo;
-(u_char)metaevent;
-(int)metalength;
-(u_char*)metavalue;


-(void)setDeltaTime:(int) value;
-(void)setStartTime:(int) value;
-(void)setHasEventflag:(bool) value;
-(void)setEventFlag:(u_char) value;
-(void)setChannel:(u_char) value;
-(void)setNotenumber:(u_char) value;
-(void)setVelocity:(u_char) value;
-(void)setInstrument:(u_char) value;
-(void)setKeyPressure:(u_char) value;
-(void)setChanPressure:(u_char) value;
-(void)setControlNum:(u_char) value;
-(void)setControlValue:(u_char) value;
-(void)setPitchBend:(u_short) value;
-(void)setNumerator:(int) value;
-(void)setDenominator:(int) value;
-(void)setTempo:(int) value;
-(void)setMetaevent:(u_char) value;
-(void)setMetalength:(int) value;
-(void)setMetavalue:(u_char*) value;

-(id)copyWithZone:(NSZone*)zone;
-(void)dealloc;
@end

@interface MidiNote : NSObject <NSCopying> {
    int starttime;  /** The start time, in pulses */
    int channel;    /** The channel */
    int notenumber; /** The note, from 0 to 127. Middle C is 60 */
    int duration;   /** The duration, in pulses */
}

-(int)startTime;
-(void)setStarttime:(int)value;
-(int)channel;
-(void)setChannel:(int)value;
-(int)number;
-(void)setNumber:(int)value;
-(int)duration;
-(void)setDuration:(int)value;
-(int)endTime;
-(void)noteOff:(int)endtime;
-(id)copyWithZone:(NSZone*)zone;
-(NSString*)description;

@end

int sortbynote(void* note1, void* note2);
int sortbytime(void* note1, void* note2);

@interface MidiTrack : NSObject <NSCopying> {
    int tracknum;          /** The track number */
    Array* notes;          /** Array of notes */
    int instrument;        /** Instrument for this track */
}
-(id)initWithTrack:(int)tracknum;
-(id)initWithEvents:(Array*)events andTrack:(int)tracknum;
-(void)dealloc;
-(int)number;
-(void)setNumber:(int)value;
-(Array*)notes;
-(NSString*)instrumentName;
-(int)instrument;
-(void)setInstrument:(int)value;
-(NSString*)description;
-(void)addNote:(MidiNote *)m;
-(void)noteOffWithChannel:(int)channel andNumber:(int)num andTime:(int)endtime;
-(id)copyWithZone:(NSZone *)zone;

@end

@interface MidiFileReader : NSObject {
    u_char *data;      /** The entire midi file data */
    int datalen;       /** The data length */
    int parse_offset;  /** The current offset while parsing */
}
-(id)initWithFile:(NSString*)filename;
-(void)checkRead:(int)amount;
-(u_char)peek;
-(u_char)readByte;
-(u_short)readShort;
-(int)readInt;
-(u_char*)readBytes:(int)len;
-(char*)readAscii:(int)len;
-(int)readVarlen;
-(void)skip:(int)amount;
-(int)offset;
-(void)dealloc;
@end

/******************************************************************************/

@interface MidiFile : NSObject {
    NSString* filename;      /** The Midi file name */
    Array *events;           /** Array< Array<MidiEvent>> : the raw midi events. An Array of MidiTracks */
    Array *tracks;           /** The tracks (MidiTrack) of the midifile that have notes. Array of MidiTracks that contain notes */
    u_short trackmode;       /** 0 (single track), 1 (simultaneous tracks) 2 (independent tracks) */
    MGTimeSignature* timesig;  /** The time signature */
    int quarternote;         /** The number of pulses per quarter note */
    int totalpulses;         /** The total length of the song, in pulses */
    BOOL trackPerChannel;    /** True if we've split each channel into a track */
}
//Instance Methods
-(Array*)events;
-(NSString *)writeTemporaryMIDI; //Returns filepath of new Midi file
-(void)transposeByAmount:(int)interval;
-(u_short)trackmode;
-(MGTimeSignature *)timesig;
-(BOOL)trackPerChannel;
-(int)quarternote;

-(id)initWithFile:(NSString*)path;
-(Array*)readTrack:(MidiFileReader*)file;
-(Array*)tracks;
-(MGTimeSignature*)time;
-(NSString*)filename;
-(NSString*)description;
-(int)totalpulses;
-(IntArray*)guessMeasureLength;
-(BOOL)changeSound:(MidiSoundOptions *)options toFile:(NSString*)filename;
-(BOOL)changeSoundPerChannel:(MidiSoundOptions *)options toFile:(NSString*)filename;
-(Array*)changeSheetMusicOptions:(SheetMusicOptions*)options;


//Class Methods
+(void)findHighLowNotes:(Array*)notes withMeasure:(int)measurelen startIndex:(int)startindex
                        fromStart:(int)starttime toEnd:(int)endtime withHigh:(int*)high
                        andLow:(int*)low;
+(void)findExactHighLowNotes:(Array*)notes startIndex:(int)startindex
                        withStart:(int)starttime withHigh:(int*)high
                        andLow:(int*)low; 

+(Array*)splitTrack:(MidiTrack *)track withMeasure:(int)measurelen;
+(Array*)splitChannels:(MidiTrack *)track withEvents:(Array*)events;
+(MidiTrack*) combineToSingleTrack:(Array *)tracks;

+(Array*)combineToTwoTracks:(Array *)tracks withMeasure:(int)measurelen;
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

@end



