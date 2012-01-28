//
//  MGSingleStaffView.h
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 1/22/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGTimeSignature.h"


@interface MGSingleStaffView : UIImageView {
    MGTimeSignature *_timeSignature;
}
@property(nonatomic,retain) MGTimeSignature *timeSignature;

-(void)displayTimeSignature; 

@end
