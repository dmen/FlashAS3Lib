package com.gmrmarketing.trugreen
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.LoaderInfo; //for flashVars
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import com.greensock.TweenLite;
	import flash.net.URLLoader;
	import flash.display.Loader;
	import flash.utils.getDefinitionByName;
	
	
	public class Main extends MovieClip
	{
		private var version:String;
		private var images:Array;
		private var currentImage:int;
		private var imageContainer:MovieClip;
		private var fadeTimer:Timer;
		private var textTimer:Timer;
		private var xmlLoader:URLLoader;
		private var theData:XML;
		private var theItem:XMLList;
		private var offer:MovieClip;
		private var imageFolder:String;
		
		
		public function Main()
		{			
			version = loaderInfo.parameters.flashVar;			
			
			currentImage = -1;
			images = new Array();
			
			imageContainer = new MovieClip();
			imageContainer.mask = theMask; //already on stage
			addChildAt(imageContainer, 1);			
			
			xmlLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);
			xmlLoader.load(new URLRequest("data.xml"));
		}
		
		
		
		private function xmlLoaded(e:Event):void
		{
			theData = new XML(e.target.data);
			
			var slideTime:int = parseInt(theData.slideTimer);
			
			fadeTimer = new Timer(slideTime, 1);
			fadeTimer.addEventListener(TimerEvent.TIMER, showNextImage, false, 0, true);
			
			textTimer = new Timer(slideTime, 1);
			textTimer.addEventListener(TimerEvent.TIMER, fadeText, false, 0, true);
			
			imageFolder = theData.imageFolder;
			
			//get the rotator data regardless as the text info is needed
			var im:String = theData.rotator.images;
			var ims:Array = im.split(",");
			
			var tx:String = theData.rotator.text;
			var txs:Array = tx.split(",");
			
			var tl:String = theData.rotator.textLocs;
			var tls:Array = tl.split(",");			
			
			for (var i:int = 0; i < ims.length; i++) {
				var p:Array = new Array(ims[i], txs[i], tls[i * 2], tls[i * 2 + 1]);
				images.push(p);
			}
			
			var off:Class;
			theItem = theData.item.(@fvar == version);
			if (version == "" || version == null || theItem.length() == 0) {
				off = getDefinitionByName( theData.rotator.offer ) as Class;
				showNextImage();				
			}else {
				off = getDefinitionByName( theItem.offer ) as Class;
				loadImage();
			}
			
			//offer circle
			var offer:MovieClip = new off();
			offer.x = 697;
			offer.y = 13;
			addChild(offer);
		}
		
		
		
		private function loadImage():void
		{
			var iLoader:Loader = new Loader();
			iLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, staticLoaded, false, 0, true);
			iLoader.load(new URLRequest(imageFolder + theItem.image));
		}
		
		
		
		private function showNextImage(e:TimerEvent = null):void
		{			
			currentImage++;
			if (currentImage >= images.length) {
				currentImage = 0;
			}
			
			var iLoader:Loader = new Loader();
			iLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded, false, 0, true);
			iLoader.load(new URLRequest(imageFolder + images[currentImage][0]));
		}
		
		
		
		private function staticLoaded(e:Event):void
		{
			var bmp:Bitmap = Bitmap(e.currentTarget.content);
			bmp.alpha = 0;
			imageContainer.addChild(bmp);
			
			TweenLite.to(bmp, 1, { alpha:1 } );
			
			showNextText();
		}
		
		
		
		private function showNextText():void
		{			
			if (imageContainer.numChildren > 1) {
				imageContainer.removeChildAt(1);
			}
			
			currentImage++;
			if (currentImage >= images.length) {
				currentImage = 0;
			}
			
			var tx:Class = getDefinitionByName( images[currentImage][1] ) as Class;
			var txt:MovieClip = new tx();
			
			if (currentImage == 0) {
				txt.theText.text = theItem.subhead;				
			}		
			
			txt.alpha = 0;
			txt.x = images[currentImage][2];
			txt.y = images[currentImage][3];
			
			imageContainer.addChild(txt);
			
			TweenLite.to(txt, 1, { alpha:1, delay:.25, onComplete:nextText } );			
		}
		
		
		
		private function nextText():void
		{
			textTimer.start();
		}
		
		private function fadeText(e:TimerEvent):void
		{
			TweenLite.to(imageContainer.getChildAt(1), 1, { alpha:0, onComplete:showNextText } );
		}
		
		
		
		private function imageLoaded(e:Event):void
		{
			var bmp:Bitmap = Bitmap(e.currentTarget.content);
			bmp.alpha = 0;
			imageContainer.addChild(bmp);
			
			var tx:Class = getDefinitionByName( images[currentImage][1] ) as Class;
			var txt:MovieClip = new tx();
			txt.alpha = 0;
			txt.x = images[currentImage][2];
			txt.y = images[currentImage][3];
			
			imageContainer.addChild(txt);
			
			TweenLite.to(bmp, 1, { alpha:1 } );
			TweenLite.to(txt, 1, { alpha:1, delay:.25, onComplete:removeLastImage } );
		}	
		
		
		
		private function removeLastImage():void
		{
			if (imageContainer.numChildren > 2) {
				imageContainer.removeChildAt(0);
				imageContainer.removeChildAt(0);
			}
			
			fadeTimer.start();
		}
		
	}
	
}