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
	
	
	public class SoloFace extends EventDispatcher
	{
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
		private var maskDisplayMatrix:Matrix;
		
		private var maskBlur:BlurFilter;
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var finalImage:Bitmap;//container for the final image from createTriple()
		
		private var bg:MovieClip;//background graphic
		private var isApplyingMakeup:Boolean;
		private var isTriple:Boolean;
		private var isGroup:Boolean;
		
		private var colorVals:Array;//brightness,contrast,saturation from cityDialog
		
		private var eroder:GlowFilter;
		
		private var cityImage:BitmapData;//text image of the city name from the cityDialog
		
		
		public function SoloFace()
		{	
			bg = new background();
			clip = new solo();
			rDialog = new rotDialog();
			finalImage = new Bitmap();			
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(b:BRFManager, group:Boolean, colorValues:Array, cIm:BitmapData):void
		{			
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			brfManager = b;
			isGroup = group;
			colorVals = colorValues;
			cityImage = cIm;
			
			//if group - hide the triple face and head shape buttons
			if (isGroup){
				clip.btnTriple.visible = false;						
			}else{
				//solo
				clip.btnTriple.visible = true;
			}
			
			clip.turnText.visible = false;
			clip.scaleText.visible = false;
			clip.btnFace1.visible = false;
			clip.btnFace2.visible = false;		
			
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, uvsLoaded);
			l.load(new URLRequest("assets/baseuvs.txt"));
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
			
			maskDisplay = new Bitmap(new BitmapData(640, 360, true, 0x00000000));
			maskDisplayMatrix = new Matrix();
			maskDisplayMatrix.scale(.5, .5);
			
			doTakePhoto = true;
			
			clip.addChild(maskDisplay);
			clip.addChild(rDialog);
			
			maskBlur = new BlurFilter(10, 10, 2);
			eroder = new GlowFilter(0x000000, 1, 3, 3, 3, 2, true, false);
			
			clip.addChildAt(bg, 0);
			
			if(f3d == null) {
				f3d = new HeadMask(new Rectangle(0, 0, _width, _height));
				clip.addChildAt(f3d, 0);
			}
			
			isApplyingMakeup = true;
			isTriple = false;
			
			clip.btnFace1.addEventListener(MouseEvent.MOUSE_DOWN, useFace1, false, 0, true);
			clip.btnFace2.addEventListener(MouseEvent.MOUSE_DOWN, useFace2, false, 0, true);
			clip.btnMakeup.addEventListener(MouseEvent.MOUSE_DOWN, selectMakeup, false, 0, true);
			clip.btnTriple.addEventListener(MouseEvent.MOUSE_DOWN, selectTriple, false, 0, true);
			clip.btnNoMakeup.addEventListener(MouseEvent.MOUSE_DOWN, selectNoMakeup, false, 0, true);
			enableTakePhoto();
			
			clip.addEventListener(Event.ENTER_FRAME, update);
		}
		
		
		private function selectMakeup(e:MouseEvent):void
		{
			isApplyingMakeup = true;
			isTriple = false;
			clip.turnText.visible = false;
			clip.scaleText.visible = false;
			clip.btnFace1.visible = false;
			clip.btnFace2.visible = false;
			enableTakePhoto();
		}
		
		
		private function selectNoMakeup(e:MouseEvent):void
		{
			isApplyingMakeup = false;
			isTriple = false;
			clip.turnText.visible = false;
			clip.scaleText.visible = false;
			clip.btnFace1.visible = false;
			clip.btnFace2.visible = false;
			drawing.clear();//remove makeup from the overlay
			enableTakePhoto();
		}
		
		
		private function selectTriple(e:MouseEvent):void
		{
			isApplyingMakeup = true;
			isTriple = true;
			clip.turnText.visible = true;
			clip.scaleText.visible = true;
			clip.btnFace1.visible = true;
			clip.btnFace2.visible = true;
			disableTakePhoto();
		}
		
		
		private function enableTakePhoto():void
		{
			clip.btnTakePhoto.addEventListener(MouseEvent.MOUSE_DOWN, beginCountdown, false, 0, true);
			TweenMax.to(clip.btnTakePhoto, .5, {alpha:1});
		}
		
		
		private function disableTakePhoto():void
		{
			clip.btnTakePhoto.removeEventListener(MouseEvent.MOUSE_DOWN, beginCountdown);
			TweenMax.to(clip.btnTakePhoto, .5, {alpha:0});
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
						
						var b:BitmapData = new BitmapData(_width, _height, true, 0x00000000);
						
						if(isTriple){
							//f3d only used for the triple face
							if (f3d){
								f3d.update(i, face, true);
								
								
	//////////////////////////////////////////
								faceMask = f3d.getScreenshot();
								
								//turn anything not black to pure white
								b.threshold(faceMask, new Rectangle(0, 0, _width, _height), new Point(), ">", 0x00000000, 0xffffffff, 0x00ffffff);								
								
								//inner black glow for the erosion
								b.applyFilter(b, new Rectangle(0, 0, _width, _height), new Point(), eroder);		
								
								//threshold the inner glow image to get only the white pixels - which effectively erodes the edges								
								b.threshold(b, new Rectangle(0, 0, _width, _height), new Point(), ">", 0x00EEEEEE, 0xFFFFFFFF, 0x00FFFFFF, false);								
								
								//fill right half of the mask with white
								//b.fillRect(new Rectangle(_width * .5, 0, _width * .5, _height), 0xffffffff);
								
								//blur the edges
								b.applyFilter(b, new Rectangle(0, 0, _width, _height), new Point(), maskBlur);								
								
								//TESTING
								maskDisplay.bitmapData.draw(cameraData, maskDisplayMatrix, null, null, null, true);
								maskDisplay.bitmapData.draw(b, maskDisplayMatrix, null, BlendMode.DIFFERENCE, null, true);
								rDialog.sc.text = face.scale;
								rDialog.ry.text = face.rotationY;
								//TESTING	
////////////////////////////////////////////
							}
							
							if (face.scale < 215){
								clip.scaleText.text = "Come Closer";
							}else if (face.scale > 290){
								clip.scaleText.text = "Too Close";
							}else{
								clip.scaleText.text = "Good";
							}
							
							//rotation goes above 0 when looking left... doesn't seem to work when looking right
							if (face.rotationY < .3){
								clip.turnText.text = "Turn Left";
							}else if (face.rotationY > .6){
								clip.turnText.text = "Turn Right";
							}else{
								clip.turnText.text = "Good";
							}
							
							if (doTakePhoto && face.scale > 215 && face.scale < 290 && face.rotationY > .3 && face.rotationY < .6){//was > .35
								
								//FACE IN CORRECT SPOT - TAKE THE PIC
								clip.faceHole.visible = false;
								
								doTakePhoto = false;
								
								var tmp:BitmapData = grabUserPhoto();
								var fin:BitmapData = createTriple(tmp);
								clip.addChild(new Bitmap(fin));
								
								clip.faceHole.visible = true;
								
								//TESTING - hit space to clear the photo
								clip.stage.addEventListener(KeyboardEvent.KEY_DOWN, checkKey, false, 0, true);
							}
							
						}//isTriple
					}
				}
			}
		}
		
		
		private function grabUserPhoto():BitmapData
		{
			var sPic:BitmapData = new BitmapData(_width, _height);				
			sPic.draw(cameraData);
			if(isApplyingMakeup){
				sPic.draw(drawSprite);
			}
			return sPic;
		}
		
		
		private function useFace1(e:MouseEvent):void
		{
			f3d.showHead1();
		}
		
		
		private function useFace2(e:MouseEvent):void
		{
			f3d.showHead2();
		}
		
		
		private function checkKey(e:KeyboardEvent):void
		{
			if (e.charCode == 32) {
				doTakePhoto = true;
				clip.stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkKey);
				if(myContainer.contains(finalImage)){
					myContainer.removeChild(finalImage);
				}								
			}
		}
		
		
		private function beginCountdown(e:MouseEvent):void
		{
			
		}
		
		
		private function createTriple(userPhoto:BitmapData):BitmapData
		{
			faceMask = f3d.getScreenshot();			
			
			var finalImage:BitmapData = new BitmapData(1080, 1080, false, 0xffffff);		//final is 1080x1080 for Instagram
			var b:BitmapData = new BitmapData(_width, _height, true, 0x00000000);	
			var headCutout:BitmapData = new BitmapData(_width, _height, true, 0x00000000);
			var pink:BitmapData = new pinkFade();	//458x650
			
			var ov:BitmapData = new overlay();
			ov.copyPixels(cityImage, cityImage.rect, new Point(325, 800), null, null, true);
			
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
			
			headCutout.copyPixels(userPhoto, new Rectangle(0, 0, _width, _height), new Point(), b, new Point(), true);

			//user image - crop to face circle - from 700 to 1220		
			var faceCrop:BitmapData = new BitmapData(520, 720, true, 0x00000000);
			//crop starting at x=380 - camImage is at 320 - 380+320 = 700
			faceCrop.copyPixels(headCutout, new Rectangle(380, 0, 520, 720), new Point(0, 0), null, null, true);
			
			//these all range from -100 to 100
			faceCrop.applyFilter(faceCrop, faceCrop.rect, new Point(),  MatrixUtil.setBrightness(colorVals[0]));
			faceCrop.applyFilter(faceCrop, faceCrop.rect, new Point(),  MatrixUtil.setContrast(colorVals[1]));			
			faceCrop.applyFilter(faceCrop, faceCrop.rect, new Point(),  MatrixUtil.setSaturation(colorVals[2]));			
			
			var sm1:Matrix = new Matrix();
			sm1.scale(.96, .96);		
			
			var sm2:Matrix = new Matrix();
			sm2.scale(.98, .98);
			
			var userEighty:BitmapData = new BitmapData(faceCrop.width * sm1.a, faceCrop.height * sm1.d, true, 0x00000000);
			var pinkEighty:BitmapData = new BitmapData(faceCrop.width * sm2.a, faceCrop.height * sm2.d, true, 0x00000000);
			
			var userNinety:BitmapData = new BitmapData(faceCrop.width * sm2.a, faceCrop.height * sm2.d, true, 0x00000000);
			var pinkNinety:BitmapData = new BitmapData(faceCrop.width * sm2.a, faceCrop.height * sm2.d, true, 0x00000000);			
			
			userEighty.draw(faceCrop, sm1, null, null, null, true);
			pinkEighty.draw(pink, sm2, null, null, null, true);
			
			userNinety.draw(faceCrop, sm2, null, null, null, true);
			pinkNinety.draw(pink, sm2, null, null, null, true);			
			
			var top:int = 50;
			finalImage.copyPixels(pink, pink.rect, new Point(130, top + 70), null, null, true);
			finalImage.copyPixels(userEighty, userEighty.rect, new Point(130, top + 20), null, null, true);
			finalImage.copyPixels(pink, pink.rect, new Point(243, top + 70), null, null, true);
			finalImage.copyPixels(userNinety, userNinety.rect, new Point(243, top + 10), null, null, true);
			finalImage.copyPixels(pink, pink.rect, new Point(350, top + 70), null, null, true);
			finalImage.copyPixels(faceCrop, faceCrop.rect, new Point(350, top), null, null, true);
			
			finalImage.copyPixels(ov, new Rectangle(0, 0, 1080, 1080), new Point(), null, null, true);//add the white overlay
			
			return finalImage;
		}
	}
	
}