//
//  FlixelFilterBWVertex.m
//  GPU_Image_Test
//
//  Created by Colin McDonald on 12-06-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlixelFilterBWVertex.h"

/*
 Exported using GLSL Studio: 2012-06-28 10:44 AM
 Name: Black and white vertex
 Author: flixel
 */

NSString *const kGPUImageFlixelFilterBWVertexShaderString = SHADER_STRING
(
 Pass thought Vertex Shader:
 
 attribute mediump vec4 position;
 attribute lowp vec2 coord;
 
 varying lowp vec2 coordVar;
 
 uniform mediump mat4 modelView;
 uniform mediump mat4 projection;
 uniform mediump mat3 normalMatrix;
 uniform lowp sampler2D tex;
 
 void main()
 {
     vec4 p = modelView * position;
     gl_Position = projection * p;
     coordVar = coord;
 }
 );

@implementation FlixelFilterBWVertex

@end
