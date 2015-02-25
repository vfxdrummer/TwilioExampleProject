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
  
  __weak IBOutlet UIButton* _dialButton;
  __weak IBOutlet UIButton* _hangupButton;
  __weak IBOutlet UIButton* _answerButton;
  __weak IBOutlet UIButton* _ignoreButton;
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
  
  // set initial button visibility
  [self setDialButtonState];
  
  [self updateTwilioToken];
}

- (void)setDialButtonState {
  [_dialButton   setHidden:NO];
  [_hangupButton setHidden:NO];
  [_answerButton setHidden:YES];
  [_ignoreButton setHidden:YES];
}

- (void)setAnswerButtonState {
  [_dialButton   setHidden:YES];
  [_hangupButton setHidden:YES];
  [_answerButton setHidden:NO];
  [_ignoreButton setHidden:NO];
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
  _connection = [_phone connect:params delegate:self];
}

- (IBAction)hangupButtonPressed:(id)sender
{
    [_connection disconnect];
}

- (IBAction)answerButtonPressed:(id)sender
{
  [_connection accept];
  [self setDialButtonState];
}

- (IBAction)ignoreButtonPressed:(id)sender
{
  [_connection reject];
  [self setDialButtonState];
}

- (void)device:(TCDevice *)device didReceiveIncomingConnection:(TCConnection *)connection
{
    NSLog(@"Incoming connection from: %@", [connection parameters][@"From"]);
    if (device.state == TCDeviceStateBusy) {
        [connection reject];
    } else {
      //        [connection accept];
        [self setAnswerButtonState];
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
