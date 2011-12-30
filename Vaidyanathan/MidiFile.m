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

#import "MidiFile.h"
#import <Foundation/NSAutoreleasePool.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <assert.h>
#include <stdio.h>
#include <sys/stat.h>
#include <math.h>

/* This file contains the classes for parsing and modifying MIDI music files */

/* Midi file format.
 *
 * The Midi File format is described below.  The description uses
 * the following abbreviations.
 *
 * u1     - One byte
 * u2     - Two bytes (big endian)
 * u4     - Four bytes (big endian)
 * varlen - A variable length integer, that can be 1 to 4 bytes. The 
 *          integer ends when you encounter a byte that doesn't have 
 *          the 8th bit set (a byte less than 0x80).
 * len?   - The length of the data depends on some code
 *          
 *
 * The Midi files begins with the main Midi header
 * u4 = The four ascii characters 'MThd'
 * u4 = The length of the MThd header = 6 bytes
 * u2 = 0 if the file contains a single track
 *      1 if the file contains one or more simultaneous tracks
 *      2 if the file contains one or more independent tracks
 * u2 = number of tracks
 * u2 = if >  0, the number of pulses per quarter note
 *      if <= 0, then ???
 *
 * Next come the individual Midi tracks.  The total number of Midi
 * tracks was given above, in the MThd header.  Each track starts
 * with a header:
 *
 * u4 = The four ascii characters 'MTrk'
 * u4 = Amount of track data, in bytes.
 * 
 * The track data consists of a series of Midi events.  Each Midi event
 * has the following format:
 *
 * varlen  - The time between the previous event and this event, measured
 *           in "pulses".  The number of pulses per quarter note is given
 *           in the MThd header.
 * u1      - The Event code, always betwee 0x80 and 0xFF
 * len?    - The event data.  The length of this data is determined by the
 *           event code.  The first byte of the event data is always < 0x80.
 *
 * The event code is optional.  If the event code is missing, then it
 * defaults to the previous event code.  For example:
 *
 *   varlen, eventcode1, eventdata,
 *   varlen, eventcode2, eventdata,
 *   varlen, eventdata,  // eventcode is eventcode2
 *   varlen, eventdata,  // eventcode is eventcode2
 *   varlen, eventcode3, eventdata,
 *   ....
 *
 *   How do you know if the eventcode is there or missing? Well:
 *   - All event codes are between 0x80 and 0xFF
 *   - The first byte of eventdata is always less than 0x80.
 *   So, after the varlen delta time, if the next byte is between 0x80
 *   and 0xFF, its an event code.  Otherwise, its event data.
 *
 * The Event codes and event data for each event code are shown below.
 *
 * Code:  u1 - 0x80 thru 0x8F - Note Off event.
 *             0x80 is for channel 1, 0x8F is for channel 16.
 * Data:  u1 - The note number, 0-127.  Middle C is 60 (0x3C)
 *        u1 - The note velocity.  This should be 0
 * 
 * Code:  u1 - 0x90 thru 0x9F - Note On event.
 *             0x90 is for channel 1, 0x9F is for channel 16.
 * Data:  u1 - The note number, 0-127.  Middle C is 60 (0x3C)
 *        u1 - The note velocity, from 0 (no sound) to 127 (loud).
 *             A value of 0 is equivalent to a Note Off.
 *
 * Code:  u1 - 0xA0 thru 0xAF - Key Pressure
 * Data:  u1 - The note number, 0-127.
 *        u1 - The pressure.
 *
 * Code:  u1 - 0xB0 thru 0xBF - Control Change
 * Data:  u1 - The controller number
 *        u1 - The value
 *
 * Code:  u1 - 0xC0 thru 0xCF - Program Change
 * Data:  u1 - The program number.
 *
 * Code:  u1 - 0xD0 thru 0xDF - Channel Pressure
 *        u1 - The pressure.
 *
 * Code:  u1 - 0xE0 thru 0xEF - Pitch Bend
 * Data:  u2 - Some data
 *
 * Code:  u1     - 0xFF - Meta Event
 * Data:  u1     - Metacode
 *        varlen - Length of meta event
 *        u1[varlen] - Meta event data.
 *
 *
 * The Meta Event codes are listed below:
 *
 * Metacode: u1         - 0x0  Sequence Number
 *           varlen     - 0 or 2
 *           u1[varlen] - Sequence number
 *
 * Metacode: u1         - 0x1  Text
 *           varlen     - Length of text
 *           u1[varlen] - Text
 *
 * Metacode: u1         - 0x2  Copyright
 *           varlen     - Length of text
 *           u1[varlen] - Text
 *
 * Metacode: u1         - 0x3  Track Name
 *           varlen     - Length of name
 *           u1[varlen] - Track Name
 *
 * Metacode: u1         - 0x58  Time Signature
 *           varlen     - 4 
 *           u1         - numerator
 *           u1         - log2(denominator)
 *           u1         - clocks in metronome click
 *           u1         - 32nd notes in quarter note (usually 8)
 *
 * Metacode: u1         - 0x59  Key Signature
 *           varlen     - 2
 *           u1         - if >= 0, then number of sharps
 *                        if < 0, then number of flats * -1
 *           u1         - 0 if major key
 *                        1 if minor key
 *
 * Metacode: u1         - 0x51  Tempo
 *           varlen     - 3  
 *           u3         - quarter note length in microseconds
 */

/* The list of Midi Events */
#define EventNoteOff         0x80
#define EventNoteOn          0x90
#define EventKeyPressure     0xA0
#define EventControlChange   0xB0
#define EventProgramChange   0xC0
#define EventChannelPressure 0xD0
#define EventPitchBend       0xE0
#define SysexEvent1          0xF0
#define SysexEvent2          0xF7
#define MetaEvent            0xFF

/* The list of Meta Events */
#define MetaEventSequence      0x0
#define MetaEventText          0x1
#define MetaEventCopyright     0x2
#define MetaEventSequenceName  0x3
#define MetaEventInstrument    0x4
#define MetaEventLyric         0x5
#define MetaEventMarker        0x6
#define MetaEventEndOfTrack    0x2F
#define MetaEventTempo         0x51
#define MetaEventSMPTEOffset   0x54
#define MetaEventTimeSignature 0x58
#define MetaEventKeySignature  0x59


/* Return a string representation of a Midi event */
static const char* eventName(int ev) {
    if (ev >= EventNoteOff && ev < EventNoteOff + 16)
        return "NoteOff";
    else if (ev >= EventNoteOn && ev < EventNoteOn + 16) 
        return "NoteOn";
    else if (ev >= EventKeyPressure && ev < EventKeyPressure + 16) 
        return "KeyPressure";
    else if (ev >= EventControlChange && ev < EventControlChange + 16) 
        return "ControlChange";
    else if (ev >= EventProgramChange && ev < EventProgramChange + 16) 
        return "ProgramChange";
    else if (ev >= EventChannelPressure && ev < EventChannelPressure + 16)
        return "ChannelPressure";
    else if (ev >= EventPitchBend && ev < EventPitchBend + 16)
        return "PitchBend";
    else if (ev == MetaEvent)
        return "MetaEvent";
    else if (ev == SysexEvent1 || ev == SysexEvent2)
        return "SysexEvent";
    else
        return "Unknown";
}

/** Write a variable length number to the buffer at the given offset.
 * Return the number of bytes written.
 */
static int varlenToBytes(int num, u_char *buf, int offset) {
    u_char b1 = (u_char) ((num >> 21) & 0x7F);
    u_char b2 = (u_char) ((num >> 14) & 0x7F);
    u_char b3 = (u_char) ((num >>  7) & 0x7F);
    u_char b4 = (u_char) (num & 0x7F);

    if (b1 > 0) {
        buf[offset]   = (u_char)(b1 | 0x80);
        buf[offset+1] = (u_char)(b2 | 0x80);
        buf[offset+2] = (u_char)(b3 | 0x80);
        buf[offset+3] = b4;
        return 4;
    }
    else if (b2 > 0) {
        buf[offset]   = (u_char)(b2 | 0x80);
        buf[offset+1] = (u_char)(b3 | 0x80);
        buf[offset+2] = b4;
        return 3;
    }
    else if (b3 > 0) {
        buf[offset]   = (u_char)(b3 | 0x80);
        buf[offset+1] = b4;
        return 2;
    }
    else {
        buf[offset] = b4;
        return 1;
    }
}

/** Write a 4-byte integer to buf[offset : offset+4] */
static void intToBytes(int value, u_char *buf, int offset) {
    buf[offset] = (u_char)( (value >> 24) & 0xFF );
    buf[offset+1] = (u_char)( (value >> 16) & 0xFF );
    buf[offset+2] = (u_char)( (value >> 8) & 0xFF );
    buf[offset+3] = (u_char)( value & 0xFF );
}

/** Write the given buffer to the given file.
 *  If an error occurs, set error = 1.
 */
static void dowrite(int fd, u_char *buf, int len, int *error) {
    int n = 0;
    int offset = 0;
    do {
        n = write(fd, &buf[offset], len - offset);
        if (n > 0) {
            offset += n;
        }
        else if (n == 0) {
            *error = 1;
            return;
        }
        else if (n == -1 && errno == EINTR) {
        }
        else if (n == -1) {
            *error = 1;
            return;
        }
    }
    while (offset < len);
}

