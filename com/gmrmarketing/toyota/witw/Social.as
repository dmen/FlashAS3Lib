package com.gmrmarketing.toyota.witw
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.geom.Point;
	
	public class Social extends EventDispatcher
	{
		public static const READY:String = "dataLoadedFromServices";		
		public static const FINISHED_HIDING:String = "finishedHiding";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var web:Web;//loads images and messages
		private var images:Array; //array of DisplayImage objects
		private var texts:Array;//array of DisplayText objects
		
		
		public function Social()
		{
			images = [];
			images.push(new DisplayImage(43, 168),new DisplayImage(311, 168),new DisplayImage(573, 168),new DisplayImage(1634, 168));
			images.push(new DisplayImage(308, 434), new DisplayImage(1105, 434), new DisplayImage(1634, 434));
			//images.push(new DisplayImage(308, 434),new DisplayImage(1105, 434),new DisplayImage(1504, 434));
			images.push(new DisplayImage(842, 704),new DisplayImage(1107, 704),new DisplayImage(1372, 704),new DisplayImage(1635, 704));
			
			texts = [];
			texts.push(new DisplayText(1103, 168, 509, 245, 0xD71B23, 0xD71B23));//big red one
			texts.push(new DisplayText(43, 704, 509, 245, 0x58595B, 0x58595B)); //big gray one
			
			texts.push(new DisplayText(43, 434, 245, 245, 0xD71B23, 0xffffff));
			//texts.push(new DisplayText(43, 434, 114, 245, 0xD71B23, 0xffffff));
			//texts.push(new DisplayText(174, 434, 114, 245, 0x58595B, 0xffffff));
			texts.push(new DisplayText(1370, 434, 245, 245, 0xD71B23, 0xffffff));
			//texts.push(new DisplayText(1370, 434, 114, 245, 0xD71B23, 0xffffff));
			//texts.push(new DisplayText(1764, 434, 114, 245, 0x58595B, 0xffffff));			
			
			//texts.push(new DisplayText(839, 168, 245, 245, 0x58595B, 0xffffff));
			texts.push(new DisplayText(839, 168, 245, 114, 0x58595B, 0xffffff));
			texts.push(new DisplayText(839, 299, 245, 114, 0xD71B23, 0xffffff));			
			
			
			
			//texts.push(new DisplayText(574, 704, 245, 245, 0x58595B, 0xffffff));
			texts.push(new DisplayText(574, 704, 245, 114, 0x58595B, 0xffffff));
			texts.push(new DisplayText(574, 834, 245, 114, 0xD71B23, 0xffffff));
			
			web = new Web();
			web.addEventListener(Web.REFRESH_COMPLETE, socialReady);
			
			clip = new social();
		}
		
		
		private function socialReady(e:Event):void
		{
			web.removeEventListener(Web.REFRESH_COMPLETE, socialReady);
			dispatchEvent(new Event(READY));
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.bgLines.alpha = 0; //red/gray line at top/bottom
			clip.bgLines.scaleY = .1;
			clip.logo.alpha = 0;
			clip.visit.alpha = 0;
			clip.header.alpha = 0;
			clip.follow.scaleX = 0;
			
			var i:int;
			var displayIndex:int;
			//distribute allMessages among the DisplayText objects
			var allTexts:Array = web.messages;//array of objects with message,user properties
			displayIndex = 0;
			for (i = 0; i < allTexts.length; i++) {
				texts[displayIndex].addText(allTexts[i]);
				displayIndex++;
				if (displayIndex >= texts.length) {
					displayIndex = 0;
				}
			}
			
			//distribute allImages among the DisplayImage objects
			var allImages:Array = web.images;//array of bitmaps
			displayIndex = 0;
			for (i = 0; i < allImages.length; i++) {
				images[displayIndex].addImage(allImages[i]);
				displayIndex++;
				if (displayIndex >= images.length) {
					displayIndex = 0;
				}
			}
			TweenMax.to(clip.follow, .5, { scaleX:1, alpha:1, ease:Back.easeOut, delay:1 } );
			TweenMax.to(clip.bgLines, 1, { alpha:1, scaleY:1, ease:Back.easeOut } );
			TweenMax.to(clip.logo, 1, { alpha:1, delay:1} );
			clip.visit.x += 100;
			TweenMax.to(clip.visit, .5, { alpha:1, x:"-100", delay:.75, ease:Back.easeOut});
			clip.header.y += 100;
			TweenMax.to(clip.header, .5, { alpha:1, y:"-100", delay:.3, ease:Back.easeOut, onComplete:showImages } );
		}
		
		
		public function hide():void
		{
			web.refresh();
			
			TweenMax.killAll();
			
			var i:int;
			for (i = 0; i < images.length; i++) {				
				images[i].hide();
			}
			for (i = 0; i < texts.length; i++) {
				texts[i].hide();
			}
			
			TweenMax.to(clip.header, 1, { alpha:0, delay:2 } );
			TweenMax.to(clip.follow, 1, { alpha:0, delay:.5 } );
			TweenMax.to(clip.logo, 1, { alpha:0, delay:2.2 } );
			TweenMax.to(clip.visit, 1, { alpha:0, delay:2.3 } );
			
			TweenMax.to(clip.bgLines, 1, { alpha:0, scaleY:0, delay:2.5, ease:Back.easeIn, onComplete:finished } );
		}
		
		
		private function finished():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			dispatchEvent(new Event(FINISHED_HIDING));
		}
		
		
		private function showImages():void
		{
			var i:int;
			//add all images to myContainer
			for (i = 0; i < images.length; i++) {
				if(!myContainer.contains(images[i])){
					myContainer.addChild(images[i]);
				}
				TweenMax.delayedCall(i * .2, images[i].doTransition);
				//images[i].doTransition();
			}
			for (i = 0; i < texts.length; i++) {
				if(!myContainer.contains(texts[i])){
					myContainer.addChild(texts[i]);
				}
				TweenMax.delayedCall(1 + i * .2, texts[i].doTransition);
				//texts[i].doTransition();
			}
		}
		
	}
	
}