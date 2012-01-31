//
//  MGSingleStaffView.m
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 1/22/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "MGSingleStaffView.h"
#import "MGBarLineView.h"
#import "MGNote.h"

@interface MGSingleStaffView (Private)
-(int)totalPositions; /** Returns total number of visual "positions" in measure */
@end

@implementation MGSingleStaffView
@synthesize timeSignature = _timeSignature;
@synthesize noteArray = _noteArray;

-(void)dealloc {
    [super dealloc];
}

/** Does not take in a frame. For initing instance without knowing layout */
-(id)init {
    if (self = [super init]) {
        UIImage *singleStaff = [UIImage imageNamed:@"SingleStaff.png"];
        self.image = singleStaff;
        self.noteArray = [[NSMutableArray alloc]init];
        
        //Create opening bar line
        //MGBarLineView *startingLine = [[MGBarLineView alloc]initAtPosition:CGPointMake(0.0, 0.0)];
        //[self addSubview:startingLine];
    }
    return self;
}

//Takes in frame size in which to display staff
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImage *singleStaff = [UIImage imageNamed:@"SingleStaff.png"];
        self.image = singleStaff;
        self.noteArray = [[NSMutableArray alloc]init];
        
        //Create opening bar line
        //MGBarLineView *startingLine = [[MGBarLineView alloc]initAtPosition:CGPointMake(0.0, 0.0)];
        //[self addSubview:startingLine];
    }
    return self;
}


-(void)displayTimeSignature {
    [self.timeSignature initView];
    self.timeSignature.view.center = CGPointMake(0.0, self.center.y);
    [self addSubview:self.timeSignature.view];
}

//Display normal musical notation
-(void)displayRegular {
    for (int i = 0; i < [self.noteArray count]; i++) {
        MGNote *note = [self.noteArray objectAtIndex:i];
        CGFloat yPosition = [self pitchPosition:note.pitchClass];
        [note displayAtPosition:CGPointMake(i*10,yPosition)];
        [self addSubview:note.image];        
    }
}


/************************************************************************/
/**
 -(int)totalPositions {
 return 0;
 }*/

-(CGFloat)pitchPosition:(int)pitch {
    if (pitch == PITCH_CLASS_A) {return 0;}
    else if (pitch == PITCH_CLASS_A) {return 10;}
    else if (pitch == PITCH_CLASS_Asharp) {return 20;}
    else if (pitch == PITCH_CLASS_B) {return 30;}
    else if (pitch == PITCH_CLASS_C) {return 40;}
    else if (pitch == PITCH_CLASS_Csharp) {return 50;}
    else if (pitch == PITCH_CLASS_D) {return 60;}
    else if (pitch == PITCH_CLASS_Dsharp) {return 70;}
    else if (pitch == PITCH_CLASS_E) {return 80;}
    else if (pitch == PITCH_CLASS_F) {return 90;}
    else if (pitch == PITCH_CLASS_Fsharp) {return 100;}
    else if (pitch == PITCH_CLASS_G) {return 110;}
    else if (pitch == PITCH_CLASS_Gsharp) {return 120;}
    else {NSLog(@"MGSingleStaffView:error");}
}


@end
