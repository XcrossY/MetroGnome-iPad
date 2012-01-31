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
@synthesize image           = _image;
@synthesize imageCenter     = _imagecenter;


-(void)dealloc {
    [self.image release];
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


-(id)initWithPitchClass:(NSInteger)pitchClass {
    if (self = [super init]) {
        if (pitchClass < 0 || pitchClass >= PITCH_CLASS_TOTAL) {
            NSLog(@"Attempted illegal pitch class");
            return nil;
        }
        else {
            self.pitchClass = pitchClass;
        }
    }
    return self;
}


//Inits appropriate image
-(void)initImageWithValue:(NoteDuration)value {
    if (value == Whole) self.image = [[UIImageView alloc]initWithImage:[UIImage  imageNamed:@"WholeNote.png"]];
    else if (value == DottedHalf) self.image = [[UIImageView alloc]initWithImage:[UIImage  imageNamed:@"DottedHalfNote.png"]];
    else if (value == Half) self.image = [[UIImageView alloc]initWithImage:[UIImage  imageNamed:@"HalfNote.png"]];
    else if (value == DottedQuarter) self.image = [[UIImageView alloc]initWithImage:[UIImage  imageNamed:@"DottedQuarterNote.png"]];
    else if (value == Quarter) self.image = [[UIImageView alloc]initWithImage:[UIImage  imageNamed:@"QuarterNote.png"]];
    else if (value == DottedEighth) self.image = [[UIImageView alloc]initWithImage:[UIImage  imageNamed:@"DottedEighthNote.png"]];
    else if (value == Eighth) self.image = [[UIImageView alloc]initWithImage:[UIImage  imageNamed:@"EighthNOte.png"]];
    else if (value == Triplet) self.image = [[UIImageView alloc]initWithImage:[UIImage  imageNamed:@"TripletNote.png"]];
    else if (value == Sixteenth) self.image = [[UIImageView alloc]initWithImage:[UIImage  imageNamed:@"SixteenthNote.png"]];
    else if (value == ThirtySecond) self.image = [[UIImageView alloc]initWithImage:[UIImage  imageNamed:@"ThirtySecondNote.png"]];
    else NSLog(@"MGNote: attempted to init image of unsupported value");
    
}

/** Initializes image of note and sets position */
-(void)displayAtPosition:(CGPoint)position {

    if (self.image == NULL) {
        NSLog(@"MGNote: tried to display note w/out image");
        return;
    }
    self.image.center = position; //Make specific to each image
}

//Plays a single note (not a chord)
/*-(void)play:(HSTREAM)stream {
    if (self != nil) {
        [self noteOn:stream];
        NSDate * NoteOnTime = [NSDate date];
        [NSThread sleepForTimeInterval:self.duration];
        
        //[NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(noteOffTimer:)
                                       userInfo:nil
                                        repeats:NO];*/
        /*[self noteOff:stream];
        NSDate *NoteOffTime = [NSDate date];
        
        NSLog(@"Note length: %f",[NoteOffTime timeIntervalSinceDate:NoteOnTime]);
    }
}*/

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