/** @class MidiEvent
 * A MidiEvent represents a single event (such as EventNoteOn) in the
 * Midi file. It includes the delta time of the event.
 */
@implementation MidiEvent

/** Initialize all the MidiEvent fields to 0 */
- (id)init {
    deltaTime = 0;
    startTime = 0;
    hasEventflag = 0;
    eventFlag = 0;
    channel = 0;
    notenumber = 0;
    velocity = 0;
    instrument = 0;
    keyPressure = 0;
    chanPressure = 0;
    controlNum = 0;
    controlValue = 0;
    pitchBend = 0;
    numerator = 0;
    denominator = 0;
    tempo = 0;
    metaevent = 0;
    metalength = 0;
    metavalue = NULL;
    return self;
}


/* See MidiFile.h for a description of each field */
- (int)deltaTime { return deltaTime; }
- (int)startTime { return startTime; }
- (bool)hasEventflag { return hasEventflag; }
- (u_char)eventFlag { return eventFlag; }
- (u_char)channel { return channel; }
- (u_char)notenumber { return notenumber; }
- (u_char)velocity { return velocity; }
- (u_char)instrument { return instrument; }
- (u_char)keyPressure { return keyPressure; }
- (u_char)chanPressure { return chanPressure; }
- (u_char)controlNum { return controlNum; }
- (u_char)controlValue { return controlValue; }
- (u_short)pitchBend { return pitchBend; }
- (int)numerator { return numerator; }
- (int)denominator { return denominator; }
- (int)tempo { return tempo; }
- (u_char)metaevent { return metaevent; }
- (int)metalength { return metalength; }
- (u_char*)metavalue { return metavalue; }

- (void)setDeltaTime:(int)value { deltaTime = value; }
- (void)setStartTime:(int)value { startTime = value; }
- (void)setHasEventflag:(bool)value { hasEventflag = value; }
- (void)setEventFlag:(u_char)value { eventFlag = value; }
- (void)setChannel:(u_char)value { channel = value; }
- (void)setNotenumber:(u_char)value { notenumber = value; }
- (void)setVelocity:(u_char)value { velocity = value; }
- (void)setInstrument:(u_char)value { instrument = value; }
- (void)setKeyPressure:(u_char)value { keyPressure = value; }
- (void)setChanPressure:(u_char)value { chanPressure = value; }
- (void)setControlNum:(u_char)value { controlNum = value; }
- (void)setControlValue:(u_char)value { controlValue = value; }
- (void)setPitchBend:(u_short)value { pitchBend = value; }
- (void)setNumerator:(int)value { numerator = (u_char)value; }
- (void)setDenominator:(int)value { denominator = (u_char)value; }
- (void)setTempo:(int)value { tempo = value; }
- (void)setMetaevent:(u_char)value { metaevent = value; }
- (void)setMetalength:(int)value { metalength = value; }
- (void)setMetavalue:(u_char*)value { metavalue = value; }

- (id)copyWithZone:(NSZone*)zone {
    MidiEvent *mevent = [[MidiEvent alloc] init];
    [mevent setDeltaTime:deltaTime];
    [mevent setStartTime:startTime];
    [mevent setHasEventflag:hasEventflag];
    [mevent setEventFlag:eventFlag];
    [mevent setChannel:channel];
    [mevent setNotenumber:notenumber];
    [mevent setVelocity:velocity];
    [mevent setInstrument:instrument];
    [mevent setKeyPressure:keyPressure];
    [mevent setChanPressure:chanPressure];
    [mevent setControlNum:controlNum];
    [mevent setControlValue:controlValue];
    [mevent setPitchBend:pitchBend];
    [mevent setNumerator:numerator];
    [mevent setDenominator:denominator];
    [mevent setTempo:tempo];
    [mevent setMetaevent:metaevent];
    [mevent setMetalength:metalength];
    [mevent setMetavalue:metavalue];
    return mevent;
}

- (void)dealloc {
    if (eventFlag == MetaEvent || eventFlag == SysexEvent1 ||
        eventFlag == SysexEvent2) {
        /* free(metavalue); */
        metavalue = NULL;
    }
    [super dealloc];
}

@end



/** @class MidiNote
 * A MidiNote contains
 *
 * starttime - The time (measured in pulses) when the note is pressed.
 * channel   - The channel the note is from.  This is used when matching
 *             NoteOff events with the corresponding NoteOn event.
 *             The channels for the NoteOn and NoteOff events must be
 *             the same.
 * notenumber - The note number, from 0 to 127.  Middle C is 60.
 * duration  - The time duration (measured in pulses) after which the 
 *             note is released.
 *
 * A MidiNote is created when we encounter a NoteOff event.  The duration
 * is initially unknown (set to 0).  When the corresponding NoteOff event
 * is found, the duration is set by the method NoteOff().
 */

@implementation MidiNote

- (id)init {
    starttime = 0;
    channel = 0;
    duration = 0;
    notenumber = 0;
    return self;
} 

/* Get and set the MidiNote fields */
- (int)startTime {
    return starttime;
}

- (void)setStarttime:(int)t {
    starttime = t;
}

- (int)endTime {
    return starttime + duration;
}

- (int)duration {
    return duration;
}

- (void)setDuration:(int)d {
    duration = d;
}

- (int)channel {
    return channel;
}

- (void)setChannel:(int)n {
    channel = n;
}

- (int)number {
    return notenumber;
}

- (void)setNumber:(int)n {
    notenumber = n;
}

/* A NoteOff event occurs for this note at the given time.
 * Calculate the note duration based on the noteoff event.
 */
- (void)noteOff:(int)endtime {
    duration = endtime - starttime;
}

- (id)copyWithZone:(NSZone*)zone {
    MidiNote *m = [[MidiNote alloc] init];
    [m setStarttime:starttime];
    [m setChannel:channel];
    [m setNumber:notenumber];
    [m setDuration:duration];
    return m;
}

- (NSString*)description {
    NSString *s = [NSString stringWithFormat:
                      @"MidiNote channel=%d number=%d start=%d duration=%d",
                      channel, notenumber, starttime, duration ];
    return s;
}

- (void)dealloc {
    [super dealloc];
}

@end /* class MidiNote */

/** Compare two MidiNotes based on their start times.
 *  If the start times are equal, compare by their numbers.
 *  Used by the C mergesort function.
 */
int sortbytime(void* v1, void* v2) {
    MidiNote **m1 = (MidiNote**) v1;
    MidiNote **m2 = (MidiNote**) v2;
    MidiNote *note1 = *m1;
    MidiNote *note2 = *m2;

    if ([note1 startTime] == [note2 startTime]) {
        return [note1 number] - [note2 number];
    }
    else {
        return [note1 startTime] - [note2 startTime];
    }
}


/** @class MidiTrack
 * The MidiTrack takes as input the raw MidiEvents for the track, and gets:
 * - The list of midi notes in the track.
 * - The first instrument used in the track.
 *
 * For each NoteOn event in the midi file, a new MidiNote is created
 * and added to the track, using the AddNote() method.
 * 
 * The NoteOff() method is called when a NoteOff event is encountered,
 * in order to update the duration of the MidiNote.
 */ 
@implementation MidiTrack

/** Create an empty MidiTrack. Used by the copy method */
- (id)initWithTrack:(int)t {
    tracknum = t;
    notes = [Array new:20];
    instrument = 0;
    return self;
}

/** Create a MidiTrack based on the Midi events.  Extract the NoteOn/NoteOff
 *  events to gather the list of MidiNotes.
 */
- (id)initWithEvents:(Array*)list andTrack:(int)num {
    tracknum = num;
    notes = [Array new:100];
    instrument = 0;

    for (int i= 0;i < [list count]; i++) {
        MidiEvent *mevent = [list get:i];
        if ([mevent eventFlag] == EventNoteOn && [mevent velocity] > 0) {
            MidiNote *note = [[MidiNote alloc] init];
            [note setStarttime:[mevent startTime]];
            [note setChannel:[mevent channel]];
            [note setNumber:[mevent notenumber]];
            [self addNote:note];
            [note release];
        }
        else if ([mevent eventFlag] == EventNoteOn && [mevent velocity] == 0) {
            [self noteOffWithChannel:[mevent channel] andNumber:[mevent notenumber]
                  andTime:[mevent startTime] ];
        }
        else if ([mevent eventFlag] == EventNoteOff) {
            [self noteOffWithChannel:[mevent channel] andNumber:[mevent notenumber]
                  andTime:[mevent startTime] ];
        }
        else if ([mevent eventFlag] == EventProgramChange) {
            instrument = [mevent instrument];
        }
    }
    if ([notes count] > 0 && [(MidiNote*)[notes get:0] channel] == 9) {
        instrument = 128;  /* Percussion */
    }
    return self;
}


- (void)dealloc {
    [notes release];
    [super dealloc];
}

- (int)number {
    return tracknum;
}

- (void)setNumber:(int)value {
    tracknum = value;
}

- (Array*)notes {
    return notes;
}

- (NSString*)instrumentName {
    if (instrument >= 0 && instrument <= 128) {
        return [[MidiFile instrumentNames] objectAtIndex:instrument];
    }
    else {
        return @"";
    }
}


