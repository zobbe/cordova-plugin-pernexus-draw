//
//  TouchViewController.m
//
//  Created by Morten Zobbe on 06/12/16.
//

#import <QuartzCore/QuartzCore.h>
#import "PXTouchDrawViewController.h"
#import "PXTouchDrawView.h"
#import <AVFoundation/AVFoundation.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@implementation PXTouchDrawViewController
{
    BOOL coloursShown;
    CGRect buttonsAnimationStartFrame;
    BOOL sizesShown;
    CGRect sizeAnimationStartFrame;
    float penSize;
    
}

@synthesize mainImage;
@synthesize tempDrawImage;
@synthesize imageLayer;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //disable gesture recognizer
    for (UIGestureRecognizer *recognizer in
         self.navigationController.view.gestureRecognizers) {
        [recognizer setEnabled:NO];
    }
    

}

- (void)setUpToolbar
{
    NSArray *items = [[NSArray alloc] init];
    
    UIBarButtonItem *btSize = [[UIBarButtonItem alloc] initWithTitle:@"Tykkelse" style:UIBarButtonItemStylePlain target:self action:@selector(toggleSize:event:)];
    
    UIBarButtonItem *btRecycle = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                               target:self
                                                                               action:@selector(clearAll)];
    UIBarButtonItem *btSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                            target:self
                                                                            action:@selector(saveAll)];
    
    UIBarButtonItem *btPickImage = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                 target:self
                                                                                 action:@selector(pickImage)];
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    
    self.navigationItem.rightBarButtonItem = btSave;
    
    if (self.drawingType != DrawingTypeBW) {
        self.colorBtn = [[UIButton alloc] init];
        self.colorBtn.frame = CGRectMake(0, 0, 30, 30);
        self.colorBtn.layer.borderColor = [UIColor blackColor].CGColor;
        self.colorBtn.layer.borderWidth = 2;
        self.colorBtn.backgroundColor = self.colour;
        [self.colorBtn addTarget:self action:@selector(toggleColour:event:) forControlEvents:UIControlEventTouchUpInside];
        self.colorBtn.layer.cornerRadius = 0.5 * self.colorBtn.bounds.size.width;
        self.btColour = [[UIBarButtonItem alloc] initWithCustomView:self.colorBtn];
        [self setColourButtonColour];
    }
    
    if (self.drawingType == DrawingTypeBW) {
        items = [NSArray arrayWithObjects:btRecycle, flexItem, btSize, nil];
    }
    
    if (self.drawingType == DrawingTypeColor) {
        items = [NSArray arrayWithObjects:self.btColour, flexItem, btRecycle, flexItem, btSize, nil];
    }
    
    if (self.drawingType == DrawingTypeImageAnnotation) {
        items = [NSArray arrayWithObjects:self.btColour, flexItem, btRecycle, flexItem, btPickImage, flexItem, btSize, nil];
    }
    
    [self setToolbarItems:items animated:YES];

    [[self navigationController] setToolbarHidden:NO animated:NO];
    self.navigationController.toolbar.barStyle = UIBarStyleDefault;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.mainImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.tempDrawImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backgroundLayer = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backgroundLayer.backgroundColor = [UIColor whiteColor];
    self.imageLayer = [[UIImageView alloc] init];

    self.backgroundLayer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mainImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tempDrawImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageLayer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.backgroundLayer];
    [self.view addSubview:self.imageLayer];
    [self.view addSubview:self.mainImage];
    [self.view addSubview:self.tempDrawImage];

    if (self.drawingType == DrawingTypeBW) {
        self.colour = [UIColor blackColor];
    }
    else {
       self.colour = [UIColor redColor];
    }
    
    penSize = 10.0f;

    [self setUpToolbar];
    NSArray *subviews = [[[self navigationController] navigationBar] subviews];
    for(UIView *view in subviews){
        if([view isKindOfClass:[UITextField class]])
            [view setHidden:YES];
    }
    [[self navigationController]setNavigationBarHidden:NO];
    self.navigationController.toolbar.translucent = NO;
}

