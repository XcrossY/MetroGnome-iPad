//
//  MGScore.m
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 12/20/11.
//  Copyright (c) 2011 Princeton University. All rights reserved.
//

#import "MGScore.h"
#import "MGNote.h"

@implementation MGScore
@synthesize fileName        = _fileName;
@synthesize partsArray      = _partsArray;
@synthesize timeSignature   = _timeSignature;
@synthesize keySignature    = _keySignature;
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
        
        //Go through each track. Tracks --> Parts
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
        
        //Determine key signature
        self.keySignature = [self findKeySignature];
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

/** Calculates key signature */
-(MGKeySignature *)findKeySignature {
    /** Should only need one part. May need to modify to check every
    part and pick most common determined key signature*/
    MGPart *part = [self.partsArray objectAtIndex:0];
    
    
    /** Current method only looks for number of accidentals. 
     Can be made more sophisticated */
    
    /** Creating variables to track num of accidentals*/
    int numAccidentals = 6;
    IntArray *sharpArray = [[IntArray alloc]initWithCapacity:numAccidentals];
    IntArray *flatArray = [[IntArray alloc]initWithCapacity:numAccidentals];
    for (int i = 0; i < numAccidentals; i++) {
        [sharpArray add:0];
        [flatArray add:0];
    }
    /** Record all accidentals. Weight importance based
     on rhythmic value, i.e. probability of chordal 
     vs. passing tone */
    for (int i = 0; i < [part.notesArray count]; i++) {
        MGNote *note = [part.notesArray objectAtIndex:i];
        if (note.pitchClass == PITCH_CLASS_Fsharp) {
            int num = [sharpArray get:0];
            [sharpArray set:num++ index:0];
        }
        else if (note.pitchClass == PITCH_CLASS_Csharp) {
            int num = [sharpArray get:1];
            [sharpArray set:num++ index:1];
        }
        else if (note.pitchClass == PITCH_CLASS_Gsharp) {
            int num = [sharpArray get:2];
            [sharpArray set:num++ index:2];
        }
        else if (note.pitchClass == PITCH_CLASS_Dsharp) {
            int num = [sharpArray get:3];
            [sharpArray set:num++ index:3];
        }
        else if (note.pitchClass == PITCH_CLASS_Asharp) {
            int num = [sharpArray get:4];
            [sharpArray set:num++ index:4];
        }
        else if (note.pitchClass == PITCH_CLASS_Esharp) {
            //this one is more tricky, as F's are much more common
            //int num = [sharpArray get:5];
            //[sharpArray set:num++ index:5];
        }
        else if (note.pitchClass == PITCH_CLASS_Bflat) {
            int num = [flatArray get:0];
            [flatArray set:num++ index:0];
        }
        else if (note.pitchClass == PITCH_CLASS_Eflat) {
            int num = [flatArray get:1];
            [flatArray set:num++ index:1];
        }
        else if (note.pitchClass == PITCH_CLASS_Aflat) {
            int num = [flatArray get:2];
            [flatArray set:num++ index:2];
        }
        else if (note.pitchClass == PITCH_CLASS_Dflat) {
            int num = [flatArray get:3];
            [flatArray set:num++ index:3];
        }
        else if (note.pitchClass == PITCH_CLASS_Gflat) {
            int num = [flatArray get:4];
            [flatArray set:num++ index:4];
        }
    }
        
        /** Determine which tonic of relative major scale */
        MGNote *tonic = [MGNote alloc];
        if ([sharpArray maximum] == 0 && [flatArray maximum] == 0) {
           [tonic initWithPitchClass:PITCH_CLASS_C]; 
        }
        //If relatively few sharps and flats
        else if ([sharpArray totalValue] < ([part.notesArray count] / 10 ) && [flatArray totalValue] < ([part.notesArray count] / 10 )) {
            [tonic initWithPitchClass:PITCH_CLASS_C]; 
        }
        else if ([sharpArray maximum] > [flatArray maximum]) {
            int index = [sharpArray indexOfMaximum];
            if (index == 0) {
                [tonic initWithPitchClass:PITCH_CLASS_G];
            }
            else if (index == 1) {
               [tonic initWithPitchClass:PITCH_CLASS_D];
            }
            else if (index == 2) {
                [tonic initWithPitchClass:PITCH_CLASS_A];
            }
            else if (index == 3) {
                [tonic initWithPitchClass:PITCH_CLASS_E];
            }
            else if (index == 4) {
               [tonic initWithPitchClass:PITCH_CLASS_B];
            }
        }
        else if ([sharpArray maximum] < [flatArray maximum]) {
            int index = [flatArray indexOfMaximum];
            if (index == 0) {
                [tonic initWithPitchClass:PITCH_CLASS_F];
            }
            else if (index == 1) {
                [tonic initWithPitchClass:PITCH_CLASS_Bflat];
            }
            else if (index == 2) {
                [tonic initWithPitchClass:PITCH_CLASS_Eflat];
            }
            else if (index == 3) {
                [tonic initWithPitchClass:PITCH_CLASS_Aflat];
            }
            else if (index == 4) {
                [tonic initWithPitchClass:PITCH_CLASS_Gflat];
            }
        }
        else NSLog(@"MGScore: inconclusive key signature");
        
        MGKeySignature *keySignature = [[MGKeySignature alloc]initMajorWithTonic:tonic];
        [tonic release];
        [sharpArray release];
        [flatArray release];
        
        /** Check first and last chords of piece to 
         determine major of minor */
        
    return keySignature;
}



@end
