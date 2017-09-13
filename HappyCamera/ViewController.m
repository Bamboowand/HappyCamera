//
//  ViewController.m
//  HappyCamera
//
//  Created by ChenWei on 2017/9/3.
//  Copyright © 2017年 ChenWei. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/ALAssetsLibrary.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self initGPUImageVideoCamera];
    [self initGPUImageStillCamera];
    
}
#pragma mark- initCamera
-(void)initGPUImageVideoCamera{
    toughButton = NO;
    inputCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    inputCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    
    currentFilter = [[GPUImageGrayscaleFilter alloc] init];
    //    GPUImageOutput<GPUImageInput>* nextFilter = [[GPUImageCannyEdgeDetectionFilter alloc] init];
    //    GPUImageOutput<GPUImageInput>* hough = [[GPUImageHistogramFilter alloc] init];
    //    GPUImageOutput<GPUImageInput>* exposureFilter  = [[GPUImageExposureFilter alloc] init];
    //    GPUImageOutput<GPUImageInput>* toonFilter            =[[GPUImageToonFilter alloc] init];
    //    GPUImageOutput<GPUImageInput>* spepiaFilter = [[GPUImageSepiaFilter alloc] init];
    
    
    [inputCamera addTarget:currentFilter];
    [currentFilter addTarget:_glView];
    //
    //
    //    [inputCamera addTarget:nextFilter];
    //    [nextFilter addTarget:_glView];
    
    
    //    NSMutableArray *filterArr = [NSMutableArray array];
    //    [filterArr addObject:currentFilter];
    //    [filterArr addObject:exposureFilter];
    //    [filterArr addObject:toonFilter];
    //    [filterArr addObject:spepiaFilter];
    //
    //    filterPiepeline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:filterArr input:inputCamera output:_glView];
    
#pragma unused(nextFilter)
#pragma unused(hough)
    
    [inputCamera startCameraCapture];
}

-(void)initGPUImageStillCamera{
    _stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    _stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _stillCamera.horizontallyMirrorFrontFacingCamera = YES;
    _stillCamera.horizontallyMirrorRearFacingCamera = NO;
    
    _filter = [[GPUImageGrayscaleFilter alloc] init];
    
    [_stillCamera addTarget:_filter];
    [_filter addTarget:_glView];
    
    [_stillCamera startCameraCapture];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Action function
- (IBAction)recordVideo:(id)sender {
    
//    pathMovie = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Movie%lld.m4v", (long long)[[NSDate date] timeIntervalSince1970]]];
    pathMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Movie013.m4v"];
    unlink([pathMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathMovie];
    
    if(!toughButton){
        movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
        movieWriter.encodingLiveVideo = YES;
        [currentFilter addTarget:movieWriter];

        inputCamera.audioEncodingTarget = movieWriter;
        [movieWriter startRecording];
        
        
        _recordButtin.titleLabel.text = @"Stop";
        toughButton = YES;
    }else{
        [currentFilter removeTarget:movieWriter];
        inputCamera.audioEncodingTarget = nil;
        [movieWriter finishRecording];
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:movieURL])
        {
            [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     if (error) {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                     } else {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                                        delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                     }
                 });
             }];
        }
        
        
        _recordButtin.titleLabel.text = @"R";
        toughButton = NO;
    }
    
}

- (IBAction)captureImage:(UIButton *)sender {
    [_stillCamera capturePhotoAsJPEGProcessedUpToFilter:_filter withCompletionHandler:^(NSData *processedJPEG, NSError *error){
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageDataToSavedPhotosAlbum:processedJPEG metadata:_stillCamera.currentCaptureMetadata completionBlock:^(NSURL *assetURL, NSError *saveError){
            if(saveError){
                NSLog(@"Error: The image failed to be written");
            }else{
                NSLog(@"Photo saved :%@", assetURL);
            }
        }];
    }];
}
@end
