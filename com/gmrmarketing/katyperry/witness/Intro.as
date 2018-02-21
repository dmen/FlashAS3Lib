// Decompiled by AS3 Sorcerer 5.64
// www.as3sorcerer.com

//com.gmrmarketing.katyperry.witness.Intro

package com.gmrmarketing.katyperry.witness
{
    import flash.events.EventDispatcher;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.utils.Timer;
    import com.greensock.TweenMax;
    import com.greensock.easing.Back;
    import flash.events.TimerEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.display.*;
    import flash.events.*;
    import com.greensock.easing.*;

    public class Intro extends EventDispatcher 
    {

        public static const COMPLETE:String = "introComplete";

        private var myContainer:DisplayObjectContainer;
        private var clip:MovieClip;
        private var perlin:PerlinNoise;
        private var circleTimer:Timer;
        private var myStartKey:int;

        public function Intro()
        {
            this.clip = new intro();
            this.perlin = new PerlinNoise();
            this.circleTimer = new Timer(1200);
        }

        public function set container(_arg_1:DisplayObjectContainer):void
        {
            this.myContainer = _arg_1;
        }

        public function show(_arg_1:int):void
        {
            if (!this.myContainer.contains(this.clip))
            {
                this.myContainer.addChild(this.clip);
            };
            this.myStartKey = _arg_1;
            this.perlin.show(this.clip.bg);
            this.enableRemote(this.myStartKey);
            TweenMax.from(this.clip.vline, 0.3, {
                "scaleY":0,
                "ease":Back.easeOut
            });
            TweenMax.from(this.clip.tip, 0.25, {
                "scaleX":0,
                "scaleY":0,
                "delay":0.25,
                "ease":Back.easeOut
            });
            TweenMax.from(this.clip.usingRemote, 0.3, {
                "y":"-50",
                "alpha":0,
                "delay":0.5,
                "ease":Back.easeOut
            });
            this.addCircle();
            this.circleTimer.addEventListener(TimerEvent.TIMER, this.addCircle, false, 0, true);
            this.circleTimer.start();
        }

        private function addCircle(_arg_1:TimerEvent=null):void
        {
            var _local_2:AnimatedCircle = new AnimatedCircle(false, 30, 0.8);
            _local_2.x = 279;
            _local_2.y = 458;
            this.clip.addChild(_local_2);
        }

        public function disableRemote():void
        {
            this.myContainer.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.introCheck);
            this.myContainer.removeEventListener(MouseEvent.MOUSE_DOWN, this.mouseStart);
        }

        public function enableRemote(_arg_1:int):void
        {
            this.myStartKey = _arg_1;
            this.myContainer.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.introCheck, false, 0, true);
            this.myContainer.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseStart, false, 0, true);
            this.myContainer.stage.focus = this.myContainer.stage;
        }

        public function hide():void
        {
            if (this.myContainer.contains(this.clip))
            {
                this.myContainer.removeChild(this.clip);
            };
            this.myContainer.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.introCheck);
            this.myContainer.removeEventListener(MouseEvent.MOUSE_DOWN, this.mouseStart);
            this.perlin.hide();
            this.circleTimer.removeEventListener(TimerEvent.TIMER, this.addCircle);
            this.circleTimer.reset();
        }

        private function introCheck(_arg_1:KeyboardEvent):void
        {
            if (_arg_1.charCode == this.myStartKey)
            {
                this.myContainer.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.introCheck);
                this.myContainer.removeEventListener(MouseEvent.MOUSE_DOWN, this.mouseStart);
                dispatchEvent(new Event(COMPLETE));
            };
        }

        private function mouseStart(_arg_1:MouseEvent):void
        {
            this.myContainer.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.introCheck);
            this.myContainer.removeEventListener(MouseEvent.MOUSE_DOWN, this.mouseStart);
            dispatchEvent(new Event(COMPLETE));
        }


    }
}//package com.gmrmarketing.katyperry.witness