- (int)instrument {
    return instrument;
}

- (void)setInstrument:(int)value {
    instrument = value;
} 

/** Add a MidiNote to this track.  This is called for each NoteOn event */
- (void)addNote:(MidiNote*)m {
    [notes add:m];
}

/** A NoteOff event occured.  Find the MidiNote of the corresponding
 * NoteOn event, and update the duration of the MidiNote.
 */
- (void)noteOffWithChannel:(int)channel andNumber:(int)number andTime:(int)endtime {
    for (int i = [notes count]-1; i >= 0; i--) {
        MidiNote* note = [notes get:i];
        if ([note channel] == channel && [note number] == number &&
            [note duration] == 0) {
            [note noteOff:endtime];
            return;
        }
    }
}

/** Return a deep copy clone of this MidiTrack */
- (id)copyWithZone:(NSZone*)zone {
    MidiTrack *track = [[MidiTrack alloc] initWithTrack:tracknum];
    [track setInstrument:instrument];
    for (int i = 0; i < [notes count]; i++) {
        MidiNote *note = [notes get:i];
        MidiNote *notecopy = [note copy];
        [[track notes] add:notecopy ];
        [notecopy release];
    }
    return track;
}

- (NSString*)description {
    NSString *s = [NSString stringWithFormat:
                      @"Track number=%d instrument=%d\n", tracknum, instrument];
    for (int i = 0; i < [notes count]; i++) {
        MidiNote *m = [notes get:i];
        s = [s stringByAppendingString:[m description]];
        s = [s stringByAppendingString:@"\n"];
    }
    s = [s stringByAppendingString:@"End Track\n"];
    return s;
}

@end /* class MidiTrack */


/** @class MidiFileException
 * A MidiFileException is thrown when an error occurs
 * while parsing the Midi File.  The constructore takes
 * the file offset (in bytes) where the error occurred,
 * and a string describing the error.
 */
@implementation MidiFileException
+(id)init:(NSString*)reason offset:(int)off {
    NSString *s = [NSString stringWithFormat:@"%@ at offset %d", reason, off];
    MidiFileException *e =
        [[MidiFileException alloc] initWithName:@"MidiFileException"
          reason:s userInfo:nil];
    return e;
}
@end


/** @class MidiFileReader
 * The MidiFileReader is used to read low-level binary data from a file.
 * This class can do the following:
 *
 * - Peek at the next byte in the file.
 * - Read a byte
 * - Read a 16-bit big endian short
 * - Read a 32-bit big endian int
 * - Read a fixed length ascii string (not null terminated)
 * - Read a "variable length" integer.  The format of the variable length
 *   int is described at the top of this file.
 * - Skip ahead a given number of bytes
 * - Return the current offset.
 */
@implementation MidiFileReader

/** Create a new MidiFileReader for the given filename */
- (id)initWithFile:(NSString*)filename {
    const char *name = [filename cStringUsingEncoding:NSASCIIStringEncoding];
    int fd = open(name, O_RDONLY);
    if (fd == -1) {
        const char *err = strerror(errno);
        NSString *reason = @"Unable to open file ";
        reason = [reason stringByAppendingString:filename];
        reason = [reason stringByAppendingString:@":"];
        reason = [reason stringByAppendingString:
           [NSString stringWithCString:err encoding:NSASCIIStringEncoding]];
        MidiFileException *e = [MidiFileException init:reason offset:0];
        @throw e;
    }
    struct stat info;
    int ret = stat(name, &info);
    if (info.st_size == 0) {
        NSString *reason = @"File is empty:";
        reason = [reason stringByAppendingString:filename];
        MidiFileException *e = [MidiFileException init:reason offset:0];
        @throw e;
    }
    datalen = info.st_size;
    data = (u_char*)malloc(datalen);
    int offset = 0;
    while (1) {
        if (offset == datalen)
            break;
        int n = read(fd, &data[offset], datalen - offset);
        if (n <= 0)
            break;
        offset += n;
    }
    close(fd);
    parse_offset = 0;
    return self;
}

/** Check that the given number of bytes doesn't exceed the file size */
- (void)checkRead:(int)amount {
    if (parse_offset + amount > datalen) {
        NSString *reason = @"File is truncated";
        MidiFileException *e = [MidiFileException init:reason offset:parse_offset];
        @throw e;
    }
} 

/** Return the next byte in the file, but don't increment the parse offset */
- (u_char)peek {
    [self checkRead:1];
    return data[parse_offset];
}


/** Read a byte from the file */
- (u_char)readByte {
    [self checkRead:1];
    u_char x = data[parse_offset];
    parse_offset++;
    return x;
}

/** Read the given number of bytes from the file */
- (u_char*)readBytes:(int) amount {
    [self checkRead:amount];
    u_char* result = malloc(sizeof(u_char) * amount);
    memcpy(result, &data[parse_offset], amount);
    parse_offset += amount;
    return result;
}

/** Read a 16-bit short from the file */
- (u_short)readShort {
    [self checkRead:2];
    u_short x = (u_short) ( (data[parse_offset] << 8) | data[parse_offset+1] );
    parse_offset += 2;
    return x;
}

/** Read a 32-bit int from the file */
- (int)readInt {
    [self checkRead:4];
    int x = (int)( (data[parse_offset] << 24) | (data[parse_offset+1] << 16) | 
                   (data[parse_offset+2] << 8) | data[parse_offset+3] );
    parse_offset += 4;
    return x;
}

/** Read an ascii string with the given length */
- (char*)readAscii:(int)len {
    [self checkRead:len];
    char* s = (char*) &data[parse_offset];
    parse_offset += len;
    return s;
}

/** Read a variable-length integer (1 to 4 bytes). The integer ends
 * when you encounter a byte that doesn't have the 8th bit set
 * (a byte less than 0x80).
 */
- (int)readVarlen {
    unsigned int result = 0;
    u_char b;
    int i;

    b = [self readByte];
    result = (unsigned int)(b & 0x7f);

    for (i = 0; i < 3; i++) {
        if ((b & 0x80) != 0) {
            b = [self readByte];
            result = (unsigned int)( (result << 7) + (b & 0x7f) );
        }
        else {
            break;
        }
    }
    return (int)result;
}

/** Skip over the given number of bytes */
- (void)skip:(int)amount {
    [self checkRead:amount];
    parse_offset += amount;
}

/** Return the current parse offset */
- (int)offset {
    return parse_offset;
}


- (void)dealloc {
    free(data);
    [super dealloc];
}

@end /* class MidiFileReader */


/* Midi File */


/** @class MidiFile
 *
 * The MidiFile class contains the parsed data from the Midi File.
 * It contains:
 * - All the tracks in the midi file, including all MidiNotes per track.
 * - The time signature (e.g. 4/4, 3/4, 6/8)
 * - The number of pulses per quarter note.
 * - The tempo (number of microseconds per quarter note).
 *
 * The constructor takes a filename as input, and upon returning,
 * contains the parsed data from the midi file.
 *
 * The methods readTrack() and readMetaEvent() are helper functions called
 * by the constructor during the parsing.
 *
 * After the MidiFile is parsed and created, the user can retrieve the 
 * tracks and notes by using the method tracks and [tracks notes].
 *
 * There are two methods for modifying the midi data based on the menu
 * options selected:
 *
 * - changeSheetMusicOptions()
 *   Apply the menu options to the parsed MidiFile.  This uses the helper functions:
 *     splitTrack()
 *     combineToTwoTracks()
 *     shiftTime()
 *     transpose()
 *     roundStartTimes()
 *     roundDurations()
 *
 * - changeSound()
 *   Apply the menu options to the MIDI music data, and save the modified midi data
 *   to a file, for playback.  This uses the helper functions:
 *     addTempoEvent()
 *     changeSoundPerChannel
 */

@implementation MidiFile

/*Z*/
-(Array*)events {
    return events;
}

/** Get the list of tracks (MidiTrack) */
- (Array*)tracks {
    return tracks;
}

/** Get the time signature */
- (MGTimeSignature*)time {
    return timesig;
}

/** Get the file name */
- (NSString*)filename {
    return filename;
}

/** Get the total length (in pulses) of the song */
- (int)totalpulses {
    return totalpulses;
}

/** Parse the given Midi file, and return an instance of this MidiFile
 * class.  After reading the midi file, this object will contain:
 * - The raw list of midi events
 * - The Time Signature of the song
 * - All the tracks in the song which contain notes. 
 * - The number, starttime, and duration of each note.
 */
