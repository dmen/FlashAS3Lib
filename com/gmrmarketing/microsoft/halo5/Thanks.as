package com.gmrmarketing.microsoft.halo5
{
	import flash.events.*;
	import flash.display.*;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	//import flash.filesystem.*; 
	import com.adobe.images.JPEGEncoder;
	import com.dynamicflash.util.Base64;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	
	public class Thanks extends EventDispatcher
	{
		public static const COMPLETE:String = "thanksComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var userPhoto:BitmapData;
		
		private var encWide:String;
		private var encSquare:String;
		
		
		public function Thanks()
		{
			clip = new mcThanks();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(userImage:BitmapData):void
		{
			userPhoto = userImage;
			
			if (myContainer) {
				if (!myContainer.contains(clip)) {
					myContainer.addChild(clip);
				}
			}
			
			//wait before processing because it will lock the screen
			var a:Timer = new Timer(200, 1);
			a.addEventListener(TimerEvent.TIMER, process, false, 0, true);
			a.start();
		}
		
		
		private function process(e:TimerEvent):void
		{		
			var st:int = getTimer();
			//scale height of armor image to 1005 pixels
			var ratio:Number = 1005 / userPhoto.height;
			var m:Matrix = new Matrix();
			m.scale(ratio, ratio);
			var scaledArmor:BitmapData = new BitmapData(userPhoto.width * ratio, userPhoto.height * ratio, true, 0x00000000);
			scaledArmor.draw(userPhoto, m, null, null, null, true);
			
			//apply glow
			var glow:GlowFilter = new GlowFilter(0xffffff, .8, 18, 18, 2, 2);
			scaledArmor.applyFilter(scaledArmor, new Rectangle(0, 0, scaledArmor.width, scaledArmor.height), new Point(0, 0), glow);
			
			var bg:BitmapData = new finalWideBG();
			var over:BitmapData = new finalWideOverlay();
			
			var xPoint:int = Math.round((1920 - scaledArmor.width) * .5);
			bg.copyPixels(scaledArmor, new Rectangle(0, 0, scaledArmor.width, 1005), new Point( xPoint, 0), null, null, true);
			bg.copyPixels(over, new Rectangle(0, 0, 1920, 1005), new Point( 0, 0), null, null, true);
			
			
			//Now make the square image
			var bgs:BitmapData = new finalSquareBG();
			var overs:BitmapData = new finalSquareOverlay();
			xPoint = Math.round((1005 - scaledArmor.width) * .5);
			bgs.copyPixels(scaledArmor, new Rectangle(0, 0, scaledArmor.width, 1005), new Point( xPoint, 0), null, null, true);
			bgs.copyPixels(overs, new Rectangle(0, 0, 1005, 1005), new Point( 0, 0), null, null, true);
			
			
			var encoder:JPEGEncoder = new JPEGEncoder(82); //quality 1-100
			var encoderS:JPEGEncoder = new JPEGEncoder(82); //quality 1-100
			
			var wideArray:ByteArray = encoder.encode(bg);
			var squareArray:ByteArray = encoderS.encode(bgs);
			
			encWide = Base64.encodeByteArray(wideArray);
			encSquare = Base64.encodeByteArray(squareArray);
			
			dispatchEvent(new Event(COMPLETE));
			//trace("processTime:",getTimer() - st);
		}
		
		
		public function get images():Object
		{			
			return { "wide":encWide, "square":encSquare };
		}
		
		public function hide():void
		{
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
			
		}
		/*
		private function editingComplete(e:Event):void
		{
			
			
			
			
			var show:Bitmap = new Bitmap(bgs);
			show.x = 578;//120;
			show.y = 150;
			mainContainer.addChild(show);			
			
		
			var encoder:JPEGEncoder = new JPEGEncoder(82); //quality 1-100
			var ba:ByteArray = encoder.encode(bgs); //bitmap data object						
			enc = Base64.encodeByteArray(ba);
			try{
				var file:File = File.documentsDirectory.resolvePath( "square.jpg" );
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.APPEND );
				stream.writeBytes (ba, 0, ba.length );
				stream.close();
				file = null;
				stream = null;
			}catch (e:Error) {
							
			}
			
		}*/
		
	}
	
}