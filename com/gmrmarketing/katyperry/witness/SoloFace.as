// Decompiled by AS3 Sorcerer 5.64
// www.as3sorcerer.com

//com.gmrmarketing.katyperry.witness.SoloFace

package com.gmrmarketing.katyperry.witness
{
    import flash.events.EventDispatcher;
    import brfv4.BRFManager;
    import brfv4.as3.DrawingUtils;
    import flash.display.Sprite;
    import brfv4.utils.BRFv4PointUtils;
    import __AS3__.vec.Vector;
    import flash.media.Camera;
    import flash.display.BitmapData;
    import flash.media.Video;
    import flash.geom.Matrix;
    import flash.display.Bitmap;
    import flash.display.MovieClip;
    import flash.filters.BlurFilter;
    import flash.display.DisplayObjectContainer;
    import flash.filters.GlowFilter;
    import flash.utils.Timer;
    import com.gmrmarketing.utilities.TimeoutHelper;
    import flash.events.TimerEvent;
    import flash.net.URLLoader;
    import flash.events.Event;
    import flash.net.URLRequest;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import com.greensock.TweenMax;
    import com.greensock.easing.Back;
    import brfv4.BRFFace;
    import brfv4.BRFState;
    import flash.geom.Point;
    import com.chargedweb.utils.MatrixUtil;
    import __AS3__.vec.*;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.filters.*;
    import com.greensock.easing.*;
    import flare.basic.*;
    import flash.net.*;
    import flash.media.*;

    public class SoloFace extends EventDispatcher 
    {

        public static const BACK:String = "soloBack";
        public static const COMPLETE:String = "soloComplete";

        private const _width:Number = 0x0500;
        private const _height:Number = 720;

        private var brfManager:BRFManager;
        private var drawing:DrawingUtils;
        private var drawSprite:Sprite;
        private var toDegree:Function = BRFv4PointUtils.toDegree;
        private var _baseNodes:Vector.<Sprite> = new Vector.<Sprite>();
        private var camera:Camera;
        private var cameraData:BitmapData;
        private var video:Video;
        private var faceTexture:BitmapData;
        private var faceUVs:Vector.<Number>;
        private var camMatrix:Matrix;
        private var camImage:Bitmap;
        private var faceMask:BitmapData;
        private var rDialog:MovieClip;
        private var doTakePhoto:Boolean;
        private var f3d:HeadMask;
        private var maskDisplay:Bitmap;
        private var maskBlur:BlurFilter;
        private var clip:MovieClip;
        private var myContainer:DisplayObjectContainer;
        private var finalImage:BitmapData;
        private var bg:MovieClip;
        private var isApplyingMakeup:Boolean;
        private var isTriple:Boolean;
        private var isGroup:Boolean;
        private var colorVals:Array;
        private var eroder:GlowFilter;
        private var cityImages:Array;
        private var countdown:Countdown;
        private var tripleStep:int;
        private var step2Timer:Timer;
        private var tim:TimeoutHelper;
        private var restoreSelection:Boolean;
        private var isZoomPlaying:Boolean;

        public function SoloFace()
        {
            this.bg = new background();
            this.clip = new solo();
            this.countdown = new Countdown();
            this.rDialog = new rotDialog();
            this.drawSprite = new Sprite();
            this.tim = TimeoutHelper.getInstance();
            this.video = new Video(this._width, this._height);
            this.video.smoothing = true;
            this.step2Timer = new Timer(1000, 1);
            this.step2Timer.addEventListener(TimerEvent.TIMER, this.doStep2);
        }

        public function set container(_arg_1:DisplayObjectContainer):void
        {
            this.myContainer = _arg_1;
            this.countdown.container = this.myContainer;
        }

        public function get userPhoto():BitmapData
        {
            return (this.finalImage);
        }

        public function show(_arg_1:BRFManager, _arg_2:Boolean, _arg_3:Array, _arg_4:Array, _arg_5:Boolean):void
        {
            if (!this.myContainer.contains(this.clip))
            {
                this.myContainer.addChild(this.clip);
            };
            this.brfManager = _arg_1;
            this.isGroup = _arg_2;
            this.colorVals = _arg_3;
            this.cityImages = _arg_4;
            this.restoreSelection = _arg_5;
            if (this.isGroup)
            {
                this.clip.btnTriple.visible = false;
            }
            else
            {
                this.clip.btnTriple.visible = true;
            };
            this.clip.innerCircle.visible = false;
            this.clip.faceHole.visible = false;
            this.clip.headTurn.gotoAndStop(1);
            this.clip.headTurn.visible = false;
            this.clip.iconZoom.visible = false;
            this.clip.popup.gotoAndStop(1);
            this.clip.popup.visible = false;
            var _local_6:URLLoader = new URLLoader();
            _local_6.addEventListener(Event.COMPLETE, this.uvsLoaded);
            _local_6.load(new URLRequest("assets/baseuvs.txt"));
        }

        public function hide():void
        {
            this.countdown.removeEventListener(Countdown.FLASH, this.takePic);
            this.countdown.hide();
            this.clip.removeEventListener(Event.ENTER_FRAME, this.update);
            this.clip.btnMakeup.removeEventListener(MouseEvent.MOUSE_DOWN, this.selectMakeup);
            this.clip.btnTriple.removeEventListener(MouseEvent.MOUSE_DOWN, this.selectTriple);
            this.clip.btnNoMakeup.removeEventListener(MouseEvent.MOUSE_DOWN, this.selectNoMakeup);
            this.video.attachCamera(null);
            this.drawing.clear();
            this.step2Timer.reset();
            if (this.myContainer.contains(this.clip))
            {
                this.myContainer.removeChild(this.clip);
            };
            if (((this.drawSprite) && (this.clip.contains(this.drawSprite))))
            {
                this.clip.removeChild(this.drawSprite);
            };
            if (((this.camImage) && (this.clip.contains(this.camImage))))
            {
                this.clip.removeChild(this.camImage);
            };
            if (((this.f3d) && (this.clip.contains(this.f3d))))
            {
                this.clip.removeChild(this.f3d);
            };
        }

        private function uvsLoaded(_arg_1:Event):void
        {
            var _local_2:Array = _arg_1.target.data.split(",");
            this.faceUVs = new Vector.<Number>();
            var _local_3:int;
            while (_local_3 < _local_2.length)
            {
                this.faceUVs.push(_local_2[_local_3]);
                _local_3++;
            };
            this.drawing = new DrawingUtils(this.drawSprite);
            this.faceMask = new BitmapData(this._width, this._height, true, 0);
            this.faceTexture = new makeup();
            this.camera = Camera.getCamera();
            this.camera.setMode(this._width, this._height, 30);
            this.video.attachCamera(this.camera);
            this.cameraData = new BitmapData(this._width, this._height, true, 4282664004);
            this.camMatrix = new Matrix();
            this.camMatrix.scale(-1, 1);
            this.camMatrix.translate(this._width, 0);
            this.camImage = new Bitmap(this.cameraData);
            this.drawSprite.x = 320;
            this.drawSprite.y = 180;
            this.camImage.x = 320;
            this.camImage.y = 180;
            this.clip.addChildAt(this.drawSprite, 0);
            this.clip.addChildAt(this.camImage, 0);
            this.doTakePhoto = true;
            this.maskBlur = new BlurFilter(6, 6, 2);
            this.eroder = new GlowFilter(0, 1, 3, 3, 3, 2, true, false);
            this.clip.addChildAt(this.bg, 0);
            if (this.f3d == null)
            {
                this.f3d = new HeadMask(new Rectangle(0, 0, this._width, this._height));
                this.clip.addChildAt(this.f3d, 0);
            };
            this.tripleStep = 0;
            this.clip.btnTakePhoto.theText.text = "Take Photo";
            this.clip.btnTakePhoto.theText.y = -41;
            if (this.restoreSelection)
            {
                if (this.isTriple)
                {
                    this.clip.btnTriple.alpha = 1;
                    this.clip.btnTriple.x = 960;
                    this.clip.btnTriple.y = 766;
                    this.clip.btnTriple.scaleX = (this.clip.btnTriple.scaleY = 1);
                    this.clip.btnTriple.purpleCircle.scaleX = (this.clip.btnTriple.purpleCircle.scaleY = 1.2);
                    this.clip.btnMakeup.alpha = 1;
                    this.clip.btnMakeup.x = 835;
                    this.clip.btnMakeup.y = 831;
                    this.clip.btnMakeup.scaleX = (this.clip.btnMakeup.scaleY = 0.75);
                    this.clip.btnMakeup.purpleCircle.scaleX = (this.clip.btnMakeup.purpleCircle.scaleY = 0.75);
                    this.clip.btnNoMakeup.alpha = 1;
                    this.clip.btnNoMakeup.x = 1085;
                    this.clip.btnNoMakeup.y = 831;
                    this.clip.btnNoMakeup.scaleX = (this.clip.btnNoMakeup.scaleY = 0.75);
                    this.clip.btnNoMakeup.purpleCircle.scaleX = (this.clip.btnNoMakeup.purpleCircle.scaleY = 0.75);
                    this.clip.instructions.x = 1080;
                    this.clip.btnTakePhoto.theText.text = "Start";
                    this.clip.btnTakePhoto.theText.y = -21;
                    this.clip.popup.gotoAndStop(1);
                    this.clip.popup.visible = true;
                    this.clip.alpha = 1;
                    this.clip.popup.scaleX = (this.clip.popup.scaleY = 0);
                    TweenMax.to(this.clip.popup, 0.5, {
                        "scaleX":1,
                        "scaleY":1,
                        "ease":Back.easeOut
                    });
                }
                else
                {
                    if (this.isApplyingMakeup)
                    {
                        this.clip.btnMakeup.alpha = 1;
                        this.clip.btnMakeup.x = 835;
                        this.clip.btnMakeup.y = 831;
                        this.clip.btnMakeup.scaleX = (this.clip.btnMakeup.scaleY = 1);
                        this.clip.btnMakeup.purpleCircle.scaleX = (this.clip.btnMakeup.purpleCircle.scaleY = 1.2);
                        this.clip.btnTriple.alpha = 1;
                        this.clip.btnTriple.x = 960;
                        this.clip.btnTriple.y = 766;
                        this.clip.btnTriple.scaleX = (this.clip.btnTriple.scaleY = 0.75);
                        this.clip.btnTriple.purpleCircle.scaleX = (this.clip.btnTriple.purpleCircle.scaleY = 0.75);
                        this.clip.btnNoMakeup.alpha = 1;
                        this.clip.btnNoMakeup.x = 1085;
                        this.clip.btnNoMakeup.y = 831;
                        this.clip.btnNoMakeup.scaleX = (this.clip.btnNoMakeup.scaleY = 0.75);
                        this.clip.btnNoMakeup.purpleCircle.scaleX = (this.clip.btnNoMakeup.purpleCircle.scaleY = 0.75);
                    }
                    else
                    {
                        this.clip.btnMakeup.alpha = 1;
                        this.clip.btnMakeup.x = 835;
                        this.clip.btnMakeup.y = 831;
                        this.clip.btnMakeup.scaleX = (this.clip.btnMakeup.scaleY = 0.75);
                        this.clip.btnMakeup.purpleCircle.scaleX = (this.clip.btnMakeup.purpleCircle.scaleY = 0.75);
                        this.clip.btnTriple.alpha = 1;
                        this.clip.btnTriple.x = 960;
                        this.clip.btnTriple.y = 766;
                        this.clip.btnTriple.scaleX = (this.clip.btnTriple.scaleY = 0.75);
                        this.clip.btnTriple.purpleCircle.scaleX = (this.clip.btnTriple.purpleCircle.scaleY = 0.75);
                        this.clip.btnNoMakeup.alpha = 1;
                        this.clip.btnNoMakeup.x = 1085;
                        this.clip.btnNoMakeup.y = 831;
                        this.clip.btnNoMakeup.scaleX = (this.clip.btnNoMakeup.scaleY = 1);
                        this.clip.btnNoMakeup.purpleCircle.scaleX = (this.clip.btnNoMakeup.purpleCircle.scaleY = 1.2);
                    };
                };
            }
            else
            {
                this.isApplyingMakeup = true;
                this.isTriple = false;
                this.clip.btnMakeup.alpha = 1;
                this.clip.btnMakeup.x = 835;
                this.clip.btnMakeup.y = 831;
                this.clip.btnMakeup.scaleX = (this.clip.btnMakeup.scaleY = 1);
                this.clip.btnMakeup.purpleCircle.scaleX = (this.clip.btnMakeup.purpleCircle.scaleY = 1.2);
                this.clip.btnTriple.alpha = 1;
                this.clip.btnTriple.x = 960;
                this.clip.btnTriple.y = 766;
                this.clip.btnTriple.scaleX = (this.clip.btnTriple.scaleY = 0.75);
                this.clip.btnTriple.purpleCircle.scaleX = (this.clip.btnTriple.purpleCircle.scaleY = 0.75);
                this.clip.btnNoMakeup.alpha = 1;
                this.clip.btnNoMakeup.x = 1085;
                this.clip.btnNoMakeup.y = 831;
                this.clip.btnNoMakeup.scaleX = (this.clip.btnNoMakeup.scaleY = 0.75);
                this.clip.btnNoMakeup.purpleCircle.scaleX = (this.clip.btnNoMakeup.purpleCircle.scaleY = 0.75);
            };
            this.clip.instructions.visible = false;
            this.clip.faceHole.visible = false;
            this.clip.innerCircle.visible = false;
            this.clip.btnMakeup.addEventListener(MouseEvent.MOUSE_DOWN, this.selectMakeup, false, 0, true);
            this.clip.btnTriple.addEventListener(MouseEvent.MOUSE_DOWN, this.selectTriple, false, 0, true);
            this.clip.btnNoMakeup.addEventListener(MouseEvent.MOUSE_DOWN, this.selectNoMakeup, false, 0, true);
            this.clip.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, this.goBack, false, 0, true);
            this.clip.btnTakePhoto.removeEventListener(MouseEvent.MOUSE_DOWN, this.cancelPressed);
            this.clip.btnTakePhoto.addEventListener(MouseEvent.MOUSE_DOWN, this.beginCountdown, false, 0, true);
            this.clip.addEventListener(Event.ENTER_FRAME, this.update, false, 0, true);
        }

        private function selectMakeup(_arg_1:MouseEvent):void
        {
            this.tim.buttonClicked();
            TweenMax.killTweensOf(this.clip.btnTriple);
            TweenMax.killTweensOf(this.clip.btnTriple.purpleCircle);
            TweenMax.killTweensOf(this.clip.btnNoMakeup);
            TweenMax.killTweensOf(this.clip.btnNoMakeup.purpleCircle);
            this.clip.btnNoMakeup.scaleX = (this.clip.btnNoMakeup.scaleY = 0.75);
            this.clip.btnNoMakeup.purpleCircle.scaleX = (this.clip.btnNoMakeup.purpleCircle.scaleY = 0.75);
            this.clip.btnTriple.scaleX = (this.clip.btnTriple.scaleY = 0.75);
            this.clip.btnTriple.purpleCircle.scaleX = (this.clip.btnTriple.purpleCircle.scaleY = 0.75);
            TweenMax.to(this.clip.btnMakeup, 0.3, {
                "scaleX":1,
                "scaleY":1,
                "ease":Back.easeOut
            });
            TweenMax.to(this.clip.btnMakeup.purpleCircle, 0.3, {
                "scaleX":1.2,
                "scaleY":1.2,
                "delay":0.2,
                "ease":Back.easeOut
            });
            this.isApplyingMakeup = true;
            this.isTriple = false;
            this.clip.instructions.visible = false;
            this.clip.faceHole.visible = false;
            this.clip.innerCircle.visible = false;
            this.clip.popup.visible = false;
            this.clip.btnTakePhoto.theText.text = "Take Photo";
            this.clip.btnTakePhoto.theText.y = -41;
        }

        private function selectNoMakeup(_arg_1:MouseEvent):void
        {
            this.tim.buttonClicked();
            TweenMax.killTweensOf(this.clip.btnTriple);
            TweenMax.killTweensOf(this.clip.btnTriple.purpleCircle);
            TweenMax.killTweensOf(this.clip.btnMakeup);
            TweenMax.killTweensOf(this.clip.btnMakeup.purpleCircle);
            this.clip.btnMakeup.scaleX = (this.clip.btnMakeup.scaleY = 0.75);
            this.clip.btnMakeup.purpleCircle.scaleX = (this.clip.btnMakeup.purpleCircle.scaleY = 0.75);
            this.clip.btnTriple.scaleX = (this.clip.btnTriple.scaleY = 0.75);
            this.clip.btnTriple.purpleCircle.scaleX = (this.clip.btnTriple.purpleCircle.scaleY = 0.75);
            TweenMax.to(this.clip.btnNoMakeup, 0.3, {
                "scaleX":1,
                "scaleY":1,
                "ease":Back.easeOut
            });
            TweenMax.to(this.clip.btnNoMakeup.purpleCircle, 0.3, {
                "scaleX":1.2,
                "scaleY":1.2,
                "delay":0.2,
                "ease":Back.easeOut
            });
            this.isApplyingMakeup = false;
            this.isTriple = false;
            this.clip.instructions.visible = false;
            this.clip.faceHole.visible = false;
            this.clip.innerCircle.visible = false;
            this.clip.popup.visible = false;
            this.drawing.clear();
            this.clip.btnTakePhoto.theText.text = "Take Photo";
            this.clip.btnTakePhoto.theText.y = -41;
        }

        private function selectTriple(_arg_1:MouseEvent):void
        {
            this.tim.buttonClicked();
            TweenMax.killTweensOf(this.clip.btnNoMakeup);
            TweenMax.killTweensOf(this.clip.btnNoMakeup.purpleCircle);
            TweenMax.killTweensOf(this.clip.btnMakeup);
            TweenMax.killTweensOf(this.clip.btnMakeup.purpleCircle);
            this.clip.btnMakeup.scaleX = (this.clip.btnMakeup.scaleY = 0.75);
            this.clip.btnMakeup.purpleCircle.scaleX = (this.clip.btnMakeup.purpleCircle.scaleY = 0.75);
            this.clip.btnNoMakeup.scaleX = (this.clip.btnNoMakeup.scaleY = 0.75);
            this.clip.btnNoMakeup.purpleCircle.scaleX = (this.clip.btnNoMakeup.purpleCircle.scaleY = 0.75);
            TweenMax.to(this.clip.btnTriple, 0.3, {
                "scaleX":1,
                "scaleY":1,
                "ease":Back.easeOut
            });
            TweenMax.to(this.clip.btnTriple.purpleCircle, 0.3, {
                "scaleX":1.2,
                "scaleY":1.2,
                "delay":0.2,
                "ease":Back.easeOut
            });
            this.isApplyingMakeup = true;
            this.isTriple = true;
            this.clip.instructions.visible = false;
            this.clip.instructions.x = 1080;
            this.clip.faceHole.visible = false;
            this.clip.innerCircle.visible = false;
            this.clip.popup.gotoAndStop(1);
            this.clip.popup.visible = true;
            this.clip.popup.alpha = 1;
            this.clip.popup.scaleX = (this.clip.popup.scaleY = 0);
            TweenMax.to(this.clip.popup, 0.5, {
                "scaleX":1,
                "scaleY":1,
                "ease":Back.easeOut
            });
            this.clip.btnTakePhoto.theText.text = "Start";
            this.clip.btnTakePhoto.theText.y = -21;
            this.tripleStep = 0;
        }

        private function goBack(_arg_1:MouseEvent):void
        {
            this.tim.buttonClicked();
            dispatchEvent(new Event(BACK));
        }

        private function update(_arg_1:Event):void
        {
            var _local_2:Vector.<BRFFace>;
            var _local_3:int;
            var _local_4:BRFFace;
            var _local_5:Vector.<int>;
            var _local_6:Timer;
            this.cameraData.draw(this.video, this.camMatrix);
            if (this.isApplyingMakeup)
            {
                this.brfManager.update(this.cameraData);
                this.drawing.clear();
                _local_2 = this.brfManager.getFaces();
                _local_3 = 0;
                while (_local_3 < _local_2.length)
                {
                    _local_4 = _local_2[_local_3];
                    if (((_local_4.state == BRFState.FACE_TRACKING_START) || (_local_4.state == BRFState.FACE_TRACKING)))
                    {
                        _local_5 = _local_4.triangles.concat();
                        _local_5.splice((_local_5.length - 18), 18);
                        this.drawing.drawTexture(_local_4.vertices, _local_5, this.faceUVs, this.faceTexture);
                        if (this.isTriple)
                        {
                            if (this.f3d)
                            {
                                this.f3d.update(_local_3, _local_4, true);
                            };
                            if (((this.tripleStep == 1) || (this.tripleStep == 2)))
                            {
                                if (this.tripleStep == 1)
                                {
                                    if (_local_4.scale < 180)
                                    {
                                        this.clip.instructions.theText.text = "Move closer";
                                        this.step2Timer.reset();
                                        if (!this.isZoomPlaying)
                                        {
                                            this.isZoomPlaying = true;
                                            this.clip.iconZoom.gotoAndPlay(1);
                                        };
                                    }
                                    else
                                    {
                                        if (_local_4.scale > 240)
                                        {
                                            this.clip.instructions.theText.text = "Move back";
                                            this.step2Timer.reset();
                                            if (!(!(this.isZoomPlaying)))
                                            {
                                                this.isZoomPlaying = true;
                                                this.clip.iconZoom.gotoAndPlay(1);
                                            };
                                        }
                                        else
                                        {
                                            this.clip.instructions.theText.text = "Perfect";
                                            this.step2Timer.start();
                                            this.isZoomPlaying = false;
                                            this.clip.iconZoom.gotoAndStop(76);
                                        };
                                    };
                                };
                                this.clip.innerCircle.scaleX = (this.clip.innerCircle.scaleY = (_local_4.scale * 0.007));
                                if (_local_4.scale < 180)
                                {
                                    TweenMax.killTweensOf(this.clip.faceHole);
                                    TweenMax.to(this.clip.faceHole, 0.5, {"colorTransform":{
                                            "tint":0,
                                            "tintAmount":1
                                        }});
                                }
                                else
                                {
                                    if (_local_4.scale > 240)
                                    {
                                        TweenMax.killTweensOf(this.clip.faceHole);
                                        TweenMax.to(this.clip.faceHole, 0.5, {"colorTransform":{
                                                "tint":0,
                                                "tintAmount":1
                                            }});
                                    }
                                    else
                                    {
                                        TweenMax.killTweensOf(this.clip.faceHole);
                                        TweenMax.to(this.clip.faceHole, 0.5, {"colorTransform":{
                                                "tint":11232946,
                                                "tintAmount":1
                                            }});
                                    };
                                };
                                if (this.tripleStep == 2)
                                {
                                    if (_local_4.rotationY < 0.35)
                                    {
                                        this.clip.instructions.theText.text = "Turn your head to the left";
                                    }
                                    else
                                    {
                                        if (_local_4.rotationY > 0.6)
                                        {
                                            this.clip.instructions.theText.text = "Too far left";
                                        }
                                        else
                                        {
                                            this.clip.instructions.theText.text = "Hold that pose!";
                                        };
                                    };
                                };
                            };
                            if (((((((this.tripleStep == 2) && (this.doTakePhoto)) && (_local_4.scale > 180)) && (_local_4.scale < 240)) && (_local_4.rotationY > 0.35)) && (_local_4.rotationY < 0.6)))
                            {
                                TweenMax.to(this.clip.faceHole, 0.3, {"alpha":0});
                                TweenMax.to(this.clip.innerCircle, 0.3, {"alpha":0});
                                this.doTakePhoto = false;
                                _local_6 = new Timer(500, 1);
                                _local_6.addEventListener(TimerEvent.TIMER, this.takeTriplePic, false, 0, true);
                                _local_6.start();
                            };
                        };
                    };
                    _local_3++;
                };
            };
        }

        private function doStep2(_arg_1:TimerEvent):void
        {
            this.tim.buttonClicked();
            this.tripleStep = 2;
            this.clip.headTurn.play();
            this.clip.headTurn.visible = true;
            this.clip.iconZoom.visible = false;
            this.clip.iconZoom.gotoAndStop(1);
            this.clip.instructions.x = 1018;
            this.isZoomPlaying = false;
        }

        private function takeTriplePic(_arg_1:TimerEvent):void
        {
            this.countdown.removeEventListener(Countdown.FLASH, this.takePic);
            this.countdown.showWhite();
            var _local_2:BitmapData = this.grabUserPhoto();
            this.finalImage = this.createTriple(_local_2);
            var _local_3:Timer = new Timer(500, 1);
            _local_3.addEventListener(TimerEvent.TIMER, this.sendComplete, false, 0, true);
            _local_3.start();
        }

        private function sendComplete(_arg_1:TimerEvent):void
        {
            dispatchEvent(new Event(COMPLETE));
        }

        private function grabUserPhoto():BitmapData
        {
            var _local_1:BitmapData = new BitmapData(this._width, this._height);
            _local_1.draw(this.cameraData);
            if (this.isApplyingMakeup)
            {
                _local_1.draw(this.drawSprite);
            };
            return (_local_1);
        }

        private function takePic(_arg_1:Event):void
        {
            this.countdown.removeEventListener(Countdown.FLASH, this.takePic);
            var _local_2:BitmapData = this.grabUserPhoto();
            var _local_3:BitmapData = new overlay2();
            _local_3.copyPixels(this.cityImages[1], this.cityImages[1].rect, new Point(620, 1015), null, null, true);
            var _local_4:Matrix = new Matrix();
            _local_4.scale(1.5, 1.5);
            var _local_5:BitmapData = new BitmapData(720, 720, false, 0);
            _local_5.copyPixels(_local_2, new Rectangle(280, 0, 720, 720), new Point());
            this.finalImage = new BitmapData(1080, 1080, false, 0xFFFFFF);
            this.finalImage.draw(_local_5, _local_4, null, null, null, true);
            this.finalImage.copyPixels(_local_3, new Rectangle(0, 0, 1080, 1080), new Point(), null, null, true);
            var _local_6:Timer = new Timer(500, 1);
            _local_6.addEventListener(TimerEvent.TIMER, this.sendComplete, false, 0, true);
            _local_6.start();
        }

        private function beginCountdown(_arg_1:MouseEvent):void
        {
            this.clip.btnTakePhoto.removeEventListener(MouseEvent.MOUSE_DOWN, this.beginCountdown);
            this.clip.btnTakePhoto.fill.alpha = 1;
            TweenMax.to(this.clip.btnTakePhoto.fill, 0.3, {"alpha":0});
            this.tim.buttonClicked();
            if (this.isTriple)
            {
                this.hideButtons();
                this.clip.btnTakePhoto.visible = false;
                this.clip.instructions.theText.text = "Move Closer";
                this.clip.instructions.x = 1080;
                this.clip.popup.gotoAndStop(2);
                TweenMax.to(this.clip.instructions, 0.5, {
                    "delay":2,
                    "alpha":1,
                    "onComplete":this.startIconZoom
                });
                TweenMax.to(this.clip.popup, 0.5, {
                    "delay":2,
                    "alpha":0,
                    "onComplete":this.killPopup
                });
            }
            else
            {
                this.hideButtons();
                this.countdown.addEventListener(Countdown.FLASH, this.takePic, false, 0, true);
                this.countdown.show();
            };
        }

        private function startIconZoom():*
        {
            this.clip.btnTakePhoto.visible = true;
            this.clip.btnTakePhoto.theText.text = "Cancel";
            this.clip.btnTakePhoto.theText.y = -21;
            this.clip.btnTakePhoto.addEventListener(MouseEvent.MOUSE_DOWN, this.cancelPressed, false, 0, true);
            this.clip.instructions.visible = true;
            this.clip.instructions.alpha = 1;
            this.clip.innerCircle.visible = true;
            this.clip.innerCircle.alpha = 1;
            this.clip.faceHole.visible = true;
            this.clip.faceHole.alpha = 0.6;
            this.clip.iconZoom.visible = true;
            this.clip.iconZoom.gotoAndPlay(1);
            this.tripleStep = 1;
        }

        private function killPopup():void
        {
            this.clip.popup.gotoAndStop(1);
            this.clip.popup.visible = false;
        }

        private function hideButtons():void
        {
            TweenMax.to(this.clip.btnMakeup, 0.5, {
                "scaleX":0,
                "scaleY":0,
                "x":960,
                "y":906,
                "alpha":0
            });
            TweenMax.to(this.clip.btnTriple, 0.5, {
                "scaleX":0,
                "scaleY":0,
                "x":960,
                "y":906,
                "alpha":0
            });
            TweenMax.to(this.clip.btnNoMakeup, 0.5, {
                "scaleX":0,
                "scaleY":0,
                "x":960,
                "y":906,
                "alpha":0
            });
        }

        private function cancelPressed(_arg_1:MouseEvent):void
        {
            this.tim.buttonClicked();
            TweenMax.killTweensOf(this.clip.instructions);
            this.clip.btnTakePhoto.removeEventListener(MouseEvent.MOUSE_DOWN, this.cancelPressed);
            this.clip.btnTakePhoto.theText.text = "Start";
            this.clip.btnTakePhoto.theText.y = -21;
            this.clip.btnTakePhoto.addEventListener(MouseEvent.MOUSE_DOWN, this.beginCountdown, false, 0, true);
            TweenMax.to(this.clip.faceHole, 0.5, {"alpha":0});
            TweenMax.to(this.clip.innerCircle, 0.5, {"alpha":0});
            TweenMax.to(this.clip.instructions, 0.5, {"alpha":0});
            this.clip.headTurn.visible = false;
            this.clip.iconZoom.visible = false;
            this.tripleStep = 0;
            TweenMax.to(this.clip.btnMakeup, 0.5, {
                "scaleX":0.75,
                "scaleY":0.75,
                "x":835,
                "y":831,
                "alpha":1
            });
            TweenMax.to(this.clip.btnTriple, 0.5, {
                "scaleX":1,
                "scaleY":1,
                "x":960,
                "y":766,
                "alpha":1
            });
            TweenMax.to(this.clip.btnNoMakeup, 0.5, {
                "scaleX":0.75,
                "scaleY":0.75,
                "x":1085,
                "y":831,
                "alpha":1
            });
        }

        private function createTriple(_arg_1:BitmapData):BitmapData
        {
            var _local_10:uint;
            this.faceMask = this.f3d.getScreenshot();
            var _local_2:BitmapData = new BitmapData(1080, 1080, false, 0xFFFFFF);
            var _local_3:BitmapData = new BitmapData(this._width, this._height, true, 0);
            var _local_4:BitmapData = new BitmapData(this._width, this._height, true, 0);
            var _local_5:BitmapData = new pinkFade();
            var _local_6:BitmapData = new overlay();
            _local_6.copyPixels(this.cityImages[0], this.cityImages[0].rect, new Point(325, 788), null, null, true);
            _local_3.threshold(this.faceMask, new Rectangle(0, 0, this._width, this._height), new Point(), ">", 0, 0xFFFFFFFF, 0xFFFFFF);
            _local_3.applyFilter(_local_3, new Rectangle(0, 0, this._width, this._height), new Point(), this.eroder);
            _local_3.threshold(_local_3, new Rectangle(0, 0, this._width, this._height), new Point(), ">", 0xEEEEEE, 0xFFFFFFFF, 0xFFFFFF, false);
            _local_3.fillRect(new Rectangle((this._width * 0.5), 0, (this._width * 0.5), this._height), 0xFFFFFFFF);
            _local_3.applyFilter(_local_3, new Rectangle(0, 0, this._width, this._height), new Point(), this.maskBlur);
            _local_4.copyPixels(_arg_1, new Rectangle(0, 0, this._width, this._height), new Point(), _local_3, new Point(), true);
            var _local_7:BitmapData = new BitmapData(353, 530, true, 0);
            _local_7.copyPixels(_local_4, new Rectangle(450, 115, 353, 530), new Point(0, 0), null, null, true);
            var _local_8:BitmapData = new BitmapData(479, 720, true, 0);
            var _local_9:Matrix = new Matrix();
            _local_9.scale(1.35849056603774, 1.35849056603774);
            _local_8.draw(_local_7, _local_9, null, null, null, true);
            var _local_11:int;
            while (_local_11 < 479)
            {
                _local_10 = _local_8.getPixel(_local_11, 360);
                if (_local_10 != 0) break;
                _local_11++;
            };
            _local_11 = (_local_11 * 0.28);
            _local_8.applyFilter(_local_8, _local_8.rect, new Point(), MatrixUtil.setBrightness(this.colorVals[0]));
            _local_8.applyFilter(_local_8, _local_8.rect, new Point(), MatrixUtil.setContrast(this.colorVals[1]));
            _local_8.applyFilter(_local_8, _local_8.rect, new Point(), MatrixUtil.setSaturation(this.colorVals[2]));
            var _local_12:Matrix = new Matrix();
            _local_12.scale(0.96, 0.96);
            var _local_13:Matrix = new Matrix();
            _local_13.scale(0.98, 0.98);
            var _local_14:BitmapData = new BitmapData((_local_8.width * _local_12.a), (_local_8.height * _local_12.d), true, 0);
            var _local_15:BitmapData = new BitmapData((_local_8.width * _local_13.a), (_local_8.height * _local_13.d), true, 0);
            _local_14.draw(_local_8, _local_12, null, null, null, true);
            _local_15.draw(_local_8, _local_13, null, null, null, true);
            var _local_16:int = 70;
            _local_2.copyPixels(_local_5, _local_5.rect, new Point((170 + (_local_11 * 0.96)), (_local_16 + 70)), null, null, true);
            _local_2.copyPixels(_local_14, _local_14.rect, new Point(170, (_local_16 + 20)), null, null, true);
            _local_2.copyPixels(_local_5, _local_5.rect, new Point((280 + (_local_11 * 0.98)), (_local_16 + 70)), null, null, true);
            _local_2.copyPixels(_local_15, _local_15.rect, new Point(280, (_local_16 + 10)), null, null, true);
            _local_2.copyPixels(_local_5, _local_5.rect, new Point((390 + _local_11), (_local_16 + 70)), null, null, true);
            _local_2.copyPixels(_local_8, _local_8.rect, new Point(390, _local_16), null, null, true);
            _local_2.copyPixels(_local_6, new Rectangle(0, 0, 1080, 1080), new Point(), null, null, true);
            return (_local_2);
        }


    }
}//package com.gmrmarketing.katyperry.witness

