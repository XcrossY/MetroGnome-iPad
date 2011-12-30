//
//  MGPart.m
//  MetroGnomeiPad
//
//  Created by Zander on 10/8/11.
//  Copyright 2011 MetroGnome, LLC. All rights reserved.
//

#import "MGPart.h"

@implementation MGPart
@synthesize stream;
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
    if (capacity == 0) {
        capacity = 1;
    }
    array = [NSMutableArray arrayWithCapacity:capacity];
    
    if (timeSignature == nil) {
        self.timeSignature = [MGTimeSignature commonTime];
    }
    else {
        self.timeSignature = timeSignature;
    }
    return self;
}

-(id)initWithCapacity:(NSInteger)capacity {
    return [self initWithCapacity:capacity andTimeSignature:nil];
}

-(id)initWithTimeSignature:(MGTimeSignature *)timeSignature {
    return [self initWithCapacity:0 andTimeSignature:timeSignature];
}

#pragma mark
#pragma mark Methods

//Play the entire part
-(void)play:(HSTREAM)astream{
    for (int i=0; i<[self count]; i++) {
        MGNote *note = [self getNote:i];
        note.duration = self.timeSignature.tempo * note.duration / BEATS_PER_MIN;
        [note play:astream];
    }
}



-(void)add:(void *)notes {
    [array addObject:notes];
}

-(void)addChord:(MGChord *)chord {
    [array addObject:chord];
}


-(MGNote *)getNote:(NSInteger)index {
    assert(index >= 0 && index < [array count]);
    return [array objectAtIndex:index];
}


-(NSInteger)count {
    return [array count];
}    


@end
