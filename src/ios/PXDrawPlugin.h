#import <Cordova/CDVPlugin.h>

enum DestinationType {
    DestinationTypeDataUrl = 0,
    DestinationTypeFileUri
};
typedef NSUInteger DestinationType;

enum EncodingType {
    EncodingTypeJPEG = 0,
    EncodingTypePNG
};
typedef NSUInteger EncodingType;

enum DrawingType {
    DrawingTypeBW = 0,
    DrawingTypeColor,
    DrawingTypeImageAnnotation
};
typedef NSUInteger DrawingType;

@interface PXDrawPlugin : CDVPlugin

- (void)getDrawing:(CDVInvokedUrlCommand*)command;

@end
