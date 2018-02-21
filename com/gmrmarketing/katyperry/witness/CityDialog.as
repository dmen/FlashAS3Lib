// Decompiled by AS3 Sorcerer 5.64
// www.as3sorcerer.com

//com.gmrmarketing.katyperry.witness.CityDialog

package com.gmrmarketing.katyperry.witness
{
    import flash.events.EventDispatcher;
    import flash.display.MovieClip;
    import flash.display.DisplayObjectContainer;
    import flash.net.SharedObject;
    import flash.text.TextFormat;
    import flash.events.MouseEvent;
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;

    public class CityDialog extends EventDispatcher 
    {

        public static const COMPLETE:String = "cityDialogComplete";

        private var clip:MovieClip;
        private var myContainer:DisplayObjectContainer;
        private var theCity:String;
        private var so:SharedObject;
        private var tClip:MovieClip;
        private var blackFormatter:TextFormat;
        private var whiteFormatter:TextFormat;

        public function CityDialog()
        {
            this.clip = new cityDialog();
            this.tClip = new cityText();
            this.blackFormatter = new TextFormat();
            this.blackFormatter.color = 0;
            this.blackFormatter.letterSpacing = -6;
            this.whiteFormatter = new TextFormat();
            this.whiteFormatter.color = 0xFFFFFF;
            this.whiteFormatter.letterSpacing = -6;
            this.so = SharedObject.getLocal("KPCityData");
            if (this.so.data.city == null)
            {
                this.so.data.city = "";
                this.so.data.bri = 60;
                this.so.data.con = 20;
                this.so.data.sat = 30;
                this.so.data.key = 32;
                this.so.data.mode = "consumer";
                this.so.flush();
            };
            this.tClip.theText.text = String(this.so.data.city).toUpperCase();
        }

        public function set container(_arg_1:DisplayObjectContainer):void
        {
            this.myContainer = _arg_1;
        }

        public function updateQueue(_arg_1:int, _arg_2:String):void
        {
            this.clip.queueNum.text = _arg_1.toString();
            this.clip.qError.text = _arg_2;
        }

        public function show(_arg_1:int):void
        {
            this.clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, this.closeDialog, false, 0, true);
            this.clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, this.saveCity, false, 0, true);
            this.clip.spaceRadio.addEventListener(MouseEvent.MOUSE_DOWN, this.checkSpace, false, 0, true);
            this.clip.aRadio.addEventListener(MouseEvent.MOUSE_DOWN, this.checkA, false, 0, true);
            this.clip.corpRadio.addEventListener(MouseEvent.MOUSE_DOWN, this.checkCorporate, false, 0, true);
            this.clip.conRadio.addEventListener(MouseEvent.MOUSE_DOWN, this.checkConsumer, false, 0, true);
            if (!this.myContainer.contains(this.clip))
            {
                this.myContainer.addChild(this.clip);
            };
            this.clip.x = 50;
            this.clip.y = 450;
            this.clip.theText.text = this.so.data.city;
            this.clip.bri.text = int(this.so.data.bri).toString();
            this.clip.con.text = int(this.so.data.con).toString();
            this.clip.sat.text = int(this.so.data.sat).toString();
            this.clip.queueNum.text = _arg_1.toString();
            if (this.so.data.key == 32)
            {
                this.checkSpace();
            }
            else
            {
                this.checkA();
            };
            if (this.so.data.mode == "consumer")
            {
                this.checkConsumer();
            }
            else
            {
                this.checkCorporate();
            };
        }

        public function get theKey():int
        {
            return (this.so.data.key);
        }

        public function get mode():String
        {
            return (this.so.data.mode);
        }

        public function get cityImages():Array
        {
            var _local_1:BitmapData = new BitmapData(430, 60, true, 0);
            this.tClip.theText.setTextFormat(this.blackFormatter);
            _local_1.draw(this.tClip);
            var _local_2:BitmapData = new BitmapData(430, 60, true, 0);
            this.tClip.theText.setTextFormat(this.whiteFormatter);
            _local_2.draw(this.tClip);
            return ([_local_1, _local_2]);
        }

        public function getColorValues():Array
        {
            return ([this.so.data.bri, this.so.data.con, this.so.data.sat]);
        }

        private function checkSpace(_arg_1:MouseEvent=null):void
        {
            this.clip.spaceRadio.gotoAndStop(2);
            this.clip.aRadio.gotoAndStop(1);
        }

        private function checkA(_arg_1:MouseEvent=null):void
        {
            this.clip.spaceRadio.gotoAndStop(1);
            this.clip.aRadio.gotoAndStop(2);
        }

        private function checkCorporate(_arg_1:MouseEvent=null):void
        {
            this.clip.corpRadio.gotoAndStop(2);
            this.clip.conRadio.gotoAndStop(1);
        }

        private function checkConsumer(_arg_1:MouseEvent=null):void
        {
            this.clip.corpRadio.gotoAndStop(1);
            this.clip.conRadio.gotoAndStop(2);
        }

        private function closeDialog(_arg_1:MouseEvent=null):void
        {
            if (_arg_1)
            {
                _arg_1.stopImmediatePropagation();
            };
            this.clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, this.closeDialog);
            this.clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, this.saveCity);
            this.clip.spaceRadio.removeEventListener(MouseEvent.MOUSE_DOWN, this.checkSpace);
            this.clip.aRadio.removeEventListener(MouseEvent.MOUSE_DOWN, this.checkA);
            this.clip.corpRadio.removeEventListener(MouseEvent.MOUSE_DOWN, this.checkCorporate);
            this.clip.conRadio.removeEventListener(MouseEvent.MOUSE_DOWN, this.checkConsumer);
            if (this.myContainer.contains(this.clip))
            {
                this.myContainer.removeChild(this.clip);
            };
            dispatchEvent(new Event(COMPLETE));
        }

        private function saveCity(_arg_1:MouseEvent):void
        {
            _arg_1.stopImmediatePropagation();
            this.so.data.city = this.clip.theText.text;
            this.so.data.bri = parseInt(this.clip.bri.text);
            this.so.data.con = parseInt(this.clip.con.text);
            this.so.data.sat = parseInt(this.clip.sat.text);
            this.so.data.key = ((this.clip.spaceRadio.currentFrame == 2) ? 32 : 65);
            this.so.data.mode = ((this.clip.corpRadio.currentFrame == 2) ? "corporate" : "consumer");
            this.so.flush();
            this.tClip.theText.text = String(this.clip.theText.text).toUpperCase();
            this.closeDialog();
        }


    }
}//package com.gmrmarketing.katyperry.witness

