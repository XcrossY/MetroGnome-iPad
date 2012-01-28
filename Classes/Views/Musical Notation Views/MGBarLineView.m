//
//  MGBarLineView.m
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 1/28/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "MGBarLineView.h"

@implementation MGBarLineView

//point is top of barline
-(id)initAtPosition:(CGPoint)point {
    [self initWithImage:[UIImage imageNamed:@"BarLine.png"]];
    self.center = CGPointMake(point.x, point.y+self.frame.size.height/2);
    return self; 
}


@end
