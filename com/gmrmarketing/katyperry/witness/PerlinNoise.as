// Decompiled by AS3 Sorcerer 5.64
// www.as3sorcerer.com

//com.gmrmarketing.katyperry.witness.PerlinNoise

package com.gmrmarketing.katyperry.witness
{
    import flash.geom.Matrix;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObjectContainer;
    import flash.display.BlendMode;
    import flash.events.Event;
    import flash.display.BitmapDataChannel;
    import flash.geom.Point;
    import com.chargedweb.utils.MatrixUtil;

    public class PerlinNoise 
    {

        private var gradMat:Matrix;
        private var display:Bitmap;
        private var masker:BitmapData;
        private var _perlinBitmapData:BitmapData;
        private var _n:Number;
        private var myContainer:DisplayObjectContainer;
        private var seed:Number;

        public function PerlinNoise()
        {
            this.gradMat = new Matrix();
            this.gradMat.scale(3, 3);
            this._perlinBitmapData = new BitmapData(640, 360, false);
            this.masker = new BitmapData(1920, 1080, true, 0);
            this.display = new Bitmap(this.masker);
            this.display.blendMode = BlendMode.ADD;
        }

        public function show(_arg_1:DisplayObjectContainer):void
        {
            this._n = 0;
            this.seed = (5000 * Math.random());
            this.myContainer = _arg_1;
            this.myContainer.addChildAt(this.display, 1);
            this.myContainer.addEventListener(Event.ENTER_FRAME, this.update, false, 0, true);
        }

        public function hide():void
        {
            if (this.myContainer.contains(this.display))
            {
                this.myContainer.removeChild(this.display);
            };
            this.myContainer.removeEventListener(Event.ENTER_FRAME, this.update);
        }

        private function update(_arg_1:Event):void
        {
            this._n = (this._n + 1);
            this._perlinBitmapData.perlinNoise(500, 500, 2, this.seed, false, false, BitmapDataChannel.ALPHA, true, [new Point(-(this._n), -(this._n)), new Point(-(this._n), (this._n * 0.5))]);
            this._perlinBitmapData.applyFilter(this._perlinBitmapData, this._perlinBitmapData.rect, new Point(), MatrixUtil.setBrightness(-60));
            this.masker.draw(this._perlinBitmapData, this.gradMat, null, null, null, true);
        }


    }
}//package com.gmrmarketing.katyperry.witness

