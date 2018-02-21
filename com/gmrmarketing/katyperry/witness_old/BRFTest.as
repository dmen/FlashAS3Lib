package com.gmrmarketing.katyperry.witness
{
	import flash.display.*;
	import flash.events.*;	
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
	
	
	public class BRFTest extends MovieClip
	{
		private var brfManager:BRFManager;
		private var drawing:DrawingUtils;
		private var drawSprite:Sprite;
		
		private var toDegree:Function = BRFv4PointUtils.toDegree;
		
		private var _baseNodes:Vector.<Sprite> = new Vector.<Sprite>();
		
		private var _width:Number = 1280;
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
		private var photo:BitmapData; //cropped image from the camera
		private var doTakePhoto:Boolean;
		
		private var f3d:BRFv4Drawing3DUtils_Flare3D;		
		
		private var maskDisplay:Bitmap;
		private var maskDisplayMatrix:Matrix;
		
		private var maskBlur:BlurFilter;
		
		private var stats:Stats;
		
		//brfManager.reset() at end of each interaction
		//brfManager.setFaceDetectionRoi( Rectangle roi )
		
		
		public function BRFTest()
		{
			brfManager = new BRFManager();
			
			drawSprite = new Sprite();
			drawing	= new DrawingUtils(drawSprite);			
			
			photo = new BitmapData(350, 540, true, 0x00000000);
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
			
			//put behind any stage elements
			
			drawSprite.x = 320;
			drawSprite.y = 180;			
			camImage.x = 320;
			camImage.y = 180;
			
			addChildAt(drawSprite, 0);
			addChildAt(camImage, 0);
			
			maskDisplay = new Bitmap(new BitmapData(480, 270, true, 0x00000000));
			maskDisplayMatrix = new Matrix();
			maskDisplayMatrix.scale(.5, .5);
			
			doTakePhoto = true;
			
			//addChild(maskDisplay);
			
			maskBlur = new BlurFilter(5, 5, 2);
			
			faceUVs = new Vector.<Number>();
			faceUVs.push(0.000000, 0.122956, 0.008402, 0.264702, 0.018111, 0.410590, 0.035701, 0.550737, 0.079737, 0.689546, 0.152051, 0.802090, 0.248652, 0.891267, 0.351980, 0.972994, 0.475458, 0.999756, 0.605917, 0.983710, 0.718554, 0.907782, 0.823061, 0.832025, 0.903835, 0.729955, 0.957449, 0.595034, 0.978614, 0.449082, 0.992867, 0.302854, 1.000000, 0.154495, 0.083128, 0.095333, 0.145160, 0.017912, 0.241014, 0.000000, 0.342505, 0.018179, 0.440778, 0.054008, 0.600825, 0.055089, 0.701773, 0.024003, 0.795268, 0.011144, 0.887383, 0.036419, 0.938000, 0.111915, 0.511139, 0.142664, 0.503343, 0.230333, 0.497176, 0.318562, 0.489266, 0.413877, 0.391226, 0.482515, 0.438473, 0.504775, 0.495820, 0.522134, 0.546605, 0.503395, 0.598752, 0.485754, 0.181009, 0.173957, 0.240190, 0.143211, 0.308596, 0.143044, 0.371702, 0.172747, 0.307553, 0.192188, 0.242128, 0.195274, 0.642685, 0.176134, 0.702435, 0.144910, 0.772108, 0.153784, 0.825776, 0.182269, 0.769546, 0.206094, 0.703294, 0.200399, 0.311327, 0.673350, 0.379076, 0.650122, 0.448182, 0.637439, 0.498827, 0.652737, 0.551304, 0.636159, 0.615335, 0.652749, 0.683948, 0.680695, 0.616524, 0.720266, 0.550845, 0.737568, 0.498285, 0.739667, 0.442104, 0.736824, 0.377309, 0.714711, 0.337437, 0.673419, 0.447339, 0.672178, 0.498513, 0.677860, 0.552297, 0.673091, 0.655346, 0.678428, 0.552641, 0.676628, 0.501121, 0.683019, 0.448451, 0.673848);
			
			stats = new Stats();
			addChild(stats);
			
			init();
		}
		
		
		private function init():void 		
		{	
			var resolution:Rectangle = new Rectangle(0, 0, _width, _height);
			
			brfManager.init(resolution, resolution, "com.gmrmarketing.brftest");
			brfManager.setNumFacesToTrack(numFacesToTrack);
			
			var maxFaceSize:Number = _height;		
	
			brfManager.setFaceDetectionParams(maxFaceSize * 0.20, maxFaceSize * 1.00, 12, 8);
			brfManager.setFaceTrackingStartParams(maxFaceSize * 0.20, maxFaceSize * 1.00, 32, 35, 32);
			brfManager.setFaceTrackingResetParams(maxFaceSize * 0.15, maxFaceSize * 1.00, 40, 55, 32);
			
			if(f3d == null) {
				f3d = new BRFv4Drawing3DUtils_Flare3D(resolution);
				addChild(f3d);
			}
			
			loadModels();
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		
		private function update(e:Event) : void 
		{
			cameraData.draw(video, camMatrix);//just flips image horizontally			
			brfManager.update(cameraData);		
			
			if(f3d) {
				f3d.hideAll(); // Hide 3d models. Only show them on top of tracked faces.
				//f3d.updateVideo(cameraData);
			}
	
			drawing.clear();
	
			// Get all faces. 	
			var faces : Vector.<BRFFace> = brfManager.getFaces();
	
			// If no face was tracked: hide the image overlays.	
			for(var i:int = 0; i < faces.length; i++) {
	
				var face:BRFFace = faces[i];			// get face
				
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
						b.fillRect(new Rectangle(_width * .5, 0, width * .5, _height), 0xffffffff);
						
						b.applyFilter(b, new Rectangle(0, 0, _width, _height), new Point(), maskBlur);
						
						//maskDisplay.bitmapData.fillRect(new Rectangle(0, 0, _width, _height), 0x00000000);
						maskDisplay.bitmapData.draw(cameraData, maskDisplayMatrix, null, null, null, true);
						maskDisplay.bitmapData.draw(b, maskDisplayMatrix, null, BlendMode.DIFFERENCE, null, true);
					}					
					
					if (doTakePhoto && face.scale > 200 && face.scale < 220 && face.rotationY > .35 && face.rotationY < .5){
						
						//FACE IN CORRECT SPOT - TAKE THE PIC
						faceHole.visible = false;
						
						var sPic:BitmapData = new BitmapData(_width, _height);						
						sPic.draw(stage);
						
						photoFull.copyPixels(sPic, new Rectangle(0,0,_width,_height), new Point(), b, new Point(), true);						
						
						doTakePhoto = false;
						
						createTriple();
						
						faceHole.visible = true;
					}	
				}
			}
		}
		
		
		public function loadModels():void 
		{			
			if(f3d) {	
				f3d.removeAll();
				f3d.loadModel("assets/female.zf3d", 1);
			}
		}
		
		
		//uses photoFull
		private function createTriple():void
		{
			var wh:BitmapData = new BitmapData(1080,1080,false,0xffffff);
			var pink:BitmapData = new pinkFade();	//458x540

			//user image - crop to face circle			
			var userCrop:BitmapData = new BitmapData(440,540,true,0x00000000);
			userCrop.copyPixels(photoFull, new Rectangle(260, 0, 440, 540), new Point(0, 0), null, null, true);
			
			userCrop.applyFilter(userCrop, userCrop.rect, new Point(),  MatrixUtil.setContrast(10));
			userCrop.applyFilter(userCrop, userCrop.rect, new Point(),  MatrixUtil.setBrightness(10));
			//userCrop.applyFilter(userCrop, userCrop.rect, new Point(),  MatrixUtil.setSaturation(30));			
			
			var sm1:Matrix = new Matrix();
			sm1.scale(.96, .96);		
			
			var sm2:Matrix = new Matrix();
			sm2.scale(.98,.98);
			
			var userEighty:BitmapData = new BitmapData(userCrop.width * sm1.a, userCrop.height * sm1.d, true, 0x00000000);
			var pinkEighty:BitmapData = new BitmapData(userCrop.width * sm2.a, userCrop.height * sm2.d, true, 0x00000000);
			
			var userNinety:BitmapData = new BitmapData(userCrop.width * sm2.a, userCrop.height * sm2.d, true, 0x00000000);
			var pinkNinety:BitmapData = new BitmapData(userCrop.width * sm2.a, userCrop.height * sm2.d, true, 0x00000000);			
			
			userEighty.draw(userCrop, sm1, null, null, null, true);
			pinkEighty.draw(pink, sm2, null, null, null, true);
			
			userNinety.draw(userCrop, sm2, null, null, null, true);
			pinkNinety.draw(pink, sm2, null, null, null, true);			
			
			wh.copyPixels(pink, pink.rect, new Point(230, 0), null, null, true);
			wh.copyPixels(userEighty, userEighty.rect, new Point(210, 20), null, null, true);
			wh.copyPixels(pink, pink.rect, new Point(303, 0), null, null, true);
			wh.copyPixels(userNinety, userNinety.rect, new Point(283, 10), null, null, true);
			wh.copyPixels(pink, pink.rect, new Point(370, 0), null, null, true);
			wh.copyPixels(userCrop, userCrop.rect, new Point(350, 0), null, null, true);
			
			var b:Bitmap = new Bitmap(wh);
			addChild(b);
		}

		
	}
	
}