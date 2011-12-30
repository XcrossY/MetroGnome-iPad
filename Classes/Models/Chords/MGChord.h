//
//  MGChord.h
//  MetroGnomeiPad
//
//  Created by Zander on 9/29/11.
//  Copyright 2011 MetroGnome, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGNote.h"

// A chord is an NSMutableArray of MGNotes
@interface MGChord : NSObject {
    NSMutableArray *array;
}

-(id)initWithCapacity:          (NSInteger) capacity;
//-(id)initWithChord:             (NSInteger) chordName;
-(id)initMajorTriadWithTonic:   (MGNote *)  tonic;
-(id)initMinorTriadWithTonic:   (MGNote *)  tonic;
-(void)addNote:                 (MGNote *)  note;  


-(void)play:                    (HSTREAM)   stream; 

//Returns note. Bass note is index 0
-(MGNote *)getNote:(NSInteger)index; 
-(NSInteger)count;

@end
