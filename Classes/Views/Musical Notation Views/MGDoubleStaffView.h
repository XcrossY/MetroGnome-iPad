//
//  MGDoubleStaffView.h
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 1/22/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSingleStaffView.h"

@interface MGDoubleStaffView : UIView {
    MGSingleStaffView *_topStaff;
    MGSingleStaffView *_bottomStaff;
}
@property(nonatomic, retain) MGSingleStaffView *topStaff;
@property(nonatomic, retain) MGSingleStaffView *bottomStaff;

@end