- (void)toggleSize:(id)sender event:(UIEvent*)event
{
    UIView *targetedView = [[event.allTouches anyObject] view];
    sizeAnimationStartFrame = [self.view convertRect:targetedView.frame
                                               fromView:targetedView];
    
    if (sizesShown)
    {
        [self hideSizeButtons];
    }
    else
    {
        [self showSizeButtons];
    }

}

- (void)toggleColour:(id)sender event:(UIEvent*)event
{
    UIView *targetedView = [[event.allTouches anyObject] view];
    buttonsAnimationStartFrame = [self.view convertRect:targetedView.frame
                                               fromView:targetedView];

    if (coloursShown)
    {
        [self hideColourButtons];
    }
    else
    {
        [self showColourButtons];
    }
}

- (void)showSizeButtons
{
    if (!sizesShown) {
        
        self.smallSizeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.mediumSizeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.largeSizeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        self.smallSizeButton.alpha = 0.0;
        self.mediumSizeButton.alpha = 0.0;
        self.largeSizeButton.alpha = 0.0;
        
        float toolBarOriginY = self.view.frame.size.height;
        float toolBarWidth = self.view.frame.size.width;
        
        self.smallSizeButton.frame = CGRectMake(toolBarWidth-20-10, toolBarOriginY, 20.0, 20.0);
        self.smallSizeButton.tag = 3;
        self.mediumSizeButton.frame = CGRectMake(toolBarWidth-35-10, toolBarOriginY, 35.0, 35.0);
        self.mediumSizeButton.tag = 10;
        self.largeSizeButton.frame = CGRectMake(toolBarWidth-50-10, toolBarOriginY, 50.0, 50.0);
        self.largeSizeButton.tag = 30;
        
        self.smallSizeButton.backgroundColor = self.colour;
        [self.smallSizeButton addTarget:self
                           action:@selector(penSizeChanged:)
                       forControlEvents:UIControlEventTouchDown];
        
        [self.smallSizeButton.layer setMasksToBounds:YES];
        [self.smallSizeButton.layer setCornerRadius:10.0f];
        [self.smallSizeButton.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.smallSizeButton.layer setBorderWidth:3.0f];
        
        [self.view addSubview:self.smallSizeButton];
        
        self.mediumSizeButton.backgroundColor = self.colour;
        [self.mediumSizeButton addTarget:self
                            action:@selector(penSizeChanged:)
                  forControlEvents:UIControlEventTouchDown];
        
        [self.mediumSizeButton.layer setMasksToBounds:YES];
        [self.mediumSizeButton.layer setCornerRadius:17.5f];
        [self.mediumSizeButton.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.mediumSizeButton.layer setBorderWidth:3.0f];
        
        [self.view addSubview:self.mediumSizeButton];
        
        self.largeSizeButton.backgroundColor = self.colour;
        [self.largeSizeButton addTarget:self
                             action:@selector(penSizeChanged:)
                   forControlEvents:UIControlEventTouchDown];
        
        [self.largeSizeButton.layer setMasksToBounds:YES];
        [self.largeSizeButton.layer setCornerRadius:25.0f];
        [self.largeSizeButton.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.largeSizeButton.layer setBorderWidth:3.0f];
        
        [self.view addSubview:self.largeSizeButton];

        
        sizesShown = YES;
        
        
        [UIView animateWithDuration:0.3 animations:^{
            self.smallSizeButton.frame = CGRectMake(toolBarWidth-20-10.0, toolBarOriginY - (10+50+10+35+10+20), 20.0, 20.0);
            self.mediumSizeButton.frame = CGRectMake(toolBarWidth-35-10.0, toolBarOriginY - (10+50+10+35), 35.0, 35.0);
            self.largeSizeButton.frame = CGRectMake(toolBarWidth-50-10.0, toolBarOriginY - (50.0+10), 50.0, 50.0);
            
            self.smallSizeButton.alpha = 1.0;
            self.mediumSizeButton.alpha = 1.0;
            self.largeSizeButton.alpha = 1.0;

        }];
        
    }
}


