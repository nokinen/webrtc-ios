//
//  VideoView.h
//
/*
 *
 * Last updated by: Gregg Ganley
 * Nov 2013
 *
 */

#import <UIKit/UIKit.h>
#import "RTCVideoTrack.h"

@interface VideoView : UIView

- (void)setRemoteVideoTrack:(RTCVideoTrack *)track;
- (void)setLocalVideoTrack:(RTCVideoTrack *)track;

@end
