//
//  GPUImageViewController.m
//  GPU_Image_Test
//
//  Created by Colin McDonald on 12-06-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GPUImage.h"
#import "GPUImageViewController.h"
//#import "FlixelFilterBWVertex.h"

@interface GPUImageViewController ()

@property (nonatomic, strong) NSString *logString;
@property (nonatomic, strong) NSMutableArray *imagesToFilter;

@end

@implementation GPUImageViewController

NSInteger const NUMBER_OF_IMAGES = 40;

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
    
    // if the images array has not yet been defined,
    // then create it and load it with images
    if(nil == self.imagesToFilter)
        self.imagesToFilter = [NSMutableArray arrayWithCapacity:NUMBER_OF_IMAGES];
    
    for(int i=0; i<NUMBER_OF_IMAGES; i++)
        if([self.imagesToFilter count] > i)
            [self.imagesToFilter replaceObjectAtIndex:i withObject:[UIImage imageNamed:@"porsche.jpg"]];
        else 
            [self.imagesToFilter addObject:[UIImage imageNamed:@"porsche.jpg"]];
    
    // set the image view up to display an animation of 
    // of all of the images in array initialized above
    [self startImageViewAnimation];
}

-(void)startImageViewAnimation {
    [self.imageView setAnimationImages:self.imagesToFilter];
    [self.imageView startAnimating];
}

-(IBAction)processImageGPUCoreImage:(id)sender {
    NSLog(@"Processing Image on GPU w/ Core Image");
    NSDate *startTime = [NSDate date];
    
    // process each image in the image array
    for(int i=0; i<NUMBER_OF_IMAGES; i++)
    {
        //NSLog(@"Processing Image: %d", i + 1);
        UIImage *currentImage = [self.imagesToFilter objectAtIndex:i];
        [self porcessImage:&currentImage CoreImageWithCPURendering:NO];
        
        // I would love if we were able to process the image by reference from the 
        // array, rather than having to replace the object...but objective-c arrays
        // are not like C/C++ arrays apparently :(
        [self.imagesToFilter replaceObjectAtIndex:i withObject:currentImage];
    }
        
    NSDate *endTime = [NSDate date];
    NSTimeInterval executionTime = [endTime timeIntervalSinceDate:startTime];
    NSString *timeResultMessage = [NSString stringWithFormat:@"Rendering on GPU with CoreImage took: %f seconds.", executionTime];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Results" message:timeResultMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    self.logString = [NSString stringWithFormat:@"%@\n%@", self.logString, timeResultMessage];
    
    // reload images in the ImageView
    [self startImageViewAnimation];
}

-(IBAction)processImageCPUCoreImage:(id)sender {
    NSLog(@"Processing Image on CPU w/ Core Image");
    NSDate *startTime = [NSDate date];
    
    // process each image in the image array
    for(int i=0; i<NUMBER_OF_IMAGES; i++)
    {
        //NSLog(@"Processing Image: %d", i + 1);
        UIImage *currentImage = [self.imagesToFilter objectAtIndex:i];
        [self porcessImage:&currentImage CoreImageWithCPURendering:YES];
        
        // I would love if we were able to process the image by reference from the 
        // array, rather than having to replace the object...but objective-c arrays
        // are not like C/C++ arrays apparently :(
        [self.imagesToFilter replaceObjectAtIndex:i withObject:currentImage];
    }
    
    NSDate *endTime = [NSDate date];
    
    NSTimeInterval executionTime = [endTime timeIntervalSinceDate:startTime];
    NSString *timeResultMessage = [NSString stringWithFormat:@"Rendering on CPU with CoreImage took: %f seconds.", executionTime];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Results" message:timeResultMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    self.logString = [NSString stringWithFormat:@"%@\n%@", self.logString, timeResultMessage];
    
    // reload images in the ImageView
    [self startImageViewAnimation];
}

-(void)porcessImage:(UIImage **) image CoreImageWithCPURendering:(BOOL)CPURendering {
    // note...UIImage.CIImage does not work in some cases...the below is most compatible
    CIImage *beginImage = [CIImage imageWithCGImage:(*image).CGImage];
    
    CIContext *context = [CIContext contextWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:CPURendering] forKey:kCIContextUseSoftwareRenderer]];
    
    // NOTE: an input intensity of 0.5 approx matches what is produced by the GPUImage Sepia filter
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey, beginImage, @"inputIntensity", [NSNumber numberWithFloat:0.5], nil];
    
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    *image = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
}

-(IBAction)processImageGPUImage:(id)sender {
    NSLog(@"Processing Image on GPU w/ GPUImage");
    NSDate *startTime = [NSDate date];
    
    for(int i=0; i<NUMBER_OF_IMAGES; i++)
    {
        //NSLog(@"Processing Image: %d", i + 1);
        UIImage *currentImage = [self.imagesToFilter objectAtIndex:i];
        GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:currentImage];
        GPUImageSepiaFilter *stillImageFilter = [[GPUImageSepiaFilter alloc] init];
        //FlixelFilterBWVertex *flixelFilter = [[FlixelFilterBWVertex alloc] init];
        
        [stillImageSource addTarget:stillImageFilter];
        [stillImageSource processImage];
        
        // this statement is likely the one that the Apple engineer said could hamper 
        // performance (in comparison with CoreImage)
        UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentlyProcessedOutput];
        
        [self.imagesToFilter replaceObjectAtIndex:i withObject:currentFilteredVideoFrame];
    }
        
    NSDate *endTime = [NSDate date];
    NSTimeInterval executionTime = [endTime timeIntervalSinceDate:startTime];
    NSString *timeResultMessage = [NSString stringWithFormat:@"Rendering on GPU with GPUImage took: %f seconds.", executionTime];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Results" message:timeResultMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    self.logString = [NSString stringWithFormat:@"%@\n%@", self.logString, timeResultMessage];
    
    // reload images in the ImageView
    [self startImageViewAnimation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
