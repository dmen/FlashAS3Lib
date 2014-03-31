package com.gmrmarketing.bicycle
{
	import com.dynamicflash.util.Base64;
	import com.adobe.images.JPGEncoder;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	import flash.events.IOErrorEvent;
	
	
	public class CardImage extends EventDispatcher
	{
		private const SERVICE_URL:String = "http://bicycle.gmrmarketing.com/BicycleWs.asmx/PostPhoto";
		private const sizeX:int = 825;
		private const sizeY:int = 1125;
		public static const DID_POST:String = "cardWasPosted";
		public static const DID_NOT_POST:String = "cardWasNotPosted";
		
		private var emailLoader:URLLoader;
		private var curProgress:Number = 0;
		
		
		public function CardImage()
		{			
		}
		
		/**
		 * Used to encode the jpeg byteArray to a string for sending to the server
		 * or saving to disk if send fails
		 * 
		 * @param	ba
		 * @return
		 */
		public function getBase64(ba:ByteArray):String
		{
			return Base64.encodeByteArray(ba);
		}
		
		
		/**
		 * Gets a ByteArray from the base64 encoded string
		 * @param	b64
		 * @return
		 */
		public function getByteArray(b64:String):ByteArray
		{
			return Base64.decodeToByteArray(b64);
		}
		
		
		/**
		 * Returns a ByteArray from the jpegEncoder of the passed in bitmapData object
		 * @param	bmpd
		 * @param	q - JPEG Quality
		 * @return
		 */
		public function getJpeg(bmpd:BitmapData, q:int = 80):ByteArray
		{			
			var encoder:JPGEncoder = new JPGEncoder(q);
			var ba:ByteArray = encoder.encode(bmpd);
			return ba;
		}
		
		
		/**
		 * Returns a BitmapData of the current card design
		 * @return
		 */
		public function cardBitmap(theCard:MovieClip):BitmapData
		{
			var bounds:Rectangle = getRealBounds(theCard);
			var bmpd:BitmapData = new BitmapData(sizeX, sizeY);
			
			var matrix:Matrix = new Matrix();
			matrix.translate( -bounds.x, -bounds.y);
			matrix.scale(sizeX / bounds.width, sizeY / bounds.height);
			bmpd.draw(theCard, matrix, null, null, null, true);
			
			//doPrint(bmpd);
			return bmpd;
		}
		
		
		
		/**
		 * Adds the id string onto the card image
		 * @param	bmpd
		 * @param	id
		 * @return
		 */
		public function addID(bmpd:BitmapData, id:String):BitmapData
		{
			var m:Matrix = new Matrix();			
			
			var tf:TextFormat = new TextFormat();
			tf.size = 56;
			var t:TextField = new TextField();			
			t.autoSize = TextFieldAutoSize.LEFT;
			t.multiline = false;
			t.background = true;
			t.backgroundColor = 0xFFFFFF;			
			t.textColor = 0x000000;
			t.text = id;
			t.setTextFormat(tf);
			
			//draw id text into image for printing
			m.translate((sizeX - t.textWidth) * .5, sizeY - 150); //put code lower center
			bmpd.draw(t, m);
			
			return bmpd;
		}
		
		
		/**
		 * Posts to the service
		 * @param	encoded Base64 encoded ByteArray - JPEG
		 * @param	uid
		 */
		public function postImage(encoded:String, uid:String):void
		{
			var request:URLRequest = new URLRequest(SERVICE_URL);
			
			emailLoader = new URLLoader();
			emailLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
			
			var variables:URLVariables = new URLVariables();
			variables.code = uid;
			variables.imagebuffer = encoded;
			
			request.data = variables;
			request.method = URLRequestMethod.POST;
			
			emailLoader.addEventListener(Event.COMPLETE, emailSent, false, 0, true);
			emailLoader.addEventListener(IOErrorEvent.IO_ERROR, emailError, false, 0, true);
			emailLoader.addEventListener(ProgressEvent.PROGRESS, prog, false, 0, true);			
			
			emailLoader.load(request);		
		}
		
		private function emailSent(e:Event):void
		{
			emailLoader.removeEventListener(Event.COMPLETE, emailSent);
			emailLoader.removeEventListener(IOErrorEvent.IO_ERROR, emailError);
			emailLoader.removeEventListener(ProgressEvent.PROGRESS, prog);
			curProgress = 1;
			dispatchEvent(new Event(DID_POST));
		}
		
		private function emailError(e:IOErrorEvent):void
		{
			emailLoader.removeEventListener(Event.COMPLETE, emailSent);
			emailLoader.removeEventListener(IOErrorEvent.IO_ERROR, emailError);
			emailLoader.removeEventListener(ProgressEvent.PROGRESS, prog);
			curProgress = 0;
			dispatchEvent(new Event(DID_NOT_POST));
		}
		
		private function prog(e:ProgressEvent):void
		{
			curProgress = e.bytesLoaded / e.bytesTotal;
			
		}
		
		public function getProgress():Number
		{
			return curProgress;
		}
		
		
		/**
		 * Used to get the proper bounds for a masked clip where masked content can be out of the clip bounds
		 * @param	displayObject
		 * @return
		 */
		private function getRealBounds(displayObject:DisplayObject):Rectangle
		{
			var bounds:Rectangle;
			var boundsDispO:Rectangle = displayObject.getBounds( displayObject );
			 
			var bitmapData:BitmapData = new BitmapData( int( boundsDispO.width + 0.5 ), int( boundsDispO.height + 0.5 ), true, 0 );
			 
			var matrix:Matrix = new Matrix();
			matrix.translate( -boundsDispO.x, -boundsDispO.y);
			 
			bitmapData.draw( displayObject, matrix, new ColorTransform( 1, 1, 1, 1, 255, -255, -255, 255 ) );
			 
			bounds = bitmapData.getColorBoundsRect( 0xFF000000, 0xFF000000 );
			bounds.x += boundsDispO.x;
			bounds.y += boundsDispO.y;
			 
			bitmapData.dispose();
			
			return bounds;
		}
		
	}	
}