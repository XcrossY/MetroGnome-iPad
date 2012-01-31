//
//  MGOptions.h
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 1/29/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGTimeSignature.h"

@interface MGOptions : NSObject {
    BOOL _displayAll;
    BOOL _normalStaffSize; //Displays staves at normal size
    MGTimeSignature *_timeSignature;
}
@property(nonatomic,assign) BOOL displayAll;
@property(nonatomic,assign) BOOL normalStaffSize;
@property(nonatomic,retain) MGTimeSignature *timeSignature;

@end
