//
//  MGScore.m
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 12/20/11.
//  Copyright (c) 2011 Princeton University. All rights reserved.
//

#import "MGScore.h"

@implementation MGScore
@synthesize timeSignature = _timeSignature;

#pragma mark 
#pragma mark Initialization
-(void)dealloc {
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

-(void)add:(MGPart *)part {
    [array addObject:part];
}



@end
