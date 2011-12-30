//
//  MGKeySignature.h
//  MetroGnomeiPad
//
//  Created by Zander on 9/28/11.
//  Copyright 2011 Princeton University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGNote.h"


@interface MGKeySignature : NSObject {
    MGNote *_tonic;
    NSInteger _mode; //0 Major, 1 minor
}
@property(nonatomic,retain) MGNote *tonic;
@property(nonatomic,assign) NSInteger mode;

-(id)initMode:(NSInteger)mode 
    withTonic:(MGNote *)tonic;
-(id)initMajorWithTonic:(MGNote *)tonic;
-(id)initMinorWithTonic:(MGNote *)tonic;

//Postive for sharps, negative for flats
-(NSInteger)getNumAccidentals;

@end
