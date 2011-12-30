//
//  MGSheetMusicViewController.m
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 12/19/11.
//  Copyright (c) 2011 Princeton University. All rights reserved.
//

#import "MGSheetMusicViewController.h"

@implementation MGSheetMusicViewController
@synthesize sheetMusicView = _sheetMusicView;

-(void)dealloc {
    self.sheetMusicView = nil;
    [super dealloc];
}

-(id)initWithMGScore:(MGScore *)score {
    if (self = [super init]) {
        CGSize screenSize = [UIScreen mainScreen].currentMode.size;
        self.sheetMusicView = [[MGSheetMusicView alloc]initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    }
    
    return self;
}

@end
