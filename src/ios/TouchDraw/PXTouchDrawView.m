#import <QuartzCore/QuartzCore.h>
#import "PXTouchDrawView.h"

@implementation PXTouchDrawView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Only one finger/stylus for signing/drawing
        [self setMultipleTouchEnabled:NO];
    }

    return self;
}

@end
