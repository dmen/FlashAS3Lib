// Decompiled by AS3 Sorcerer 5.64
// www.as3sorcerer.com

//com.gmrmarketing.katyperry.witness.CurrentCustomer

package com.gmrmarketing.katyperry.witness
{
    import flash.events.EventDispatcher;
    import flash.display.MovieClip;
    import flash.display.DisplayObjectContainer;
    import flash.utils.Timer;
    import flash.events.MouseEvent;
    import com.greensock.TweenMax;
    import com.greensock.easing.Back;
    import flash.events.TimerEvent;
    import flash.events.Event;
    import flash.display.*;
    import flash.events.*;
    import com.greensock.easing.*;

    public class CurrentCustomer extends EventDispatcher 
    {

        public static const COMPLETE:String = "currentComplete";

        private var clip:MovieClip;
        private var myContainer:DisplayObjectContainer;
        private var selection:Boolean = true;
        private var perlin:PerlinNoise;
        private var circleTimer:Timer;

        public function CurrentCustomer()
        {
            this.clip = new currentCust();
            this.perlin = new PerlinNoise();
            this.circleTimer = new Timer(1200);
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
            this.perlin.show(this.clip.bg);
            this.clip.btnYes.addEventListener(MouseEvent.MOUSE_DOWN, this.selectedYes, false, 0, true);
            this.clip.btnNo.addEventListener(MouseEvent.MOUSE_DOWN, this.selectedNo, false, 0, true);
            this.clip.btnYes.fill.alpha = 0;
            this.clip.btnNo.fill.alpha = 0;
            TweenMax.from(this.clip.title, 0.3, {
                "y":"-75",
                "alpha":0,
                "ease":Back.easeOut
            });
            TweenMax.from(this.clip.question, 0.3, {
                "y":"-50",
                "alpha":0,
                "delay":0.1,
                "ease":Back.easeOut
            });
            TweenMax.from(this.clip.worry, 0.3, {
                "y":"50",
                "alpha":0,
                "delay":0.2,
                "ease":Back.easeOut
            });
            TweenMax.from(this.clip.btnYes, 0.3, {
                "y":"75",
                "alpha":0,
                "delay":0.2,
                "ease":Back.easeOut
            });
            TweenMax.from(this.clip.btnNo, 0.3, {
                "y":"75",
                "alpha":0,
                "delay":0.3,
                "ease":Back.easeOut
            });
            TweenMax.from(this.clip.tap, 0.5, {
                "alpha":0,
                "delay":0.5
            });
            this.addCircle();
            this.circleTimer.addEventListener(TimerEvent.TIMER, this.addCircle, false, 0, true);
            this.circleTimer.start();
        }

        private function addCircle(_arg_1:TimerEvent=null):void
        {
            var _local_2:AnimatedCircle = new AnimatedCircle(true);
            _local_2.x = 422;
            _local_2.y = 391;
            this.clip.addChild(_local_2);
        }

        public function hide():void
        {
            if (this.myContainer.contains(this.clip))
            {
                this.myContainer.removeChild(this.clip);
            };
            this.perlin.hide();
            this.circleTimer.removeEventListener(TimerEvent.TIMER, this.addCircle);
            this.circleTimer.reset();
        }

        public function get customer():Boolean
        {
            return (this.selection);
        }

        private function selectedYes(_arg_1:MouseEvent):void
        {
            this.selection = true;
            this.clip.btnYes.fill.alpha = 1;
            TweenMax.to(this.clip.btnYes.fill, 0.3, {
                "alpha":0,
                "onComplete":this.sendComplete
            });
        }

        private function sendComplete():void
        {
            dispatchEvent(new Event(COMPLETE));
        }

        private function selectedNo(_arg_1:MouseEvent):void
        {
            this.selection = false;
            this.clip.btnNo.fill.alpha = 1;
            TweenMax.to(this.clip.btnNo.fill, 0.3, {
                "alpha":0,
                "onComplete":this.sendComplete
            });
        }


    }
}//package com.gmrmarketing.katyperry.witness

