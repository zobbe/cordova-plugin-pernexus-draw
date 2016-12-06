exports.defineAutoTests = function () {
  describe('Draw (navigator.pxDraw)', function () {
    it('should exist', function () {
      expect(navigator.pxDraw).toBeDefined();
    });

    it('should contain a getDrawing method', function () {
      expect(navigator.pxDraw.getDrawing).toBeDefined();
      expect(typeof navigator.pxDraw.getDrawing === 'function').toBe(true);
    });

    it('should contain a DestinationType enum', function () {
      expect(navigator.pxDraw.DestinationType).toBeDefined();
      expect(typeof navigator.pxDraw.DestinationType === 'object').toBe(true);
    });

    it('should contain a EncodingType enum', function () {
      expect(navigator.pxDraw.EncodingType ).toBeDefined();
      expect(typeof navigator.pxDraw.EncodingType === 'object').toBe(true);
    });

    it('should contain a DrawingType enum', function () {
      expect(navigator.pxDraw.DrawingType).toBeDefined();
      expect(typeof navigator.pxDraw.DrawingType === 'object').toBe(true);
    });
  });

  describe('DestinationType enum', function () {
    it('DestinationType should contain a DATA_URL field', function () {
      expect(navigator.pxDraw.DestinationType.DATA_URL).toBeDefined();
    });

    it('DestinationType should contain a FILE_URI field', function () {
      expect(navigator.pxDraw.DestinationType.FILE_URI).toBeDefined();
    });
  });

  describe('EncodingType enum', function () {
    it('should contain a JPEG field', function () {
      expect(navigator.pxDraw.EncodingType.JPEG).toBeDefined();
    });

    it('should contain a PNG field', function () {
      expect(navigator.pxDraw.EncodingType.PNG).toBeDefined();
    });
  });

  describe('DrawingType enum', function () {
    it('should contain a BW field', function () {
      expect(navigator.pxDraw.DrawingType.BW).toBeDefined();
    });

    it('should contain a COLOR field', function () {
      expect(navigator.pxDraw.DrawingType.COLOR).toBeDefined();
    });

    it('should contain a IMAGE_ANNOTATION field', function () {
      expect(navigator.pxDraw.DrawingType.IMAGE_ANNOTATION).toBeDefined();
    });
  });

  describe('getDrawing method', function () {

    beforeEach(function(done) {
      setTimeout(function() {
        done();
      }, 1);
    });

    describe('default options.', function () {
      var callback = function () {};

      beforeEach(function () {
        spyOn(cordova, 'exec');
      });

      it('should pass DATA_URL when the destinationType option is not given', function () {
        var options;

        navigator.pxDraw.getDrawing(callback, callback);
        expect(cordova.exec).toHaveBeenCalled();

        options = cordova.exec.calls.argsFor(0)[4];
        if (typeof options !== 'undefined') {
          expect(options[0].destinationType).toEqual(navigator.pxDraw.DestinationType.DATA_URL);
        } else {
          expect(options).toBeDefined(); // Fail the test
        }
      });

      it('should pass PNG when the encodingType option is not given', function () {
        var options;

        navigator.pxDraw.getDrawing(callback, callback);
        expect(cordova.exec).toHaveBeenCalled();

        options = cordova.exec.calls.argsFor(0)[4];
        if (typeof options !== 'undefined') {
          expect(options[0].encodingType).toEqual(navigator.pxDraw.EncodingType.PNG);
        } else {
          expect(options).toBeDefined(); // Fail the test
        }
      });

      it('should pass IMAGE_ANNOTATION hen the inputType option is not given', function () {
        var options;

        navigator.pxDraw.getDrawing(callback, callback);
        expect(cordova.exec).toHaveBeenCalled();

        options = cordova.exec.calls.argsFor(0)[4];
        if (typeof options !== 'undefined') {
          expect(options[0].inputType).toEqual(navigator.pxDraw.DrawingType.IMAGE_ANNOTATION);
        } else {
          expect(options).toBeDefined(); // Fail the test
        }
      });
    });

    describe("long asynchronous specs", function() {
      var successCallback = null;
      var originalTimeout;
      var errorCallback = null;
      beforeEach(function() {
        successCallback = jasmine.createSpy('successCallback');
        errorCallback = jasmine.createSpy('errorCallback');
        originalTimeout = jasmine.DEFAULT_TIMEOUT_INTERVAL;
        jasmine.DEFAULT_TIMEOUT_INTERVAL = 20000;
      });

      it('should be called with a JPEG file URI when destinationType is FILE_URI, encoding type is JPEG', function (done) {
        var filetype = '.JPEG';
        navigator.pxDraw.getDrawing(successCallback, errorCallback, {
          destinationType: navigator.pxDraw.DestinationType.FILE_URI,
          encodingType: navigator.pxDraw.EncodingType.JPEG
        });
        setTimeout(function() {
          expect(successCallback).toHaveBeenCalled();
          if (successCallback.calls != null && successCallback.calls.mostRecent() != undefined) {
            expect(successCallback.calls.mostRecent().args[0].toUpperCase().indexOf(filetype)).toBeGreaterThan(0);
          }
          done();
        }, 19000);
      });

      it('should be called with a PNG file URI when destinationType is FILE_URI, encoding type is PNG', function (done) {
        var filetype = '.PNG';
        navigator.pxDraw.getDrawing(successCallback, errorCallback, {
          destinationType: navigator.pxDraw.DestinationType.FILE_URI,
          encodingType: navigator.pxDraw.EncodingType.PNG
        });
        setTimeout(function() {
          expect(successCallback).toHaveBeenCalled();
          if (successCallback.calls != null && successCallback.calls.mostRecent() != undefined) {
            expect(successCallback.calls.mostRecent().args[0].toUpperCase().indexOf(filetype)).toBeGreaterThan(0);
          }
          done();
        }, 19000);
      });


      it('should be called with a JPEG encoded data stream when destinationType is DATA_URL, encoding type is JPEG', function (done) {
        navigator.pxDraw.getDrawing(successCallback, errorCallback , {
          destinationType: navigator.pxDraw.DestinationType.DATA_URL,
          encodingType: navigator.pxDraw.EncodingType.JPEG
        });
        setTimeout(function() {
          expect(successCallback).toHaveBeenCalled();
          if (successCallback.calls != null && successCallback.calls.mostRecent() != undefined) {
            expect(successCallback.calls.mostRecent().args[0].indexOf('data:image/jpeg')).toBe(0);
          }
          done();
        }, 19000);
      });

      it('should be called with a PNG encoded data stream when destinationType is DATA_URL, encoding type is PNG', function (done) {
        navigator.pxDraw.getDrawing(successCallback, errorCallback , {
          destinationType: navigator.pxDraw.DestinationType.DATA_URL,
          encodingType: navigator.pxDraw.EncodingType.PNG
        });
        setTimeout(function() {
          expect(successCallback).toHaveBeenCalled();
          if (successCallback.calls != null && successCallback.calls.mostRecent() != undefined) {
            expect(successCallback.calls.mostRecent().args[0].indexOf('data:image/png')).toBe(0);
          }
          done();
        }, 19000);
      });

      it('should be called with a PNG encoded data stream when destinationType is DATA_URL, encoding type is PNG, inputType is DATA_URL', function (done) {
        navigator.pxDraw.getDrawing(successCallback, errorCallback , {
          destinationType: navigator.pxDraw.DestinationType.DATA_URL,
          encodingType: navigator.pxDraw.EncodingType.PNG,
          inputType : navigator.pxDraw.DrawingType.IMAGE_ANNOTATION,
        });
        setTimeout(function() {
          expect(successCallback).toHaveBeenCalled();
          if (successCallback.calls != null && successCallback.calls.mostRecent() != undefined) {
            expect(successCallback.calls.mostRecent().args[0].indexOf('data:image/png')).toBe(0);
          }
          done();
        }, 19000);
      });

      afterEach(function() {
        jasmine.DEFAULT_TIMEOUT_INTERVAL = originalTimeout;
      });
    });
  });
};
