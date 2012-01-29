//
//  MGSheetMusicViewController.m
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 12/19/11.
//  Copyright (c) 2011 Princeton University. All rights reserved.
//

#import "MGSheetMusicViewController.h"
#import "MGPart.h"
#import "MGNote.h"
#import "MGSingleStaffView.h"
#import "MGDoubleStaffView.h"


#define ORIENTATION_PORTRAIT  CGRectMake(0,0,screenSize.width, screenSize.height)
#define ORIENTATION_LANDSCAPE  CGRectMake(0,0,screenSize.height, screenSize.width)
#define BORDERX 20 //Size of border on screen
#define BORDERY 20

@implementation MGSheetMusicViewController
@synthesize sheetMusicView  = _sheetMusicView;
@synthesize score           = _score;
@synthesize midiSoundOptions = _midiSoundOptions;
@synthesize sheetMusicOptions = _sheetMusicOptions;

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
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
    self.sheetMusicView.score = self.score;
    CGRect rect = CGRectMake(0, 0, 
                             self.sheetMusicView.frame.size.width - BORDERX,
                             self.sheetMusicView.frame.size.height - BORDERY);
    
    //Determine number of measures in score
    int measureTotal = [self.score totalMeasures];
    
    //Determine type of staff layout
    if ([self.score.partsArray count] == 0) {
        NSLog(@"MGSMVC: displayAll score has no parts");
    }
    else if (1){//[self.score.partsArray count] == 1) {        
        //Init all MGSingleStaffViews
        self.sheetMusicView.staves = [[NSMutableArray alloc]
                                      initWithCapacity:measureTotal];
        MGPart *part = [self.score.partsArray objectAtIndex:0];
        for (int j = 0; j < measureTotal; j++) {
            [self.sheetMusicView.staves insertObject:[[MGSingleStaffView alloc]init] 
                                             atIndex:j];
        }
        
        //Fill staves with notes from score
        int currentMeasure = 0;
        int currentNote = 0;
        BOOL complete = FALSE;
        MGSingleStaffView *currentStaff = [self.sheetMusicView.staves objectAtIndex:0];
        while (!complete) {
            MGNote *note = [part.notesArray objectAtIndex:currentNote];
            if (note.measureNumber == currentMeasure) {
                [currentStaff.noteArray insertObject:note atIndex:currentMeasure];
            }
            //If finished with current measure, increment 
            else if (note.measureNumber == currentMeasure+1) { 
                currentMeasure++;
                MGSingleStaffView *currentStaff = [self.sheetMusicView.staves objectAtIndex:currentMeasure];
                [currentStaff.noteArray insertObject:note atIndex:currentMeasure];
            }
            else {
               NSLog(@"SheetMusicViewController: displayAll error"); 
            }
            currentNote++;
        }
        
        
        //Now need to actually display staves
        
        
        
        
        
        
        
        
        //Create all MGSingleStaffViews
        /*for (int i = 0; i < measureTotal; i++) { //while loop?
            BOOL sameMeasure = TRUE;
            while (sameMeasure) {
                int j = 0;
            }
            MGSingleStaffView *staff = [[MGSingleStaffView alloc]initWithNotes:noteArray];
            //MGSingleStaffView *staff = [[MGSingleStaffView alloc]initWithFrame:<#(CGRect)#>];
            
            //Enlarge sheet music view bounds if necessary
            if (1) {
                self.sheetMusicView.bounds = CGRectMake(0, 0, 
                                                        self.sheetMusicView.bounds.size.width, 
                                                        self.sheetMusicView.bounds.size.height);//+staffheight
            }
        }*/
        
        
        [self.sheetMusicView displaySingleStaff:measureTotal];
    } 
    else if ([self.score.partsArray count] == 2) {
        //MGDoubleStaffView *staff = [[MGDoubleStaffView alloc]initWithFrame:rect];
        //[self.sheetMusicView addSubview:staff];
    }
    
    [self.sheetMusicView displayTimeSignature];
    
    
}

@end
