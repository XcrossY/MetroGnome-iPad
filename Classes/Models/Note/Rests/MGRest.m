//
//  MGRest.m
//  MetroGnomeiPad
//
//  Created by Zander on 10/15/11.
//  Copyright 2011 MetroGnome, LLC. All rights reserved.
//

#import "MGRest.h"
#import "MIDIValues.h"


@implementation MGRest

-(void)dealloc {
    [super dealloc];
}

-(id)initWithDuration:(NSInteger)duration {
    if (self = [super init]) {
        self.pitchClass = PITCH_CLASS_NIL;
        self.duration   = duration;
    }
    
    return self;
}

@end
