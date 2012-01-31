//
//  MGSheetMusicView.h
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 12/19/11.
//  Copyright (c) 2011 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGScore.h"
#import "MGOptions.h"

@interface MGSheetMusicView : UIView {
    MGScore *_score;
    NSMutableArray *_staves; //array of staves held by the MGSheetMusicView
}
@property(nonatomic,retain) MGScore *score;
@property(nonatomic,retain) NSMutableArray *staves;


/** Displays sheet music with parameters defined in options */
-(void)displayWithOptions:(MGOptions *)options; 

-(void)displaySingleStaff:(int)number;  /** Displays number of MGSingleStaff lines */
-(void)displayTimeSignature;    /** Displays time signature on all staves */







//Wish list
-(void)displayRegular;      //Displays sheet music in its entirety
-(void)displayNotesOnly;    //Displays sheet music without rhythm
-(void)displayRhythmOnly;  //Displays sheet music without pitches
-(void)displayKeys;         //Displays piano keys of the "allowed" notes for the measure //
@end

