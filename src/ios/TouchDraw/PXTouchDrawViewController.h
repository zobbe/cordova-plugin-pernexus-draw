//
//  TouchViewController.h
//
//  Created by Morten Zobbe on 06/12/16.
//
//

#import <UIKit/UIKit.h>
#import "PXTouchDrawView.h"
#import "PXDrawPlugin.h"

typedef NSUInteger DrawingType;

@protocol SaveDrawingProtocol <NSObject>

- (void)saveDrawing:(UIImage *)drawing;
- (void)cancelDrawing;

@end

@interface PXTouchDrawViewController : UIViewController <UIPickerViewDelegate,UIImagePickerControllerDelegate>{

    CGPoint lastPoint;
    BOOL mouseSwiped;
}

@property (strong, nonatomic) id delegate;

@property (assign, nonatomic) DrawingType drawingType;

@property (strong, nonatomic) UIImageView *mainImage;
@property (strong, nonatomic) UIImageView *tempDrawImage;
@property (strong, nonatomic) UIImageView *imageLayer;
@property (strong, nonatomic) UIImageView *backgroundLayer;

@property (assign, nonatomic) BOOL saved;
@property (assign, nonatomic) BOOL pickingImage;

@property(nonatomic, strong) UIButton *redButton;
@property(nonatomic, strong) UIButton *yellowButton;
@property(nonatomic, strong) UIButton *blueButton;
@property(nonatomic, strong) UIButton *greenButton;
@property(nonatomic, strong) UIButton *blackButton;

@property(nonatomic, strong) UIButton *smallSizeButton;
@property(nonatomic, strong) UIButton *mediumSizeButton;
@property(nonatomic, strong) UIButton *largeSizeButton;

@property(nonatomic, strong) UIColor *colour;

@property(nonatomic, strong) UIBarButtonItem *btColour;

@property(nonatomic, strong) UIButton *colorBtn;

- (void)saveAll;
- (void)pickImage;
- (void)clearAll;
- (void)cancelAll;


@end

