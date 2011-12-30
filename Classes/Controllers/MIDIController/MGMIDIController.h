//
//  MGMIDIController.h
//  MetroGnomeiPad
//
//  Created by Zander on 10/8/11.
//  Copyright 2011 MetroGnome, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGPart.h"

@interface MGMIDIController : NSObject {
    
}

-(void)test;
-(void)play:(MGPart *)part;

-(void)writeMIDI:(MGPart *)part;
-(void)loadMIDI:(MGPart *)part;

@end