- (id)initWithFile:(NSString*)path {
    const char *hdr;
    int len;

    filename = [path retain];
    tracks = [Array new:5];
    trackPerChannel = NO;

    MidiFileReader *file = [[MidiFileReader alloc] initWithFile:filename];
    hdr = [file readAscii:4];
    if (strncmp(hdr, "MThd", 4) != 0) {
		[file release];
        MidiFileException *e =
           [MidiFileException init:@"Bad MThd header" offset:0];
        @throw e;
    }
    len = [file readInt];
    if (len !=  6) {
        [file release];
        MidiFileException *e =
           [MidiFileException init:@"Bad MThd len" offset:4];
        @throw e;
    }
    trackmode = [file readShort];
    int num_tracks = [file readShort];
    quarternote = [file readShort];

    events = [Array new:num_tracks];
    for (int tracknum = 0; tracknum < num_tracks; tracknum++) {
        Array *trackevents = [self readTrack:file];
        MidiTrack *track = 
          [[MidiTrack alloc] initWithEvents:trackevents andTrack:tracknum];
        [events add:trackevents];
        [trackevents release];
        [track setNumber:tracknum];
        if ([[track notes] count] > 0) {
            [tracks add:track];
        }
        [track release];
    }

    /* Get the length of the song in pulses */
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        MidiNote *last = [[track notes] get:([[track notes] count] -1) ];
        if (totalpulses < [last startTime] + [last duration]) {
            totalpulses = [last startTime] + [last duration];
        }
    }

    /* If we only have one track with multiple channels, then treat
     * each channel as a separate track.
     */
    if ([tracks count] == 1 && [MidiFile hasMultipleChannels:[tracks get:0]]) {
        Array *trackevents = [events get:[[tracks get:0] number] ];
        Array* newtracks = [MidiFile splitChannels:[tracks get:0] withEvents:trackevents];
        trackPerChannel = YES;
        [tracks release];
        tracks = newtracks;
    }

    [MidiFile checkStartTimes:tracks];

    /* Determine the time signature */
    int tempo = 0;
    int numer = 0;
    int denom = 0;
    for (int tracknum = 0; tracknum < [events count]; tracknum++) {
        Array *eventlist = [events get:tracknum];
        for (int i = 0; i < [eventlist count]; i++) {
            MidiEvent *mevent = [eventlist get:i];
            if ([mevent metaevent] == MetaEventTempo && tempo == 0) {
                tempo = [mevent tempo];
            }
            if ([mevent metaevent] == MetaEventTimeSignature && numer == 0) {
                numer = [mevent numerator];
                denom = [mevent denominator];
            }
        }
    }

    if (tempo == 0) {
        tempo = 500000; /* 500,000 microseconds = 0.05 sec */
    }
    if (numer == 0) {
        numer = 4; denom = 4;
    }
    timesig = [[MGTimeSignature alloc] initWithNumerator:numer
                     andDenominator:denom
                     andQuarter:quarternote
                     andTempo:tempo];

    
    [file release];
    return self;
}

- (void)dealloc {
    [filename release];
    [tracks release];
    [timesig release];
    [events release];
    [super dealloc];
}

/** Parse a single track into a list of MidiEvents.
 * Entering this function, the file offset should be at the start of
 * the MTrk header.  Upon exiting, the file offset should be at the
 * start of the next MTrk header.
 */
- (Array*)readTrack:(MidiFileReader*)file {
    Array *result = [Array new:20];
    int starttime = 0;
    const char *hdr = [file readAscii:4];

    if (strncmp(hdr, "MTrk", 4) != 0) {
        MidiFileException *e =
           [MidiFileException init:@"Bad MTrk header" offset:([file offset] -4)];
        @throw e;
    }
    int tracklen = [file readInt];
    int trackend = tracklen + [file offset];

    int eventflag = 0;

    while ([file offset] < trackend) {
        /* If the midi file is truncated here, we can still recover.
         * Just return what we've parsed so far.
         */
        int startoffset, deltatime;
        u_char peekevent;
        @try {
            startoffset = [file offset];
            deltatime = [file readVarlen];
            starttime += deltatime;
            peekevent = [file peek];
        }
        @catch (MidiFileException* e) {
            return result;
        } 

        MidiEvent *mevent = [[MidiEvent alloc] init];
        [result add:mevent];
        [mevent setDeltaTime:deltatime];
        [mevent setStartTime:starttime];

        if (peekevent >= EventNoteOff) {
            [mevent setHasEventflag:YES];
            eventflag = [file readByte];
            /* printf("Read new event %d %s\n", eventflag, eventName(eventflag)); */
        }

        /**
        printf("offset %d:event %d %s delta %d\n",
               startoffset, eventflag, eventName(eventflag), [mevent deltatime]);
        **/

        if (eventflag >= EventNoteOn && eventflag < EventNoteOn + 16) {
            [mevent setEventFlag:EventNoteOn];
            [mevent setChannel:(u_char)(eventflag - EventNoteOn)];
            [mevent setNotenumber:[file readByte]];
            [mevent setVelocity:[file readByte]];
        }
        else if (eventflag >= EventNoteOff && eventflag < EventNoteOff + 16) {
            [mevent setEventFlag:EventNoteOff];
            [mevent setChannel:(u_char)(eventflag - EventNoteOff)];
            [mevent setNotenumber:[file readByte]];
            [mevent setVelocity:[file readByte]];
        }
        else if (eventflag >= EventKeyPressure && 
                 eventflag < EventKeyPressure + 16) {
            [mevent setEventFlag:EventKeyPressure];
            [mevent setChannel:(u_char)(eventflag - EventKeyPressure)];
            [mevent setNotenumber:[file readByte]];
            [mevent setKeyPressure:[file readByte]];
        }
        else if (eventflag >= EventControlChange && 
                 eventflag < EventControlChange + 16) {
            [mevent setEventFlag:EventControlChange];
            [mevent setChannel:(u_char)(eventflag - EventControlChange)];
            [mevent setControlNum:[file readByte]];
            [mevent setControlValue:[file readByte]];
        }
        else if (eventflag >= EventProgramChange && 
                 eventflag < EventProgramChange + 16) {
            [mevent setEventFlag:EventProgramChange];
            [mevent setChannel:(u_char)(eventflag - EventProgramChange)];
            [mevent setInstrument:[file readByte]];
            
        }
        else if (eventflag >= EventChannelPressure && 
                 eventflag < EventChannelPressure + 16) {
            [mevent setEventFlag:EventChannelPressure];
            [mevent setChannel:(u_char)(eventflag - EventChannelPressure)];
            [mevent setChanPressure:[file readByte]];
        }
        else if (eventflag >= EventPitchBend && 
                 eventflag < EventPitchBend + 16) {
            [mevent setEventFlag:EventPitchBend];
            [mevent setChannel:(u_char)(eventflag - EventPitchBend)];
            [mevent setPitchBend:[file readShort]];
        }
        else if (eventflag == SysexEvent1) {
            [mevent setEventFlag:SysexEvent1];
            [mevent setMetalength:[file readVarlen]];
            [mevent setMetavalue:[file readBytes:[mevent metalength]] ];
        }
        else if (eventflag == SysexEvent2) {
            [mevent setEventFlag:SysexEvent2];
            [mevent setMetalength:[file readVarlen]];
            [mevent setMetavalue:[file readBytes:[mevent metalength]] ];
        }
        else if (eventflag == MetaEvent) {
            [mevent setEventFlag:MetaEvent];
            [mevent setMetaevent:[file readByte]];
            [mevent setMetalength:[file readVarlen]];
            [mevent setMetavalue:[file readBytes:[mevent metalength]] ];

            if ([mevent metaevent] == MetaEventTimeSignature) {
                if ([mevent metalength] != 4) {
                    MidiFileException *e = 
                    [MidiFileException init:@"Bad Meta Event Time Signature len" 
                      offset:[file offset]];
                    @throw e;
                }
                [mevent setNumerator:[mevent metavalue][0] ];
                u_char log2 = [mevent metavalue][1];
                [mevent setDenominator:(int)pow(2, log2)];
            }
            else if ([mevent metaevent] == MetaEventTempo) {
                if ([mevent metalength] != 3) {
                    MidiFileException *e = 
                    [MidiFileException init:@"Bad Meta Event Tempo len" 
                      offset:[file offset]];
                    @throw e;
                }
                u_char *value = [mevent metavalue];
                [mevent setTempo:((value[0] << 16) | (value[1] << 8) | value[2])];
            }
            else if ([mevent metaevent] == MetaEventEndOfTrack) {
                [mevent release];
                break; 
            }
        }
        else {
            /* printf("Unknown eventflag %d offset %d\n", eventflag, [file offset]); */
            MidiFileException *e =
                [MidiFileException init:@"Unknown event" offset:([file offset] -4)];
            @throw e;
        }
        [mevent release];
    }

    return result;
}


/** Return true if this track contains multiple channels.
 * If a MidiFile contains only one track, and it has multiple channels,
 * then we treat each channel as a separate track.
 */
+(BOOL) hasMultipleChannels:(MidiTrack*) track {
    Array *notes = [track notes];
    int channel = [(MidiNote*)[notes get:0] channel];
    for (int i =0; i < [notes count]; i++) {
        MidiNote *note = [notes get:i];
        if ([note channel] != channel) {
            return true;
        }
    }
    return false;
}


/** Calculate the track length (in bytes) given a list of Midi events */
+(int)getTrackLength:(Array*)events {
    int len = 0;
    u_char buf[1024];
    for (int i = 0; i < [events count]; i++) {
        MidiEvent *mevent = [events get:i];
        len += varlenToBytes([mevent deltaTime], buf, 0);
        len += 1;  /* for eventflag */
        switch ([mevent eventFlag]) {
            case EventNoteOn: len += 2; break;
            case EventNoteOff: len += 2; break;
            case EventKeyPressure: len += 2; break;
            case EventControlChange: len += 2; break;
            case EventProgramChange: len += 1; break;
            case EventChannelPressure: len += 1; break;
            case EventPitchBend: len += 2; break;

            case SysexEvent1:
            case SysexEvent2:
                len += varlenToBytes([mevent metalength], buf, 0);
                len += [mevent metalength];
                break;
            case MetaEvent:
                len += 1;
                len += varlenToBytes([mevent metalength], buf, 0);
                len += [mevent metalength];
                break;
            default: break;
        }
    }
    return len;
}

