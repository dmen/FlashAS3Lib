// Decompiled by AS3 Sorcerer 5.64
// www.as3sorcerer.com

//com.gmrmarketing.katyperry.witness.Countdown

package com.gmrmarketing.katyperry.witness
{
    import flash.events.EventDispatcher;
    import flash.display.MovieClip;
    import flash.display.DisplayObjectContainer;
    import com.greensock.TweenMax;
    import flash.events.Event;
    import flash.display.*;
    import flash.events.*;
    import com.greensock.easing.*;

    public class Countdown extends EventDispatcher 
    {

        public static const FLASH:String = "flashShowing";
        public static const COMPLETE:String = "countdownComplete";

        private var clip:MovieClip;
        private var white:MovieClip;
        private var myContainer:DisplayObjectContainer;

        public function Countdown()
        {
            this.clip = new countdown();
            this.white = new whiteFlash();
        }

        public function set container(_arg_1:DisplayObjectContainer):void
        {
            this.myContainer = _arg_1;
        }

        public function show():void
        {
            if (!this.myContainer.contains(this.clip))
            {
                this.myContainer.addChild(this.clip);
            };
            this.clip.scaleX = (this.clip.scaleY = 4.5);
            this.clip.alpha = 1;
            this.clip.x = 960;
            this.clip.y = 520;
            this.clip.theText.text = "3";
            TweenMax.to(this.clip, 1.5, {
                "scaleX":0,
                "scaleY":0,
                "alpha":0,
                "onComplete":this.showTwo
            });
        }

        private function showTwo():void
        {
            this.clip.scaleX = (this.clip.scaleY = 4.5);
            this.clip.alpha = 1;
            this.clip.theText.text = "2";
            TweenMax.to(this.clip, 1.5, {
                "scaleX":0,
                "scaleY":0,
                "alpha":0,
                "onComplete":this.showOne
            });
        }

        private function showOne():void
        {
            this.clip.scaleX = (this.clip.scaleY = 4.5);
            this.clip.alpha = 1;
            this.clip.theText.text = "1";
            TweenMax.to(this.clip, 1.5, {
                "scaleX":0,
                "scaleY":0,
                "alpha":0,
                "onComplete":this.showWhite
            });
        }

        public function showWhite():void
        {
            dispatchEvent(new Event(FLASH));
            if (!this.myContainer.contains(this.white))
            {
                this.myContainer.addChild(this.white);
            };
            this.white.alpha = 1;
            TweenMax.to(this.white, 0.5, {
                "alpha":0,
                "onComplete":this.allDone
            });
        }

        public function hide():void
        {
            TweenMax.killTweensOf(this.clip);
            TweenMax.killTweensOf(this.white);
            this.allDone();
        }

        private function allDone():void
        {
            if (this.myContainer.contains(this.white))
            {
                this.myContainer.removeChild(this.white);
            };
            if (this.myContainer.contains(this.clip))
            {
                this.myContainer.removeChild(this.clip);
            };
        }


    }
}//package com.gmrmarketing.katyperry.witness

