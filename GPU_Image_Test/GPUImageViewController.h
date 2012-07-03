//
//  GPUImageViewController.h
//  GPU_Image_Test
//
//  Created by Colin McDonald on 12-06-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPUImageViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

-(IBAction)showLog:(id)sender;
-(IBAction)refreshImages:(id)sender;
-(IBAction)processImageGPUCoreImage:(id)sender;
-(IBAction)processImageCPUCoreImage:(id)sender;
-(IBAction)processImageGPUImage:(id)sender;

@end
