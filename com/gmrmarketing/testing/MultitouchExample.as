package com.gmrmarketing.testing
{	
	import flash.display.Sprite;
    import flash.text.TextField;
	import flash.ui.Multitouch;
    import flash.ui.MultitouchInputMode;
	

    public class MultitouchExample extends Sprite {

        Multitouch.inputMode = MultitouchInputMode.GESTURE;

        public function MultitouchExample() {
trace(Multitouch.supportsGestureEvents);
            if(Multitouch.supportsGestureEvents){
                var supportedGesturesVar:Vector.<String> = Multitouch.supportedGestures;
                var deviceSupports:TextField = new TextField();
                deviceSupports.width = 200;
                deviceSupports.height = 200;
                deviceSupports.wordWrap = true;

                for (var i:int=0; i<supportedGesturesVar.length; ++i) {
                    deviceSupports.appendText(supportedGesturesVar[i] + ",  ");
                    addChild(deviceSupports);
                }
            }
        }
    }
	
}