package com.gmrmarketing.nestle.dolcegusto2016.cafe
{
	import flash.events.*;
	import flash.display.*;
	import flash.net.*;
	import flash.text.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Flavors extends EventDispatcher
	{
		public static const COMPLETE:String = "flavorsComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var loader:URLLoader;
		private var flavors:Array;//aray loaded from the JSON
		private var flavorContainer:Sprite;//holds all the flavors - tweened left and right
		private var currentFlavor:MovieClip;//current flavor - used in imageLoaded to place the bitmap into
		
		private var yAdd:int = 420;//multiplied by curColCount to get y position of flavor
		private var curColCount:int;//current flavor number in the column - three per column
		private var curCol:int;//the current column - used for formatting the columns
		private var curX:int;//current x position where flavors are placed
		private var numPages:int;//number of two column sets
		private var curPage:int;
		
		private var indicatorContainer:Sprite;//holds the circle indicators for the number of pages
		
		
		public function Flavors()
		{
			clip = new mcFlavors();
			
			flavorContainer = new Sprite();
			clip.addChildAt(flavorContainer, 0);//add behind the buttons
			flavorContainer.x = 0;
			flavorContainer.y = 394;
			
			indicatorContainer = new Sprite();//contains instances of mcFlavorIndicator (24x24 gray circle)
			clip.addChild(indicatorContainer);
			indicatorContainer.y = 1721;//top of the circles
			
			clip.btnLeft.alpha = .1;
			
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, parseJSON);
			loader.load(new URLRequest("flavors.json"));
		}
		
		
		/**
		 * Done only once at app start
		 * parses the flavors - will be an object with a flavors array
		 * containing flavor objects
		 * @param	e
		 */
		private function parseJSON(e:Event):void
		{
			loader.removeEventListener(Event.COMPLETE, parseJSON);
			var js:Object = JSON.parse(loader.data);
			flavors = js.flavors;
			curColCount = 0;
			curCol = 1;
			curX = 80;//start at 80 - then add 1208, then 1528, then alternate between those two
			numPages = 1;			
			loadNextFlavor();
		}
		
		
		/**
		 * Done only once at app start
		 * loads the image for the next flavor in the list
		 * each flavor is added to flavorContainer
		 */
		private function loadNextFlavor():void
		{
			if(flavors.length > 0){
				var nf:Object = flavors.shift();
				
				currentFlavor = new mcFlavorOne();
				currentFlavor.flavor.text = nf.flavor;
				currentFlavor.description.autoSize = TextFieldAutoSize.LEFT;				
				currentFlavor.description.text = nf.description;
				
				if (nf.status != "Try it here!"){
					TweenMax.to(currentFlavor.status, 0, {tint:0xf26526});
				}
				currentFlavor.status.text = nf.status;
				currentFlavor.status.y = currentFlavor.description.y + currentFlavor.description.textHeight + 15;
				
				flavorContainer.addChild(currentFlavor);
				currentFlavor.x = curX;
				currentFlavor.y = yAdd * curColCount;
				curColCount++;
				if (curColCount >= 3){
					curColCount = 0;
					curCol++;
					if (curCol % 2 == 0){
						curX += 1208;
					}else{
						curX += 1528;
						numPages++;
					}
				}
				
				var im:String = "assets/flavorImages/" + nf.image;				
				var l:Loader = new Loader();
				l.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded, false, 0, true);
				l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imageError, false, 0, true);
				l.load(new URLRequest(im));	
			}else{
				
				//loading complete - build the indicator
				for (var i:int = 0; i < numPages; i++){
					var indic:MovieClip = new mcFlavorIndicator();
					indic.x = i * (indic.width + 25);
					indicatorContainer.addChild(indic);
				}
				indicatorContainer.x = 1368 - (indicatorContainer.width * .5);
				
			}
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
			
			//reset to page 1
			curPage = 1;
			flavorContainer.x = 0;
			
			flavorContainer.getChildAt(0).alpha = 0;
			flavorContainer.getChildAt(1).alpha = 0;
			flavorContainer.getChildAt(2).alpha = 0;
			flavorContainer.getChildAt(3).alpha = 0;
			flavorContainer.getChildAt(4).alpha = 0;
			flavorContainer.getChildAt(5).alpha = 0;
			
			clip.btnLeft.alpha = .2;
			clip.btnRight.alpha = 1;
			
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, flavorsComplete, false, 0, true);
			clip.btnLeft.addEventListener(MouseEvent.MOUSE_DOWN, leftClicked, false, 0, true);
			clip.btnRight.addEventListener(MouseEvent.MOUSE_DOWN, rightClicked, false, 0, true);
			
			TweenMax.to(flavorContainer.getChildAt(0), .4, {alpha:1, delay:.1});
			TweenMax.to(flavorContainer.getChildAt(1), .4, {alpha:1, delay:.3});
			TweenMax.to(flavorContainer.getChildAt(2), .4, {alpha:1, delay:.5});
			TweenMax.to(flavorContainer.getChildAt(3), .4, {alpha:1, delay:.7});
			TweenMax.to(flavorContainer.getChildAt(4), .4, {alpha:1, delay:.9});
			TweenMax.to(flavorContainer.getChildAt(5), .4, {alpha:1, delay:1.1});
			
			showPageNum();
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, flavorsComplete);
			clip.btnLeft.removeEventListener(MouseEvent.MOUSE_DOWN, leftClicked);
			clip.btnRight.removeEventListener(MouseEvent.MOUSE_DOWN, rightClicked);
		}
		
		
		/**
		 * places the loaded bitmap into currentFlavor
		 * @param	e
		 */
		private function imageLoaded(e:Event):void
		{	
			var b:Bitmap = new Bitmap(e.target.content.bitmapData);
			b.smoothing = true;
			currentFlavor.addChild(b);
			b.x = 40;
			b.y = 15;
			loadNextFlavor();
		}
		
		
		private function imageError(e:IOErrorEvent):void
		{
			trace("image error", e.toString());
			loadNextFlavor();//keep loading
		}
		
		
		private function leftClicked(e:MouseEvent):void
		{
			if(!TweenMax.isTweening(flavorContainer) && curPage > 1){
				TweenMax.to(flavorContainer, .5, {x:"2736", ease:Back.easeInOut});
				curPage--;
				showPageNum();
			}
			if (curPage <= 1){
				TweenMax.to(clip.btnLeft, .5, {alpha:.1});				
			}
			TweenMax.to(clip.btnRight, .5, {alpha:1});
		}
		
		
		private function rightClicked(e:MouseEvent):void
		{
			if(!TweenMax.isTweening(flavorContainer) && curPage < numPages){
				TweenMax.to(flavorContainer, .5, {x:"-2736", ease:Back.easeInOut});
				curPage++;
				showPageNum();
			}
			if (curPage >= numPages){
				TweenMax.to(clip.btnRight, .5, {alpha:.1});				
			}
			TweenMax.to(clip.btnLeft, .5, {alpha:1});
		}
		
		
		/**
		 * Called when the close button is clicked
		 * @param	e
		 */
		private function flavorsComplete(e:MouseEvent):void
		{
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		/**
		 * shows the page number in little circles at the bottom
		 */
		private function showPageNum():void
		{
			var n:int = indicatorContainer.numChildren;
			for (var i:int = 0; i < n; i++){
				if ((i + 1) == curPage){
					TweenMax.to(indicatorContainer.getChildAt(i), .75, {tint:0x930053});
				}else{
					TweenMax.to(indicatorContainer.getChildAt(i), 0, {tint:0xc0c0c0});
				}
			}
		}
		
	}
	
}