//
//  MGScore.m
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 12/20/11.
//  Copyright (c) 2011 Princeton University. All rights reserved.
//

#import "MGScore.h"

@implementation MGScore
@synthesize fileName        = _fileName;
@synthesize partsArray      = _partsArray;
@synthesize timeSignature   = _timeSignature;
@synthesize trackMode       = _trackMode;
@synthesize quarterNote     = _quarterNote;
@synthesize totalPulses     = _totalPulses;

#pragma mark 
#pragma mark Initialization
-(void)dealloc {
    [self.partsArray release];
    [super dealloc];   
}

//The number of notes/chords.
-(id)initWithCapacity:(NSInteger)capacity 
     andTimeSignature:(MGTimeSignature *)timeSignature {
    if (self = [super init]) {
        if (capacity == 0) {
            capacity = 1;
        }
        
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

-(id)initWithMidiFile: (MidiFile *)midiFile {
    if (self = [super init]) {
        self.fileName = [midiFile filename];
        self.timeSignature = [midiFile timesig];
        self.totalPulses = [midiFile totalpulses];
        self.quarterNote = [midiFile quarternote];
        self.trackMode = [midiFile trackmode];
        self.partsArray = [[NSMutableArray alloc]initWithCapacity:1];
        
        for (int i = 0; i < [[midiFile events] count]; i++) {
            Array *trackArray = [[midiFile events] get:i];
            MGPart *part = [[MGPart alloc]initWithMidiEventArray:trackArray];
            
            //If part is legitimate, add to score
            if (part != nil && [part.notesArray count] != 0) {
                [self.partsArray addObject:part];
                
                //Once part is added, go through and modify
                for (int j = 0; j < [part.notesArray count]; j++) {
                    MGNote *note = [part.notesArray objectAtIndex:j];
                    note.measureNumber = 
                        [self.timeSignature getMeasureForTime:note.startTime];
                }
            }
        }  
    }
    return self;
}

//Check to make sure this doesn't double init
-(id)initWithFileName: (NSString *)fileName {
        MidiFile *midiFile = [[MidiFile alloc]initWithFile:fileName];
        return [self initWithMidiFile:midiFile];
}

#pragma mark
#pragma mark Methods

-(void)add:(MGPart *)part {
    [self.partsArray addObject:part];
}

/** Returns total number of measures in the score */
-(int)totalMeasures {
    return [self.timeSignature getMeasureForTime:self.totalPulses];
}



@end
