//
//  AVPlayerClass.h
//  AVPlayerForVideo
//
//  Created by Александр Карцев on 10/15/15.
//  Copyright © 2015 Alex Kartsev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class AVPlayer;

@interface AVPlayerClass : UIView

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSURL *url;


- (void)setMovieToPlayer:(AVPlayer *) player;

@end
