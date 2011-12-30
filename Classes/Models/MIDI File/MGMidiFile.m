//
//  MGMidiFile.m
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 12/29/11.
//  Copyright (c) 2011 Princeton University. All rights reserved.
//

#import "MGMidiFile.h"
//currently in h file#import "MidiFile.h"

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
@implementation MGMidiFile
@synthesize filename    = _filename;
@synthesize events      = _events;
@synthesize tracks      = _tracks;
@synthesize timeSignature = timeSignature;

- (void)dealloc {
    [self.filename release];
    [self.tracks release];
    [self.timeSignature release];
    [self.events release];
    [super dealloc];
}



/** Parse the given Midi file, and return an instance of this MGMidiFile
 * class.  After reading the midi file, this object will contain:
 * - The raw list of midi events
 * - The Time Signature of the song
 * - All the tracks in the song which contain notes. 
 * - The number, starttime, and duration of each note.
 
 Uses MidiFileReader to parse midi files.
 */
- (id)initWithFile:(NSString*)path {
    const char *hdr;
    int len;
    
    self.filename = [path retain];
    self.tracks = [[NSMutableArray alloc]initWithCapacity:5]; //seems to be random initialization number
    trackPerChannel = NO;
    
    MidiFileReader *file = [[MidiFileReader alloc] initWithFile:self.filename];
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
    
    self.events = [[NSMutableArray alloc ]initWithCapacity:num_tracks];
    for (int tracknum = 0; tracknum < num_tracks; tracknum++) {
        Array *trackevents = [self readTrack:file];
        MidiTrack *track = 
        [[MidiTrack alloc] initWithEvents:trackevents andTrack:tracknum];
        [self.events addObject:trackevents];
        [trackevents release];
        [track setNumber:tracknum];
        if ([[track notes] count] > 0) {
            [self.tracks addObject:track];
        }
        [track release];
    }
    
    /* Get the length of the song in pulses */
    for (int tracknum = 0; tracknum < [self.tracks count]; tracknum++) {
        MidiTrack *track = [self.tracks objectAtIndex:tracknum];
        MidiNote *last = [[track notes] get:([[track notes] count] -1) ];
        if (totalpulses < [last startTime] + [last duration]) {
            totalpulses = [last startTime] + [last duration];
        }
    }
    
    /* If we only have one track with multiple channels, then treat
     * each channel as a separate track.
     */
    if ([self.tracks count] == 1 && [MidiFile hasMultipleChannels:[self.tracks objectAtIndex:0]]) {
       
        Array *trackevents = [self.events objectAtIndex:[[self.tracks objectAtIndex:0] number] ];
        NSMutableArray* newtracks = (NSMutableArray *)[MidiFile splitChannels:[self.tracks objectAtIndex:0] 
                                                                   withEvents:trackevents];
        trackPerChannel = YES;
        [self.tracks release];
        self.tracks = newtracks;
    }
    
    //[MidiFile checkStartTimes:self.tracks]; /*Add in function later
    
    /* Determine the time signature */
    int tempo = 0;
    int numer = 0;
    int denom = 0;
    for (int tracknum = 0; tracknum < [self.events count]; tracknum++) {
        Array *eventlist = [self.events objectAtIndex:tracknum];
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
        numer = 4; denom = 4; /* Default to common time */
    }
    self.timeSignature = [[MGTimeSignature alloc] initWithNumerator:numer
                                                     andDenominator:denom
                                                         andQuarter:quarternote
                                                           andTempo:tempo];
    
    
    [file release];
    return self;
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




@end
