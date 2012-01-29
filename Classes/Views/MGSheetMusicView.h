//
//  MGSheetMusicView.h
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 12/19/11.
//  Copyright (c) 2011 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGScore.h"

@interface MGSheetMusicView : UIView {
    MGScore *_score;
    NSMutableArray *_staves; //array of staves held by the MGSheetMusicView
}
@property(nonatomic,retain) MGScore *score;
@property(nonatomic,assign) NSMutableArray *staves;

//-(void)display:(MGScore *)score;


-(void)displaySingleStaff:(int)number;  /** Displays number of MGSingleStaff lines */
-(void)displayTimeSignature;    /** Displays time signature on all staves */
@end

