//
//  MetroGnomeiPadAppDelegate.m
//  MetroGnomeiPad
//
//  Created by Zander on 9/22/11.
//  Copyright 2011 MetroGnome, LLC. All rights reserved.
//

#import "MetroGnomeiPadAppDelegate.h"
#import "MGMIDIController.h"
#import "MGSheetMusicViewController.h"
#import "MGHomeViewController.h"

@implementation MetroGnomeiPadAppDelegate
@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
    MGMIDIController *controller = [[MGMIDIController alloc]init];
    [controller test];  
    [controller release];
    
    MGHomeViewController *homeViewController = [[MGHomeViewController alloc] init];
    [self.window addSubview:homeViewController.view];
    
    //MGSheetMusicViewController *viewController = [[MGSheetMusicViewController alloc]initWithMGScore:nil];
    //[self.window addSubview:viewController.sheetMusicView];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
