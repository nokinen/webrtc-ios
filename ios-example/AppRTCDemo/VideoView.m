//
//  VideoView.m
//
/*
 *
 * Last updated by: Gregg Ganley
 * Nov 2013
 *
 */


#import "VideoView.h"

#import "RTCVideoRenderer.h"
#import <QuartzCore/QuartzCore.h>

@interface VideoView () {
    UIInterfaceOrientation _videoOrientation;
    UIColor *_color;
    
    RTCVideoTrack* _track;
    RTCVideoTrack* _localTrack;
    
    RTCVideoRenderer* _renderer;
    RTCVideoRenderer* _localRenderer;
}

@property (nonatomic, retain) UIView<RTCVideoRenderView> *renderView;
@property (nonatomic, retain) UIView<RTCVideoRenderView> *localRenderView;

@end

@implementation VideoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)initialize
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.autoresizesSubviews = YES;
    
    self.renderView = [RTCVideoRenderer newRenderViewWithFrame:self.frame];
    self.renderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.localRenderView = [RTCVideoRenderer newRenderViewWithFrame:CGRectMake(0, 0, 120, 80)];
    
    [self addSubview:self.renderView];
    [self addSubview:self.localRenderView];
    
    [self setBackgroundColor:[UIColor redColor]];
}

- (void)setRemoteVideoTrack:(RTCVideoTrack *)track
{
    
    [_track removeRenderer:_renderer];
    [_renderer stop];
    
    _track = track;
    
    if (_track) {
        if (!_renderer) {
            _renderer = [[RTCVideoRenderer alloc] initWithRenderView:[self renderView]];
        }
        [_track addRenderer:_renderer];
        [_renderer start];
    }
}

- (void)setLocalVideoTrack:(RTCVideoTrack *)track
{
    
    [_localTrack removeRenderer:_renderer];
    [_localRenderer stop];
    
    _localTrack = track;
    
    if (_localTrack) {
        if (!_localRenderer) {
            _localRenderer = [[RTCVideoRenderer alloc] initWithRenderView:[self localRenderView]];
        }
        [_localTrack addRenderer:_localRenderer];
        [_localRenderer start];
    }
}

@end
