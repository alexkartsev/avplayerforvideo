//
//  ViewController.m
//  AVPlayerForVideo
//
//  Created by Александр Карцев on 10/15/15.
//  Copyright © 2015 Alex Kartsev. All rights reserved.
//

#import "ViewController.h"

static void *Context = &Context;

@interface ViewController ()

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (weak, nonatomic) IBOutlet UILabel *currentPlayerTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingPlayerTimeLabel;
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, assign) CMTime duration;
@property (nonatomic, strong) id playerTimeObserver;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setURL:[NSURL URLWithString:@"http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8"]];
    [self.mySlider setAutoresizingMask:(UIViewAutoresizingFlexibleWidth)];
    
    [self.mySlider addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDown];
    [self.mySlider addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventValueChanged];
    [self.mySlider addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpInside];
    [self.mySlider addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)doneLoadingAsset:(AVAsset *)asset withKeys:(NSArray *)keys {
    
    // Remove observer from old playerItem and create new one
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
    }
    
    [self setPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
    
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                         context:Context];
    
    if (!self.player) {
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];
        [self.playerView setMovieToPlayer:self.player];
        [self.player play];
    }
}


- (void)setURL:(NSURL *)url {
    self.asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *keys = @[@"tracks"];
    [self.asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doneLoadingAsset:self.asset withKeys:keys];
        });
    }];
}

- (IBAction)sliderAction:(id)sender {
}

- (IBAction)button:(id)sender {
    [self.player pause];
}

- (IBAction)playButton:(id)sender {
    [self.player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)syncScrobber {
    NSInteger currentSeconds = ceilf(CMTimeGetSeconds(self.player.currentTime));
    NSInteger seconds = currentSeconds % 60;
    NSInteger minutes = currentSeconds / 60;
    NSInteger hours = minutes / 60;
    minutes = minutes % 60;
    
    NSInteger duration = ceilf(CMTimeGetSeconds(self.duration));
    NSInteger currentDurationSeconds = duration-currentSeconds;
    NSInteger durationSeconds = currentDurationSeconds % 60;
    NSInteger durationMinutes = currentDurationSeconds / 60;
    NSInteger durationHours = durationMinutes / 60;
    durationMinutes = durationMinutes % 60;
    
    [self.currentPlayerTimeLabel setText:[NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds]];
    [self.remainingPlayerTimeLabel setText:[NSString stringWithFormat:@"-%02ld:%02ld:%02ld", (long)durationHours, (long)durationMinutes, (long)durationSeconds]];
    
    [self.mySlider setMinimumValue:0.];
    [self.mySlider setMaximumValue:duration];
    [self.mySlider setValue:currentSeconds];
}

- (void)addPlayerTimeObserver {
    if (!_playerTimeObserver) {
        __unsafe_unretained ViewController *weakSelf = self;
        id observer = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(.5, NSEC_PER_SEC)
                                                                queue:dispatch_get_main_queue()
                                                           usingBlock:^(CMTime time) {
                                                               
                                                               ViewController *strongSelf = weakSelf;
                                                               if (CMTIME_IS_VALID(strongSelf.player.currentTime) && CMTIME_IS_VALID(strongSelf.duration))
                                                                   [strongSelf syncScrobber];
                                                           }];
        [self setPlayerTimeObserver:observer];
    }
}

- (CMTime)duration {
    if ([self.playerItem respondsToSelector:@selector(duration)] && // 4.3
        self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        if (CMTIME_IS_VALID(self.playerItem.duration))
            return self.playerItem.duration;
    }
    
    else if (CMTIME_IS_VALID(self.player.currentItem.asset.duration))
        return self.player.currentItem.asset.duration;
    
    return kCMTimeInvalid;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == Context) {
        if ([keyPath isEqualToString:@"status"])
        {
            AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
            switch (status) {
                case AVPlayerStatusUnknown: {
                    self.currentPlayerTimeLabel.text = @"00.00.00";
                    self.remainingPlayerTimeLabel.text = @"00.00.00";
                    [self removePlayerTimeObserver];
                }
                    break;
                    
                case AVPlayerStatusReadyToPlay: {

                    [self addPlayerTimeObserver];
                }
                    break;
                    
                case AVPlayerStatusFailed: {
                    [self removePlayerTimeObserver];
                    [self syncScrobber];
                    

                }
                    break;
            }
        }
    }
    

}

- (void)removePlayerTimeObserver {
    if (_playerTimeObserver) {
        [self.player removeTimeObserver:self.playerTimeObserver];
        [self setPlayerTimeObserver:nil];
    }
}

- (void)dealloc {
    [self removePlayerTimeObserver];
}


- (void)scrub:(id)sender {
    [self.player seekToTime:CMTimeMakeWithSeconds(self.mySlider.value, NSEC_PER_SEC)];
}

- (void)beginScrubbing:(id)sender {
    [self removePlayerTimeObserver];
}

- (void)endScrubbing:(id)sender {
    [self addPlayerTimeObserver];
}

@end

