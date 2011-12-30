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
}
@property(nonatomic,retain) MGSheetMusicView *sheetMusicView;

-(id)initWithMGScore:(MGScore *)score;
@end
