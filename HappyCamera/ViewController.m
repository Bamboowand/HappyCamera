//
//  ViewController.m
//  HappyCamera
//
//  Created by ChenWei on 2017/9/3.
//  Copyright © 2017年 ChenWei. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    toughButton = NO;
    inputCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    inputCamera.outputImageOrientation = UIInterfaceOrientationPortrait;

    
    currentFilter = [[GPUImageGrayscaleFilter alloc] init];
    GPUImageOutput<GPUImageInput>* nextFilter = [[GPUImageCannyEdgeDetectionFilter alloc] init];
    GPUImageOutput<GPUImageInput>* hough = [[GPUImageHistogramFilter alloc] init];
    GPUImageOutput<GPUImageInput>* exposureFilter  = [[GPUImageExposureFilter alloc] init];
    GPUImageOutput<GPUImageInput>* toonFilter            =[[GPUImageToonFilter alloc] init];
    GPUImageOutput<GPUImageInput>* spepiaFilter = [[GPUImageSepiaFilter alloc] init];
    
    
//    [inputCamera addTarget:currentFilter];
//    [currentFilter addTarget:_glView];
//    
//    
//    [inputCamera addTarget:nextFilter];
//    [nextFilter addTarget:_glView];
    
    
    NSMutableArray *filterArr = [NSMutableArray array];
    [filterArr addObject:currentFilter];
    [filterArr addObject:exposureFilter];
    [filterArr addObject:toonFilter];
    [filterArr addObject:spepiaFilter];
    
    

    filterPiepeline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:filterArr input:inputCamera output:_glView];

#pragma unused(nextFilter)
#pragma unused(hough)
    
    [inputCamera startCameraCapture];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)recordVideo:(id)sender {
    if(!toughButton){
        pathMovie = [NSHomeDirectory() stringByAppendingString:@"Documents/Movie4.mov"];
        unlink([pathMovie UTF8String]);
        NSURL *movieURL = [NSURL fileURLWithPath:pathMovie];
        movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480, 640)];
        movieWriter.encodingLiveVideo = YES;

        inputCamera.audioEncodingTarget = movieWriter;
        [movieWriter startRecording];
        _recordButtin.titleLabel.text = @"Stop";
        toughButton = YES;
    }else{
        inputCamera.audioEncodingTarget = nil;
        [movieWriter finishRecording];
        _recordButtin.titleLabel.text = @"Record";
        toughButton = NO;
    }
    
}
@end
