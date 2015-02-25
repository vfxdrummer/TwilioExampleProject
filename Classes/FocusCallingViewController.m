//
//  Copyright 2011-2015 Twilio. All rights reserved.
//
//  Use of this software is subject to the terms and conditions of the
//  Twilio Terms of Service located at http://www.twilio.com/legal/tos
//
 
#import "FocusCallingViewController.h"
#import "FocusCallingAppDelegate.h"
#import "SPAPIManager.h"
#import "TwilioClient.h"

@interface FocusCallingViewController() <TCDeviceDelegate,TCConnectionDelegate,UIGestureRecognizerDelegate>
{
    TCDevice* _phone;
    TCConnection* _connection;
  
  BOOL _flashingOn;
  
  __weak IBOutlet UIButton* _dialButton;
  __weak IBOutlet UIButton* _hangupButton;
  __weak IBOutlet UIButton* _answerButton;
  __weak IBOutlet UIButton* _ignoreButton;
}
@end

@implementation FocusCallingViewController

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
  
  _flashingOn = NO;
  [self setDialButtonState];
  [self updateTwilioToken];
}

- (void)setDialButtonState {
  [_dialButton   setHidden:NO];
  [_hangupButton setHidden:NO];
  [_answerButton setHidden:YES];
  [_ignoreButton setHidden:YES];
  [self deactivateFlashing:_answerButton];
}

- (void)setAnswerButtonState {
  [_dialButton   setHidden:YES];
  [_hangupButton setHidden:YES];
  [_answerButton setHidden:NO];
  [_ignoreButton setHidden:NO];
  [self activateFlashing:_answerButton];
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
  [self activateFlashing:_dialButton];
}

- (IBAction)hangupButtonPressed:(id)sender
{
  [_connection disconnect];
  [self deactivateFlashing:_dialButton];
  [self deactivateFlashing:_answerButton];
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
  [self deactivateFlashing:_dialButton];
  [self deactivateFlashing:_answerButton];
}

- (void)connectionDidConnect:(TCConnection *)connection
{
  [self activateFlashing:_dialButton];
}

- (void)connectionDidDisconnect:(TCConnection *)connection
{
  [self deactivateFlashing:_dialButton];
}

- (void)connectionDidStartConnecting:(TCConnection *)connection
{
  
}

#pragma mark -

- (void)flashOff:(UIView *)v
{
  [UIView animateWithDuration:2.0 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
    v.alpha = .01;  //don't animate alpha to 0, otherwise you won't be able to interact with it
  } completion:^(BOOL finished) {
    [self flashOn:v];
  }];
}

- (void)flashOn:(UIView *)v
{
  [UIView animateWithDuration:2.0 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
    v.alpha = 1;
  } completion:^(BOOL finished) {
    if (_flashingOn) {
      [self flashOff:v];
    }
  }];
}

- (void)activateFlashing:(UIView *)v
{
  if (!_flashingOn) {
    _flashingOn = YES;
    [self flashOn:v];
  }
}

- (void)deactivateFlashing:(UIView *)v
{
  if (_flashingOn) {
    _flashingOn = NO;
  }
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
