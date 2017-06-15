package {
    import flash.geom.Rectangle;

    import starling.core.RenderSupport;
    import starling.display.DisplayObject;

    public class Validator extends DisplayObject {

        private var renderHandler: Function;

        public function Validator(renderHandler: Function) {
            this.renderHandler = renderHandler;
        }

        override public function render(support: RenderSupport, parentAlpha: Number): void {
            support.finishQuadBatch();
            renderHandler()
        }

        override public function getBounds(targetSpace: DisplayObject, resultRect: Rectangle = null): Rectangle {
            return resultRect;
        }

    }
}
