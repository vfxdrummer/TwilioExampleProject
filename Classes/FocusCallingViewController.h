//
//  Copyright 2011-2015 Twilio. All rights reserved.
//
//  Use of this software is subject to the terms and conditions of the
//  Twilio Terms of Service located at http://www.twilio.com/legal/tos
//
 
#import <UIKit/UIKit.h>

@interface FocusCallingViewController : UIViewController 

@property (nonatomic, strong) IBOutlet UITextField *fromField;
@property (nonatomic, strong) IBOutlet UITextField *toField;

- (IBAction)dialButtonPressed:(id)sender;
- (IBAction)hangupButtonPressed:(id)sender;

@end
