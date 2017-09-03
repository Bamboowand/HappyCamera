//
//  ViewController.h
//  HappyCamera
//
//  Created by ChenWei on 2017/9/3.
//  Copyright © 2017年 ChenWei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface ViewController : UIViewController{
    GPUImageVideoCamera *inputCamera;
    GPUImageOutput<GPUImageInput> *currentFilter;
    GPUImageFilterPipeline *filterPiepeline;
    GPUImageMovieWriter *movieWriter;
    BOOL toughButton;
    NSString *pathMovie;
}

@property(nonatomic, weak)IBOutlet GPUImageView *glView;
@property (weak, nonatomic) IBOutlet UIButton *recordButtin;
- (IBAction)recordVideo:(id)sender;

@end

