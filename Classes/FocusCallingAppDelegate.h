//
//  Copyright 2011-2015 Twilio. All rights reserved.
//
//  Use of this software is subject to the terms and conditions of the
//  Twilio Terms of Service located at http://www.twilio.com/legal/tos
//
 
#import <UIKit/UIKit.h>

@class FocusCallingViewController;
@class TCDevice;

@interface FocusCallingAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet FocusCallingViewController *viewController;

@end

