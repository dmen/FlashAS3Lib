// Decompiled by AS3 Sorcerer 5.64
// www.as3sorcerer.com

//com.gmrmarketing.katyperry.witness.AnimatedCircle

package com.gmrmarketing.katyperry.witness
{
    import flash.display.Sprite;
    import flash.display.Graphics;
    import flash.display.MovieClip;
    import flash.events.Event;

    public class AnimatedCircle extends Sprite 
    {

        private var g:Graphics;
        private var curAlpha:Number;
        private var curRadius:Number;
        private var myMask:MovieClip;
        private var drawColor:Number;

        public function AnimatedCircle(_arg_1:Boolean=false, _arg_2:int=2, _arg_3:Number=1)
        {
            this.g = graphics;
            this.curAlpha = _arg_3;
            this.curRadius = _arg_2;
            this.drawColor = 0xFFFFFF;
            if (_arg_1)
            {
                this.drawColor = 2301728;
            };
            addEventListener(Event.ADDED_TO_STAGE, this.init);
        }

        private function init(_arg_1:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, this.init);
            addEventListener(Event.ENTER_FRAME, this.update);
        }

        private function update(_arg_1:Event):void
        {
            this.g.clear();
            this.g.lineStyle(2, this.drawColor, this.curAlpha);
            this.g.drawCircle(x, y, this.curRadius);
            this.curRadius = (this.curRadius + 0.8);
            this.curAlpha = (this.curAlpha - 0.01);
            if (this.curAlpha <= 0)
            {
                this.g.clear();
                removeEventListener(Event.ENTER_FRAME, this.update);
                parent.removeChild(this);
            };
        }


    }
}//package com.gmrmarketing.katyperry.witness

