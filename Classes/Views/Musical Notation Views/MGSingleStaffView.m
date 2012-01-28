//
//  MGSingleStaffView.m
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 1/22/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "MGSingleStaffView.h"
#import "MGBarLineView.h"

@implementation MGSingleStaffView
@synthesize timeSignature = _timeSignature;

//Takes in frame size in which to display staff
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImage *singleStaff = [UIImage imageNamed:@"SingleStaff.png"];
        self.image = singleStaff;
        
        //Create opening bar line
        MGBarLineView *startingLine = [[MGBarLineView alloc]initAtPosition:CGPointMake(0.0, 0.0)];
        [self addSubview:startingLine];
    }
    return self;
}

-(void)displayTimeSignature {
    [self.timeSignature initView];
    self.timeSignature.view.center = CGPointMake(0.0, self.center.y);
    [self addSubview:self.timeSignature.view];
}

@end
