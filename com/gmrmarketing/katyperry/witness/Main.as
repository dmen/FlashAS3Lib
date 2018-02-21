// Decompiled by AS3 Sorcerer 5.64
// www.as3sorcerer.com

//com.gmrmarketing.katyperry.witness.Main

package com.gmrmarketing.katyperry.witness
{
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import brfv4.BRFManager;
    import com.gmrmarketing.utilities.CornerQuit;
    import com.gmrmarketing.utilities.queue.Queue;
    import com.gmrmarketing.utilities.TimeoutHelper;
    import flash.display.StageDisplayState;
    import flash.display.StageScaleMode;
    import flash.ui.Mouse;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import flash.events.Event;
    import flash.display.BitmapData;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import com.dynamicflash.util.Base64;
    import com.adobe.images.JPEGEncoder;
    import flash.desktop.NativeApplication;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;

    public class Main extends MovieClip 
    {

        private const _width:Number = 0x0500;
        private const _height:Number = 720;

        private var mainContainer:Sprite;
        private var cornerContainer:Sprite;
        private var intro:Intro;
        private var current:CurrentCustomer;
        private var introVideo:IntroVideo;
        private var selector:Selector;
        private var solo:SoloFace;
        private var result:Result;
        private var thanks:Thanks;
        private var brfManager:BRFManager;
        private var cityDialog:CityDialog;
        private var cityCorner:CornerQuit;
        private var quitCorner:CornerQuit;
        private var queue:Queue;
        private var tim:TimeoutHelper;

        public function Main()
        {
            stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
            stage.scaleMode = StageScaleMode.SHOW_ALL;
            Mouse.hide();
            this.queue = new Queue();
            this.queue.fileName = "katyPerryQ";
            this.queue.service = new HubbleServiceExtender();
            this.mainContainer = new Sprite();
            this.cornerContainer = new Sprite();
            addChild(this.mainContainer);
            addChild(this.cornerContainer);
            this.intro = new Intro();
            this.intro.container = this.mainContainer;
            this.current = new CurrentCustomer();
            this.current.container = this.mainContainer;
            this.introVideo = new IntroVideo();
            this.introVideo.container = this.mainContainer;
            this.selector = new Selector();
            this.selector.container = this.mainContainer;
            this.solo = new SoloFace();
            this.solo.container = this.mainContainer;
            this.result = new Result();
            this.result.container = this.mainContainer;
            this.thanks = new Thanks();
            this.thanks.container = this.mainContainer;
            this.brfManager = new BRFManager();
            this.brfManager.init(new Rectangle(0, 0, this._width, this._height), new Rectangle(0, 0, this._width, this._height), "com.gmrmarketing.brftest");
            this.brfManager.setFaceDetectionParams((this._height * 0.2), this._height, 24, 8);
            this.brfManager.setFaceTrackingStartParams((this._height * 0.2), this._height, 32, 35, 32);
            this.brfManager.setFaceTrackingResetParams((this._height * 0.15), this._height, 40, 55, 32);
            this.cityDialog = new CityDialog();
            this.cityDialog.container = this.mainContainer;
            this.cityCorner = new CornerQuit();
            this.quitCorner = new CornerQuit();
            this.cityCorner.init(this.cornerContainer, "ll");
            this.quitCorner.init(this.cornerContainer, "ur");
            this.quitCorner.addEventListener(CornerQuit.CORNER_QUIT, this.quitApp);
            this.cityCorner.customLoc(1, new Point(0, (1080 - 150)));
            this.quitCorner.customLoc(1, new Point((1920 - 150), 0));
            this.tim = TimeoutHelper.getInstance();
            this.tim.addEventListener(TimeoutHelper.TIMED_OUT, this.timReset);
            this.tim.init(60000);
            this.queue.start();
            if (this.cityDialog.mode == "consumer")
            {
                this.init();
            }
            else
            {
                this.showSelector();
            };
        }

        private function init():void
        {
            this.tim.stopMonitoring();
            this.cityCorner.addEventListener(CornerQuit.CORNER_QUIT, this.showCityDialog, false, 0, true);
            this.cityCorner.show();
            this.intro.addEventListener(Intro.COMPLETE, this.showCurrent, false, 0, true);
            this.intro.show(this.cityDialog.theKey);
        }

        private function showCurrent(_arg_1:Event):void
        {
            this.intro.removeEventListener(Intro.COMPLETE, this.showCurrent);
            this.tim.startMonitoring();
            this.cityCorner.removeEventListener(CornerQuit.CORNER_QUIT, this.showCityDialog);
            this.cityCorner.hide();
            this.intro.hide();
            this.current.addEventListener(CurrentCustomer.COMPLETE, this.showIntroVideo, false, 0, true);
            this.current.show();
        }

        private function showIntroVideo(_arg_1:Event):void
        {
            this.current.removeEventListener(CurrentCustomer.COMPLETE, this.showIntroVideo);
            this.current.hide();
            this.tim.stopMonitoring();
            this.introVideo.addEventListener(IntroVideo.COMPLETE, this.showSelector, false, 0, true);
            this.introVideo.show("intro");
        }

        private function showSelector(_arg_1:Event=null):void
        {
            this.introVideo.removeEventListener(IntroVideo.COMPLETE, this.showSelector);
            this.introVideo.hide();
            this.tim.startMonitoring();
            this.brfManager.reset();
            if (this.cityDialog.mode != "consumer")
            {
                this.cityCorner.addEventListener(CornerQuit.CORNER_QUIT, this.showCityDialog, false, 0, true);
                this.cityCorner.show();
            };
            this.selector.addEventListener(Selector.COMPLETE, this.showSelection, false, 0, true);
            this.selector.show();
        }

        private function backFromPhoto(_arg_1:Event):void
        {
            this.solo.removeEventListener(SoloFace.COMPLETE, this.showResults);
            this.solo.removeEventListener(SoloFace.BACK, this.showSelector);
            this.solo.hide();
            this.showSelector();
        }

        private function showSelection(_arg_1:Event=null):void
        {
            this.tim.buttonClicked();
            var _local_2:Boolean = ((_arg_1 == null) ? true : false);
            this.selector.removeEventListener(Selector.COMPLETE, this.showSelection);
            this.selector.hide();
            this.cityCorner.removeEventListener(CornerQuit.CORNER_QUIT, this.showCityDialog);
            this.cityCorner.hide();
            var _local_3:String = this.selector.selection;
            if (_local_3 == "solo")
            {
                this.brfManager.setNumFacesToTrack(1);
                this.solo.addEventListener(SoloFace.COMPLETE, this.showResults, false, 0, true);
                this.solo.addEventListener(SoloFace.BACK, this.backFromPhoto, false, 0, true);
                this.solo.show(this.brfManager, false, this.cityDialog.getColorValues(), this.cityDialog.cityImages, _local_2);
            }
            else
            {
                this.brfManager.setNumFacesToTrack(4);
                this.solo.addEventListener(SoloFace.COMPLETE, this.showResults, false, 0, true);
                this.solo.addEventListener(SoloFace.BACK, this.backFromPhoto, false, 0, true);
                this.solo.show(this.brfManager, true, this.cityDialog.getColorValues(), this.cityDialog.cityImages, _local_2);
            };
        }

        private function showResults(_arg_1:Event):void
        {
            this.solo.removeEventListener(SoloFace.COMPLETE, this.showResults);
            this.solo.removeEventListener(SoloFace.BACK, this.showSelector);
            this.solo.hide();
            this.tim.buttonClicked();
            if (this.cityDialog.mode == "consumer")
            {
                this.result.addEventListener(Result.COMPLETE, this.showExitVideo, false, 0, true);
            }
            else
            {
                this.result.addEventListener(Result.COMPLETE, this.showThanks, false, 0, true);
            };
            this.result.addEventListener(Result.RETAKE, this.retakeFromResults, false, 0, true);
            this.result.show(this.solo.userPhoto);
        }

        private function showExitVideo(_arg_1:Event):void
        {
            this.result.removeEventListener(Result.COMPLETE, this.showExitVideo);
            this.result.removeEventListener(Result.RETAKE, this.retakeFromResults);
            this.result.hide();
            this.tim.stopMonitoring();
            this.introVideo.addEventListener(IntroVideo.COMPLETE, this.showThanks, false, 0, true);
            this.introVideo.show("exit");
        }

        private function showThanks(_arg_1:Event):void
        {
            this.introVideo.removeEventListener(IntroVideo.COMPLETE, this.showThanks);
            this.introVideo.hide();
            this.thanks.addEventListener(Thanks.SHOWING, this.sendResults, false, 0, true);
            this.thanks.show();
        }

        private function retakeFromResults(_arg_1:Event):void
        {
            this.result.removeEventListener(Result.COMPLETE, this.showThanks);
            this.result.removeEventListener(Result.RETAKE, this.retakeFromResults);
            this.result.hide();
            this.showSelection();
        }

        private function sendResults(_arg_1:Event):void
        {
            var _local_2:String;
            this.thanks.removeEventListener(Thanks.SHOWING, this.sendResults);
            var _local_3:BitmapData = this.solo.userPhoto;
            var _local_4:ByteArray = this.getJpeg(_local_3);
            var _local_5:String = this.getBase64(_local_4);
            var _local_6:Object = this.result.data;
            _local_6.customer = this.current.customer;
            _local_6.image = _local_5;
            this.queue.add(_local_6);
            var _local_7:Timer = new Timer(6000, 1);
            _local_7.addEventListener(TimerEvent.TIMER, this.doReset, false, 0, true);
            _local_7.start();
        }

        private function doReset(_arg_1:TimerEvent):void
        {
            this.thanks.hide();
            if (this.cityDialog.mode == "consumer")
            {
                this.init();
            }
            else
            {
                this.showSelector();
            };
        }

        private function timReset(_arg_1:Event):void
        {
            this.current.hide();
            this.selector.hide();
            this.solo.hide();
            this.result.hide();
            if (this.cityDialog.mode == "consumer")
            {
                this.init();
            }
            else
            {
                this.showSelector();
            };
        }

        private function getBase64(_arg_1:ByteArray):String
        {
            return (Base64.encodeByteArray(_arg_1));
        }

        private function getJpeg(_arg_1:BitmapData, _arg_2:int=80):ByteArray
        {
            var _local_3:JPEGEncoder = new JPEGEncoder(_arg_2);
            var _local_4:ByteArray = _local_3.encode(_arg_1);
            return (_local_4);
        }

        private function showCityDialog(_arg_1:Event):void
        {
            this.intro.disableRemote();
            this.queue.addEventListener(Queue.QUEUE_CHANGE, this.updateQueueEntries, false, 0, true);
            this.cityDialog.addEventListener(CityDialog.COMPLETE, this.hideCityDialog, false, 0, true);
            this.cityDialog.show(this.queue.remainingItems);
        }

        private function hideCityDialog(_arg_1:Event):void
        {
            this.queue.removeEventListener(Queue.QUEUE_CHANGE, this.updateQueueEntries);
            this.cityDialog.removeEventListener(CityDialog.COMPLETE, this.hideCityDialog);
            this.intro.enableRemote(this.cityDialog.theKey);
        }

        private function updateQueueEntries(_arg_1:Event):void
        {
            this.cityDialog.updateQueue(this.queue.remainingItems, this.queue.queueChangeString);
        }

        private function quitApp(_arg_1:Event):void
        {
            NativeApplication.nativeApplication.exit();
        }


    }
}//package com.gmrmarketing.katyperry.witness

