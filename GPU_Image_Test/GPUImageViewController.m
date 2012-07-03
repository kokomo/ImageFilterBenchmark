//
//  GPUImageViewController.m
//  GPU_Image_Test
//
//  Created by Colin McDonald on 12-06-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GPUImage.h"
#import "GPUImageViewController.h"
#import "FlixelFilterBWVertex.h"

@interface GPUImageViewController ()

@property (nonatomic, strong) NSString *logString;
@property (nonatomic, strong) NSMutableArray *imagesToFilter;
@end

@implementation GPUImageViewController

@synthesize imageView=_imageView, logString=_logString, imagesToFilter=_imagesToFilter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshImages:self];
    self.logString = @"";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(IBAction)showLog:(id)sender {
    NSLog(@"Showing Log");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Results" message:self.logString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    self.logString = @"";
}

-(IBAction)refreshImages:(id)sender {
    NSLog(@"Refreshing Image");
    
    int numberOfImages = 1;
    
    if(nil == self.imagesToFilter)
    {
        self.imagesToFilter = [NSMutableArray arrayWithCapacity:numberOfImages];
        for(int i=0; i<numberOfImages; i++)
            [self.imagesToFilter addObject:[UIImage imageNamed:@"porsche.jpg"]];
    }

    //[self startImageViewAnimation];
}

-(void)startImageViewAnimation {
    //self.imageView = nil;
    //self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [self.imagesToFilter objectAtIndex:0];
    //[self.imageView setAnimationImages:self.imagesToFilter];
    //[self.imageView startAnimating];
}

-(IBAction)processImageGPUCoreImage:(id)sender {
    NSLog(@"Processing Image on GPU w/ Core Image");
    NSDate *startTime = [NSDate date];
    
    NSEnumerator *e = [self.imagesToFilter objectEnumerator];
    UIImage *currentImage;
    
    int i = 0;
    while (currentImage = [e nextObject]) {
        NSLog(@"Processing Image: %d", ++i);
        UIImage *image = [self.imagesToFilter objectAtIndex:0];
        [self porcessImage:&image CoreImageWithCPURendering:NO];
    }
        
    NSDate *endTime = [NSDate date];
    NSTimeInterval executionTime = [endTime timeIntervalSinceDate:startTime];
    NSString *timeResultMessage = [NSString stringWithFormat:@"Rendering on GPU with CoreImage took: %f seconds.", executionTime];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Results" message:timeResultMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    self.logString = [NSString stringWithFormat:@"%@\n%@", self.logString, timeResultMessage];
    
    [self startImageViewAnimation];
}

-(IBAction)processImageCPUCoreImage:(id)sender {
    NSLog(@"Processing Image on CPU w/ Core Image");
    NSDate *startTime = [NSDate date];
    
    //[self porcessImageCoreImageWithCPURendering:YES];
    
    NSDate *endTime = [NSDate date];
    NSTimeInterval executionTime = [endTime timeIntervalSinceDate:startTime];
    NSString *timeResultMessage = [NSString stringWithFormat:@"Rendering on CPU with CoreImage took: %f seconds.", executionTime];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Results" message:timeResultMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    self.logString = [NSString stringWithFormat:@"%@\n%@", self.logString, timeResultMessage];
}

-(void)porcessImage:(UIImage **) image CoreImageWithCPURendering:(BOOL)CPURendering {
    // note...UIImage.CIImage does not work in some cases...the below is most compatible
    CIImage *beginImage = [CIImage imageWithCGImage:(*image).CGImage];
    
    CIContext *context = [CIContext contextWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:CPURendering] forKey:kCIContextUseSoftwareRenderer]];
    
    // NOTE: an input intensity of 0.5 approx matches what is produced by the GPUImage Sepia filter
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey, beginImage, @"inputIntensity", [NSNumber numberWithFloat:0.5], nil];
    
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    //UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    *image = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
}

-(IBAction)processImageGPUImage:(id)sender {
    NSLog(@"Processing Image on GPU w/ GPUImage");
    NSDate *startTime = [NSDate date];
    
    UIImage *inputImage = self.imageView.image;
    
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
    GPUImageSepiaFilter *stillImageFilter = [[GPUImageSepiaFilter alloc] init];
    //FlixelFilterBWVertex *flixelFilter = [[FlixelFilterBWVertex alloc] init];
    
    [stillImageSource addTarget:stillImageFilter];
    [stillImageSource processImage];
    
    UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentlyProcessedOutput];
    self.imageView.image = currentFilteredVideoFrame;
    
    NSDate *endTime = [NSDate date];
    NSTimeInterval executionTime = [endTime timeIntervalSinceDate:startTime];
    NSString *timeResultMessage = [NSString stringWithFormat:@"Rendering on GPU with GPUImage took: %f seconds.", executionTime];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Results" message:timeResultMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    self.logString = [NSString stringWithFormat:@"%@\n%@", self.logString, timeResultMessage];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
