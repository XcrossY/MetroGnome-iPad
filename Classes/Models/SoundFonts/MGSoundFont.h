//
//  MGSoundFont.h
//  MetroGnomeiPad
//
//  Created by Zander on 9/24/11.
//  Copyright 2011 MetroGnome, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "bassmidi.h"

//Objective-C wrapper of BASS_MIDI_FONT
@interface MGSoundFont : NSObject {
    HSOUNDFONT      _font;
    NSString        *_name;
    NSInteger       _bank;
    NSInteger       _preset;
    NSInteger       _instrumentTotal;
}
@property(nonatomic,assign) HSOUNDFONT  font;
@property(nonatomic,copy)   NSString    *name;
@property(nonatomic,assign) NSInteger   bank;
@property(nonatomic,assign) NSInteger   preset;
@property(nonatomic,assign) NSInteger   instrumentTotal;

-(id)initWithFileName:(NSString *)fileName;
-(BASS_MIDI_FONT)getBASSMIDIFONT;

@end
