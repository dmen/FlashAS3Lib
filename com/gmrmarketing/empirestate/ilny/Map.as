package com.gmrmarketing.empirestate.ilny
{
	import flash.events.*;
	import flash.display.*
	import com.greensock.TweenMax;	
	import com.greensock.easing.*;
	import flash.filters.DropShadowFilter;
	import flash.geom.*;
	import org.gestouch.gestures.TransformGesture;
	import org.gestouch.events.GestureEvent;
	
	
	public class Map extends EventDispatcher
	{
		public static const INTEREST_SELECTED:String = "interestSelected";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var interests:Interests;
		private var mapData:MapData;
		private var currentInterests:Array;//array of objects from mapData
		private var currentInterest:Object; //data object of clicked icon - one item from currentInterests
		private var markerContainer:Sprite;
		
		private var sp:Sprite;
		private var tranGes:TransformGesture;	
		
		private var ds:DropShadowFilter;
		private var intManager:InterestsManager;
		
		
		public function Map()
		{
			clip = new mcMap();//library
			
			sp = new Sprite();
			sp.graphics.beginFill(0x00ff00);
			sp.graphics.drawRect(0, 0, 1920, 1080);
			sp.graphics.endFill();
			sp.alpha = 0;
			clip.map.addChild(sp);
			
			mapData = new MapData();
			
			interests = new Interests();//left side interests selector
			intManager = InterestsManager.getInstance();
			
			markerContainer = new Sprite();
			clip.map.addChild(markerContainer);
			
			tranGes = new TransformGesture(clip.map);
			
			ds = new DropShadowFilter(0, 0, 0, 1, 5, 5, 1, 1);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
			interests.container = myContainer;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}			
			
			clip.title.y = -clip.title.height;
			clip.subTitle.y = -clip.subTitle.height;
			clip.pinch.scaleX = clip.pinch.scaleY = 0;
			
			clip.map.scaleX = clip.map.scaleY = 0;
			clip.map.cityNames.alpha = 0;
			clip.map.roads.alpha = 0;
			
			tranGes.addEventListener(org.gestouch.events.GestureEvent.GESTURE_BEGAN, onGesture);
			tranGes.addEventListener(org.gestouch.events.GestureEvent.GESTURE_CHANGED, onGesture);
			
			TweenMax.to(clip.title, .3, { y:0 } );
			TweenMax.to(clip.subTitle, .3, { y:159, delay:.15, onComplete:showInterests } );
		}
		
		
		private function onGesture(e:org.gestouch.events.GestureEvent):void
		{			
			var matrix:Matrix = clip.map.transform.matrix;
			
			matrix.translate(tranGes.offsetX, tranGes.offsetY);
			clip.map.transform.matrix = matrix;
			
			if (tranGes.scale != 1)
			{
				var transformPoint:Point = matrix.transformPoint(clip.map.globalToLocal(tranGes.location));
				matrix.translate(-transformPoint.x, -transformPoint.y);
				matrix.scale(tranGes.scale, tranGes.scale);
				matrix.translate(transformPoint.x, transformPoint.y);
				
				clip.map.transform.matrix = matrix;
			}
			/*
			//limit scale
			clip.map.scaleX = Math.min(6, clip.map.scaleX);
			clip.map.scaleY = clip.map.scaleX;
			
			clip.map.scaleX = Math.max(1.4, clip.map.scaleX);
			clip.map.scaleY = clip.map.scaleX;
			*/
			//(curscale - minScale) / scaleRange
			clip.map.roads.alpha = (clip.map.scaleX - 1.4) / 6.6;//full vis when scale = 8
			clip.map.cityNames.alpha = (clip.map.scaleX - 1.4) / 3.6;//full vis when scale = 5
			clip.map.regionNames.alpha = 1 - ((clip.map.scaleX - 1.4) / 2.6);//full hidden when scale = 4
			
			//scale markers
			var n:int = markerContainer.numChildren;
			var s:Number = Math.max((1 / clip.map.scaleX) * 1.4, .1);
			for (var i:int = 0; i < n; i++) {
				markerContainer.getChildAt(i).scaleX = markerContainer.getChildAt(i).scaleY = s;
			}
		}
		
		
		private function showInterests():void
		{
			interests.show();
			interests.addEventListener(Interests.CHANGED, updateInterests);
			
			TweenMax.to(clip.pinch, .5, { scaleX:1, scaleY:1, delay:1, ease:Back.easeOut } );
			TweenMax.to(clip.map, 1, { scaleX:1.4, scaleY:1.4, delay:1, ease:Back.easeOut } );
		}
		
		
		/**
		 * called by listener whenever the selected interests change
		 * gets the current array of interest objects based on the selection
		 * @param	e
		 */
		public function updateInterests(e:Event = null):void
		{
			currentInterests = mapData.getInterests(interests.interests);
			
			//remove old markers
			while (markerContainer.numChildren) {
				markerContainer.removeChildAt(0);
			}
	
			for (var i:int = 0; i < currentInterests.length; i++) {				
				var a:MovieClip;				
				
				//true if the user has this item already in their bucket list
				var inList:Boolean = intManager.hasInterest(currentInterests[i]);
				
				//determine icon - using level 1 icon only for now... 
				switch(currentInterests[i].cat1) {
					case "Must See":
						if (inList) {
							a = new iconMustSeeRed();
						}else{
							a = new iconMustSee();
						}
						break;
					case "History":
						if (inList) {
							a = new iconHistoryRed();
						}else{
							a = new iconHistory();
						}
						break;
					case "Family Fun":
						if(inList){
							a = new iconFamilyFunRed();
						}else {
							a = new iconFamilyFun();
						}
						break;
					case "Wineries":
						if(inList){
							a = new iconWineriesRed();
						}else {
							a = new iconWineries();
						}
						break;
					case "Breweries":
						if(inList){
							a = new iconBreweriesRed();
						}else {
							a = new iconBreweries();
						}
						break;
					case "Art & Culture":
						if(inList){
							a = new iconCultureRed();
						}else {
							a = new iconCulture();
						}
						break;
					case "Parks and Beaches":
						if(inList){
							a = new iconParksRed();
						}else {
							a = new iconParks();
						}
						break;
				}				
				
				//inject index of this interest - used when clicking on the icon - matches index in currentInterests array
				a.interestIndex = i; 
				
				markerContainer.addChild(a);				
				a.x = currentInterests[i].x;
				a.y = currentInterests[i].y;
				
				//scale marker - matches scaling in onGesture()
				a.scaleX = a.scaleY = Math.max((1 / clip.map.scaleX) * 1.4, .1);			
				
				a.filters = [ds];
				a.addEventListener(MouseEvent.CLICK, interestClicked, false, 0, true);
			}
		}
		
		
		/**
		 * returns the current interest object
		 * one item from currentInterests
		 */
		public function get interestData():Object
		{
			return currentInterest;
		}
		
		
		/**
		 * callback for CLICK on an interest icon
		 * dispatches INTEREST_SELECTED which will show
		 * the detail dialog box from Main
		 * @param	e
		 */
		private function interestClicked(e:MouseEvent):void
		{
			var i:int = MovieClip(e.currentTarget).interestIndex;
			currentInterest = currentInterests[i];
			dispatchEvent(new Event(INTEREST_SELECTED));			
		}
		
	}
	
}