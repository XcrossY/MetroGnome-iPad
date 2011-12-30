//
//  MGSheetMusicView.m
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 12/19/11.
//  Copyright (c) 2011 Princeton University. All rights reserved.
//

#import "MGSheetMusicView.h"

@implementation MGSheetMusicView

-(void)dealloc {
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithPatternImage:
                                [UIImage imageNamed:@"SheetMusicPaper.png"]];
    }
    return self;
}



@end