- (void)showColourButtons
{
    if (!coloursShown) {

        self.redButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.blueButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.greenButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.blackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.yellowButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

        self.redButton.alpha = 0.0;
        self.yellowButton.alpha = 0.0;
        self.greenButton.alpha = 0.0;
        self.blueButton.alpha = 0.0;
        self.blackButton.alpha = 0.0;
        
        float toolBarOriginY = self.view.frame.size.height;

        self.redButton.frame = CGRectMake(10, toolBarOriginY, 35, 35);
        self.yellowButton.frame = CGRectMake(10, toolBarOriginY, 35, 35);
        self.blueButton.frame = CGRectMake(10, toolBarOriginY, 35, 35);
        self.greenButton.frame = CGRectMake(10, toolBarOriginY, 35, 35);
        self.blackButton.frame = CGRectMake(10, toolBarOriginY, 35, 35);

        self.redButton.backgroundColor = [UIColor redColor];
        [self.redButton addTarget:self
                           action:@selector(colourChanged:)
                 forControlEvents:UIControlEventTouchDown];

        [self.redButton.layer setMasksToBounds:YES];
        [self.redButton.layer setCornerRadius:17.5f];
        [self.redButton.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.redButton.layer setBorderWidth:3.0f];

        [self.view addSubview:self.redButton];
        
        self.yellowButton.backgroundColor = [UIColor yellowColor];
        [self.yellowButton addTarget:self
                           action:@selector(colourChanged:)
                 forControlEvents:UIControlEventTouchDown];
        
        [self.yellowButton.layer setMasksToBounds:YES];
        [self.yellowButton.layer setCornerRadius:17.5f];
        [self.yellowButton.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.yellowButton.layer setBorderWidth:3.0f];
        
        [self.view addSubview:self.yellowButton];

        self.blueButton.backgroundColor = [UIColor blueColor];
        [self.blueButton addTarget:self
                            action:@selector(colourChanged:)
                  forControlEvents:UIControlEventTouchDown];

        [self.blueButton.layer setMasksToBounds:YES];
        [self.blueButton.layer setCornerRadius:17.5f];
        [self.blueButton.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.blueButton.layer setBorderWidth:3.0f];

        [self.view addSubview:self.blueButton];

        self.greenButton.backgroundColor = [UIColor greenColor];
        [self.greenButton addTarget:self
                             action:@selector(colourChanged:)
                   forControlEvents:UIControlEventTouchDown];

        [self.greenButton.layer setMasksToBounds:YES];
        [self.greenButton.layer setCornerRadius:17.5f];
        [self.greenButton.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.greenButton.layer setBorderWidth:3.0f];

        [self.view addSubview:self.greenButton];

        self.blackButton.backgroundColor = [UIColor blackColor];
        [self.blackButton addTarget:self
                             action:@selector(colourChanged:)
                   forControlEvents:UIControlEventTouchDown];

        [self.blackButton.layer setMasksToBounds:YES];
        [self.blackButton.layer setCornerRadius:17.5f];
        [self.blackButton.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.blackButton.layer setBorderWidth:3.0f];

        [self.view addSubview:self.blackButton];

        coloursShown = YES;

        
        [UIView animateWithDuration:0.3 animations:^{
            self.redButton.frame = CGRectMake(10.0, toolBarOriginY - 5*(35+10), 35, 35);
            self.yellowButton.frame = CGRectMake(10.0, toolBarOriginY - 4*(35+10), 35, 35);
            self.greenButton.frame = CGRectMake(10.0, toolBarOriginY - 3*(35+10), 35, 35);
            self.blueButton.frame = CGRectMake(10.0, toolBarOriginY - 2*(35+10), 35, 35);
            self.blackButton.frame = CGRectMake(10.0, toolBarOriginY - (35+10), 35, 35);

            self.redButton.alpha = 1.0;
            self.yellowButton.alpha = 1.0;
            self.greenButton.alpha = 1.0;
            self.blueButton.alpha = 1.0;
            self.blackButton.alpha = 1.0;
        }];

    }
}

- (void)penSizeChanged:(UIButton*)sender {
    NSLog(@"Size changed.");
    [self hideSizeButtons];
    float size = sender.tag;
    
    [self setPenSize:size];
}


- (void)setPenSize:(float)size
{
    NSLog(@"Size set to: %f",size);
    penSize = size;
}

- (void)colourChanged:(id)sender
{
    NSLog(@"Colour changed.");
    [self hideColourButtons];
    self.colour = [(UIButton *)sender backgroundColor];

    [self setColourButtonColour];
}

