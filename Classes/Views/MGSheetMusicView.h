//
//  MGSheetMusicView.h
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 12/19/11.
//  Copyright (c) 2011 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGScore.h"

@interface MGSheetMusicView : UIView

-(void)display:(MGScore *)score;
@end