/** Write the given list of Midi events into a valid Midi file. This
 *  method is used for sound playback, for creating new Midi files
 *  with the tempo, transpose, etc changed.
 *
 *  Return true on success, and false on error.
 */
+(BOOL)writeMidiFile:(NSString*)filename withEvents:(Array*)eventlists
                 andMode:(int)trackmode andQuarter:(int)quarter {
    u_char buf[4096];
    const char *cfilename;
    int file, error;

    cfilename = [filename cStringUsingEncoding:NSASCIIStringEncoding];
    file = open(cfilename, O_CREAT|O_TRUNC|O_WRONLY, 0644);
    if (file < 0) {
        return NO;
    }

    error = 0;
    /* Write the MThd, len = 6, track mode, number tracks, quarter note */
    dowrite(file, (u_char*)"MThd", 4, &error);
    intToBytes(6, buf, 0);
    dowrite(file, buf, 4, &error);
    buf[0] = (u_char)(trackmode >> 8);
    buf[1] = (u_char)(trackmode & 0xFF);
    dowrite(file, buf, 2, &error);
    buf[0] = 0;
    buf[1] = (u_char)[eventlists count];
    dowrite(file, buf, 2, &error);
    buf[0] = (u_char)(quarter >> 8);
    buf[1] = (u_char)(quarter & 0xFF);
    dowrite(file, buf, 2, &error);

    for (int tracknum = 0; tracknum < [eventlists count]; tracknum++) {
        Array *events = [eventlists get:tracknum];

        /* Write the MTrk header and track length */
        dowrite(file, (u_char*)"MTrk", 4, &error);
        int len = [MidiFile getTrackLength:events];
        intToBytes(len, buf, 0);
        dowrite(file, buf, 4, &error);

        for (int i = 0; i < [events count]; i++) {
            MidiEvent *mevent = [events get:i];
            int varlen = varlenToBytes([mevent deltaTime], buf, 0);
            dowrite(file, buf, varlen, &error);

            if ([mevent eventFlag] == SysexEvent1 ||
                [mevent eventFlag] == SysexEvent2 ||
                [mevent eventFlag] == MetaEvent) {
                buf[0] = [mevent eventFlag];
            }
            else {
                buf[0] = (u_char)([mevent eventFlag] + [mevent channel]);
            }
            dowrite(file, buf, 1, &error);

            if ([mevent eventFlag] == EventNoteOn) {
                buf[0] = [mevent notenumber];
                buf[1] = [mevent velocity];
                dowrite(file, buf, 2, &error);
            }
            else if ([mevent eventFlag] == EventNoteOff) {
                buf[0] = [mevent notenumber];
                buf[1] = [mevent velocity];
                dowrite(file, buf, 2, &error);
            }
            else if ([mevent eventFlag] == EventKeyPressure) {
                buf[0] = [mevent notenumber];
                buf[1] = [mevent keyPressure];
                dowrite(file, buf, 2, &error);
            }
            else if ([mevent eventFlag] == EventControlChange) {
                buf[0] = [mevent controlNum];
                buf[1] = [mevent controlValue];
                dowrite(file, buf, 2, &error);
            }
            else if ([mevent eventFlag] == EventProgramChange) {
                buf[0] = [mevent instrument];
                dowrite(file, buf, 1, &error);
            }
            else if ([mevent eventFlag] == EventChannelPressure) {
                buf[0] = [mevent chanPressure];
                dowrite(file, buf, 1, &error);
            }
            else if ([mevent eventFlag] == EventPitchBend) {
                buf[0] = (u_char)([mevent pitchBend] >> 8);
                buf[1] = (u_char)([mevent pitchBend] & 0xFF);
                dowrite(file, buf, 2, &error);
            }
            else if ([mevent eventFlag] == SysexEvent1) {
                int offset = varlenToBytes([mevent metalength], buf, 0);
                memcpy(&(buf[offset]), [mevent metavalue], [mevent metalength]);
                dowrite(file, buf, offset + [mevent metalength], &error);
            }
            else if ([mevent eventFlag] == SysexEvent2) {
                int offset = varlenToBytes([mevent metalength], buf, 0);
                memcpy(&(buf[offset]), [mevent metavalue], [mevent metalength]);
                dowrite(file, buf, offset + [mevent metalength], &error);
            }
            else if ([mevent eventFlag] == MetaEvent &&
                     [mevent metaevent] == MetaEventTempo) {
                buf[0] = [mevent metaevent];
                buf[1] = 3;
                buf[2] = (u_char)(([mevent tempo] >> 16) & 0xFF);
                buf[3] = (u_char)(([mevent tempo] >> 8) & 0xFF);
                buf[4] = (u_char)([mevent tempo] & 0xFF);
                dowrite(file, buf, 5, &error);
            }
            else if ([mevent eventFlag] == MetaEvent) {
                buf[0] = [mevent metaevent];
                int offset = varlenToBytes([mevent metalength], buf, 1) + 1;
                memcpy(&(buf[offset]), [mevent metavalue], [mevent metalength]);
                dowrite(file, buf, offset + [mevent metalength], &error);
            }
        }
    }
    close(file);
    if (error)
        return NO;
    else
        return YES;
}


/** Clone the list of MidiEvents */
+(Array*)cloneMidiEvents:(Array*)origlist {
    Array *newlist = [Array new:[origlist count]];
    for (int tracknum = 0; tracknum < [origlist count]; tracknum++) {
        Array *origevents = [origlist get:tracknum];
        Array *newevents = [Array new:[origevents count]];
        [newlist add:newevents];
        for (int i = 0; i < [origevents count]; i++) {
            MidiEvent *mevent = [origevents get:i];
            MidiEvent *eventcopy = [mevent copy];
            [newevents add:eventcopy];
            [eventcopy release];
        }
        [newevents release];
    }
    return newlist;
}


/** Add a tempo event to the beginning of each track */
+(void) addTempoEvent:(Array*)eventlist withTempo:(int)tempo {
    for (int tracknum = 0; tracknum < [eventlist count]; tracknum++) {

        /* Create a new tempo event */
        MidiEvent *tempoEvent = [[MidiEvent alloc] init];
        [tempoEvent setDeltaTime:0];
        [tempoEvent setStartTime:0];
        [tempoEvent setHasEventflag:YES];
        [tempoEvent setEventFlag:MetaEvent];
        [tempoEvent setMetaevent:MetaEventTempo];
        [tempoEvent setMetalength:3];
        [tempoEvent setTempo:tempo];

        /* Insert the event at the beginning of the events array */
        Array *events = [eventlist get:tracknum];
        [events add:tempoEvent];
        for (int i = [events count]-2; i >= 0; i--) {
            MidiEvent *event = [events get:i];
            [events set:event index:i+1];
        }
        [events set:tempoEvent index:0];
        [tempoEvent release];
    }
}


/** Start the Midi music at the given pause time (in pulses).
 *  Remove any NoteOn/NoteOff events that occur before the pause time.
 *  For other events, change the delta-time to 0 if they occur
 *  before the pause time.  Return the modified Midi Events.
 */
+(Array*)startAtPauseTime:(int)pauseTime withEvents:(Array*)list {
    Array *newlist = [Array new:[list count]];
    for (int tracknum = 0; tracknum < [list count]; tracknum++) {
        Array *events = [list get:tracknum];
        Array *newevents = [Array new:[events count]];
        [newlist add:newevents];

        BOOL foundEventAfterPause = NO;
        for (int i = 0; i < [events count]; i++) {
            MidiEvent *mevent = [events get:i];

            if ([mevent startTime] < pauseTime) {
                if ([mevent eventFlag] == EventNoteOn ||
                    [mevent eventFlag] == EventNoteOff) {

                    /* Skip NoteOn/NoteOff event */
                }
                else {
                    [mevent setDeltaTime:0];
                    [newevents add:mevent];
                }
            }
            else if (!foundEventAfterPause) {
                [mevent setDeltaTime:([mevent startTime] - pauseTime)];
                [newevents add:mevent];
                foundEventAfterPause = YES;
            }
            else {
                [newevents add:mevent];
            }
        }
        [newevents release];
    }
    return newlist;
}


/** Change the following sound options in the Midi file:
 * - The tempo (the microseconds per pulse)
 * - The instruments per track
 * - The note number (transpose value)
 * - The tracks to include
 * Save the modified midi data to the given filename.
 * Return true if the file was saved successfully, else false.
 */
