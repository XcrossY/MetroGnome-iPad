//
//  MGHomeViewController.h
//  MetroGnomeiPad
//
//  Created by Alexander Pease on 12/20/11.
//  Copyright (c) 2011 Princeton University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGHomeViewController : NSObject {
    UIView *_view;
}
@property(nonatomic,retain) UIView *view;

-(id)init;
-(void)intro;

@end
