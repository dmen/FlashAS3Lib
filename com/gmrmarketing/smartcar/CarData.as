package com.gmrmarketing.smartcar
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import com.dynamicflash.util.Base64;
	import com.adobe.images.JPGEncoder;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	import flash.events.*;
	
	
	
	
	public class CarData extends EventDispatcher
	{
		public static const DID_POST:String = "carDataWasPosted";
		public static const DID_NOT_POST:String = "carDatadWasNotPosted";
		
		private var scene:String; //scene name - city,suburbs,beach,nightlife
		private var audioSelection:Array; //four item array of integers in range 1-4  - bass,drums,guitar,synth
		private var tex:BitmapData; //the tiled 1500x1500 image applied to the car
		private var texSet:Boolean; //true after setCarTexture() has been called
		private var pat:String;
		private var tiling:int; //tiling of the kaleid pattern
		private var license:String; //license plate
		private var venueID:String = "0"; //default to 0 - not reset in init
		private var licenseImage:BitmapData;
		private var curBGColor:Number; //background color for the kaleidoscope
		private var kPoint:Point; //last touch spot on kaleidoscope
		private var sliderPos:int;
		
		private var poster:URLLoader;
		private var postResponse:String;
		
		private var jpeg:ByteArray; //jpeg image from jpeg encoder
		private var encoded:String; //base64 encoded string of the jpeg for sending to webservice
		
		
		
		public function CarData()
		{			
			init();
		}
		
		public function init():void
		{
			//set defaults
			scene = "city";
			audioSelection = new Array(0, 0, 0, 0);
			tex = new BitmapData(1500, 1500, true, 0x00000000);
			texSet = false;
			pat = "btnKal1";
			tiling = 1;
			license = "";			
			postResponse = "";
			licenseImage = new BitmapData(102, 30, true, 0x00000000);
			curBGColor = 0xffeeeeee;
			kPoint = null;
			sliderPos = 35;
		}
		
		/**
		 * Called from Main.venSelected()
		 * @param	id
		 */
		public function setVenueID(id:String):void
		{
			venueID = id;			
		}
		
		public function setScene(s:String):void
		{
			scene = s;
		}
		
		public function getScene():String
		{
			return scene;
		}
		
		public function setAudioSelection(a:Array):void
		{
			audioSelection = a;
		}
		
		public function getAudioSelection():Array
		{
			return audioSelection;
		}
		
		public function audioSet():Boolean
		{
			var a:Boolean = false;
			for (var i:int = 0; i < audioSelection.length; i++) {
				if (audioSelection[i] != 0) {
					a = true;
					break;
				}
			}
			return a;
		}
		
		public function setCarTexture(b:BitmapData):void
		{
			tex = b;			
		}
		public function texIsSet():void
		{
			texSet = true;
		}
		public function textureSet():Boolean
		{
			return texSet;
		}
		
		public function getCarTexture():BitmapData
		{
			return tex;
		}
		public function setBGColor(n:Number):void
		{
			//trace("carData.setBGColor", n);
			curBGColor = n;
		}
		public function getBGColor():Number
		{
			//trace("carData.getBGColor", curBGColor);
			return curBGColor;
		}
		public function setPattern(p:String):void
		{
			pat = p;
		}
		
		public function getPattern():String
		{
			return pat;
		}
		
		public function setTiling(t:int):void
		{
			tiling = t;
		}
		
		public function getTiling():int
		{
			return tiling;
		}
		
		public function setTilingSliderPosition(pos:int):void
		{
			sliderPos = pos;
		}
		
		public function getTilingSliderPosition():int
		{
			return sliderPos;
		}
		
		public function setKPoint(p:Point):void
		{
			kPoint = p;
		}
		
		public function getKPoint():Point
		{
			return kPoint;
		}
		public function setLicense(l:String):void
		{
			license = l;
		}
		
		public function getLicense():String
		{
			return license;
		}
		
		public function setLicenseImage(i:BitmapData):void
		{
			licenseImage = i;
		}
		
		public function getLicenseImage():BitmapData
		{
			return licenseImage;
		}
		
		
		public function getDataID():String
		{
			return postResponse;
		}
		
		
		
		//IMAGE STUFF
		
		
		/**
		 * Posts to the web service defined in StaticData			
		 */		
		public function postToService():void
		{			
			var request:URLRequest = new URLRequest(StaticData.POST_PHOTO_URL);
			
			jpeg = getJpeg(tex);
			encoded = getBase64(jpeg);
			
			poster = new URLLoader();
			
			//CAVEAT: IOErrorEvent.IO_ERROR will not be thrown when the format is set to URLLoaderDataFormat.VARIABLES
			//this is due to that constant being "variables" and not "VARIABLES" as it should be... bug
			//workaround is to just use the string "VARIABLES"
			poster.dataFormat = "VARIABLES";
			
			var variables:URLVariables = new URLVariables();		
			
			variables.eventId = venueID;
			variables.imagebuffer = encoded; //send base64 encoded string to service
			variables.tracks = audioSelection.join(","); //bass,drums,guitar,synth 1-4 each
			variables.vid = scene; //city, suburbs, beach, nightlife
			variables.license = license;
			
			request.data = variables;
			request.method = URLRequestMethod.POST;
			
			poster.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
			poster.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);			
			
			try{
				poster.load(request);
			}catch (e:Error) {
				dataError();
			}
		}
		
		
		private function dataPosted(e:Event):void
		{			
			var vars:URLVariables = new URLVariables(e.target.data);
			
			postResponse = vars.success; //either "false" or the ID of this saved data to pass to the form app
			
			if(postResponse != "false"){
				poster.removeEventListener(Event.COMPLETE, dataPosted);
				poster.removeEventListener(IOErrorEvent.IO_ERROR, dataError);			
				
				dispatchEvent(new Event(DID_POST));
			}else {
				dataError();
			}			
		}
		
		
		public function getRequest():Object
		{
			var a:Object = new Object();
			a.eventId = venueID;			
			a.imagebuffer = encoded;
			a.image = jpeg; //byteArray
			a.tracks = audioSelection.join(",");
			a.vid = scene;
			a.license = license;
			
			return a;			
		}
		
		
		private function dataError(e:IOErrorEvent = null):void
		{			
			poster.removeEventListener(Event.COMPLETE, dataPosted);
			poster.removeEventListener(IOErrorEvent.IO_ERROR, dataError);
			
			postResponse = "";
			dispatchEvent(new Event(DID_NOT_POST));
		}
		
		
		/**
		 * Returns a ByteArray from the jpegEncoder of the passed in bitmapData object
		 * @param	bmpd
		 * @param	q - JPEG Quality
		 * @return
		 */
		private function getJpeg(bmpd:BitmapData, q:int = 80):ByteArray
		{			
			var encoder:JPGEncoder = new JPGEncoder(q);			
			var ba:ByteArray = encoder.encode(bmpd);
			return ba;
		}
		
		
		/**
		 * Used to encode the jpeg byteArray to a string for sending to the server
		 * or saving to disk if send fails
		 * 
		 * @param	ba
		 * @return
		 */
		private function getBase64(ba:ByteArray):String
		{
			return Base64.encodeByteArray(ba);
		}
		
	}
	
}