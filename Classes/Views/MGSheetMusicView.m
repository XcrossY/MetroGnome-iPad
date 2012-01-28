//
//  MGSheetMusicView.m
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 12/19/11.
//  Copyright (c) 2011 Princeton University. All rights reserved.
//

#import "MGSheetMusicView.h"
#import "MGScore.h"
#import "MGSingleStaffView.h"
#import "MGBarLineView.h"

#define STAFFHEIGHT 256
//Amount of space between staves and edge of frame
#define STAFFBORDERX 20
#define STAFFBORDERY 20 

@implementation MGSheetMusicView
@synthesize score   = _score;
@synthesize staves  = _staves;

-(void)dealloc {
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.autoresizesSubviews = YES;
        self.backgroundColor = [UIColor colorWithPatternImage:
                                [UIImage imageNamed:@"SheetMusicPaper.png"]];
    }
    return self;
}

-(void)displaySingleStaff:(int)number {
    if (number == 1) { //Staff in center of screen
        CGRect rect = CGRectMake(STAFFBORDERX, 
                                 (self.frame.size.height - STAFFHEIGHT)/2, 
                                 self.frame.size.width - 2*STAFFBORDERX, 
                                 STAFFHEIGHT);
        MGSingleStaffView *staff = [[MGSingleStaffView alloc]initWithFrame:rect];
        [self.staves addObject:staff];
        [self addSubview:staff];
    }
}

/** Displays time signature on all staves */
-(void)displayTimeSignature {
    for (int i = 0; i < [self.staves count]; i++) {
        [[self.staves objectAtIndex:i] displayTimeSignature];
        [[self.staves objectAtIndex:i] displayTimeSignature];
    }
}

/**-(void)display:(MGPart *)score {
    
}*/




@end
