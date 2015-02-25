//
//  Copyright 2011-2015 Twilio. All rights reserved.
//
//  Use of this software is subject to the terms and conditions of the
//  Twilio Terms of Service located at http://www.twilio.com/legal/tos
//
 
#import "FocusCallingAppDelegate.h"
#import "FocusCallingViewController.h"

@implementation FocusCallingAppDelegate

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
    // Set the view controller as the window's root view controller and display.
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
