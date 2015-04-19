//
//  Copyright 2011-2015 Twilio. All rights reserved.
//
//  Use of this software is subject to the terms and conditions of the
//  Twilio Terms of Service located at http://www.twilio.com/legal/tos
//
 
#import "FocusCallingViewController.h"
#import "FocusCallingAppDelegate.h"
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEFliteController.h>
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OELogging.h>
#import <OpenEars/OEAcousticModel.h>
#import <Slt/Slt.h>
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
@property (nonatomic, strong) Slt *slt;
@property (nonatomic, strong) OEEventsObserver *openEarsEventsObserver;
@property (nonatomic, strong) OEPocketsphinxController *pocketsphinxController;
@property (nonatomic, strong) OEFliteController *fliteController;

// Things which help us show off the dynamic language features.
@property (nonatomic, copy) NSString *pathToDynamicallyGeneratedLanguageModel;
@property (nonatomic, copy) NSString *pathToDynamicallyGeneratedDictionary;
@end

@implementation FocusCallingViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self initializeOpenEars];
  
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
- (void)dealloc {
  [self openEarsStopListening];
}

- (void)initializeOpenEars {
  // OpenEars object initialization
  self.fliteController = [[OEFliteController alloc] init];
  self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
  self.openEarsEventsObserver.delegate = self;
  self.slt = [[Slt alloc] init];
  
  // OpenEars
  [self.openEarsEventsObserver setDelegate:self]; // Make this class the delegate of OpenEarsObserver so we can get all of the messages about what OpenEars is doing.
  
  [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil]; // Call this before setting any OEPocketsphinxController characteristics
  
  // This is the language model we're going to start up with. The only reason I'm making it a class property is that I reuse it a bunch of times in this example,
  // but you can pass the string contents directly to OEPocketsphinxController:startListeningWithLanguageModelAtPath:dictionaryAtPath:languageModelIsJSGF:
  
  NSArray *languageArray = @[@"HEY",
                             @"OK",
                             @"HELLO",
                             @"HI",
                             @"FOCUS",
                             @"CALL",
                             @"TEXT",
                             @"JOE",
                             @"TIM",
                             @"BLAD",
                             @"DAVE"];
  OELanguageModelGenerator *languageModelGenerator = [[OELanguageModelGenerator alloc] init];
  
  // languageModelGenerator.verboseLanguageModelGenerator = TRUE; // Uncomment me for verbose language model generator debug output.
  
  NSError *error = [languageModelGenerator generateLanguageModelFromArray:languageArray withFilesNamed:@"FirstOpenEarsDynamicLanguageModel" forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" in order to create a language model for Spanish recognition instead of English.
  
  
  if(error) {
    NSLog(@"Dynamic language generator reported error %@", [error description]);
  } else {
    self.pathToDynamicallyGeneratedLanguageModel = [languageModelGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"FirstOpenEarsDynamicLanguageModel"];
    self.pathToDynamicallyGeneratedDictionary = [languageModelGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"FirstOpenEarsDynamicLanguageModel"];
  }
  
  [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil]; // Call this once before setting properties of the OEPocketsphinxController instance.
  
  // start listening
  [self openEarsStartListening];
}

- (void)openEarsStartListening {
  if(![OEPocketsphinxController sharedInstance].isListening) {
    [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE]; // Start speech recognition if we aren't already listening.
  }
}

- (void)openEarsStopListening {
  NSError *error = nil;
  if([OEPocketsphinxController sharedInstance].isListening) { // Stop if we are currently listening.
    error = [[OEPocketsphinxController sharedInstance] stopListening];
    if(error)NSLog(@"Error stopping listening in stopButtonAction: %@", error);
  }
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

#pragma mark OEEventsObserver delegate methods

// This is an optional delegate method of OEEventsObserver which delivers the text of speech that Pocketsphinx heard and analyzed, along with its accuracy score and utterance ID.
- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
  
  NSLog(@"Local callback: The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID); // Log it.
  
//  self.heardTextView.text = [NSString stringWithFormat:@"Heard: \"%@\"", hypothesis]; // Show it in the status box.
//  
//  // This is how to use an available instance of OEFliteController. We're going to repeat back the command that we heard with the voice we've chosen.
//  [self.fliteController say:[NSString stringWithFormat:@"You said %@",hypothesis] withVoice:self.slt];
  [self.toField setText:hypothesis];
}

// An optional delegate method of OEEventsObserver which informs that Pocketsphinx detected speech and is starting to process it.
- (void) pocketsphinxDidDetectSpeech {
  
}

/** Pocketsphinx couldn't start because it has no mic permissions (will only be returned on iOS7 or later).*/
- (void) pocketsphinxFailedNoMicPermissions {
  
}

/** The user prompt to get mic permissions, or a check of the mic permissions, has completed with a TRUE or a FALSE result  (will only be returned on iOS7 or later).*/
- (void) micPermissionCheckCompleted:(BOOL)result {
  
}

#pragma mark - keyboard

- (void)dismissKeyboard {
  [self.view endEditing:YES];
}

#pragma mark - touch actions

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  if ([touch.view isKindOfClass:[UIButton class]]) {
    return NO;
  }
  return YES;
}

@end