- (BOOL)changeSound:(MidiSoundOptions *)options toFile:(NSString*)destfile {
    if (trackPerChannel) {
        return [self changeSoundPerChannel:options toFile:destfile];
    }

    /* A midifile can contain tracks with notes and tracks without notes.
     * The options.tracks and options.instruments are for tracks with notes.
     * So the track numbers in 'options' may not match correctly if the
     * midi file has tracks without notes. Re-compute the instruments, and
     * tracks to keep.
     */
    int num_tracks = [events count];
    IntArray *instruments = [IntArray new:num_tracks];
    IntArray *keeptracks  = [IntArray new:num_tracks];

    for (int i = 0; i < num_tracks; i++) {
        [instruments add:0];
        [keeptracks add:YES];
    }
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        int realtrack = [track number];
        [instruments set:[options->instruments get:tracknum] index:realtrack ];
        [keeptracks set:[options->tracks get:tracknum] index:realtrack ];
    }

    Array *newevents = [MidiFile cloneMidiEvents:events];
    [MidiFile addTempoEvent:newevents withTempo:options->tempo];

    /* Change the note number (transpose), instrument, and tempo */
    for (int tracknum = 0; tracknum < [newevents count]; tracknum++) {
        Array *eventlist = [newevents get:tracknum];
        for (int i = 0; i < [eventlist count]; i++) {
            MidiEvent *mevent = [eventlist get:i];
            int num = [mevent notenumber] + options->transpose;
            if (num < 0)
                num = 0;
            if (num > 127)
                num = 127;
            [mevent setNotenumber:(u_char)num];
            if (!options->useDefaultInstruments) {
                [mevent setInstrument:(u_char)[instruments get:tracknum] ];
            }
            [mevent setTempo:options->tempo];
        }
    }

    if (options->pauseTime != 0) {
        Array *oldevents = newevents;
        newevents = [MidiFile startAtPauseTime:options->pauseTime withEvents:oldevents]; 
        [oldevents release];
    }

    /* Change the tracks to include */
    int count = 0;
    for (int tracknum = 0; tracknum < [keeptracks count]; tracknum++) {
         if ([keeptracks get:tracknum]) {
             count++;
         }
    }

    Array *result = [Array new:count];
    for (int tracknum = 0; tracknum < [keeptracks count]; tracknum++) {
        if ([keeptracks get:tracknum]) {
            [result add:[newevents get:tracknum]];
        }
    }
    [newevents release];
    [keeptracks release];
    [instruments release];
    BOOL ret = [MidiFile writeMidiFile:destfile withEvents:result
                     andMode:trackmode andQuarter:quarternote];
    [result release];
    return ret;
}



/** Change the following sound options in the Midi file:
 * - The tempo (the microseconds per pulse)
 * - The instruments per track
 * - The note number (transpose value)
 * - The tracks to include
 * Save the modified Midi data to the given filename.
 * Return true if the file was saved successfully, else false.
 *
 * This Midi file only has one actual track, but we've split that
 * into multiple fake tracks, one per channel, and displayed that
 * to the end-user.  So changing the instrument, and tracks to
 * include, is implemented differently than the ChangeSound() method:
 *
 * - We change the instrument based on the channel, not the track.
 * - We include/exclude channels, not tracks.
 * - We exclude a channel by setting the note volume/velocity to 0.
 */
- (BOOL)changeSoundPerChannel:(MidiSoundOptions *)options toFile:(NSString*)destfile {
    /* Determine which channels to include/exclude.
     * Also, determine the instrument for each channel.
     */
    IntArray *instruments = [IntArray new:16];
    IntArray *keepchannel  = [IntArray new:16];

    for (int i = 0; i < 16; i++) {
        [instruments add:0];
        [keepchannel add:YES];
    }
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        MidiNote *note = [[track notes] get:0];
        int channel = [note channel];
        [instruments set:[options->instruments get:tracknum] index:channel ];
        [keepchannel set:[options->tracks get:tracknum] index:channel ];
    }

    Array *newevents = [MidiFile cloneMidiEvents:events];
    [MidiFile addTempoEvent:newevents withTempo:options->tempo];

    /* Change the note number (transpose), instrument, and tempo */
    for (int tracknum = 0; tracknum < [newevents count]; tracknum++) {
        Array *eventlist = [newevents get:tracknum];
        for (int i = 0; i < [eventlist count]; i++) {
            MidiEvent *mevent = [eventlist get:i];
            int num = [mevent notenumber] + options->transpose;
            if (num < 0)
                num = 0;
            if (num > 127)
                num = 127;
            [mevent setNotenumber:(u_char)num];
            int channel = [mevent channel];
            if (![keepchannel get:channel]) {
                [mevent setVelocity:0];
            }
            if (!options->useDefaultInstruments) {
                u_char instr = [instruments get:channel];
                [mevent setInstrument:instr];
            }
            [mevent setTempo:options->tempo];
        }
    }
    if (options->pauseTime != 0) {
        Array *oldevents = newevents;
        newevents = [MidiFile startAtPauseTime:options->pauseTime withEvents:oldevents];
        [oldevents release];
    }
    [instruments release];
    [keepchannel release];
    BOOL ret = [MidiFile writeMidiFile:destfile withEvents:newevents
                     andMode:trackmode andQuarter:quarternote];
    [newevents release];
    return ret;
}



/** Apply the given sheet music options to the midi file.
 *  Return the midi tracks with the changes applied.
 */
- (Array*)changeSheetMusicOptions:(SheetMusicOptions*)options {
    Array *old;
    Array* newtracks = [Array new:10];

    for (int track = 0; track < [tracks count]; track++) {
        if ([options->tracks get:track]) {
            MidiTrack *t = [tracks get:track];
            MidiTrack *copy = [t copy];
            [newtracks add:copy];
            [copy release];
        }
    }

    /* To make the sheet music look nicer, we round the start times
     * so that notes close together appear as a single chord.  We
     * also extend the note durations, so that we have longer notes
     * and fewer rest symbols.
     */
    MGTimeSignature *time = [self time];
    if (options->time != nil) {
        time = options->time;
    }

    [MidiFile roundStartTimes:newtracks toInterval:options->combineInterval withTime:[self time]];
    [MidiFile roundDurations:newtracks withQuarter:[time quarter]];

    if (options->twoStaffs) {
        old = newtracks;
        newtracks = [MidiFile combineToTwoTracks:newtracks withMeasure:[time measure]];
        [old release];
    }
    if (options->shifttime != 0) {
        [MidiFile shiftTime:newtracks byAmount:options->shifttime];
    }

    if (options->transpose != 0) {
        [MidiFile transpose:newtracks byAmount:options->transpose];
    }

    return newtracks;
}


/** Shift the starttime of the notes by the given amount.
 * This is used by the Shift Notes menu to shift notes left/right.
 */
+(void)shiftTime:(Array*)tracks byAmount:(int) amount {
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        for (int j = 0; j < [[track notes] count]; j++) {
            MidiNote *note = [[track notes] get:j];
            [note setStarttime:([note startTime] + amount)];
        }
    }
}

/* Shift the note keys up/down by the given amount */
+(void)transpose:(Array*) tracks byAmount:(int) amount {
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        for (int j = 0; j < [[track notes] count]; j++) {
            MidiNote *note = [[track notes] get:j];
            [note setNumber:([note number] + amount)];
            if ([note number] < 0) {
                [note setNumber:0];
            }
        }
    }
}


/* Find the highest and lowest notes that overlap this interval (starttime to endtime).
 * This method is used by splitTrack to determine which staff (top or bottom) a note
 * should go to.
 *
 * For more accurate splitTrack() results, we limit the interval/duration of this note
 * (and other notes) to one measure. We care only about high/low notes that are
 * reasonably close to this note.
 */

+(void)findHighLowNotes:(Array*)notes withMeasure:(int)measurelen startIndex:(int)startindex
                        fromStart:(int)starttime toEnd:(int)endtime withHigh:(int*)high
                        andLow:(int*)low {

    int i = startindex;
    if (starttime + measurelen < endtime) {
        endtime = starttime + measurelen;
    }

    while (i < [notes count]) {
        MidiNote *note = [notes get:i];
        if ([note startTime] >= endtime) {
            break;
        }
        if ([note endTime] < starttime) {
            i++;
            continue;
        }
        if ([note startTime] + measurelen < starttime) {
            i++;
            continue;
        }
        if (*high < [note number]) {
            *high = [note number];
        }
        if (*low > [note number]) {
            *low = [note number];
        }
        i++;
    }
}

/* Find the highest and lowest notes that start at this exact start time */
+(void)findExactHighLowNotes:(Array*)notes startIndex:(int)startindex
                        withStart:(int)starttime withHigh:(int*)high
                        andLow:(int*)low {

    int i = startindex;

    while ([(MidiNote*)[notes get:i] startTime] < starttime) {
        i++;
    }

    while (i < [notes count]) {
        MidiNote *note = [notes get:i];
        if ([note startTime] != starttime) {
            break;
        }
        if (*high < [note number]) {
            *high = [note number];
        }
        if (*low > [note number]) {
            *low = [note number];
        }
        i++;
    }
}


/* Split the given MidiTrack into two tracks, top and bottom.
 * The highest notes will go into top, the lowest into bottom.
 * This function is used to split piano songs into left-hand (bottom)
 * and right-hand (top) tracks.
 */
