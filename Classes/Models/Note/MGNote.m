//
//  MGNote.m
//  MetroGnomeiPad
//
//  Created by Zander on 9/28/11.
//  Copyright 2011 MetroGnome, LLC. All rights reserved.
//

#import "MGNote.h"
#import "bassmidi.h"

@interface MGNote (Private)
-(BOOL)checkBASSError;
@end


@implementation MGNote
@synthesize pitchClass      = _pitchClass;
@synthesize octave          = _octave;
@synthesize duration        = _duration;
@synthesize startTime       = _startTime;
@synthesize velocity        = _velocity;
@synthesize measureNumber   = _measureNumber;

-(void)dealloc {
    [super dealloc];
}

/*
-(id)initWithPitchClass:(NSInteger)pitchClass
                 octave:(NSInteger)octave
               duration:(NSInteger)duration {
    if (self = [super init]) {
        if (pitchClass >= PITCH_CLASS_TOTAL) {
            self.pitchClass = pitchClass - PITCH_CLASS_TOTAL;
            self.octave     = octave + 1;
            self.duration   = duration;
        }
        else if (pitchClass < 0) {
            NSLog(@"Attempted negative pitch class");
            return nil;
        }
        else {
            self.pitchClass = pitchClass;
            self.octave     = octave;
            self.duration   = duration;
        }
    }
    return self;
}*/

-(id)initWithMidiEvent:(MidiEvent *)midiEvent {
    if (self = [super init]) {
        //EventNoteOn triggers creation of MGNote
        if ([midiEvent eventFlag] == EventNoteOn && [midiEvent velocity] >= 0) {
            self.startTime = [midiEvent startTime];
            self.pitchClass = [midiEvent notenumber] % 12;
            self.octave = ([midiEvent notenumber] / 12) + 1;
            self.velocity = [midiEvent velocity];
            self.duration = 0; //Will be modified upon NoteOff event
        }
        /*else if ([mevent eventFlag] == EventProgramChange) {
            instrument = [mevent instrument];
        }*/
        else NSLog(@"MGNote: Failed initWithMidiEvent:");   
    }
    return self;
}

//Plays a single note (not a chord)
-(void)play:(HSTREAM)stream {
    if (self != nil) {
        [self noteOn:stream];
        NSDate * NoteOnTime = [NSDate date];
        [NSThread sleepForTimeInterval:self.duration];
        
        /*[NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(noteOffTimer:)
                                       userInfo:nil
                                        repeats:NO];*/
        [self noteOff:stream];
        NSDate *NoteOffTime = [NSDate date];
        
        NSLog(@"Note length: %f",[NoteOffTime timeIntervalSinceDate:NoteOnTime]);
    }
}

 /*
-(void)play:(HSTREAM)stream {
    if (self != nil) {
        BASS_MIDI_StreamEvent(stream, 0, MIDI_EVENT_ATTACK, MAKEWORD([self MIDIValue], 100));
        if ([self checkBASSError]) {
            NSLog(@"Failed attack");
        }
     }
 }
*/



-(MGNote *)ascendingInterval:(NSInteger)interval {
    MGNote *newNote = [[MGNote alloc]init];
    if (self.pitchClass + interval >= PITCH_CLASS_TOTAL) {
        newNote.pitchClass  = self.pitchClass + interval - PITCH_CLASS_TOTAL;
        newNote.octave      = self.octave + 1;
        
    } else {
        newNote.pitchClass  = self.pitchClass + interval;
        newNote.octave      = self.octave;
    }
    newNote.duration = self.duration;
    
    return [newNote autorelease];      
}



#pragma mark -
#pragma mark Private

//Sends "note on" MIDI signal to BASS
-(void)noteOn:(HSTREAM)stream {    
    BASS_MIDI_StreamEvent(stream, 0, MIDI_EVENT_NOTE, MAKEWORD([self MIDIValue], 100));
    if ([self checkBASSError]) {
        NSLog(@"Failed attack");
    }
}

//Sends "note off" MIDI signal to BASS
-(void)noteOff:(HSTREAM)stream {    
    BASS_MIDI_StreamEvent(stream, 0, MIDI_EVENT_NOTE, [self MIDIValue]);
    if ([self checkBASSError]) {
        NSLog(@"Failed attack");
    }
}

-(BOOL)checkBASSError {
    int error = BASS_ErrorGetCode();
    if (error != 0) {
        NSLog(@"BASS Error %i in MGNote", error);
        return TRUE;
    }
    return FALSE;
}

//Octave numbering following C4 convention
-(NSInteger)MIDIValue {
    return 12 * (self.octave + 1) + self.pitchClass;
}


@end