- (void)setColourButtonColour
{
    if ([_btColour respondsToSelector:@selector(setTintColor:)])
    {
        // TODO: make sure the word 'White' is visible when white is selected
        [self.colorBtn setBackgroundColor:self.colour];
    }
}


- (void)hideSizeButtons
{
    if (sizesShown) {
        float toolBarOriginY = self.view.frame.size.height;
        float toolBarWidth = self.view.frame.size.width;
        [UIView animateWithDuration:0.3 animations:^{
            self.smallSizeButton.frame = CGRectMake(toolBarWidth-20-10, toolBarOriginY, 20.0, 20.0);
            self.mediumSizeButton.frame = CGRectMake(toolBarWidth-35-10, toolBarOriginY, 35.0, 35.0);
            self.largeSizeButton.frame = CGRectMake(toolBarWidth-50-10, toolBarOriginY, 50.0, 50.0);
            
            self.smallSizeButton.alpha = 0.0;
            self.mediumSizeButton.alpha = 0.0;
            self.largeSizeButton.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.smallSizeButton removeFromSuperview];
            [self.mediumSizeButton removeFromSuperview];
            [self.largeSizeButton removeFromSuperview];
        }];
        
        sizesShown = NO;
    }
}


- (void)hideColourButtons
{
    if (coloursShown) {
        float toolBarOriginY = self.view.frame.size.height;
        [UIView animateWithDuration:0.3 animations:^{
            self.redButton.frame = CGRectMake(10, toolBarOriginY, 35, 35);
            self.blueButton.frame = CGRectMake(10, toolBarOriginY, 35, 35);
            self.greenButton.frame = CGRectMake(10, toolBarOriginY, 35, 35);
            self.blackButton.frame = CGRectMake(10, toolBarOriginY, 35, 35);
            self.yellowButton.frame = CGRectMake(10, toolBarOriginY, 35, 35);

            self.redButton.alpha = 0.0;
            self.yellowButton.alpha = 0.0;
            self.greenButton.alpha = 0.0;
            self.blueButton.alpha = 0.0;
            self.blackButton.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.redButton removeFromSuperview];
            [self.blueButton removeFromSuperview];
            [self.yellowButton removeFromSuperview];
            [self.greenButton removeFromSuperview];
            [self.blackButton removeFromSuperview];
        }];

        coloursShown = NO;
    }
}

