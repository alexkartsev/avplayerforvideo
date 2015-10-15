//
//  AVPlayerClass.m
//  AVPlayerForVideo
//
//  Created by Александр Карцев on 10/15/15.
//  Copyright © 2015 Alex Kartsev. All rights reserved.
//

#import "AVPlayerClass.h"

@implementation AVPlayerClass

+(Class) layerClass
{
    return [AVPlayerLayer class];
}

-(AVPlayer *)player
{
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setMovieToPlayer:(AVPlayer *)player
{
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

@end
