package {
    import flash.display.BitmapData;
    import flash.display.MovieClip;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.utils.ByteArray;

    import starling.core.Starling;
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.events.EnterFrameEvent;
    import starling.events.Event;
    import starling.textures.AtfData;
    import starling.textures.Texture;

    [SWF(width="2048", height="1024", frameRate="10", scaleMode="noScale")]
    public class Main extends MovieClip {

        [Embed(source="/../assets/texture1024.atf", mimeType="application/octet-stream")]
        private const TextureAsset: Class;
        private var textureAssetBytes: ByteArray;

        private var textureA: Texture;
        private var textureB: Texture;
        private var imageA: Image;
        private var imageB: Image;

        private var renderedBitmapData: BitmapData;
        private var textField:TextField;

        private var imageWidth: int;
        private var imageHeight: int;

        private var frameNumber: int = 0;
        private var valid: Boolean = true;


        public function Main() {
            super();

            textureAssetBytes = new TextureAsset();
            var atf:AtfData = new AtfData(textureAssetBytes);
            imageWidth = atf.width;
            imageHeight = atf.height;

            const stageWidth: int = imageWidth * 2;
            const stageHeight: int = imageHeight;

            var starling: Starling = new Starling(Sprite, stage, new Rectangle(0, 0, stageWidth, stageHeight), null, "auto", "auto");
            starling.enableErrorChecking = true;
            starling.addEventListener(Event.ROOT_CREATED, onRootCreated);
            starling.start();

            renderedBitmapData = new BitmapData(stageWidth, stageHeight, false);

            textField = new TextField();
            textField.autoSize = TextFieldAutoSize.LEFT;
            addChild(textField);
        }

        private function onRootCreated(event: Event): void {
            var root: Sprite = Sprite(Starling.current.root);
            root.addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
            textureA = Texture.fromAtfData(textureAssetBytes);
            textureB = Texture.fromAtfData(textureAssetBytes);
            imageA = new Image(textureA);
            imageB = new Image(textureB);
            root.addChild(imageA);
            root.addChild(imageB);
            root.addChild(new Validator(validateHandler));
            imageB.x = imageWidth;
        }

        private function validateHandler(): void {
            if (!valid) {
                return;
            }
            valid = validate();
        }

        private function onEnterFrame(event: EnterFrameEvent): void {
            var message:String = "Frame=" + frameNumber + " valid=" + valid;
            trace(message);
            textField.text = message;
            if (!valid) {
                var root: Sprite = Sprite(Starling.current.root);
                root.removeEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
            } else {
                upload();
            }
            frameNumber++;
        }

        private function validate(): Boolean {
            var bmp: BitmapData = renderedBitmapData;
            try {
                Starling.current.context.drawToBitmapData(bmp);
            } catch (err: Error) {
                trace(err);
                return true;
            }
            for (var x: int = 0; x < imageWidth; x++) {
                for (var y: int = 0; y < imageHeight; y++) {
                    var aColor: uint = bmp.getPixel(x, y);
                    var bColor: uint = bmp.getPixel(x + imageWidth, y);
                    if (aColor !== bColor) {
                        markPoint(x, y);
                        markPoint(x + imageWidth, y);
                        return false;
                    }
                }
            }
            return true;
        }

        private function markPoint(x: int, y: int): void {
            graphics.lineStyle(1, 0xff0000, 1);
            graphics.drawCircle(x, y, 10);
        }

        private function upload(): void {
            textureB.root.uploadAtfData(textureAssetBytes);
        }

    }

}