- (void)viewDidUnload
{
    [self setMainImage:nil];
    [self setTempDrawImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)saveAll
{
    NSLog(@"saveAll ");
    
    //composite the cacheImage and the backgroundImage
    
    UIImage *output;
    
    CGRect rect = AVMakeRectWithAspectRatioInsideRect(self.imageLayer.image.size, self.mainImage.frame);
    
    if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
        // if portrait
        CGSize size = CGSizeMake(self.mainImage.bounds.size.width, self.mainImage.bounds.size.height);
        UIGraphicsBeginImageContext(size);
        [self.imageLayer.image drawInRect:CGRectMake(0, size.height/2 - rect.size.height/2 , rect.size.width, rect.size.height)];
        [self.mainImage.image drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        UIImage* annotation = self.tempDrawImage.image;
        
        //scale the cacheImage to fit the new bounds
        [annotation drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        output = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else {
        // if landscape
        CGSize size = CGSizeMake(self.mainImage.bounds.size.width, self.mainImage.bounds.size.height);
        UIGraphicsBeginImageContext(size);
        [self.imageLayer.image drawInRect:CGRectMake(size.width/2 - rect.size.width/2, size.height/2 - rect.size.height/2 , rect.size.width, rect.size.height)];
        [self.mainImage.image drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        UIImage* annotation = self.tempDrawImage.image;
        
        //scale the cacheImage to fit the new bounds
        [annotation drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        output = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    

    self.saved = YES;
    [self.delegate saveDrawing:output];

    self.tempDrawImage = nil;
}

- (void)clearAll
{
    NSLog(@"clearAll ");

    self.mainImage.image = nil;
    self.imageLayer.image = nil;
    self.mainImage.frame = self.view.bounds;
    self.tempDrawImage.frame = self.view.bounds;
    self.backgroundLayer.frame = self.view.bounds;
    self.imageLayer.frame = self.view.bounds;
    
}

- (void)cancelAll
{
    NSLog(@"cancelAll ");

    [self.delegate cancelDrawing];
}
- (void)pickImage
{
    self.pickingImage = YES;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.pickingImage = NO;
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    self.imageLayer.image = chosenImage;
    [self setFramesToFitImage];
    
    NSLog(@"mainImage frame: %@",NSStringFromCGRect(self.mainImage.frame));
    NSLog(@"tempdrawImage frame: %@",NSStringFromCGRect(self.tempDrawImage.frame));
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)setFramesToFitImage {
    self.mainImage.frame = self.view.bounds;
    self.tempDrawImage.frame = self.view.bounds;
    self.backgroundLayer.frame = self.view.bounds;
    self.imageLayer.frame = self.view.bounds;
    if (self.imageLayer.image != nil) {
        CGRect rect = AVMakeRectWithAspectRatioInsideRect(self.imageLayer.image.size, self.view.bounds);
        CGRect frameSize = CGRectMake(rect.origin.x, rect.origin.y, round(rect.size.width), round(rect.size.height));
        self.mainImage.frame = frameSize;
        self.backgroundLayer.frame = frameSize;
        
        self.imageLayer.frame = frameSize;
        self.tempDrawImage.frame = frameSize;
        self.imageLayer.contentMode = UIViewContentModeScaleAspectFit;
    }
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    self.pickingImage = NO;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.mainImage];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.mainImage];
    
    UIGraphicsBeginImageContext(self.mainImage.frame.size);
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.mainImage.frame.size.width, self.mainImage.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), penSize );
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), _colour.CGColor);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.tempDrawImage setAlpha:1.0];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!mouseSwiped) {
        UIGraphicsBeginImageContext(self.mainImage.frame.size);
        [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.mainImage.frame.size.width, self.mainImage.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), penSize);
        CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), _colour.CGColor);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContext(self.mainImage.frame.size);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.mainImage.frame.size.width, self.mainImage.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.mainImage.frame.size.width, self.mainImage.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempDrawImage.image = nil;
    UIGraphicsEndImageContext();
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    UINavigationBar *navBar = [[self navigationController] navigationBar];
    NSArray *subviews = [navBar subviews];
    for(UIView *view in subviews){
        if([view isKindOfClass:[UITextField class]])
            [view setHidden:NO];
    }
    if([[self navigationController] isNavigationBarHidden]){
        [[self navigationController] setNavigationBarHidden:NO];
        [[self navigationController] setNavigationBarHidden:YES];
    }else{
        [[self navigationController] setNavigationBarHidden:YES];
        [[self navigationController] setNavigationBarHidden:NO];
    }
    [navBar layoutSubviews];

    if (!self.saved && !self.pickingImage) {
        [self cancelAll];
    }

    //re-enable gesture recognizer
    for (UIGestureRecognizer *recognizer in
         self.navigationController.view.gestureRecognizers) {
        [recognizer setEnabled:YES];
    }
}

#pragma mark InterfaceOrientationMethods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (UIInterfaceOrientationIsPortrait(interfaceOrientation) || UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        //self.view = portraitView;
        [self changeTheViewToPortrait:YES andDuration:duration];
        
    }
    else if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        //self.view = landscapeView;
        [self changeTheViewToPortrait:NO andDuration:duration];
    }
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------

- (void) changeTheViewToPortrait:(BOOL)portrait andDuration:(NSTimeInterval)duration{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    
    if(portrait){
        //change the view and subview frames for the portrait view
        self.mainImage.frame = self.view.bounds;
        self.tempDrawImage.frame = self.view.bounds;
        self.backgroundLayer.frame = self.view.bounds;
        self.imageLayer.frame = self.view.bounds;
    }
    else{
        //change the view and subview  frames for the landscape view
        self.mainImage.frame = self.view.bounds;
        self.tempDrawImage.frame = self.view.bounds;
        self.backgroundLayer.frame = self.view.bounds;
        self.imageLayer.frame = self.view.bounds;
    }
    
    [UIView commitAnimations];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self setFramesToFitImage];
}

@end
