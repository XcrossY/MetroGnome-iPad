//
//  MGPart.h
//  MetroGnomeiPad
//
//  Created by Zander on 10/8/11.
//  Copyright 2011 MetroGnome, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGChord.h"
#import "MGTimeSignature.h"

/* A part contains a string of notes/chords. It is a single instrument. */
@interface MGPart : NSObject {
    NSMutableArray *_notesArray;
    MGTimeSignature *_timeSignature;
    //track number?
}
@property(nonatomic,assign) NSMutableArray *notesArray;
@property(nonatomic,assign) MGTimeSignature *timeSignature;

//Initialization functions
-(id)initWithCapacity: (NSInteger)capacity
     andTimeSignature: (MGTimeSignature *)timeSignature;
-(id)initWithCapacity: (NSInteger)capacity;
-(id)initWithTimeSignature:(MGTimeSignature *)timeSignature;
-(id)initWithMidiEventArray:(Array *)array;

-(void)add:             (void*) chord;
-(MGNote *)getNote:     (NSInteger)index; 
//-(void)play:            (HSTREAM)astream; 
-(NSInteger)count;



@end
