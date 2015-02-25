//
//  Copyright 2011-2015 Twilio. All rights reserved.
//
//  Use of this software is subject to the terms and conditions of the
//  Twilio Terms of Service located at http://www.twilio.com/legal/tos
//
 
#import "HelloMonkeyViewController.h"
#import "HelloMonkeyAppDelegate.h"
#import "SPAPIManager.h"
#import "TwilioClient.h"

@interface HelloMonkeyViewController() <TCDeviceDelegate,TCConnectionDelegate,UIGestureRecognizerDelegate>
{
    TCDevice* _phone;
    TCConnection* _connection;
}
@end

@implementation HelloMonkeyViewController

- (void)viewDidLoad
{
  [[TwilioClient sharedInstance] setLogLevel:TC_LOG_DEBUG];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(fromTextChanged:)
                                               name:UITextFieldTextDidEndEditingNotification
                                             object:self.fromField];
  
  // tap gesture recognizer
  UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
  tapGesture.cancelsTouchesInView = NO;
  tapGesture.delegate = self;
  [self.view addGestureRecognizer:tapGesture];
  
  [self updateTwilioToken];
}

- (void)updateTwilioToken {
  [[SPAPIManager sharedManager] tokenForUser:self.fromField.text
                                successBlock:^void(NSString* token) {
                                  _phone = [[TCDevice alloc] initWithCapabilityToken:token delegate:self];
                                  
                                } failureBlock:^(NSString* message) {
                                  
                                }  networkBlock:^(NSError* error) {
                                  NSLog(@"Error retrieving token: %@", [error localizedDescription]);
                                }];
}

- (void) fromTextChanged:(id)notification {
  [self updateTwilioToken];
}

- (IBAction)dialButtonPressed:(id)sender
{
  NSDictionary *params = @{@"To": self.toField.text};
//  [[SPAPIManager sharedManager] tokenForUser:self.fromField.text
//                                successBlock:^void(NSString* token) {
//                                  _phone = [[TCDevice alloc] initWithCapabilityToken:token delegate:self];
                                  _connection = [_phone connect:params delegate:self];
                                  
//                                } failureBlock:^(NSString* message) {
//                                  
//                                }  networkBlock:^(NSError* error) {
//                                  NSLog(@"Error retrieving token: %@", [error localizedDescription]);
//                                }];
}

- (IBAction)hangupButtonPressed:(id)sender
{
    [_connection disconnect];
}

- (void)device:(TCDevice *)device didReceiveIncomingConnection:(TCConnection *)connection
{
    NSLog(@"Incoming connection from: %@", [connection parameters][@"From"]);
    if (device.state == TCDeviceStateBusy) {
        [connection reject];
    } else {
        [connection accept];
        _connection = connection;
    }
}

- (void)deviceDidStartListeningForIncomingConnections:(TCDevice*)device
{
    NSLog(@"Device: %@ deviceDidStartListeningForIncomingConnections", device);
}

- (void)device:(TCDevice *)device didStopListeningForIncomingConnections:(NSError *)error
{
    NSLog(@"Device: %@ didStopListeningForIncomingConnections: %@", device, error);
}

- (void)connection:(TCConnection *)connection didFailWithError:(NSError *)error
{
  
}

- (void)connectionDidConnect:(TCConnection *)connection
{
  
}

- (void)connectionDidDisconnect:(TCConnection *)connection
{
  
}

- (void)connectionDidStartConnecting:(TCConnection *)connection
{
  
}

#pragma mark -

- (void)dismissKeyboard {
  [self.view endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  if ([touch.view isKindOfClass:[UIButton class]]) {
    return NO;
  }
  return YES;
}

@end
