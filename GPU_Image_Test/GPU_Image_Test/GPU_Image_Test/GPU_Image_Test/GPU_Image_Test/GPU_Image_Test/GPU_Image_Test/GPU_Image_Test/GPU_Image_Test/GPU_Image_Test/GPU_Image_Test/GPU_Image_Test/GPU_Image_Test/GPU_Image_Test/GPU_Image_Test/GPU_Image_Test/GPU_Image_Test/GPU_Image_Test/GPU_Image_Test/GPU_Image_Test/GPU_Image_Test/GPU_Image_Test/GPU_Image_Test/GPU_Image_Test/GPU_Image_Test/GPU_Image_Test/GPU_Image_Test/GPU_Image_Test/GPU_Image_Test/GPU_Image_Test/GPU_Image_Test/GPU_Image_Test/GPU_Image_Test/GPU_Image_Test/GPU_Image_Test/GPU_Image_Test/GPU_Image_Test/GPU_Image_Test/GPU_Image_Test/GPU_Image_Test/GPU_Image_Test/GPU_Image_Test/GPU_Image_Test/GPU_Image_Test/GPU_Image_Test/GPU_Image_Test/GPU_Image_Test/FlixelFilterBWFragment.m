/*
 Exported using GLSL Studio: 2012-06-28 10:44 AM
 Name: Black and white fragment
 Author: flixel
 */

#import "FlixelFilterBWFragment.h"

NSString *const kGPUImageFlixelFilterBWFragmentShaderString = SHADER_STRING
(
    varying lowp vec2 coordVar;
     
    uniform mediump mat4 modelView;
    uniform mediump mat4 projection;
    uniform mediump mat3 normalMatrix;
    uniform lowp sampler2D tex;
     
     
    void main()
    {
        
        lowp vec4 tColor = texture2D(tex, coordVar);
        lowp float bwColor = (tColor.r + tColor.g + tColor.b)/3.0;
        lowp vec4 myBWColor = vec4(bwColor, bwColor, bwColor, 1.0);
        gl_FragColor = myBWColor;
    }
);

@implementation FlixelFilterBWFragment

@end
