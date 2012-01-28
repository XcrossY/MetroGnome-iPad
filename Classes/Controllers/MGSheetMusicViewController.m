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
#define BORDER 20 //Size of border on screen

@implementation MGSheetMusicViewController
@synthesize sheetMusicView  = _sheetMusicView;
@synthesize score           = _score;

-(void)dealloc {
    self.sheetMusicView = nil;
    [super dealloc];
}

-(id)initWithMGScore:(MGScore *)score {
    if (self = [super init]) {
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
    
    
    //Set SheetMusicView size
    CGSize screenSize = [UIScreen mainScreen].currentMode.size; //used to define orientations
    self.sheetMusicView = [[MGSheetMusicView alloc]initWithFrame:
                           ORIENTATION_LANDSCAPE];
    CGRect rect = CGRectMake(0, 0, 
                             self.sheetMusicView.frame.size.width - BORDER,
                             self.sheetMusicView.frame.size.height - BORDER);
    
    //Determine type of staff layout
    if ([self.score.partsArray count] == 0) {
        NSLog(@"MGSMVC: displayAll score has no parts");
    }
    else if (1){//[self.score.partsArray count] == 1) {        
        [self.sheetMusicView displaySingleStaff:1];
    } 
    else if ([self.score.partsArray count] == 2) {
        MGDoubleStaffView *staff = [[MGDoubleStaffView alloc]initWithFrame:rect];
        [self.sheetMusicView addSubview:staff];
    }
    
    [self.sheetMusicView displayTimeSignature:self.score.timeSignature];
    
    
}

@end
