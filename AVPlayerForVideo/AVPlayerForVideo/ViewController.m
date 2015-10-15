//
//  ViewController.m
//  AVPlayerForVideo
//
//  Created by Александр Карцев on 10/15/15.
//  Copyright © 2015 Alex Kartsev. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMovie];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setupMovie
{
    NSURL *url = [NSURL URLWithString:@"http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8"];
    self.player = [AVPlayer playerWithURL:url];
    [self.playerView setMovieToPlayer:self.player];
    [self.player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
