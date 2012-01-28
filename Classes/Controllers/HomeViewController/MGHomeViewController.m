//
//  MGHomeViewController.m
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 12/20/11.
//  Copyright (c) 2011 Princeton University. All rights reserved.
//

#import "MGHomeViewController.h"
#import "MGSheetMusicView.h"

@implementation MGHomeViewController
@synthesize view = _view;

-(void)dealloc {
    [super dealloc];
}

-(id)init {
    if (self = [super init]) {
        //[self intro];
        CGSize screenSize = [UIScreen mainScreen].currentMode.size;
        self.view = [[MGSheetMusicView alloc]initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    }
    return self;
}


//Deprecate
-(void)intro {
    if (self) {
        CGSize screenSize = [UIScreen mainScreen].currentMode.size;
        self.view = [[MGSheetMusicView alloc]initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)]; //make png smaller!
        
        UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectZero];
        [logo setImage:[UIImage imageNamed:@"TrebleClefLogoBold.png"]];
        [logo sizeToFit];
        logo.frame = CGRectMake((screenSize.width-logo.frame.size.width)/2, 
                                (screenSize.height-logo.frame.size.height)/2, 
                                logo.frame.size.width, logo.frame.size.height);
        [self.view addSubview:logo];
        
        //Wait 2 seconds
        /*[NSThread sleepForTimeInterval:2.0];
        
        NSLog(@"after");
        [logo removeFromSuperview];
        [logo release];
         */
    }
}


@end
