//
//  MGSheetMusicViewController.h
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 12/19/11.
//  Copyright (c) 2011 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSheetMusicView.h"
#import "MGScore.h"


@interface MGSheetMusicViewController : UIViewController {
    MGSheetMusicView *_sheetMusicView;
    MGScore *_score;
    MidiSoundOptions _midiSoundOptions;
    SheetMusicOptions _sheetMusicOptions;
}
@property(nonatomic,retain) MGSheetMusicView *sheetMusicView;
@property(nonatomic,retain) MGScore *score;
@property(readwrite,assign) MidiSoundOptions midiSoundOptions;
@property(readwrite,assign) SheetMusicOptions sheetMusicOptions;

-(id)initWithMGScore:(MGScore *)score;

/** Displays all parts of the MGScore */
-(void)displayAll;

@end
