// Decompiled by AS3 Sorcerer 5.64
// www.as3sorcerer.com

//com.gmrmarketing.katyperry.witness.IntroVideo

package com.gmrmarketing.katyperry.witness
{
    import flash.events.EventDispatcher;
    import flash.display.MovieClip;
    import flash.display.DisplayObjectContainer;
    import flash.media.Video;
    import flash.net.NetConnection;
    import flash.net.NetStream;
    import flash.events.AsyncErrorEvent;
    import flash.events.NetStatusEvent;
    import flash.events.Event;
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.media.*;

    public class IntroVideo extends EventDispatcher 
    {

        public static const COMPLETE:String = "introVideoComplete";

        private var clip:MovieClip;
        private var myContainer:DisplayObjectContainer;
        private var theVideo:Video;
        private var nc:NetConnection;
        private var ns:NetStream;
        private var cbOBject:Object;

        public function IntroVideo()
        {
            this.clip = new introVideo();
            this.cbOBject = new Object();
            this.theVideo = new Video(1920, 1080);
            this.theVideo.x = 0;
            this.theVideo.y = 0;
        }

        public function set container(_arg_1:DisplayObjectContainer):void
        {
            this.myContainer = _arg_1;
        }

        public function show(_arg_1:String="intro"):void
        {
            if (!this.myContainer.contains(this.clip))
            {
                this.myContainer.addChild(this.clip);
            };
            if (!this.clip.contains(this.theVideo))
            {
                this.clip.addChild(this.theVideo);
            };
            this.nc = new NetConnection();
            this.nc.connect(null);
            this.ns = new NetStream(this.nc);
            this.ns.client = this.cbOBject;
            if (_arg_1 == "intro")
            {
                this.ns.play("assets/introVideo.mp4");
            }
            else
            {
                this.ns.play("assets/exitVideo.mp4");
            };
            this.theVideo.attachNetStream(this.ns);
            this.ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this.asyncErrorHandler);
            this.ns.addEventListener(NetStatusEvent.NET_STATUS, this.netStatusHandler);
        }

        public function hide():void
        {
            if (this.ns)
            {
                this.ns.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, this.asyncErrorHandler);
                this.ns.removeEventListener(NetStatusEvent.NET_STATUS, this.netStatusHandler);
            };
            this.theVideo.clear();
            this.nc = null;
            this.ns = null;
            if (this.myContainer.contains(this.clip))
            {
                this.myContainer.removeChild(this.clip);
            };
            if (this.clip.contains(this.theVideo))
            {
                this.clip.removeChild(this.theVideo);
            };
        }

        private function asyncErrorHandler(_arg_1:AsyncErrorEvent):void
        {
        }

        private function netStatusHandler(_arg_1:NetStatusEvent):void
        {
            if (_arg_1.info.code == "NetStream.Play.Stop")
            {
                dispatchEvent(new Event(COMPLETE));
            };
        }


    }
}//package com.gmrmarketing.katyperry.witness

