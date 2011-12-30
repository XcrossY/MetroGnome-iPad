//
//  MGScore.h
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 12/20/11.
//  Copyright (c) 2011 Princeton University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGPart.h"
#import "MGTimeSignature.h"

/* A part contains a string of notes/chords. It is a single instrument,
 voice, or piano (one or both hands) */
@interface MGScore : NSObject {
    NSMutableArray *array; //of MGParts
    MGTimeSignature *_timeSignature;
}
@property(nonatomic,assign) MGTimeSignature *timeSignature;

//Initialization functions
-(id)initWithCapacity: (NSInteger)capacity
     andTimeSignature: (MGTimeSignature *)timeSignature;
-(id)initWithCapacity: (NSInteger)capacity;
-(id)initWithTimeSignature:(MGTimeSignature *)timeSignature;

-(void)add:             (MGPart *)part; 





@end