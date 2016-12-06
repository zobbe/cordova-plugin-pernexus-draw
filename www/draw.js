var Drawing = function () {
    var pxDraw = {};

    var getDrawing =  function (successCallback, errorCallback, options) {
        var argsCheck = require('cordova/argscheck');
        var opts = options || {};

        argsCheck.checkArgs('fFO', 'Drawing.getDrawing', arguments);
        if (typeof opts.destinationType === 'undefined' || opts.destinationType === null) {
            opts.destinationType = DestinationType.DATA_URL;
        }

        if (typeof opts.encodingType === 'undefined' || opts.encodingType === null) {
            opts.encodingType = EncodingType.PNG;
        }

        if (typeof opts.drawingType === 'undefined' || opts.drawingType === null) {
            opts.drawingType = DrawingType.IMAGE_ANNOTATION;
        }

        cordova.exec(successCallback, errorCallback, "PXDrawPlugin", "getDrawing", [opts]);
    };

    var DrawingType =  {
        BW: 0,         			// Black & White drawing
        COLOR: 1,         	 	// Color drawing
        IMAGE_ANNOTATION: 2     // Be able to draw on image
    };

    var DestinationType = {
        DATA_URL: 0,         // Return base64 encoded string
        FILE_URI: 1          // Return file uri (content://media/external/images/media/2 for Android)
    };

    var EncodingType = {
        JPEG: 0,             // Return JPEG encoded image
        PNG: 1               // Return PNG encoded image
    };

    pxDraw.getDrawing = getDrawing;
    pxDraw.DrawingType = DrawingType;
    pxDraw.DestinationType = DestinationType;
    pxDraw.EncodingType = EncodingType;

    return pxDraw;
};

module.exports = Drawing();
