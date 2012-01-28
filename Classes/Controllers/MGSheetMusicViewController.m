//
//  MGSheetMusicViewController.m
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 12/19/11.
//  Copyright (c) 2011 Princeton University. All rights reserved.
//

#import "MGSheetMusicViewController.h"
#import "MGSingleStaffView.h"
#import "MGDoubleStaffView.h"

#define ORIENTATION_PORTRAIT  CGRectMake(0,0,screenSize.width, screenSize.height)
#define ORIENTATION_LANDSCAPE  CGRectMake(0,0,screenSize.height, screenSize.width)

@implementation MGSheetMusicViewController
@synthesize sheetMusicView  = _sheetMusicView;
@synthesize score           = _score;

-(void)dealloc {
    self.sheetMusicView = nil;
    [super dealloc];
}

-(id)initWithMGScore:(MGScore *)score {
    if (self = [super init]) {
        CGSize screenSize = [UIScreen mainScreen].currentMode.size;
        
        self.sheetMusicView = [[MGSheetMusicView alloc]initWithFrame:
                               ORIENTATION_LANDSCAPE];
        self.score = score;
    }
    
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ((orientation == UIInterfaceOrientationLandscapeRight) ||
        (orientation == UIInterfaceOrientationLandscapeLeft))
        return YES;
    
    return NO;
}


/** Displays all parts of the MGScore */
-(void)displayAll {
    //Set size parameters for staves
    
    
    //Determine type of staff layout
    if ([self.score.partsArray count] == 0) {
        NSLog(@"MGSMVC: displayAll score has no parts");
    }
    if (1){//[self.score.partsArray count] == 1) {
        CGRect rect = CGRectMake(0, 0, 
                                 self.sheetMusicView.frame.size.width, 100);
        MGSingleStaffView *staff = [[MGSingleStaffView alloc]initWithFrame:rect];
        [self.sheetMusicView addSubview:staff];
    } 
    else if ([self.score.partsArray count] == 2) {
        CGRect rect = CGRectMake(0, 0, 
                                 self.sheetMusicView.frame.size.width, 100);
        MGDoubleStaffView *staff = [[MGDoubleStaffView alloc]initWithFrame:rect];
        [self.sheetMusicView addSubview:staff];
    }
    
    
}

@end
