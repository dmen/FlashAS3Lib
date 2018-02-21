// Decompiled by AS3 Sorcerer 5.64
// www.as3sorcerer.com

//com.gmrmarketing.katyperry.witness.Thanks

package com.gmrmarketing.katyperry.witness
{
    import flash.events.EventDispatcher;
    import flash.display.MovieClip;
    import flash.display.DisplayObjectContainer;
    import com.greensock.TweenMax;
    import com.greensock.easing.Back;
    import flash.events.Event;
    import flash.display.*;
    import flash.events.*;
    import com.greensock.easing.*;

    public class Thanks extends EventDispatcher 
    {

        public static const SHOWING:String = "thanksShowing";

        private var clip:MovieClip;
        private var myContainer:DisplayObjectContainer;

        public function Thanks()
        {
            this.clip = new thanks();
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
            TweenMax.from(this.clip.logo, 1, {
                "alpha":0,
                "onComplete":this.itsShowing
            });
            TweenMax.from(this.clip.title, 0.3, {
                "y":"75",
                "alpha":0,
                "ease":Back.easeOut
            });
            TweenMax.from(this.clip.enjoy, 0.3, {
                "y":"75",
                "alpha":0,
                "delay":0.1,
                "ease":Back.easeOut
            });
        }

        private function itsShowing():void
        {
            dispatchEvent(new Event(SHOWING));
        }

        public function hide():void
        {
            if (this.myContainer.contains(this.clip))
            {
                this.myContainer.removeChild(this.clip);
            };
        }


    }
}//package com.gmrmarketing.katyperry.witness

