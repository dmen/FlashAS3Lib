package com.gmrmarketing.katyperry.witness
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.media.*;
	import flash.filters.*;
	import brfv4.BRFFace;//in the ANE
	import brfv4.BRFManager;//in the ANE
	import brfv4.as3.DrawingUtils;
	import brfv4.utils.BRFv4PointUtils;
	import brfv4.utils.BRFv4Drawing3DUtils_Flare3D;
	import flash.display3D.textures.RectangleTexture;	
	import flash.geom.*;
	import flare.basic.*;
	import com.chargedweb.utils.MatrixUtil;
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class SoloFace extends EventDispatcher
	{
		public static const BACK:String = "soloBack";
		public static const COMPLETE:String = "soloComplete";
		
		private var brfManager:BRFManager;//instantiated in Main
		
		private var drawing:DrawingUtils;
		private var drawSprite:Sprite;
		
		private var toDegree:Function = BRFv4PointUtils.toDegree;
		
		private var _baseNodes:Vector.<Sprite> = new Vector.<Sprite>();
		
		private const _width:Number = 1280;//Camera
		private const _height:Number = 720;
		
		private var camera:Camera;
		private var cameraData:BitmapData;
		private var video:Video;
		
		private var faceTexture:BitmapData;
		
		private var faceUVs:Vector.<Number>;
		
		private var camMatrix:Matrix;
		private var camImage:Bitmap;//bitmap for displaying the masked camera image
		private var faceMask:BitmapData;
		
		private var rDialog:MovieClip;
				
		private var doTakePhoto:Boolean;
		
		private var f3d:HeadMask;		
		
		private var maskDisplay:Bitmap;
		
		private var maskBlur:BlurFilter;
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var finalImage:BitmapData;
		
		private var bg:MovieClip;//background graphic
		private var isApplyingMakeup:Boolean;
		private var isTriple:Boolean;
		private var isGroup:Boolean;
		
		private var colorVals:Array;//brightness,contrast,saturation from cityDialog
		
		private var eroder:GlowFilter;
		
		private var cityImages:Array;//black/white text images of the city name from the cityDialog 
		
		private var countdown:Countdown;
		
		private var tripleStep:int;
		private var step2Timer:Timer;
		
		private var tim:TimeoutHelper;
		private var restoreSelection:Boolean;//set in show
		private var isZoomPlaying:Boolean;//flag because isPlaying doesn't seem to work 
		
		
		
		public function SoloFace()
		{	
			bg = new background();			
			clip = new solo();
			countdown = new Countdown();
			rDialog = new rotDialog();
			
			tim = TimeoutHelper.getInstance();
			
			step2Timer = new Timer(1000, 1);
			step2Timer.addEventListener(TimerEvent.TIMER, doStep2);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
			countdown.container = myContainer;
		}
		
		
		public function get userPhoto():BitmapData
		{
			return finalImage;
		}
		
		
		/**
		 * 
		 * @param	b
		 * @param	group
		 * @param	colorValues
		 * @param	cIms Array with two bitmapData's of the city image - index 0 is black text, index 1 is white text
		 * @param	showLastSelection if true the button state changes depending on the state of isTriple and isApplyingMakeup
		 */
		public function show(b:BRFManager, group:Boolean, colorValues:Array, cIms:Array, showLastSelection:Boolean):void
		{			
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			brfManager = b;
			isGroup = group;
			colorVals = colorValues;
			cityImages = cIms;
			restoreSelection = showLastSelection; 
			
			//if group - hide the triple face and head shape buttons
			if (isGroup){
				clip.btnTriple.visible = false;	
				clip.soloGroup.gotoAndStop(2);//big word on the left side
			}else{
				//solo
				clip.btnTriple.visible = true;
				clip.soloGroup.gotoAndStop(1);//big word on the left side
			}
			
			clip.innerCircle.visible = false;
			clip.faceHole.visible = false;
			
			//icons for instructions
			clip.headTurn.stop();
			clip.headTurn.visible = false;
			clip.iconZoom.visible = false;
			
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, uvsLoaded);
			l.load(new URLRequest("assets/baseuvs.txt"));
		}
		
		
		public function hide():void
		{
			countdown.removeEventListener(Countdown.FLASH, takePic);
			countdown.hide();
			
			clip.removeEventListener(Event.ENTER_FRAME, update);
			
			clip.btnMakeup.removeEventListener(MouseEvent.MOUSE_DOWN, selectMakeup);
			clip.btnTriple.removeEventListener(MouseEvent.MOUSE_DOWN, selectTriple);
			clip.btnNoMakeup.removeEventListener(MouseEvent.MOUSE_DOWN, selectNoMakeup);
			
			video.attachCamera(null);
			
			step2Timer.reset();
			
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			
			if (clip.contains(drawSprite)){
				clip.removeChild(drawSprite);
			}
			
			if (clip.contains(camImage)){
				clip.removeChild(camImage);
			}
			if (clip.contains(f3d)){
				clip.removeChild(f3d);
			}
		}
		
		
		private function uvsLoaded(e:Event):void 
		{		
			var a:Array = e.target.data.split(",");
			faceUVs = new Vector.<Number>();
			for (var i:int = 0; i < a.length; i++){
				faceUVs.push(a[i]);
			}			
			
			drawSprite = new Sprite();
			drawing	= new DrawingUtils(drawSprite);						
			
			faceMask = new BitmapData(_width, _height, true, 0x00000000);
			
			faceTexture = new makeup();
			
			camera = Camera.getCamera();
			camera.setMode(_width, _height, 30);
			
			video = new Video(_width, _height);
			video.smoothing = true;			
			
			video.attachCamera(camera);
			
			cameraData = new BitmapData(_width, _height, true, 0xff444444);//not put on screen
			camMatrix = new Matrix();
			camMatrix.scale( -1, 1);//for flipping the camera image horizontally
			camMatrix.translate(_width, 0);			
			
			camImage = new Bitmap(cameraData);			
			
			drawSprite.x = 320;
			drawSprite.y = 180;			
			camImage.x = 320;
			camImage.y = 180;
			
			//add behind faceHole on stage already in the clip
			clip.addChildAt(drawSprite, 0);
			clip.addChildAt(camImage, 0);
			
CONFIG::TESTING{
			maskDisplay = new Bitmap(new BitmapData(1280, 720, true, 0x00000000));	
			clip.addChild(maskDisplay);
			maskDisplay.x = 320;
			maskDisplay.y = 180;
			clip.addChild(rDialog);
}//config::testing

			doTakePhoto = true;			
			
			maskBlur = new BlurFilter(10, 10, 2);
			eroder = new GlowFilter(0x000000, 1, 3, 3, 3, 2, true, false);
			
			clip.addChildAt(bg, 0);
			
			if(f3d == null) {
				f3d = new HeadMask(new Rectangle(0, 0, _width, _height));
				clip.addChildAt(f3d, 0);
			}
			
			tripleStep = 0;
			//button default - is istriple it will change to start
			clip.btnTakePhoto.theText.text = "Take Photo";
			clip.btnTakePhoto.theText.y = -41;
			
			if (restoreSelection){
				
				if (isTriple){
					clip.btnTriple.alpha = 1;
					clip.btnTriple.x = 960;
					clip.btnTriple.y = 766;
					clip.btnTriple.scaleX = clip.btnTriple.scaleY = 1;
					clip.btnTriple.purpleCircle.scaleX = clip.btnTriple.purpleCircle.scaleY = 1.2;
					
					clip.btnMakeup.alpha = 1;
					clip.btnMakeup.x = 835;
					clip.btnMakeup.y = 831;
					clip.btnMakeup.scaleX = clip.btnMakeup.scaleY = .75;
					clip.btnMakeup.purpleCircle.scaleX = clip.btnMakeup.purpleCircle.scaleY = .75;
					
					clip.btnNoMakeup.alpha = 1;
					clip.btnNoMakeup.x = 1085;
					clip.btnNoMakeup.y = 831;
					clip.btnNoMakeup.scaleX = clip.btnNoMakeup.scaleY = .75;
					clip.btnNoMakeup.purpleCircle.scaleX = clip.btnNoMakeup.purpleCircle.scaleY = .75;
					
					//button
					clip.btnTakePhoto.theText.text = "Start";
					clip.btnTakePhoto.theText.y = -21;
			
				}else if (isApplyingMakeup){
					clip.btnMakeup.alpha = 1;
					clip.btnMakeup.x = 835;
					clip.btnMakeup.y = 831;
					clip.btnMakeup.scaleX = clip.btnMakeup.scaleY = 1;
					clip.btnMakeup.purpleCircle.scaleX = clip.btnMakeup.purpleCircle.scaleY = 1.2;
					
					clip.btnTriple.alpha = 1;
					clip.btnTriple.x = 960;
					clip.btnTriple.y = 766;
					clip.btnTriple.scaleX = clip.btnTriple.scaleY = .75;
					clip.btnTriple.purpleCircle.scaleX = clip.btnTriple.purpleCircle.scaleY = .75;
					
					clip.btnNoMakeup.alpha = 1;
					clip.btnNoMakeup.x = 1085;
					clip.btnNoMakeup.y = 831;
					clip.btnNoMakeup.scaleX = clip.btnNoMakeup.scaleY = .75;
					clip.btnNoMakeup.purpleCircle.scaleX = clip.btnNoMakeup.purpleCircle.scaleY = .75;
				}else{
					clip.btnMakeup.alpha = 1;
					clip.btnMakeup.x = 835;
					clip.btnMakeup.y = 831;
					clip.btnMakeup.scaleX = clip.btnMakeup.scaleY = .75;
					clip.btnMakeup.purpleCircle.scaleX = clip.btnMakeup.purpleCircle.scaleY = .75;
					
					clip.btnTriple.alpha = 1;
					clip.btnTriple.x = 960;
					clip.btnTriple.y = 766;
					clip.btnTriple.scaleX = clip.btnTriple.scaleY = .75;
					clip.btnTriple.purpleCircle.scaleX = clip.btnTriple.purpleCircle.scaleY = .75;
					
					clip.btnNoMakeup.alpha = 1;
					clip.btnNoMakeup.x = 1085;
					clip.btnNoMakeup.y = 831;
					clip.btnNoMakeup.scaleX = clip.btnNoMakeup.scaleY = 1;
					clip.btnNoMakeup.purpleCircle.scaleX = clip.btnNoMakeup.purpleCircle.scaleY = 1.2;
				}
				
			}else{
				isApplyingMakeup = true;
				isTriple = false;
				
				//makeup selected by default
				clip.btnMakeup.alpha = 1;
				clip.btnMakeup.x = 835;
				clip.btnMakeup.y = 831;
				clip.btnMakeup.scaleX = clip.btnMakeup.scaleY = 1;
				clip.btnMakeup.purpleCircle.scaleX = clip.btnMakeup.purpleCircle.scaleY = 1.2;
				
				clip.btnTriple.alpha = 1;
				clip.btnTriple.x = 960;
				clip.btnTriple.y = 766;
				clip.btnTriple.scaleX = clip.btnTriple.scaleY = .75;
				clip.btnTriple.purpleCircle.scaleX = clip.btnTriple.purpleCircle.scaleY = .75;
				
				clip.btnNoMakeup.alpha = 1;
				clip.btnNoMakeup.x = 1085;
				clip.btnNoMakeup.y = 831;
				clip.btnNoMakeup.scaleX = clip.btnNoMakeup.scaleY = .75;
				clip.btnNoMakeup.purpleCircle.scaleX = clip.btnNoMakeup.purpleCircle.scaleY = .75;
			}			
			
			clip.instructions.visible = false;
			clip.faceHole.visible = false;
			clip.innerCircle.visible = false;	
			
			clip.btnMakeup.addEventListener(MouseEvent.MOUSE_DOWN, selectMakeup, false, 0, true);
			clip.btnTriple.addEventListener(MouseEvent.MOUSE_DOWN, selectTriple, false, 0, true);
			clip.btnNoMakeup.addEventListener(MouseEvent.MOUSE_DOWN, selectNoMakeup, false, 0, true);
			
			clip.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, goBack, false, 0, true);
			
			//button
			clip.btnTakePhoto.removeEventListener(MouseEvent.MOUSE_DOWN, cancelPressed);
			clip.btnTakePhoto.addEventListener(MouseEvent.MOUSE_DOWN, beginCountdown, false, 0, true);
			
			clip.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		
		private function selectMakeup(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			TweenMax.killTweensOf(clip.btnTriple);
			TweenMax.killTweensOf(clip.btnTriple.purpleCircle);
			TweenMax.killTweensOf(clip.btnNoMakeup);
			TweenMax.killTweensOf(clip.btnNoMakeup.purpleCircle);
			
			clip.btnNoMakeup.scaleX = clip.btnNoMakeup.scaleY = .75;
			clip.btnNoMakeup.purpleCircle.scaleX = clip.btnNoMakeup.purpleCircle.scaleY = .75;
			
			clip.btnTriple.scaleX = clip.btnTriple.scaleY = .75;
			clip.btnTriple.purpleCircle.scaleX = clip.btnTriple.purpleCircle.scaleY = .75;
			
			TweenMax.to(clip.btnMakeup, .3, {scaleX:1, scaleY:1, ease:Back.easeOut});
			TweenMax.to(clip.btnMakeup.purpleCircle, .3, {scaleX:1.2, scaleY:1.2, delay:.2, ease:Back.easeOut});
			
			isApplyingMakeup = true;
			isTriple = false;
			
			clip.instructions.visible = false;
			clip.faceHole.visible = false;
			clip.innerCircle.visible = false;
			
			//button
			clip.btnTakePhoto.theText.text = "Take Photo";
			clip.btnTakePhoto.theText.y = -41;
		}
		
		
		private function selectNoMakeup(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			TweenMax.killTweensOf(clip.btnTriple);
			TweenMax.killTweensOf(clip.btnTriple.purpleCircle);
			TweenMax.killTweensOf(clip.btnMakeup);
			TweenMax.killTweensOf(clip.btnMakeup.purpleCircle);
			
			clip.btnMakeup.scaleX = clip.btnMakeup.scaleY = .75;
			clip.btnMakeup.purpleCircle.scaleX = clip.btnMakeup.purpleCircle.scaleY = .75;
			
			clip.btnTriple.scaleX = clip.btnTriple.scaleY = .75;
			clip.btnTriple.purpleCircle.scaleX = clip.btnTriple.purpleCircle.scaleY = .75;
			
			TweenMax.to(clip.btnNoMakeup, .3, {scaleX:1, scaleY:1, ease:Back.easeOut});
			TweenMax.to(clip.btnNoMakeup.purpleCircle, .3, {scaleX:1.2, scaleY:1.2, delay:.2, ease:Back.easeOut});
			
			isApplyingMakeup = false;
			isTriple = false;
			
			clip.instructions.visible = false;
			clip.faceHole.visible = false;
			clip.innerCircle.visible = false;
			
			drawing.clear();//remove makeup from the overlay
			
			//button
			clip.btnTakePhoto.theText.text = "Take Photo";
			clip.btnTakePhoto.theText.y = -41;
		}
		
		
		private function selectTriple(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			TweenMax.killTweensOf(clip.btnNoMakeup);
			TweenMax.killTweensOf(clip.btnNoMakeup.purpleCircle);
			TweenMax.killTweensOf(clip.btnMakeup);
			TweenMax.killTweensOf(clip.btnMakeup.purpleCircle);
			
			clip.btnMakeup.scaleX = clip.btnMakeup.scaleY = .75;
			clip.btnMakeup.purpleCircle.scaleX = clip.btnMakeup.purpleCircle.scaleY = .75;
			
			clip.btnNoMakeup.scaleX = clip.btnNoMakeup.scaleY = .75;
			clip.btnNoMakeup.purpleCircle.scaleX = clip.btnNoMakeup.purpleCircle.scaleY = .75;
			
			TweenMax.to(clip.btnTriple, .3, {scaleX:1, scaleY:1, ease:Back.easeOut});
			TweenMax.to(clip.btnTriple.purpleCircle, .3, {scaleX:1.2, scaleY:1.2, delay:.2, ease:Back.easeOut});
			
			isApplyingMakeup = true;
			isTriple = true;
			clip.instructions.visible = false;
			clip.faceHole.visible = false;
			clip.innerCircle.visible = false;
			
			//button
			clip.btnTakePhoto.theText.text = "Start";
			clip.btnTakePhoto.theText.y = -21;
					
			tripleStep = 0;
		}
		
		
		//user clicked the back button
		private function goBack(e:MouseEvent):void
		{
			tim.buttonClicked();
			dispatchEvent(new Event(BACK));
		}		
		
		
		private function update(e:Event) : void 
		{
			cameraData.draw(video, camMatrix);//just flips image horizontally	
			
			if (isApplyingMakeup){
				
				brfManager.update(cameraData);		
				
				drawing.clear();
		
				// Get all faces. 	
				var faces:Vector.<BRFFace> = brfManager.getFaces();
		
				// If no face was tracked: hide the image overlays.	
				for(var i:int = 0; i < faces.length; i++) {
		
					var face:BRFFace = faces[i]; // get face
					
					if(face.state == brfv4.BRFState.FACE_TRACKING_START || face.state == brfv4.BRFState.FACE_TRACKING) {
						
						var triangles:Vector.<int> = face.triangles.concat();	
						triangles.splice(triangles.length - 18, 18);	
						drawing.drawTexture(face.vertices, triangles, faceUVs, faceTexture);
CONFIG::TESTING {						
						var b:BitmapData = new BitmapData(_width, _height, true, 0x00000000);
}
						
						if(isTriple){
							//f3d only used for the triple face
							if (f3d){
								f3d.update(i, face, true);								
CONFIG::TESTING {
								faceMask = f3d.getScreenshot();
								
								//turn anything not black to pure white
								b.threshold(faceMask, new Rectangle(0, 0, _width, _height), new Point(), ">", 0x00000000, 0xffffffff, 0x00ffffff);								
								
								//inner black glow for the erosion
								b.applyFilter(b, new Rectangle(0, 0, _width, _height), new Point(), eroder);		
								
								//threshold the inner glow image to get only the white pixels - which effectively erodes the edges								
								b.threshold(b, new Rectangle(0, 0, _width, _height), new Point(), ">", 0x00EEEEEE, 0xFFFFFFFF, 0x00FFFFFF, false);								
								
								//blur the edges
								b.applyFilter(b, new Rectangle(0, 0, _width, _height), new Point(), maskBlur);								
								
								//TESTING
								maskDisplay.bitmapData.draw(cameraData, null, null, null, null, true);
								maskDisplay.bitmapData.draw(b, null, null, BlendMode.DIFFERENCE, null, true);
								rDialog.sc.text = face.scale;
								rDialog.ry.text = face.rotationY;								
}//config::testing
							}
							
							//set to 1 in beginTripleSequence() after "start"button is pressed
							if (tripleStep == 1 || tripleStep == 2){
								
								//scale text only changes on step 1
								if (tripleStep == 1){									
									if (face.scale < 230){
										clip.instructions.theText.text = "Move Closer";
										step2Timer.reset();
										if (!isZoomPlaying){
											isZoomPlaying = true;
											clip.iconZoom.gotoAndPlay(1);
										}
									}else if (face.scale > 270){
										clip.instructions.theText.text = "Move Back";
										step2Timer.reset();
										if (!!isZoomPlaying){
											isZoomPlaying = true;
											clip.iconZoom.gotoAndPlay(1);
										}
									}else{
										clip.instructions.theText.text = "Perfect";
										//user has to stay proper for one sec before going to step 2 - turn left
										step2Timer.start();
										isZoomPlaying = false;
										clip.iconZoom.gotoAndStop(76);//pink circle with check
									}
								}
								
								//change circle size and color on both steps								
								clip.innerCircle.scaleX = clip.innerCircle.scaleY = face.scale * .00528;
								
								if (face.scale < 230){									
									TweenMax.killTweensOf(clip.faceHole);
									TweenMax.to(clip.faceHole, .5, {colorTransform:{tint:0x000000, tintAmount:1}});
								}else if (face.scale > 270){									
									TweenMax.killTweensOf(clip.faceHole);
									TweenMax.to(clip.faceHole, .5, {colorTransform:{tint:0x000000, tintAmount:1}});
								}else{
									TweenMax.killTweensOf(clip.faceHole);
									TweenMax.to(clip.faceHole, .5, {colorTransform:{tint:0xAB66B2, tintAmount:1}});
								}								
							
								if(tripleStep == 2){									
									if (face.rotationY < .35){
										clip.instructions.theText.text = "Turn your head to the left";
									}else if (face.rotationY > .6){
										clip.instructions.theText.text = "Too far left";
									}else{
										clip.instructions.theText.text = "Hold that pose!";
									}
								}
								
							}//tripleStep == 1 || tripleStep == 2
							
							
							if (tripleStep == 2 && doTakePhoto && face.scale > 230 && face.scale < 270 && face.rotationY > .35 && face.rotationY < .6){								
								
								TweenMax.to(clip.faceHole, .3, {alpha:0});
								TweenMax.to(clip.innerCircle, .3, {alpha:0});					
								
								doTakePhoto = false;
								
								var ti:Timer = new Timer(500, 1);
								ti.addEventListener(TimerEvent.TIMER, takeTriplePic, false, 0, true);
								ti.start();
							}							
							
						}//isTriple
					}
				}
			}
		}
		
		
		/**
		 * Called if step2Timer times out
		 * changes to step 2 - turn to the left
		 * @param	e
		 */
		private function doStep2(e:TimerEvent):void
		{
			tim.buttonClicked();
			tripleStep = 2;
			
			clip.headTurn.play();
			clip.headTurn.visible = true;
			clip.iconZoom.visible = false;
			clip.iconZoom.gotoAndStop(1);
			isZoomPlaying = false;
		}
		
		
		private function takeTriplePic(e:TimerEvent):void
		{
			countdown.removeEventListener(Countdown.FLASH, takePic);
			countdown.showWhite();
			
			var tmp:BitmapData = grabUserPhoto();
			finalImage = createTriple(tmp);
			
			//give flash .5 sec to fade before dispatching complete
			var t:Timer = new Timer(500, 1);
			t.addEventListener(TimerEvent.TIMER, sendComplete, false, 0, true);
			t.start();
		}
		
		
		/**
		 * returns the camera image with or without makeup
		 * @return
		 */
		private function grabUserPhoto():BitmapData
		{
			var sPic:BitmapData = new BitmapData(_width, _height);				
			sPic.draw(cameraData);
			if(isApplyingMakeup){
				sPic.draw(drawSprite);
			}
			return sPic;
		}
		
		
		/**
		 * Called by callback when Countdown dispatches FLASH
		 * and the flash is placed on screen
		 * @param	e
		 */
		private function takePic(e:Event):void
		{
			countdown.removeEventListener(Countdown.FLASH, takePic);
			
			var up:BitmapData = grabUserPhoto();//1280x720
			
			var ov:BitmapData = new overlay2();//1080x1080 - gradient frame
			
			//add the white city text to the overlay
			ov.copyPixels(cityImages[1], cityImages[1].rect, new Point(620, 1015), null, null, true);
			
			var m:Matrix = new Matrix();
			m.scale(1.5, 1.5);
			
			var tmp:BitmapData = new BitmapData(720, 720, false, 0x000000);
			tmp.copyPixels(up, new Rectangle(280, 0, 720, 720), new Point());//square from the center
			
			finalImage = new BitmapData(1080, 1080, false, 0xffffff);
			finalImage.draw(tmp, m, null, null, null, true);
			finalImage.copyPixels(ov, new Rectangle(0, 0, 1080, 1080), new Point(), null, null, true);
			
			//give flash .5 sec to fade before dispatching complete
			var t:Timer = new Timer(500, 1);
			t.addEventListener(TimerEvent.TIMER, sendComplete, false, 0, true);
			t.start();
		}
		
		
		private function sendComplete(e:TimerEvent):void
		{
			dispatchEvent(new Event(COMPLETE));
		}
		
	
		/**
		 * Called when the take photo or start button is pressed
		 * @param	e
		 */
		private function beginCountdown(e:MouseEvent):void
		{
			clip.btnTakePhoto.removeEventListener(MouseEvent.MOUSE_DOWN, beginCountdown);
			clip.btnTakePhoto.fill.alpha = 1;
			TweenMax.to(clip.btnTakePhoto.fill, .3, {alpha:0});
			
			tim.buttonClicked();
			if (isTriple){
				
				//"start" button was pressed - do the triple sequence to better position the user
				tripleStep = 1;				
				
				hideButtons();
				
				clip.btnTakePhoto.theText.text = "Cancel";
				clip.btnTakePhoto.theText.y = -21;
				clip.btnTakePhoto.addEventListener(MouseEvent.MOUSE_DOWN, cancelPressed, false, 0, true);
				
				clip.instructions.theText.text = "";				
				clip.instructions.visible = true;
				clip.instructions.alpha = 0;
				
				clip.innerCircle.visible = true;
				clip.innerCircle.alpha = 1;
				
				clip.faceHole.visible = true;
				clip.faceHole.alpha = .6;
				
				TweenMax.to(clip.instructions, .5, {alpha:1});
							
				clip.iconZoom.visible = true;
				clip.iconZoom.gotoAndPlay(1);
				
			}else{
				hideButtons();
				
				countdown.addEventListener(Countdown.FLASH, takePic, false, 0, true);
				countdown.show();			
			}
		}
		
		
		/**
		 * hides the buttons inside the take photo/start button at 960,906
		 */
		private function hideButtons():void
		{
			TweenMax.to(clip.btnMakeup, .5, {scaleX:0, scaleY:0, x:960, y:906, alpha:0});
			TweenMax.to(clip.btnTriple, .5, {scaleX:0, scaleY:0, x:960, y:906, alpha:0});
			TweenMax.to(clip.btnNoMakeup, .5, {scaleX:0, scaleY:0, x:960, y:906, alpha:0});
		}
		
		
		/**
		 * Cancel was pressed when in triple face
		 * @param	e
		 */
		private function cancelPressed(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			TweenMax.killTweensOf(clip.instructions);//prevents beginTripleSequence() callback from beginCountdown()
			
			clip.btnTakePhoto.removeEventListener(MouseEvent.MOUSE_DOWN, cancelPressed);
			
			clip.btnTakePhoto.theText.text = "Start";
			clip.btnTakePhoto.theText.y = -21;
			clip.btnTakePhoto.addEventListener(MouseEvent.MOUSE_DOWN, beginCountdown, false, 0, true);
			
			TweenMax.to(clip.faceHole, .5, {alpha:0});
			TweenMax.to(clip.innerCircle, .5, {alpha:0});
			
			TweenMax.to(clip.instructions, .5, {alpha:0});
			clip.headTurn.visible = false;
			clip.iconZoom.visible = false;
			
			tripleStep = 0;//triple selected but start not pressed
			
			TweenMax.to(clip.btnMakeup, .5, {scaleX:.75, scaleY:.75, x:835, y:831, alpha:1});
			TweenMax.to(clip.btnTriple, .5, {scaleX:1, scaleY:1, x:960, y:766, alpha:1});
			TweenMax.to(clip.btnNoMakeup, .5, {scaleX:.75, scaleY:.75, x:1085, y:831, alpha:1});
		}		
		
		
		private function createTriple(userPhoto:BitmapData):BitmapData
		{
			faceMask = f3d.getScreenshot();			
			
			var finalComp:BitmapData = new BitmapData(1080, 1080, false, 0xffffff);		//final is 1080x1080 for Instagram
			var b:BitmapData = new BitmapData(_width, _height, true, 0x00000000);	
			var headCutout:BitmapData = new BitmapData(_width, _height, true, 0x00000000);
			var pink:BitmapData = new pinkFade();	//272x650
			
			var ov:BitmapData = new overlay();
			
			//add the black city text to the overlay
			ov.copyPixels(cityImages[0], cityImages[0].rect, new Point(325, 800), null, null, true);
			
			//turn anything not black to pure white
			b.threshold(faceMask, new Rectangle(0, 0, _width, _height), new Point(), ">", 0x00000000, 0xffffffff, 0x00ffffff);								
			
			//inner black glow for the erosion
			b.applyFilter(b, new Rectangle(0, 0, _width, _height), new Point(), eroder);		
			
			//threshold the inner glow image to get only the white pixels - which effectively erodes the edges								
			b.threshold(b, new Rectangle(0, 0, _width, _height), new Point(), ">", 0x00EEEEEE, 0xFFFFFFFF, 0x00FFFFFF, false);								
			
			//fill right half of the mask with white
			b.fillRect(new Rectangle(_width * .5, 0, _width * .5, _height), 0xffffffff);
			
			//blur the edges
			b.applyFilter(b, new Rectangle(0, 0, _width, _height), new Point(), maskBlur);
			
			//copy the user photo into headcutout using the mask
			headCutout.copyPixels(userPhoto, new Rectangle(0, 0, _width, _height), new Point(), b, new Point(), true);

			//user image - crop to face circle - from 700 to 1220		
			var faceCrop:BitmapData = new BitmapData(520, 720, true, 0x00000000);
			//crop starting at x=380 - camImage is at 320 - 380+320 = 700
			faceCrop.copyPixels(headCutout, new Rectangle(380, 0, 520, 720), new Point(0, 0), null, null, true);
			
			//now the users face is inside a 520x720 box... find the left edge of the face for pink glow placement
			var ray:uint;
			for (var leftEdge:int = 0; leftEdge < 520; leftEdge++){
				ray = faceCrop.getPixel(leftEdge, 360);		
				if (ray != 0){
					break;
				}
			}
			//leftEdge is the left most edge of the face/mask
			leftEdge *= .3;
			
			//these all range from -100 to 100 - colorVals array is set in show() and comes from cityDialog values
			faceCrop.applyFilter(faceCrop, faceCrop.rect, new Point(),  MatrixUtil.setBrightness(colorVals[0]));
			faceCrop.applyFilter(faceCrop, faceCrop.rect, new Point(),  MatrixUtil.setContrast(colorVals[1]));			
			faceCrop.applyFilter(faceCrop, faceCrop.rect, new Point(),  MatrixUtil.setSaturation(colorVals[2]));			
			
			var sm1:Matrix = new Matrix();
			sm1.scale(.96, .96);		
			
			var sm2:Matrix = new Matrix();
			sm2.scale(.98, .98);
			
			var userEighty:BitmapData = new BitmapData(faceCrop.width * sm1.a, faceCrop.height * sm1.d, true, 0x00000000);
			//var pinkEighty:BitmapData = new BitmapData(faceCrop.width * sm2.a, faceCrop.height * sm2.d, true, 0x00000000);
			
			var userNinety:BitmapData = new BitmapData(faceCrop.width * sm2.a, faceCrop.height * sm2.d, true, 0x00000000);
			//var pinkNinety:BitmapData = new BitmapData(faceCrop.width * sm2.a, faceCrop.height * sm2.d, true, 0x00000000);			
			
			userEighty.draw(faceCrop, sm1, null, null, null, true);
			//pinkEighty.draw(pink, sm2, null, null, null, true);
			
			userNinety.draw(faceCrop, sm2, null, null, null, true);
			//pinkNinety.draw(pink, sm2, null, null, null, true);			
			
			var top:int = 50;
			finalComp.copyPixels(pink, pink.rect, new Point(130 + leftEdge * .96, top + 70), null, null, true);
			finalComp.copyPixels(userEighty, userEighty.rect, new Point(130, top + 20), null, null, true);
			finalComp.copyPixels(pink, pink.rect, new Point(240 + leftEdge * .98, top + 70), null, null, true);//was 243
			finalComp.copyPixels(userNinety, userNinety.rect, new Point(240, top + 10), null, null, true);
			finalComp.copyPixels(pink, pink.rect, new Point(350 + leftEdge, top + 70), null, null, true);
			finalComp.copyPixels(faceCrop, faceCrop.rect, new Point(350, top), null, null, true);
			
			finalComp.copyPixels(ov, new Rectangle(0, 0, 1080, 1080), new Point(), null, null, true);//add the white overlay
			
			return finalComp;
		}
	}
	
}