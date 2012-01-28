//
//  MGDoubleStaffView.m
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 1/22/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "MGDoubleStaffView.h"

@implementation MGDoubleStaffView
@synthesize topStaff    = _topStaff;
@synthesize bottomStaff = _bottomStaff;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.topStaff = [[MGSingleStaffView alloc]initWithFrame:
                         CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2)];
        self.bottomStaff = [[MGSingleStaffView alloc]initWithFrame:
                            CGRectMake(0, self.frame.size.height/2, 
                                       self.frame.size.width, self.frame.size.height/2)];
    }
    return self;
}


@end
