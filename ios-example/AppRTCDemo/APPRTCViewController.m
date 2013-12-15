/*
 * libjingle
 * Copyright 2013, Google Inc.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 *
 * Last updated by: Gregg Ganley
 * Nov 2013
 *
 */

#import "APPRTCViewController.h"
#import "APPRTCAppDelegate.h"
#import "RTCVideoRenderer.h"
#import "VideoView.h"
#import <QuartzCore/QuartzCore.h>

@interface APPRTCViewController ()

@end

@implementation APPRTCViewController

@synthesize textField = _textField;
@synthesize textInstructions = _textInstructions;
@synthesize textOutput = _textOutput;
@synthesize videoRenderer = _videoRenderer;
@synthesize videoView = _videoView;

- (void)viewDidLoad {
  [super viewDidLoad];
  self.textField.delegate = self;
    
  self.textField.keyboardType = UIKeyboardTypeNumberPad;
    
  UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
  numberToolbar.barStyle = UIBarStyleBlackTranslucent;
  numberToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                         nil];
  [numberToolbar sizeToFit];
  self.textField.inputAccessoryView = numberToolbar;
    
  if ([self connectedToInternet] == NO) {
      NSLog(@"NO INTERNET connection!");
  }
}

-(void)cancelNumberPad{
    [self.textField resignFirstResponder];
    self.textField.text = @"";
}

- (BOOL) connectedToInternet
{
    NSString *URLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.google.com"]];
    return ( URLString != NULL ) ? YES : NO;
}

-(void)doneWithNumberPad {
    //**
    //** this overides the textFieldDidEndEditing delegate below
    NSString *numberFromTheKeyboard = self.textField.text;
    [self.textField resignFirstResponder];
    
    NSString *room = numberFromTheKeyboard;
    if ([room length] == 0) {
        return;
    }
    
    NSString *url =
        [NSString stringWithFormat:@"apprtc://apprtc.appspot.com/?r=%@", room];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
    //** launch Video View
    [self setVideoCapturer];
}


- (void)displayText:(NSString *)text {
  dispatch_async(dispatch_get_main_queue(), ^(void) {
    NSString *output =
        [NSString stringWithFormat:@"%@\n%@", self.textOutput.text, text];
    self.textOutput.text = output;
  });
}

- (void)resetUI {
  self.textField.text = nil;
  self.textField.hidden = NO;
  self.textInstructions.hidden = NO;
  self.textOutput.hidden = YES;
  self.textOutput.text = nil;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
  //**
  //** see doneWithNumberPad above

  NSString *room = textField.text;
  if ([room length] == 0) {
    return;
  }
  textField.hidden = YES;
  self.textInstructions.hidden = YES;
  self.textOutput.hidden = NO;
  // TODO(hughv): Instead of launching a URL with apprtc scheme, change to
  // prepopulating the textField with a valid URL missing the room.  This allows
  // the user to have the simplicity of just entering the room or the ability to
  // override to a custom appspot instance.  Remove apprtc:// when this is done.
  NSString *url =
      [NSString stringWithFormat:@"apprtc://apprtc.appspot.com/?r=%@", room];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  // There is no other control that can take focus, so manually resign focus
  // when return (Join) is pressed to trigger |textFieldDidEndEditing|.
  [textField resignFirstResponder];
  return YES;
}

- (void)setVideoCapturer {

    //---------------------------------
	//----- SETUP CAPTURE SESSION -----
	//---------------------------------

	NSLog(@"Setting up capture session");
    self.captureSession = [[AVCaptureSession alloc] init];
	

	//----- ADD INPUTS -----
	NSLog(@"Adding video input");
	
	//ADD VIDEO INPUT
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if (device)
	{
		NSError *error;
		self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
		if (!error)
		{
			if ([self.captureSession canAddInput:self.videoInput])
				[self.captureSession addInput:self.videoInput];
			else
				NSLog(@"Couldn't add video input");
		}
		else
		{
			NSLog(@"Couldn't create video input");
		}
	}
	else
	{
		NSLog(@"Couldn't create video capture device");
	}
	
    //----- SET THE IMAGE QUALITY / RESOLUTION -----
	//Options:
	//	AVCaptureSessionPresetHigh - Highest recording quality (varies per device)
	//self.captureSession.sessionPreset = AVCaptureSessionPresetLow; // AVCaptureSessionPresetMedium; // - Suitable for WiFi sharing (actual values may change)
	//	AVCaptureSessionPresetLow - Suitable for 3G sharing (actual values may change)
	self.captureSession.sessionPreset = AVCaptureSessionPreset640x480; // - 640x480 VGA (check its supported before setting it)
	//	AVCaptureSessionPreset1280x720 - 1280x720 720p HD (check its supported before setting it)
	//	AVCaptureSessionPresetPhoto - Full photo resolution (not supported for video output)
    
	NSLog(@"Setting image quality");
	if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
		[self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    }

//    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
//    previewLayer.frame = CGRectMake(20, 20, 120, 80);
    
    //** This places the VideoView window on the screen at this location, change to move around
    _videoView = [[VideoView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_videoView];
//    [[self.view layer]addSublayer:previewLayer];

    //** if interested in adding a self view  to your video conference app
//    UIView<RTCVideoRenderView> *rv = [RTCVideoRenderer newRenderViewWithFrame:CGRectMake(20, 20, 120, 80)];
//    _videoRenderer = [[RTCVideoRenderer alloc] initWithRenderView:rv];
    
//    APPRTCAppDelegate *ad = (APPRTCAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [[ad localVideoTrack] addRenderer:_videoRenderer];

    //----- START THE CAPTURE SESSION RUNNING -----
	[self.captureSession startRunning];
    
}


@end