+(Array*)splitTrack:(MidiTrack*) track withMeasure:(int)measurelen{
    Array *notes = [track notes];
    int notes_count = [notes count];

    MidiTrack *top = [[MidiTrack alloc] initWithTrack:1];
    MidiTrack *bottom = [[MidiTrack alloc] initWithTrack:2];
    Array* result = [Array new:2];
    [result add:top]; 
    [result add:bottom];

    if (notes_count == 0)
        return result;

    int prevhigh  = 76; /* E5, top of treble staff */
    int prevlow   = 45; /* A3, bottom of bass staff */
    int startindex = 0;

    for (int i = 0; i < notes_count; i++) {
        MidiNote *note = [notes get:i];
        int number = [note number];

        int high, low, highExact, lowExact;
        high = low = highExact = lowExact = number;

        while ([(MidiNote*)[notes get:startindex] endTime] < [note startTime]) {
            startindex++;
        }

        /* I've tried several algorithms for splitting a track in two,
         * and the one below seems to work the best:
         * - If this note is more than an octave from the high/low notes
         *   (that start exactly at this start time), choose the closest one.
         * - If this note is more than an octave from the high/low notes
         *   (in this note's time duration), choose the closest one.
         * - If the high and low notes (that start exactly at this starttime)
         *   are more than an octave apart, choose the closest note.
         * - If the high and low notes (that overlap this starttime)
         *   are more than an octave apart, choose the closest note.
         * - Else, look at the previous high/low notes that were more than an
         *   octave apart.  Choose the closeset note.
         */
        [MidiFile findHighLowNotes:notes withMeasure:measurelen startIndex:startindex
                  fromStart:[note startTime] toEnd:[note endTime]
                  withHigh:&high andLow:&low];
        [MidiFile findExactHighLowNotes:notes startIndex:startindex withStart:[note startTime]
                  withHigh:&highExact andLow:&lowExact];

        if (highExact - number > 12 || number - lowExact > 12) {
            if (highExact - number <= number - lowExact) {
                [top addNote:note];
            }
            else {
                [bottom addNote:note];
            }
        }
        else if (high - number > 12 || number - low > 12) {
            if (high - number <= number - low) {
                [top addNote:note];
            }
            else {
                [bottom addNote:note];
            }
        }
        else if (highExact - lowExact > 12) {
            if (highExact - number <= number - lowExact) {
                [top addNote:note];
            }
            else {
                [bottom addNote:note];
            }
        }
        else if (high - low > 12) {
            if (high - number <= number - low) {
                [top addNote:note];
            }
            else {
                [bottom addNote:note];
            }
        }
        else {
            if (prevhigh - number <= number - prevlow) {
                [top addNote:note];
            }
            else {
                [bottom addNote:note];
            }
        }

        /* The prevhigh/prevlow are set to the last high/low
         * that are more than an octave apart.
         */
        if (high - low > 12) {
            prevhigh = high;
            prevlow = low;
        }
    }

    [[top notes] sort:sortbytime];
    [[bottom notes] sort:sortbytime];

    [top release];
    [bottom release];
    return result;
}



/** Combine the notes in the given tracks into a single MidiTrack.
 *  The individual tracks are already sorted.  To merge them, we
 *  use a mergesort-like algorithm.
 */
+(MidiTrack*) combineToSingleTrack:(Array*)tracks {
    /* Add all notes into one track */
    MidiTrack *result = [[MidiTrack alloc] initWithTrack:1];

    if ([tracks count] == 0) {
        return result;
    }
    else if ([tracks count] == 1) {
        MidiTrack *track = [tracks get:0];
        for (int i = 0; i < [[track notes] count]; i++) {
            [result addNote:[[track notes] get:i] ];
        }
        return result;
    }

    int noteindex[64];
    int notecount[64];
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        noteindex[tracknum] = 0;
        notecount[tracknum] = [[track notes] count];
    }

    MidiNote *prevnote = nil;
    while (1) {
        MidiNote *lowestnote = nil;
        int lowestTrack = -1;
        for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
            MidiTrack *track = [tracks get:tracknum];
            if (noteindex[tracknum] >= notecount[tracknum]) {
                continue;
            }
            MidiNote *note = [[track notes] get:noteindex[tracknum]];
            if (lowestnote == nil) {
                lowestnote = note;
                lowestTrack = tracknum;
            }
            else if ([note startTime] < [lowestnote startTime]) {
                lowestnote = note;
                lowestTrack = tracknum;
            }
            else if ([note startTime] == [lowestnote startTime] &&
                     [note number] < [lowestnote number]) {
                lowestnote = note;
                lowestTrack = tracknum;
            }
        }
        if (lowestnote == nil) {
            /* We've finished the merge */
            break;
        }
        noteindex[lowestTrack]++;
        if ((prevnote != nil) && ([prevnote startTime] == [lowestnote startTime]) &&
            ([prevnote number] == [lowestnote number]) ) {

            /* Don't add duplicate notes, with the same start time and number */
            if ([lowestnote duration] > [prevnote duration]) {
                [prevnote setDuration:[lowestnote duration]];
            }
        }
        else {
            [result addNote:lowestnote];
            prevnote = lowestnote;
        }
    }

    return result;
}


/** Combine the notes in all the tracks given into two MidiTracks,
 * and return them.
 * 
 * This function is intended for piano songs, when we want to display
 * a left-hand track and a right-hand track.  The lower notes go into 
 * the left-hand track, and the higher notes go into the right hand 
 * track.
 */
+(Array*) combineToTwoTracks:(Array*) tracks withMeasure:(int)measurelen {
    MidiTrack *single = [MidiFile combineToSingleTrack:tracks];
    Array* result = [MidiFile splitTrack:single withMeasure:measurelen];
    [single release];
    return result;
}


/** Check that the MidiNote start times are in increasing order.
 * This is for debugging purposes.
 */
+(void)checkStartTimes:(Array*) tracks {
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        int prevtime = -1;
        for (int j = 0; j < [[track notes] count]; j++) {
            MidiNote *note = [[track notes] get:j];
            assert([note startTime] >= prevtime);
            prevtime = [note startTime];
        }
    }
}


/** In Midi Files, time is measured in pulses.  Notes that have
 * pulse times that are close together (like within 10 pulses)
 * will sound like they're the same chord.  We want to draw
 * these notes as a single chord, it makes the sheet music much
 * easier to read.  We don't want to draw notes that are close
 * together as two separate chords.
 *
 * The SymbolSpacing class only aligns notes that have exactly the same
 * start times.  Notes with slightly different start times will
 * appear in separate vertical columns.  This isn't what we want.
 * We want to align notes with approximately the same start times.
 * So, this function is used to assign the same starttime for notes
 * that are close together (timewise).
 */
+(void)roundStartTimes:(Array*)tracks toInterval:(int)millisec withTime:(MGTimeSignature*)time {
    /* Get all the starttimes in all tracks, in sorted order */
    int initsize = 1;
    if ([tracks count] > 0) {
        initsize = [[ (MidiTrack*)[tracks get:0] notes] count];
        initsize = initsize * [tracks count]/2;
    }
    IntArray*  starttimes = [IntArray new:initsize];
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        for (int j = 0; j < [[track notes] count]; j++) {
            MidiNote *note = [[track notes] get:j];
            [starttimes add:[note startTime]];
        }
    }
    [starttimes sort];

    /* Notes within "millisec" milliseconds apart should be combined */
    int interval = [time quarter] * millisec * 1000 / [time tempo];

    /* If two starttimes are within interval millisec, make them the same */
    for (int i = 0; i < [starttimes count] - 1; i++) {
        if ([starttimes get:(i+1)] - [starttimes get:i] <= interval) {
            [starttimes set:[starttimes get:i] index:(i+1)];
        }
    }

    [MidiFile checkStartTimes:tracks];

    /* Adjust the note starttimes, so that it matches one of the starttimes values */
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        int i = 0;

        for (int j = 0; j < [[track notes] count]; j++) {
            MidiNote *note = [[track notes] get:j];
            while (i < [starttimes count] &&
                   [note startTime] - interval > [starttimes get:i]) {
                i++;
            }

            if ([note startTime] > [starttimes get:i] &&
                [note startTime] - [starttimes get:i] <= interval) {

                [note setStarttime:[starttimes get:i]];
            }
        }
        [[track notes] sort:sortbytime];
    }
    [starttimes release];
}


/** We want note durations to span up to the next note in general.
 * The sheet music looks nicer that way.  In contrast, sheet music
 * with lots of 16th/32nd notes separated by small rests doesn't
 * look as nice.  Having nice looking sheet music is more important
 * than faithfully representing the Midi File data.
 *
 * Therefore, this function rounds the duration of MidiNotes up to
 * the next note where possible.
 */
