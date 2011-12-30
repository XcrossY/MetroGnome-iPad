//
//  MGChord.m
//  MetroGnomeiPad
//
//  Created by Zander on 9/29/11.
//  Copyright 2011 MetroGnome, LLC. All rights reserved.
//

#import "MGChord.h"

//@interface MGChord (Private)
//-(void)equalizeDurations;
//@end


@implementation MGChord : NSObject

-(void)dealloc {
    [array release];
    [super dealloc];   
}

-(id)initWithCapacity:(NSInteger)capacity {
    if (capacity == 0) {
        capacity = 1;
    }
    array = [NSMutableArray arrayWithCapacity:capacity];
    return self;
}

-(id)initMajorTriadWithTonic:(MGNote *)tonic {
    if (tonic != nil && self != nil) {
        array = [[NSMutableArray alloc] initWithCapacity:3];
        [self addNote:tonic];
        [self addNote:[tonic ascendingInterval:INTERVAL_M3]];
        [self addNote:[tonic ascendingInterval:INTERVAL_P5]];
        //[self equalizeDurations];
    }
    
    return self;
}

-(id)initMinorTriadWithTonic:(MGNote *)tonic {
    if (tonic != nil && self != nil) {
        array = [[NSMutableArray alloc] initWithCapacity:3];
        [self addNote:tonic];
        [self addNote:[tonic ascendingInterval:INTERVAL_m3]];
        [self addNote:[tonic ascendingInterval:INTERVAL_P5]];
    }
    
    return self;
}

-(void)play:(HSTREAM)stream{
    //initial attacks of chord
    for (int i=0; i<[self count]; i++) {
        [[self getNote:i] noteOn:stream];
    }
    
    //duration of chord
    [NSThread sleepForTimeInterval:[[self getNote:0] duration]];
    
    //end chord
    for (int i=0; i<[self count]; i++) {
        [[self getNote:i] noteOff:stream];
    }
    
}

-(void)addNote:(MGNote *)note {
    [array addObject:note];
}

-(MGNote *)getNote:(NSInteger)index {
    assert(index >= 0 && index < [array count]);
    return [array objectAtIndex:index];
}

-(NSInteger)count {
    return [array count];
}


/*
 - (void)set:(id)obj index:(int)x {
 assert(x >= 0 && x < [array count]);
 [array replaceObjectAtIndex:x withObject:obj];
 }
 */

/* 
 - (void)remove:(id)obj {
 [array removeObject:obj];
 }
 */

/* 
 - (void)clear {
 [array removeAllObjects];
 }
 */

@end
