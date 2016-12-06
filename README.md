# cordova-plugin-pernexus-draw

This plugin defines a navigator.pxDraw object, which supplies an interface to launch a drawing pad, allowing the user to draw something or annotate a picture and save it.

The plugin is based on BlinkMobile's [cordova-plugin-sketch](https://github.com/blinkmobile/cordova-plugin-sketch)

## Installation

```sh
cordova plugin add https://github.com/zobbe/cordova-plugin-pernexus-draw.git
```

### Supported Platforms
- iOS 8.0 +

## pxDraw.getDrawing

Displays a dialog which will allow user draw something or annotate a picture based on input options.

```javascript
navigator.pxDraw.getDrawing(onSuccess, onError, options);
```

## Options

The available options for the plugin include:

- destinationType (optional)
- encodingType (optional)
- drawingType (optional)

#### DestinationType
The destinationType is the return image type, the available options are: 

- DestinationType.DATA\_URL (default)
	- Returns a base64 image string
- DestinationType.FILE\_URI
	- Returns the local file URI

#### EncodingType
The EncodingType is the return image encode type, the available options are: 

- EncodingType.PNG (default)
- EncodingType.JPEG 

The plugin will encode the return image based on EncodingType.

#### DrawingType

The drawingType describes what kind of drawing the user is able to draw. 

- DrawingType.IMAGE_ANNOTATION (default)
	- The user can draw with colors and choose an image to annotate.
- DrawingType.BW
	- The user can only draw black/white image.
- DrawingType.COLOR
	- The user can create a color drawing.

## Return image

When the user presses "Save", the plugin returns the image of the user sketched as an Data URI or File URI depending on input DestinationType.

If the user presses "Cancel", the result is `null`.




## Example

Create a button on your page

```html
<button id="open-drawing-plugin">Draw</button>
<img id="myImage" height="300px"/>
```

Then add click event

```javascript
document.getElementById("open-drawing-plugin").addEventListener("click", getDrawing, false);

function getDrawing(){
  navigator.pxDraw.getDrawing(onSuccess, onFail, {
    destinationType: navigator.pxDraw.DestinationType.DATA_URL,
    encodingType: navigator.pxDraw.EncodingType.PNG,
    drawingType: navigator.pxDraw.DrawingType.BW,
  });
}

function onSuccess(imageData) {
	if(imageData == null) { return; }
	var image = document.getElementById('myImage');
	image.src = imageData;
}

function onFail(message) {
	console.log('plugin message: ' + message);
}
```
