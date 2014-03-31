/**
 * Used by Results.as
 */
package com.gmrmarketing.nissan.rodale.athfleet
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
	
	
	public class FleetViewer extends EventDispatcher
	{
		public static const NEW_CAR_PICKED:String = "newCarPicked";
		
		private var container:DisplayObjectContainer;
		private var clipContainer:Sprite;
		private var fleetXML:XML;
		private var thumbsPerRow:int = 6;
		private const X_SPACE:int = 12;
		private const Y_SPACE:int = 12;
		private var bg:MovieClip;
		private var shadow:DropShadowFilter;
		private var theClose:MovieClip;
		private var thumbs:Array;
		private var clickedCarIndex:int; //set in carClicked
		
		
		
		public function FleetViewer($container:DisplayObjectContainer, $fleetXML:XML, useBackground:Boolean = true)
		{
			container = $container;
			fleetXML = $fleetXML;
			thumbs = new Array();
			shadow = new DropShadowFilter(0, 0, 0, .6, 4, 4, .8, 2);
			
			clipContainer = new Sprite();
			
			if(useBackground){
				bg = new fleetBG(); //lib clip
				clipContainer.addChild(bg);
			}
			
			theClose = new btnClose(); //lib clip
			clipContainer.addChild(theClose);
			theClose.x = clipContainer.width - (theClose.width * .5);
			theClose.y = 0 - (theClose.height * .5);
		}
		
		
		public function show(mainFilter:String = "", subFilter:String = ""):void
		{
			killViewer();
			
			clipContainer.alpha = 1;
			clipContainer.x = 300;
			clipContainer.y = 100;
			
			container.addChild(clipContainer);			
			
			thumbs = new Array();
			
			theClose.addEventListener(MouseEvent.MOUSE_DOWN, hide, false, 0, true);
			
			var cars:XMLList;
			if (mainFilter != "") {
				if (subFilter != "") {
					cars = fleetXML.cars.car.(type == mainFilter && subtype == subFilter);
				}else{
					cars = fleetXML.cars.car.(type == mainFilter);
				}
			}else {
				cars = fleetXML.cars.car;
			}
			
			for (var i:int = 0; i < cars.length(); i++) {
				var clip:MovieClip = new fleetThumb(); //library clip
				clip.xmlIndex = i; //inject var for retrieval when clicked
				clip.addEventListener(MouseEvent.MOUSE_DOWN, carClicked, false, 0, true);
				var facts:XMLList = cars[i].factoids.fact;
				var loader:Loader = new Loader();
				loader.load(new URLRequest("assets/" + cars[i].pic));
				clip.addChildAt(loader, 1); //add behind the text elements in the clip
				clip.theModel.htmlText = cars[i].model;				
				clip.thePrice.text = facts[0];
				var a:Array = Utility.gridLoc(i+1, thumbsPerRow);
				clipContainer.addChild(clip);
				clip.x = ((a[0]-1) * (clip.width + X_SPACE) + 10);
				clip.y = ((a[1]-1) * (clip.height + Y_SPACE) + 60);	
				clip.alpha = 0;
				clip.filters = [shadow];
				thumbs.push(clip);
			}
			
			var cX:int = Math.floor((1920 - clipContainer.width) * .5);
			var cY:int = Math.floor((1080 - clipContainer.height) * .5);
			
			TweenMax.to(clipContainer, .5, { x:cX, y:cY, ease:Back.easeOut } );
			for (var j:int = 0; j < thumbs.length; j++) {
				TweenMax.to(thumbs[j], .2, { alpha:1, delay:.25 + (.08 * j) } );
			}
		}
		
		
		public function hide(e:MouseEvent = null):void
		{			
			theClose.removeEventListener(MouseEvent.MOUSE_DOWN, hide);
			TweenMax.to(clipContainer, .5, { alpha:0, onComplete:killViewer } );
		}		
	
		
		private function carClicked(e:MouseEvent):void
		{
			clickedCarIndex = MovieClip(e.currentTarget).xmlIndex;
			dispatchEvent(new Event(NEW_CAR_PICKED));
		}
		
		
		public function getCarIndex():int
		{
			return clickedCarIndex;
		}
		
		
		private function killViewer():void
		{
			while (thumbs.length) {
				var thisThumb:MovieClip = thumbs.splice(0, 1)[0];
				thisThumb.removeChildAt(1); //remove image
				thisThumb.removeEventListener(MouseEvent.MOUSE_DOWN, carClicked);
				clipContainer.removeChild(thisThumb);
			}
			if(container.contains(clipContainer)){
				container.removeChild(clipContainer);
			}
		}
	}
	
}