+(void)roundDurations:(Array*)tracks withQuarter:(int) quarternote {
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        MidiNote *prevNote = nil;

        for (int i = 0; i < [[track notes] count]; i++) {
            MidiNote *note1 = [[track notes] get:i];

            /* Get the next note that has a different start time */
            MidiNote *note2 = note1;
            for (int j = i+1; j < [[track notes] count]; j++) {
                note2 = [[track notes] get:j];
                if ([note1 startTime] < [note2 startTime]) {
                    break;
                }
            }
            int maxduration = [note2 startTime] - [note1 startTime];

            int dur = 0;
            if (quarternote <= maxduration)
                dur = quarternote;
            else if (quarternote/2 <= maxduration)
                dur = quarternote/2;
            else if (quarternote/3 <= maxduration)
                dur = quarternote/3;
            else if (quarternote/4 <= maxduration)
                dur = quarternote/4;


            if (dur < [note1 duration]) {
                dur = [note1 duration];
            }

            /* Special case: If the previous note's duration
             * matches this note's duration, we can make a notepair.
             * So don't expand the duration in that case.
             */
            if (prevNote != nil && [prevNote startTime] < [note1 startTime] &&
                [prevNote duration] == [note1 duration] &&
                ([note1 startTime] % quarternote != 0)) {

                dur = [note1 duration];
            }
            [note1 setDuration:dur];
            prevNote = note1;
        }
    }
}

/** Split the given track into multiple tracks, separating each
 * channel into a separate track.
 */
+(Array*) splitChannels:(MidiTrack*) origtrack withEvents:(Array*)events {

    /* Find the instrument used for each channel */
    IntArray* channelInstruments = [IntArray new:16];
    for (int i =0; i < 16; i++) {
        [channelInstruments add:0];
    }
    for (int i = 0; i < [events count]; i++) {
        MidiEvent *mevent = [events get:i];
        if ([mevent eventFlag] == EventProgramChange) {
            [channelInstruments set:[mevent instrument] index:[mevent channel]];
        }
    }
    [channelInstruments set:128 index:9]; /* Channel 9 = Percussion */

    Array *result = [Array new:2];
    for (int i = 0; i < [[origtrack notes] count]; i++) {
        MidiNote *note = [[origtrack notes] get:i];
        BOOL foundchannel = FALSE;
        for (int tracknum = 0; tracknum < [result count]; tracknum++) {
            MidiTrack *track = [result get:tracknum];
            if ([note channel] == [(MidiNote*)[[track notes] get:0] channel]) {
                foundchannel = TRUE;
                [track addNote:note];
            }
        }
        if (!foundchannel) {
            MidiTrack* track = [[MidiTrack alloc] initWithTrack:([result count] + 1)];
            [track addNote:note];
            int instrument = [channelInstruments get:[note channel]];
            [track setInstrument:instrument];
            [result add:track];
            [track release];
        }
    }
    return result;
}


/** Guess the measure length.  We assume that the measure
 * length must be between 0.5 seconds and 4 seconds.
 * Take all the note start times that fall between 0.5 and 
 * 4 seconds, and return the starttimes.
 */
- (IntArray*)guessMeasureLength {
    IntArray *result = [IntArray new:30];

    int pulses_per_second = (int) (1000000.0 / [timesig tempo] * [timesig quarter]);
    int minmeasure = pulses_per_second / 2; /* The minimum measure length in pulses */
    int maxmeasure = pulses_per_second * 4; /* The maximum measure length in pulses */

    /* Get the start time of the first note in the midi file. */
    int firstnote = [timesig measure] * 5;
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        if (firstnote > [(MidiNote*)[[track notes] get:0] startTime] ) {
            firstnote = [(MidiNote*)[[track notes] get:0] startTime];
        }
    }

    /* interval = 0.06 seconds, converted into pulses */
    int interval = [timesig quarter] * 60000 / [timesig tempo];

    for (int i = 0; i < [tracks count]; i++) {
        MidiTrack *track = [tracks get:i];
        int prevtime = 0;

        for (int j = 0; j < [[track notes] count]; j++) {
            MidiNote *note = [[track notes] get:j];
            if ([note startTime] - prevtime <= interval)
                continue;

            prevtime = [note startTime];
            int time_from_firstnote = [note startTime] - firstnote;

            /* Round the time down to a multiple of 4 */
            time_from_firstnote = time_from_firstnote / 4 * 4;
            if (time_from_firstnote < minmeasure)
                continue;
            if (time_from_firstnote > maxmeasure)
                break;

            if (![result contains:time_from_firstnote]) {
                [result add:time_from_firstnote];
            }
        }
    }
    [result sort];
    return result;
}

/* The Program Change event gives the instrument that should
 * be used for a particular channel.  The following table
 * maps each instrument number (0 thru 128) to an instrument
 * name.
 */
static NSArray* instrNames = NULL;
+(NSArray*)instrumentNames {
    if (instrNames == NULL) {
        instrNames = [NSArray arrayWithObjects:
            @"Acoustic Grand Piano",
            @"Bright Acoustic Piano",
            @"Electric Grand Piano",
            @"Honky-tonk Piano",
            @"Electric Piano 1",
            @"Electric Piano 2",
            @"Harpsichord",
            @"Clavi",
            @"Celesta",
            @"Glockenspiel",
            @"Music Box",
            @"Vibraphone",
            @"Marimba",
            @"Xylophone",
            @"Tubular Bells",
            @"Dulcimer",
            @"Drawbar Organ",
            @"Percussive Organ",
            @"Rock Organ",
            @"Church Organ",
            @"Reed Organ",
            @"Accordion",
            @"Harmonica",
            @"Tango Accordion",
            @"Acoustic Guitar (nylon)",
            @"Acoustic Guitar (steel)",
            @"Electric Guitar (jazz)",
            @"Electric Guitar (clean)",
            @"Electric Guitar (muted)",
            @"Overdriven Guitar",
            @"Distortion Guitar",
            @"Guitar harmonics",
            @"Acoustic Bass",
            @"Electric Bass (finger)",
            @"Electric Bass (pick)",
            @"Fretless Bass",
            @"Slap Bass 1",
            @"Slap Bass 2",
            @"Synth Bass 1",
            @"Synth Bass 2",
            @"Violin",
            @"Viola",
            @"Cello",
            @"Contrabass",
            @"Tremolo Strings",
            @"Pizzicato Strings",
            @"Orchestral Harp",
            @"Timpani",
            @"String Ensemble 1",
            @"String Ensemble 2",
            @"SynthStrings 1",
            @"SynthStrings 2",
            @"Choir Aahs",
            @"Voice Oohs",
            @"Synth Voice",
            @"Orchestra Hit",
            @"Trumpet",
            @"Trombone",
            @"Tuba",
            @"Muted Trumpet",
            @"French Horn",
            @"Brass Section",
            @"SynthBrass 1",
            @"SynthBrass 2",
            @"Soprano Sax",
            @"Alto Sax",
            @"Tenor Sax",
            @"Baritone Sax",
            @"Oboe",
            @"English Horn",
            @"Bassoon",
            @"Clarinet",
            @"Piccolo",
            @"Flute",
            @"Recorder",
            @"Pan Flute",
            @"Blown Bottle",
            @"Shakuhachi",
            @"Whistle",
            @"Ocarina",
            @"Lead 1 (square)",
            @"Lead 2 (sawtooth)",
            @"Lead 3 (calliope)",
            @"Lead 4 (chiff)",
            @"Lead 5 (charang)",
            @"Lead 6 (voice)",
            @"Lead 7 (fifths)",
            @"Lead 8 (bass + lead)",
            @"Pad 1 (new age)",
            @"Pad 2 (warm)",
            @"Pad 3 (polysynth)",
            @"Pad 4 (choir)",
            @"Pad 5 (bowed)",
            @"Pad 6 (metallic)",
            @"Pad 7 (halo)",
            @"Pad 8 (sweep)",
            @"FX 1 (rain)",
            @"FX 2 (soundtrack)",
            @"FX 3 (crystal)",
            @"FX 4 (atmosphere)",
            @"FX 5 (brightness)",
            @"FX 6 (goblins)",
            @"FX 7 (echoes)",
            @"FX 8 (sci-fi)",
            @"Sitar",
            @"Banjo",
            @"Shamisen",
            @"Koto",
            @"Kalimba",
            @"Bag pipe",
            @"Fiddle",
            @"Shanai",
            @"Tinkle Bell",
            @"Agogo",
            @"Steel Drums",
            @"Woodblock",
            @"Taiko Drum",
            @"Melodic Tom",
            @"Synth Drum",
            @"Reverse Cymbal",
            @"Guitar Fret Noise",
            @"Breath Noise",
            @"Seashore",
            @"Bird Tweet",
            @"Telephone Ring",
            @"Helicopter",
            @"Applause",
            @"Gunshot",
            @"Percussion",
            nil
        ];
    }
    instrNames = [instrNames retain];
    return instrNames;
}


- (NSString*)description {
    NSString *s = [NSString stringWithFormat:
                     @"Midi File tracks=%d quarter=%d %@\n",
                     [tracks count], quarternote, [timesig description]];
    for (int i = 0; i < [tracks count]; i++) {
        MidiTrack *track = [tracks get:i];
        s = [s stringByAppendingString:[track description]];
    }
    return s;
}

@end /* class MidiFile */

/* Command-line program to print out a parsed Midi file. Used for debugging. */
int main2(int argc, char **argv)
{
    if (argc == 1) {
        printf("Usage: MidiFile <filename>\n");
        return 0;
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSString *filename = 
      [NSString stringWithCString:argv[1] encoding:NSASCIIStringEncoding];
    MidiFile *f = [[MidiFile alloc] initWithFile:filename];
    NSString *output = [f description];
    const char *out = [output cStringUsingEncoding:NSASCIIStringEncoding];
    printf("%s\n", out);
    return 0;
}



