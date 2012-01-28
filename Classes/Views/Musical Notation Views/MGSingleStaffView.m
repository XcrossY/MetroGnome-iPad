//
//  MGSingleStaffView.m
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 1/22/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "MGSingleStaffView.h"
#import "MGBarLineView.h"
#import "MGTimeSignatureView.h"

@implementation MGSingleStaffView
@synthesize timeSignatureView = _timeSignatureView;

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

-(void)displayTimeSignature:(MGTimeSignature *)timeSignature {
    MGTimeSignatureView *view = [[MGTimeSignatureView alloc]
                                 initWithTimeSignature:timeSignature];
    view.center = CGPointMake(0.0, self.center.y);
    [self addSubview:view];
}

@end
