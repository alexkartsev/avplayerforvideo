//
//  ViewController.h
//  AVPlayerForVideo
//
//  Created by Александр Карцев on 10/15/15.
//  Copyright © 2015 Alex Kartsev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVPlayerClass.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISlider *mySlider;
@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) IBOutlet AVPlayerClass* playerView;

@end

