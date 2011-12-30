//
//  MGNote.h
//  MetroGnomeiPad
//
//  Created by Zander on 9/28/11.
//  Copyright 2011 MetroGnome, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "bassmidi.h"


@interface MGNote : NSObject {
    NSInteger   _pitchClass;
    NSInteger   _octave;
    NSInteger   _duration;
}
@property(nonatomic,assign) NSInteger   octave;
@property(nonatomic,assign) NSInteger   pitchClass;
@property(nonatomic,assign) NSInteger   duration;

-(id)initWithPitchClass:(NSInteger)pitchClass
                 octave:(NSInteger)octave
               duration:(NSInteger)duration;

//Play an individual note (not a chord). Handles on/off
-(void)play:(HSTREAM)stream;

//Sends on and off MIDI messages to BASS
-(void)noteOn:(HSTREAM)stream; 
-(void)noteOff:(HSTREAM)stream; 

-(MGNote *)ascendingInterval:(NSInteger)interval;

@end
