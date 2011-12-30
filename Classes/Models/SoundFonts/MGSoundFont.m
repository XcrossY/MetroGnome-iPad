//
//  MGSoundFont.m
//  MetroGnomeiPad
//
//  Created by Zander on 9/24/11.
//  Copyright 2011 MetroGnome, LLC. All rights reserved.
//

#import "MGSoundFont.h"


@interface MGSoundFont (Private)

-(BOOL)checkBASSError;

@end


@implementation MGSoundFont

@synthesize font            = _font;
@synthesize name            = _name;
@synthesize bank            = _bank;
@synthesize preset          = _preset;
@synthesize instrumentTotal = _instrumentTotal;

-(void)dealloc {
    self.name = nil;
    [super dealloc];   
}

-(id)initWithFileName:(NSString *)fileName {
    if (self = [super init]) {
        if (!fileName || 
            [fileName isEqualToString:[NSString stringWithFormat:@"Chorium"]]) {
            
            const char *filePath = [[[NSBundle mainBundle] pathForResource:@"ChoriumRevA.SF2" ofType:@""] UTF8String];
            
            //HSOUNDFONT test = BASS_MIDI_FontInit(filePath, 0);
            
            self.font       = BASS_MIDI_FontInit(filePath, 0);
            self.name       = [NSString stringWithFormat:@"Chorium"];
            self.bank       = 0;
            self.preset     = -1;
            
            if ([self checkBASSError]) {
                return nil;
            }
        }
    } 
    
    return [self autorelease];
}

-(BASS_MIDI_FONT)getBASSMIDIFONT {
    BASS_MIDI_FONT BASSMIDIFONT;
    BASSMIDIFONT.font   = self.font;
    BASSMIDIFONT.preset = self.preset;
    BASSMIDIFONT.bank   = self.bank;
    
    return BASSMIDIFONT;  
}

#pragma mark -
#pragma mark Private

-(BOOL)checkBASSError {
    int error = BASS_ErrorGetCode();
    if (error != 0) {
        NSLog(@"BASS Error %i in MGSoundFont", error);
        return TRUE;
    }
    return FALSE;
}

@end
