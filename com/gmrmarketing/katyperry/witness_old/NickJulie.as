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
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flare.basic.*;
	import com.chargedweb.utils.MatrixUtil;
	import flash.net.URLRequest;
	import net.hires.debug.Stats;
	import flash.filesystem.*;
	import flash.net.FileFilter;
	
	
	public class NickJulie extends MovieClip
	{
		private var brfManager:BRFManager;
		private var drawing:DrawingUtils;
		private var drawSprite:Sprite;
		
		private var toDegree:Function = BRFv4PointUtils.toDegree;
		
		private var _baseNodes:Vector.<Sprite> = new Vector.<Sprite>();
		
		private var _width:Number = 960;
		private var _height:Number = 540;
		
		private var camera:Camera;
		private var cameraData:BitmapData;
		private var camImage:Bitmap;
		private var camMatrix:Matrix;
		private var video:Video;
		
		private var numFacesToTrack:int = 4;		
		
		private var faceTexture:BitmapData;
		
		private var faceUVs:Vector.<Number>;		
			
		private var stats:Stats;
		private var textureFile:File;
		
		
		public function NickJulie()
		{
			brfManager	= new BRFManager();
			
			drawSprite = new Sprite();
			drawing	= new DrawingUtils(drawSprite);	
			
			faceTexture = new makeup();
			
			camera = Camera.getCamera();
			camera.setMode(_width, _height, 30);
			
			video = new Video(_width, _height);
			video.smoothing = true;			
			
			video.attachCamera(camera);
			
			cameraData = new BitmapData(_width, _height, true, 0xff444444);//not put on screen
			camImage = new Bitmap(cameraData);	
			
			camMatrix = new Matrix();
			camMatrix.scale( -1, 1);//for flipping the camera image horizontally
			camMatrix.translate(960, 0);			
			
			addChildAt(drawSprite, 0);
			addChildAt(camImage,0);
			
			//these are marcel's uvs that come with brfv4
			faceUVs = new Vector.<Number>();
			faceUVs.push(0.000000, 0.122956, 0.008402, 0.264702, 0.018111, 0.410590, 0.035701, 0.550737, 0.079737, 0.689546, 0.152051, 0.802090, 0.248652, 0.891267, 0.351980, 0.972994, 0.475458, 0.999756, 0.605917, 0.983710, 0.718554, 0.907782, 0.823061, 0.832025, 0.903835, 0.729955, 0.957449, 0.595034, 0.978614, 0.449082, 0.992867, 0.302854, 1.000000, 0.154495, 0.083128, 0.095333, 0.145160, 0.017912, 0.241014, 0.000000, 0.342505, 0.018179, 0.440778, 0.054008, 0.600825, 0.055089, 0.701773, 0.024003, 0.795268, 0.011144, 0.887383, 0.036419, 0.938000, 0.111915, 0.511139, 0.142664, 0.503343, 0.230333, 0.497176, 0.318562, 0.489266, 0.413877, 0.391226, 0.482515, 0.438473, 0.504775, 0.495820, 0.522134, 0.546605, 0.503395, 0.598752, 0.485754, 0.181009, 0.173957, 0.240190, 0.143211, 0.308596, 0.143044, 0.371702, 0.172747, 0.307553, 0.192188, 0.242128, 0.195274, 0.642685, 0.176134, 0.702435, 0.144910, 0.772108, 0.153784, 0.825776, 0.182269, 0.769546, 0.206094, 0.703294, 0.200399, 0.311327, 0.673350, 0.379076, 0.650122, 0.448182, 0.637439, 0.498827, 0.652737, 0.551304, 0.636159, 0.615335, 0.652749, 0.683948, 0.680695, 0.616524, 0.720266, 0.550845, 0.737568, 0.498285, 0.739667, 0.442104, 0.736824, 0.377309, 0.714711, 0.337437, 0.673419, 0.447339, 0.672178, 0.498513, 0.677860, 0.552297, 0.673091, 0.655346, 0.678428, 0.552641, 0.676628, 0.501121, 0.683019, 0.448451, 0.673848);
			
			textureFile = new File();
			btn.addEventListener(MouseEvent.MOUSE_DOWN, pickTexture, false, 0, true);
			
			init();
		}
		
		
		private function init():void 		
		{	
			var resolution:Rectangle = new Rectangle(0, 0, _width, _height);
			
			brfManager.init(resolution, resolution, "com.gmrmarketing.nickjulie");
			brfManager.setNumFacesToTrack(numFacesToTrack);
			
			var maxFaceSize:Number = _height;		
	
			brfManager.setFaceDetectionParams(maxFaceSize * 0.20, maxFaceSize * 1.00, 12, 8);
			brfManager.setFaceTrackingStartParams(maxFaceSize * 0.20, maxFaceSize * 1.00, 32, 35, 32);
			brfManager.setFaceTrackingResetParams(maxFaceSize * 0.15, maxFaceSize * 1.00, 40, 55, 32);
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		
		private function pickTexture(e:MouseEvent):void
		{
			textureFile.browseForOpen("Select Makeup File");
			textureFile.addEventListener(Event.SELECT, texSelected);
		}
		
		private function texSelected(e:Event):void
		{
			var loader:Loader = new Loader();
			var urlReq:URLRequest = new URLRequest(textureFile.url);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaded);
			loader.load(urlReq);
		}
		 
		
		private function loaded(e:Event):void
		{
			var bmp:Bitmap = e.target.content as Bitmap;
			faceTexture = bmp.bitmapData;
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
	
				var face:BRFFace = faces[i];			// get face
				
				if(face.state == brfv4.BRFState.FACE_TRACKING_START || face.state == brfv4.BRFState.FACE_TRACKING) {
					
					var triangles:Vector.<int> = face.triangles.concat();	
					triangles.splice(triangles.length - 18, 18);	
					drawing.drawTexture(face.vertices, triangles, faceUVs, faceTexture);
				}
			}
		}		
		
	}
	
}