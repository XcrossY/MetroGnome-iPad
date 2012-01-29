//
//  MGPart.m
//  MetroGnomeiPad
//
//  Created by Zander on 10/8/11.
//  Copyright 2011 MetroGnome, LLC. All rights reserved.
//

#import "MGPart.h"
#import "MGNote.h"
#import "MidiFile.h"

@interface MGPart (Private)
-(void)noteOffMidiEvent:(MidiEvent *)midiEvent;
@end

@implementation MGPart
@synthesize notesArray    = _notesArray;
@synthesize timeSignature = _timeSignature;

#pragma mark 
#pragma mark Initialization
-(void)dealloc {
    //autoreleased? [array release];
    [super dealloc];   
}

//The number of notes/chords.
-(id)initWithCapacity:(NSInteger)capacity 
     andTimeSignature:(MGTimeSignature *)timeSignature {
    
    if (self = [super init]) {
       self.notesArray = [[NSMutableArray alloc]initWithCapacity:1]; 
        if (capacity == 0) {
            capacity = 1;
        }
        self.notesArray = [NSMutableArray arrayWithCapacity:capacity];
        
        if (timeSignature == nil) {
            self.timeSignature = [MGTimeSignature commonTime];
        }
        else {
            self.timeSignature = timeSignature;
        }
    }
    return self;
}

-(id)initWithCapacity:(NSInteger)capacity {
    return [self initWithCapacity:capacity andTimeSignature:nil];
}

-(id)initWithTimeSignature:(MGTimeSignature *)timeSignature {
    return [self initWithCapacity:0 andTimeSignature:timeSignature];
}

/** Adds MidiNotes for every MidiEvent */
-(id)initWithMidiEventArray:(Array *)eventArray {
    if (self = [super init]) {
        self.notesArray = [[NSMutableArray alloc]initWithCapacity:0];
        for (int i = 0; i < [eventArray count]; i++) {
            MidiEvent *midiEvent = [eventArray get:i];
            if ([midiEvent eventFlag] == EventNoteOn && [midiEvent velocity] >= 0)
            {
                //Init note and add to part
                MGNote *note = [[MGNote alloc]initWithMidiEvent:midiEvent];
                [self.notesArray addObject:note];
            }
            else if ([midiEvent eventFlag] == EventNoteOff) {
                [self noteOffMidiEvent:midiEvent];
            }
        }
    }

    return self;
}

-(void)noteOffMidiEvent:(MidiEvent *)midiEvent {
    if ([midiEvent eventFlag] != EventNoteOff) {
        NSLog(@"noteOffMidiEvent: attempted with incorrect midiEvent");
        return;
    }
    
    for (int i = [self.notesArray count]-1; i >= 0; i--) {
        MGNote* note = [self.notesArray objectAtIndex:i];
        if ([note MIDIValue] == [midiEvent notenumber] && note.duration == 0) {
            note.duration = [midiEvent startTime] - note.startTime;
            return;
        }
    }
}

#pragma mark
#pragma mark Methods

//Play the entire part
//-(void)play:(HSTREAM)astream{
//    for (int i=0; i<[self count]; i++) {
//        MGNote *note = [self getNote:i];
//        note.duration = self.timeSignature.tempo * note.duration / BEATS_PER_MIN;
//        [note play:astream];
//    }
//}



-(void)add:(void *)notes {
    [self.notesArray addObject:notes];
}

-(void)addChord:(MGChord *)chord {
    [self.notesArray addObject:chord];
}


-(MGNote *)getNote:(NSInteger)index {
    assert(index >= 0 && index < [self.notesArray count]);
    return [self.notesArray objectAtIndex:index];
}


-(NSInteger)count {
    return [self.notesArray count];
}    


@end
