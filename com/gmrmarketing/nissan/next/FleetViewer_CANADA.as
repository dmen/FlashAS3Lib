/**
 * Instantiated by Main
 */
package com.gmrmarketing.nissan.next
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import com.gmrmarketing.utilities.Utility;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.filters.DropShadowFilter;
	import flash.display.Bitmap;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	
	public class FleetViewer_CANADA extends EventDispatcher
	{
		public static const NEW_CAR_PICKED:String = "newCarPicked";
		
		private var container:DisplayObjectContainer;
		private var clipContainer:Sprite;
		private var fleetXML:XML;
		private var thumbsPerRow:int = 6;
		private const X_SPACE:int = 12;
		private const Y_SPACE:int = 12;
		
		private var clip:MovieClip;
		
		private var shadow:DropShadowFilter;		
		private var thumbs:Array;
		private var clickedCarId:String; //set in carClicked - id from fleetXML
		private var xOffset:int;
		private var yOffset:int;
		
		private var lastMainFilter:String;
		private var lastSubFilter:String;
		
		private var timeoutHelper:TimeoutHelper;
		
		
		public function FleetViewer_CANADA($fleetXML:XML, $xOffset:int = 0, $yOffset:int = 0 )
		{
			
			fleetXML = $fleetXML;
			xOffset = $xOffset;
			yOffset = $yOffset;
			thumbs = new Array();
			shadow = new DropShadowFilter(0, 0, 0, .6, 4, 4, .8, 2);
			
			clip = new modelClip(); //side menu from the lib
			
			clipContainer = new Sprite();
			
			lastMainFilter = "all";//default
			lastSubFilter = "";
		}
		
		
		public function show($container:DisplayObjectContainer, mainFilter:String = "", subFilter:String = ""):void
		{			
			container = $container;
			
			killViewer();
			
			if (mainFilter == "") {
				mainFilter = lastMainFilter;
				subFilter = lastSubFilter;
			}else {
				lastMainFilter = mainFilter;
				lastSubFilter = subFilter;
			}
						
			//reset hiliter
			if (mainFilter == "all") {				
				clip.hiliter.y  = clip.btnAll.y;
				clip.hiliter.height = clip.btnAll.height;
				clip.hiliter.alpha = .35;			
			}
			
			timeoutHelper = TimeoutHelper.getInstance();
			
			if (!container.contains(clipContainer)) {
				container.addChild(clip);
				container.addChild(clipContainer);
			}
			
			clipContainer.alpha = 1;
			clip.alpha = 1;
			clipContainer.x = xOffset;
			clipContainer.y = yOffset;
			
			thumbs = new Array();
			
			var cars:XMLList;
			if (mainFilter != "all") {
				if (subFilter != "") {
					cars = fleetXML.cars.car.(type == mainFilter && subtype == subFilter);
				}else{
					cars = fleetXML.cars.car.(type == mainFilter);
				}
			}else {
				//all
				cars = fleetXML.cars.car;
			}
			
			for (var i:int = 0; i < cars.length(); i++) {
				var thumb:MovieClip = new fleetThumb(); //library clip
				
				thumb.border.scaleX = thumb.border.scaleY = 0;
				thumb.theModel.alpha = 0;
				thumb.thePrice.alpha = 0;
				thumb.startingFrom.alpha = 0;
				
				thumb.id = cars[i].id; //inject id for retrieval when clicked
				thumb.addEventListener(MouseEvent.MOUSE_DOWN, carClicked, false, 0, true);
				//var facts:XMLList = cars[i].factoids.fact;
				var loader:Loader = new Loader();
				loader.load(new URLRequest("assets/" + cars[i].pic));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, smoothThumb, false, 0, true);
				thumb.addChildAt(loader, 1); //add behind the text elements in the clip
				loader.alpha = 0;
				thumb.theModel.htmlText = cars[i].model;				
				//thumb.thePrice.text = facts[0];
				var a:Array = Utility.gridLoc(i+1, thumbsPerRow);
				clipContainer.addChild(thumb);
				thumb.x = (a[0]-1) * (thumb.width + X_SPACE);
				thumb.y = (a[1]-1) * (thumb.height + Y_SPACE);	
				
				thumb.filters = [shadow];
				thumbs.push(thumb);
			}
			
			var cX:int = Math.floor((1366 - clipContainer.width) * .5) + xOffset;
			var cY:int = Math.floor((768 - clipContainer.height) * .5) + yOffset;			
			
			TweenMax.to(clipContainer, .5, { x:cX, y:cY, ease:Back.easeOut } );
			for (var j:int = 0; j < thumbs.length; j++) {
				TweenMax.to(thumbs[j].border, .3, { scaleX:1, scaleY:1, delay:.1 + (.08 * j) } );	
				
				TweenMax.to(thumbs[j].theModel, .3, { alpha:1, delay:.6 + (.08 * j) } );
				
				//CANADA - just don't show the price
				//TweenMax.to(thumbs[j].thePrice, .3, {alpha:1, delay:.6 + (.08 * j) } );		
				//TweenMax.to(thumbs[j].startingFrom, .3, {alpha:1, delay:.6 + (.08 * j) } );
				
				TweenMax.to(MovieClip(thumbs[j]).getChildAt(1), .3, { alpha:.75, delay:.6 + (.08 * j) } );				
			}
			
			//side menu buttons
			clip.btnAll.addEventListener(MouseEvent.MOUSE_DOWN, showAll, false, 0, true);
			clip.btnCars.addEventListener(MouseEvent.MOUSE_DOWN, showCars, false, 0, true);
			clip.btnElectric.addEventListener(MouseEvent.MOUSE_DOWN, showElectric, false, 0, true);
			clip.btnSports.addEventListener(MouseEvent.MOUSE_DOWN, showSports, false, 0, true);
			clip.btnCross.addEventListener(MouseEvent.MOUSE_DOWN, showCross, false, 0, true);
			clip.btnTrucks.addEventListener(MouseEvent.MOUSE_DOWN, showTrucks, false, 0, true);
		}
		
		private function smoothThumb(e:Event):void
		{
			var b:Bitmap = Bitmap(e.target.content);
			b.smoothing = true;	
		}
		
		
		public function hide():void
		{			
			clip.btnAll.removeEventListener(MouseEvent.MOUSE_DOWN, showAll);
			clip.btnCars.removeEventListener(MouseEvent.MOUSE_DOWN, showCars);
			clip.btnElectric.removeEventListener(MouseEvent.MOUSE_DOWN, showElectric);
			clip.btnSports.removeEventListener(MouseEvent.MOUSE_DOWN, showSports);
			clip.btnCross.removeEventListener(MouseEvent.MOUSE_DOWN, showCross);
			clip.btnTrucks.removeEventListener(MouseEvent.MOUSE_DOWN, showTrucks);
			
			TweenMax.to(clip, .5, { alpha:0 } );
			TweenMax.to(clipContainer, .5, { alpha:0, onComplete:killViewer } );
		}		
	
		
		private function carClicked(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			clickedCarId = MovieClip(e.currentTarget).id;
			dispatchEvent(new Event(NEW_CAR_PICKED));
		}
		
		
		public function getCarId():String
		{
			return clickedCarId;
		}
		
		
		private function killViewer():void
		{
			//trace("fv kill()");
			TweenMax.killTweensOf(clip);
			TweenMax.killTweensOf(clipContainer);
			for (var j:int = 0; j < thumbs.length; j++) {
				TweenMax.killTweensOf(thumbs[j]);
			}
			
			while (thumbs.length) {
				var thisThumb:MovieClip = thumbs.splice(0, 1)[0];
				thisThumb.removeChildAt(1); //remove image
				thisThumb.removeEventListener(MouseEvent.MOUSE_DOWN, carClicked);
				clipContainer.removeChild(thisThumb);
			}
			if(container){
				if (container.contains(clipContainer)) {
					container.removeChild(clip);
					container.removeChild(clipContainer);
				}
			}
		}
		
		private function showAll(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			moveHiliter(MovieClip(e.currentTarget));
			show(container, "all");
		}
		
		private function showCars(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			moveHiliter(MovieClip(e.currentTarget));
			show(container, "car");
		}
		
		private function showElectric(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			moveHiliter(MovieClip(e.currentTarget));
			show(container, "car", "electric");
		}
		
		private function showSports(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			moveHiliter(MovieClip(e.currentTarget));
			show(container, "car", "sports");
		}
		
		private function showCross(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			moveHiliter(MovieClip(e.currentTarget));
			show(container, "cross");
		}
		
		private function showTrucks(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			moveHiliter(MovieClip(e.currentTarget));
			show(container, "truck");
		}
		
		private function moveHiliter(btn:MovieClip):void
		{
			clip.hiliter.y = btn.y;
			clip.hiliter.alpha = 0;
			clip.hiliter.height = btn.height;
			TweenMax.to(clip.hiliter, .5, { alpha:.35 } );
		}
		
	}
	
}