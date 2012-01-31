//
//  MGKeySignature.m
//  MetroGnomeiPad
//
//  Created by Zander on 9/28/11.
//  Copyright 2011 Princeton University. All rights reserved.
//

#import "MGKeySignature.h"


@implementation MGKeySignature
@synthesize tonic = _tonic;
@synthesize mode  = _mode;

#pragma mark -
#pragma mark Inits

-(void)dealloc {
    [self.tonic release];
    [super release];
}

-(id)initMode:(NSInteger)mode 
    withTonic:(MGNote *)tonic {
    
    if (self = [super init]) {
        self.mode = mode;
        self.tonic = tonic;
    }
    return self;
}


-(id)initMajorWithTonic:(MGNote *)tonic {
    return [self initMode:KEY_SIG_MAJ withTonic:tonic];
}


-(id)initMinorWithTonic:(MGNote *)tonic {
    return [self initMode:KEY_SIG_MIN withTonic:tonic];
}

#pragma mark -
//Returns -1 if 
-(NSInteger)getNumAccidentals {
    NSInteger pitch = self.tonic.pitchClass;
    if (self.mode == KEY_SIG_MAJ) {
        if (pitch == PITCH_CLASS_A) return 3;
        else if (pitch == PITCH_CLASS_Bflat) return -2;
        else if (pitch == PITCH_CLASS_B) return 5;
        else if (pitch == PITCH_CLASS_C) return 0;
        else if (pitch == PITCH_CLASS_Csharp) return 7;
        else if (pitch == PITCH_CLASS_Dflat) return -5;
        else if (pitch == PITCH_CLASS_D) return 2;
        else if (pitch == PITCH_CLASS_Eflat) return -3;
        else if (pitch == PITCH_CLASS_E) return 4;
        else if (pitch == PITCH_CLASS_F) return -1;
        else if (pitch == PITCH_CLASS_Fsharp) return 6;
        else if (pitch == PITCH_CLASS_Gflat) return -6;
        else if (pitch == PITCH_CLASS_G) return 1;
        else if (pitch == PITCH_CLASS_Aflat) return -4;
    }
    else if (self.mode == KEY_SIG_MIN) {
        if (pitch == PITCH_CLASS_A) return 0;
        else if (pitch == PITCH_CLASS_Asharp) return 7;
        else if (pitch == PITCH_CLASS_B) return 2;
        else if (pitch == PITCH_CLASS_C) return -3;
        else if (pitch == PITCH_CLASS_Csharp) return 4;
        else if (pitch == PITCH_CLASS_D) return -1;
        else if (pitch == PITCH_CLASS_Eflat) return -6;
        else if (pitch == PITCH_CLASS_E) return 1;
        else if (pitch == PITCH_CLASS_F) return -4;
        else if (pitch == PITCH_CLASS_Fsharp) return 3;
        else if (pitch == PITCH_CLASS_G) return -2;
        else if (pitch == PITCH_CLASS_Gsharp) return 5;
    }
    else 
    {
        NSLog(@"getNumAccidentals: Unrecognized key signature mode");
    }
    return 99;
}


@end
