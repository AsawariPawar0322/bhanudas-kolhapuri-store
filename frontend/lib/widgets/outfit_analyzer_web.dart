import 'dart:html' as html;
import 'dart:js' as js;

class OutfitAnalyzer {
  static void init() {
    if (js.context.hasProperty('window')) {
      js.context.callMethod('eval', ["""
        window.analyzeOutfitVideoColor = function(videoElement, callback) {
          try {
            var canvas = document.createElement('canvas');
            canvas.width = 10;
            canvas.height = 10;
            var ctx = canvas.getContext('2d');
            ctx.drawImage(videoElement, 0, 0, 10, 10);
            
            // Average grid color extraction (dominant grid) for texture/pattern safety
            var imgData = ctx.getImageData(0, 0, 10, 10).data;
            var rSum = 0, gSum = 0, bSum = 0, count = 0;
            
            // Scan center 6x6 area of the 10x10 downsampled image (pixels index 2 to 7)
            for (var y = 2; y < 8; y++) {
              for (var x = 2; x < 8; x++) {
                var idx = (y * 10 + x) * 4;
                rSum += imgData[idx];
                gSum += imgData[idx + 1];
                bSum += imgData[idx + 2];
                count++;
              }
            }
            callback(Math.round(rSum / count), Math.round(gSum / count), Math.round(bSum / count));
          } catch(e) {
            callback(16, 185, 129); // Fallback emerald green
          }
        };
      """]);
    }
  }

  static void analyze(dynamic videoElement, Function(int r, int g, int b) callback) {
    try {
      if (videoElement is html.VideoElement) {
        js.context.callMethod('window.analyzeOutfitVideoColor', [
          videoElement,
          js.allowInterop((r, g, b) {
            callback(r as int, g as int, b as int);
          })
        ]);
      } else {
        callback(16, 185, 129);
      }
    } catch (e) {
      callback(16, 185, 129);
    }
  }
}
