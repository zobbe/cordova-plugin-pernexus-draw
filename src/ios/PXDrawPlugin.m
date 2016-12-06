#import "PXDrawPlugin.h"
#import "PXTouchDrawViewController.h"

@interface PXDrawPlugin () <SaveDrawingProtocol>

@property (copy) NSString* callbackId;
@property (nonatomic) DestinationType destinationType;
@property (nonatomic) EncodingType encodingType;
@property (nonatomic) DrawingType drawingType;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) PXTouchDrawViewController *touchDrawController;

@end

@implementation PXDrawPlugin

- (void) getDrawing:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    NSDictionary *options = command.arguments[0];

    if (!options || options.count == 0) {
        [self sendErrorResultWithMessage:@"Insufficent number of options"];
        return;
    }

    NSUInteger destinationType = [options[@"destinationType"] integerValue];
    switch (destinationType) {
        case DestinationTypeDataUrl:
        case DestinationTypeFileUri:
            self.destinationType = destinationType;
            break;
        default:
            [self sendErrorResultWithMessage:@"Invalid destinationType"];
            return;
    }

    NSUInteger encodingType = [options[@"encodingType"] integerValue];
    switch (encodingType) {
        case EncodingTypeJPEG:
        case EncodingTypePNG:
            self.encodingType = encodingType;
            break;
        default:
            [self sendErrorResultWithMessage:@"Invalid encodingType"];
            return;
    }

    NSUInteger drawingType = [options[@"drawingType"] integerValue];
    switch (drawingType) {
        case DrawingTypeBW:
            self.drawingType = drawingType;
            break;
        case DrawingTypeColor:
            self.drawingType = drawingType;
            break;
        case DrawingTypeImageAnnotation:
            self.drawingType = drawingType;
            break;
        default:
            [self sendErrorResultWithMessage:@"Invalid drawingType"];
            return;
    }


    [self doDrawing];
}

- (void) doDrawing
{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            PXTouchDrawViewController *touchDrawVC = [[PXTouchDrawViewController alloc] init];
            touchDrawVC.drawingType = self.drawingType;
            touchDrawVC.delegate = self;
            self.touchDrawController = touchDrawVC;

            UIViewController *rootVC = [[UIViewController alloc] init]; // dummy root view controller.
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:rootVC];
            [rootVC.navigationController setNavigationBarHidden:YES];
            [navVC pushViewController:touchDrawVC animated:NO];
            [self.viewController presentViewController:navVC animated:YES completion:nil];
            self.navigationController = navVC;
        });
    });
}

- (void) sendErrorResultWithMessage:(NSString *)message
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                             messageAsString:message]
                                callbackId:self.callbackId];
}

- (void) dealloc
{
    if (self.touchDrawController) {
        self.touchDrawController.delegate = nil;
        self.touchDrawController = nil;
    }

    if (self.navigationController) {
        self.navigationController = nil;
    }
}

#pragma mark - SaveDrawingProtocol

- (void) saveDrawing:(UIImage *)drawing
{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSData *drawingData;
        NSString *encType;
        if (self.encodingType == EncodingTypeJPEG) {
            drawingData = UIImageJPEGRepresentation(drawing, 1.0f);
            encType = @"jpeg";
        } else if (self.encodingType == EncodingTypePNG){
            drawingData = UIImagePNGRepresentation(drawing);
            encType = @"png";
        }

        NSString *message = nil;
        if (self.destinationType == DestinationTypeDataUrl) {
            message = [NSString stringWithFormat:@"data:image/%@;base64,%@", encType, [drawingData base64EncodedStringWithOptions:0]];
        } else if (self.destinationType == DestinationTypeFileUri) {
            NSString *fileName = [NSString stringWithFormat:@"sketch-%@.%@", [NSUUID UUID].UUIDString, encType];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSURL *filePath = [NSURL fileURLWithPath:[paths[0] stringByAppendingPathComponent:fileName]];
            NSError *error = nil;

            [drawingData writeToURL:filePath options:(NSDataWritingAtomic|NSDataWritingFileProtectionComplete)
                              error:&error];
            if (error) {
                [self sendErrorResultWithMessage:[@"Failed to write drawing data to file: " stringByAppendingString:[error localizedDescription]]];
                NSLog(@"Error: Failed to write drawing data to temp file: %@", [error localizedDescription]);
            } else {
                message = [filePath relativePath];
            }
        }

        if (message) {
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                     messageAsString:message]
                                        callbackId:self.callbackId];
            NSLog(@"Drawing saved");
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:NO];
            [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        });
    });
}

- (void) cancelDrawing
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                             messageAsString:@""]
                                callbackId:self.callbackId];

    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    NSLog(@"Drawing cancelled");
}

@end
