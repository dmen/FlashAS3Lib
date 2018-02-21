// Decompiled by AS3 Sorcerer 5.64
// www.as3sorcerer.com

//com.gmrmarketing.katyperry.witness.Selector

package com.gmrmarketing.katyperry.witness
{
    import flash.events.EventDispatcher;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import com.greensock.TweenMax;
    import com.greensock.easing.Back;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.display.*;
    import flash.events.*;
    import com.greensock.easing.*;

    public class Selector extends EventDispatcher 
    {

        public static const COMPLETE:String = "selectorComplete";

        private var myContainer:DisplayObjectContainer;
        private var clip:MovieClip;
        private var soloGroup:String = "solo";

        public function Selector()
        {
            this.clip = new selector();
        }

        public function set container(_arg_1:DisplayObjectContainer):void
        {
            this.myContainer = _arg_1;
        }

        public function get selection():String
        {
            return (this.soloGroup);
        }

        public function show():void
        {
            if (!this.myContainer.contains(this.clip))
            {
                this.myContainer.addChild(this.clip);
            };
            TweenMax.from(this.clip.title, 0.3, {
                "y":"-75",
                "alpha":0,
                "ease":Back.easeOut
            });
            TweenMax.from(this.clip.select, 0.3, {
                "y":"-50",
                "alpha":0,
                "delay":0.1,
                "ease":Back.easeOut
            });
            TweenMax.from(this.clip.btnSolo, 0.3, {
                "x":"-75",
                "alpha":0,
                "delay":0.2,
                "ease":Back.easeOut
            });
            TweenMax.from(this.clip.btnGroup, 0.3, {
                "x":"75",
                "alpha":0,
                "delay":0.3,
                "ease":Back.easeOut
            });
            this.clip.btnSolo.addEventListener(MouseEvent.MOUSE_DOWN, this.selectSolo, false, 0, true);
            this.clip.btnGroup.addEventListener(MouseEvent.MOUSE_DOWN, this.selectGroup, false, 0, true);
            this.clip.btnSolo.fill.alpha = 0;
            this.clip.btnGroup.fill.alpha = 0;
        }

        public function hide():void
        {
            if (this.myContainer.contains(this.clip))
            {
                this.myContainer.removeChild(this.clip);
            };
            this.clip.btnSolo.removeEventListener(MouseEvent.MOUSE_DOWN, this.selectSolo);
            this.clip.btnGroup.removeEventListener(MouseEvent.MOUSE_DOWN, this.selectGroup);
        }

        private function selectSolo(_arg_1:MouseEvent):void
        {
            this.soloGroup = "solo";
            this.clip.btnSolo.fill.alpha = 1;
            TweenMax.to(this.clip.btnSolo.fill, 0.3, {
                "alpha":0,
                "onComplete":this.sendComplete
            });
        }

        private function sendComplete():void
        {
            dispatchEvent(new Event(COMPLETE));
        }

        private function selectGroup(_arg_1:MouseEvent):void
        {
            this.soloGroup = "group";
            this.clip.btnGroup.fill.alpha = 1;
            TweenMax.to(this.clip.btnGroup.fill, 0.3, {
                "alpha":0,
                "onComplete":this.sendComplete
            });
        }


    }
}//package com.gmrmarketing.katyperry.witness

