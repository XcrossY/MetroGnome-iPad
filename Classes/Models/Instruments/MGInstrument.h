//
//  MGInstrument.h
//  MetroGnomeiPad
//
//  Created by Zander on 9/24/11.
//  Copyright 2011 MetroGnome, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGSoundFont.h"


@interface MGInstrument : NSObject {
    MGSoundFont *_soundFont;
    NSString *_name;
}

@property(nonatomic, retain) MGSoundFont *soundFont;
@property(nonatomic, copy) NSString *name;

-(id)initWithSoundFont:(MGSoundFont *)font
        instrumentType:(NSString *)name;

@end
