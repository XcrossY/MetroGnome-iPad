//
//  MGInstrument.m
//  MetroGnomeiPad
//
//  Created by Zander on 9/24/11.
//  Copyright 2011 MetroGnome, LLC. All rights reserved.
//

#import "MGInstrument.h"
#import "bass.h"
#import "bassmidi.h"

NSString *kChorium = @"Chorium";

@interface MGInstrument (Private)


@end



@implementation MGInstrument
@synthesize soundFont   = _soundFont;
@synthesize name        = _name;

-(void)dealloc {
    self.soundFont  = nil;
    self.name       = nil;
    [super dealloc];
}

-(id)initWithSoundFont:(MGSoundFont *)soundFont
        instrumentType:(NSString *)name {
    
    if (self = [super init]) {
        if (soundFont == nil) {
            self.soundFont = [[MGSoundFont alloc]initWithFileName:nil]; 
        }
        else {
            self.soundFont = soundFont;
        }
        
        self.name = [NSString stringWithFormat:@"success"];
    }
    
    return self;
}

#pragma mark -
#pragma mark Private

@end
