package com.gmrmarketing.katyperry.witness
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.media.*;
	import brfv4.BRFFace;//in the ANE
	import brfv4.BRFManager;//in the ANE
	import brfv4.as3.DrawingUtils;
	import brfv4.utils.BRFv4PointUtils;
	import brfv4.utils.BRFv4Drawing3DUtils_Flare3D;
	import flash.display3D.textures.RectangleTexture;
	import flash.filters.BlurFilter;
	import flash.geom.*;
	import flare.basic.*;
	import com.chargedweb.utils.MatrixUtil;
	import net.hires.debug.Stats;
	
	
	public class TripleFace extends EventDispatcher
	{
		private var brfManager:BRFManager;
		private var drawing:DrawingUtils;
		private var drawSprite:Sprite;
		
		private var toDegree:Function = BRFv4PointUtils.toDegree;
		
		private var _baseNodes:Vector.<Sprite> = new Vector.<Sprite>();
		
		private var _width:Number = 1280;//Camera
		private var _height:Number = 720;
		
		private var camera:Camera;
		private var cameraData:BitmapData;
		private var video:Video;
		
		private var numFacesToTrack:int = 1;		
		
		private var faceTexture:BitmapData;
		
		private var faceUVs:Vector.<Number>;
		
		private var camMatrix:Matrix;
		private var camImage:Bitmap;//bitmap for displaying the masked camera image
		private var faceMask:BitmapData;
		
		private var rDialog:MovieClip;
		
		private var photoFull:BitmapData;
		//private var photo:BitmapData; //cropped image from the camera
		private var doTakePhoto:Boolean;
		
		private var f3d:HeadMask;		
		
		private var maskDisplay:Bitmap;
		private var maskDisplayMatrix:Matrix;
		
		private var maskBlur:BlurFilter;
		
		private var stats:Stats;
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var finalImage:Bitmap;//container for the final image from createTriple()
		
		private var bg:MovieClip;//background graphic
		
		
		
		public function TripleFace()
		{	
			bg = new background();
			clip = new triple();
			rDialog = new rotDialog();
			finalImage = new Bitmap();
			//stats = new Stats();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
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
			
			brfManager = new BRFManager();
			
			drawSprite = new Sprite();
			drawing	= new DrawingUtils(drawSprite);			
			
			//photo = new BitmapData(350, 540, true, 0x00000000);
			photoFull = new BitmapData(_width, _height, true, 0x00000000);
			
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
			drawSprite.y = 80;			
			camImage.x = 320;
			camImage.y = 80;
			
			//add behind faceHole on stage already in the clip
			clip.addChildAt(drawSprite, 0);
			//clip.addChildAt(camImage, 0);
			
			maskDisplay = new Bitmap(new BitmapData(640, 360, true, 0x00000000));
			maskDisplayMatrix = new Matrix();
			maskDisplayMatrix.scale(.5, .5);
			
			doTakePhoto = false;
			
			clip.addChild(maskDisplay);
			clip.addChild(rDialog);
			
			maskBlur = new BlurFilter(5, 5, 2);			
			
			//was in init()
			var resolution:Rectangle = new Rectangle(0, 0, _width, _height);
			
			brfManager.init(resolution, resolution, "com.gmrmarketing.brftest");
			brfManager.setNumFacesToTrack(numFacesToTrack);
			
			var maxFaceSize:Number = _height;		
	
			brfManager.setFaceDetectionParams(maxFaceSize * 0.20, maxFaceSize * 1.00, 12, 8);
			brfManager.setFaceTrackingStartParams(maxFaceSize * 0.20, maxFaceSize * 1.00, 32, 35, 32);
			brfManager.setFaceTrackingResetParams(maxFaceSize * 0.15, maxFaceSize * 1.00, 40, 55, 32);
			
			//clip.addChildAt(bg, 0);
			
			if(f3d == null) {
				f3d = new HeadMask(resolution);
				clip.addChildAt(f3d, 0);
			}			
			
			//clip.addChild(stats);
			//stats.x = 1500;
			
			clip.btnFace1.addEventListener(MouseEvent.MOUSE_DOWN, useFace1, false, 0, true);
			clip.btnFace2.addEventListener(MouseEvent.MOUSE_DOWN, useFace2, false, 0, true);					
			
			clip.addEventListener(Event.ENTER_FRAME, update);
		}
		
		
		private function update(e:Event) : void 
		{
			cameraData.draw(video, camMatrix);//just flips image horizontally			
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
					
					//f3d only used for the triple face
					if (f3d){
						f3d.update(i, face, true);
						faceMask = f3d.getScreenshot();
						
						b.threshold(faceMask, new Rectangle(0, 0, _width, _height), new Point(), ">", 0x00000000, 0xffffffff, 0x00ffffff);
						
						//fill right half of the mask with white
						b.fillRect(new Rectangle(_width * .5, 0, _width * .5, _height), 0xffffffff);
						
						b.applyFilter(b, new Rectangle(0, 0, _width, _height), new Point(), maskBlur);
						
						//TESTING
						//maskDisplay.bitmapData.fillRect(new Rectangle(0, 0, _width, _height), 0x00000000);
						maskDisplay.bitmapData.draw(cameraData, maskDisplayMatrix, null, null, null, true);
						maskDisplay.bitmapData.draw(b, maskDisplayMatrix, null, BlendMode.DIFFERENCE, null, true);
						//TESTING						
						
						rDialog.sc.text = face.scale;
						rDialog.ry.text = face.rotationY;
					}
					
					if (face.scale < 215){
						clip.scaleText.text = "Come Closer";
					}else if (face.scale > 290){
						clip.scaleText.text = "Too Close";
					}else{
						clip.scaleText.text = "Good";
					}
					
					//rotation goes above 0 when looking left... doesn't seem to work when looking right
					if (face.rotationY < .35){
						clip.turnText.text = "Turn to your left more";
					}else if (face.rotationY > .5){
						clip.turnText.text = "Turned too far";
					}else{
						clip.turnText.text = "Good";
					}
					
					if (doTakePhoto && face.scale > 215 && face.scale < 290 && face.rotationY > .35 && face.rotationY < .5){//was > .35
						
						//FACE IN CORRECT SPOT - TAKE THE PIC
						clip.faceHole.visible = false;
						clip.noseLine.visible = false;
						
						//draw the full triple clip into sPic
						var sPic:BitmapData = new BitmapData(1920,1080);						
						sPic.draw(clip);
						
						//gets the 1280x720 cam/makeup image from the full screen image
						photoFull.copyPixels(sPic, new Rectangle(camImage.x, camImage.y, _width, _height), new Point(), b, new Point(), true);						
						
						doTakePhoto = false;
						
						createTriple();
						
						clip.faceHole.visible = true;
						clip.noseLine.visible = true;
						
						clip.stage.addEventListener(KeyboardEvent.KEY_DOWN, checkKey, false, 0, true);
					}	
				}
			}
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
				photoFull.dispose();
				finalImage.bitmapData.dispose();
			}
		}
		
		
		//uses photoFull - 1280x720
		private function createTriple():void
		{
			//final is 1080x1080 for Instagram
			var wh:BitmapData = new BitmapData(1080, 1080, false, 0xffffff);
			
			var pink:BitmapData = new pinkFade();	//458x650

			//user image - crop to face circle - from 700 to 1220		
			var userCrop:BitmapData = new BitmapData(520, 720, true, 0x00000000);
			//crop starting at x=380 - camImage is at 320 - 380+320 = 700
			userCrop.copyPixels(photoFull, new Rectangle(380, 0, 520, 720), new Point(0, 0), null, null, true);
			
			userCrop.applyFilter(userCrop, userCrop.rect, new Point(),  MatrixUtil.setContrast(10));
			userCrop.applyFilter(userCrop, userCrop.rect, new Point(),  MatrixUtil.setBrightness(10));
			//userCrop.applyFilter(userCrop, userCrop.rect, new Point(),  MatrixUtil.setSaturation(30));			
			
			var sm1:Matrix = new Matrix();
			sm1.scale(.96, .96);		
			
			var sm2:Matrix = new Matrix();
			sm2.scale(.98, .98);
			
			var userEighty:BitmapData = new BitmapData(userCrop.width * sm1.a, userCrop.height * sm1.d, true, 0x00000000);
			var pinkEighty:BitmapData = new BitmapData(userCrop.width * sm2.a, userCrop.height * sm2.d, true, 0x00000000);
			
			var userNinety:BitmapData = new BitmapData(userCrop.width * sm2.a, userCrop.height * sm2.d, true, 0x00000000);
			var pinkNinety:BitmapData = new BitmapData(userCrop.width * sm2.a, userCrop.height * sm2.d, true, 0x00000000);			
			
			userEighty.draw(userCrop, sm1, null, null, null, true);
			pinkEighty.draw(pink, sm2, null, null, null, true);
			
			userNinety.draw(userCrop, sm2, null, null, null, true);
			pinkNinety.draw(pink, sm2, null, null, null, true);			
			
			var top:int = 50;
			wh.copyPixels(pink, pink.rect, new Point(130, top + 70), null, null, true);
			wh.copyPixels(userEighty, userEighty.rect, new Point(130, top + 20), null, null, true);
			wh.copyPixels(pink, pink.rect, new Point(243, top + 70), null, null, true);
			wh.copyPixels(userNinety, userNinety.rect, new Point(243, top + 10), null, null, true);
			wh.copyPixels(pink, pink.rect, new Point(350, top + 70), null, null, true);
			wh.copyPixels(userCrop, userCrop.rect, new Point(350, top), null, null, true);
			
			//white fade with Witness logo
			var ov:BitmapData = new overlay();
			wh.copyPixels(ov, new Rectangle(0, 0, 1080, 1080), new Point(), null, null, true);
			
			finalImage.bitmapData = wh;
			if(!myContainer.contains(finalImage)){
				myContainer.addChild(finalImage);
			}
		}
	}
	
}