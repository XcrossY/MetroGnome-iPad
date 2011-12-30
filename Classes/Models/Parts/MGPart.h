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

/* A part contains a string of notes/chords. It is a single instrument,
 voice, or piano (one or both hands) */
@interface MGPart : NSObject {
    NSMutableArray *array;
    HSTREAM         stream;
    
    MGTimeSignature *_timeSignature;
}
@property(nonatomic,assign) HSTREAM stream; //To be assigned by controller
@property(nonatomic,assign) MGTimeSignature *timeSignature;

//Initialization functions
-(id)initWithCapacity: (NSInteger)capacity
     andTimeSignature: (MGTimeSignature *)timeSignature;
-(id)initWithCapacity: (NSInteger)capacity;
-(id)initWithTimeSignature:(MGTimeSignature *)timeSignature;

-(void)add:             (void*) chord;
-(MGNote *)getNote:     (NSInteger)index; 
-(void)play:            (HSTREAM)astream; 
-(NSInteger)count;



@end
