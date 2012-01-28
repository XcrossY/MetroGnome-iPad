//
//  MGSingleStaffView.h
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 1/22/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGTimeSignature.h"
#import "MGTimeSignatureView.h"

@interface MGSingleStaffView : UIImageView {
    MGTimeSignatureView *_timeSignatureView;
}
@property(nonatomic,retain) MGTimeSignatureView *timeSignatureView;

-(void)displayTimeSignature:(MGTimeSignature *)timeSignature; 

@end
