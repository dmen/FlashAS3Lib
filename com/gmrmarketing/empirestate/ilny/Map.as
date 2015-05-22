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
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Map extends EventDispatcher
	{
		public static const NEXT:String = "nextButtonPressed";
		public static const INTEREST_SELECTED:String = "interestSelected";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var interests:Interests;//left sideinterest selector
		private var mapData:MapData;
		private var currentInterests:Array;//array of current interest objects from mapData - based on selected category
		private var currentInterest:Object; //data object of clicked icon - one item from currentInterests
		private var markerContainer:Sprite;
		
		private var sp:Sprite;
		private var tranGes:TransformGesture;	
		
		private var ds:DropShadowFilter;
		private var intManager:InterestsManager;
		
		private var pinchShowing:Boolean;
		
		private var bucketList:BucketList;
		private var lastPoint:Point;
		
		private var tim:TimeoutHelper;
		
		private var heartPoint:Point;//set in show() - position of clip.youAreHere
		private var heart:MovieClip;
		private var heartContainer:Sprite;
		
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
			bucketList = new BucketList();
			intManager = InterestsManager.getInstance();//users bucket list manager
			
			markerContainer = new Sprite();
			clip.map.addChild(markerContainer);
			
			heartContainer = new Sprite();
			clip.map.addChild(heartContainer);
			
			heart = new mcYouAreHere();//lib
			
			tranGes = new TransformGesture(clip.map);
			
			tim = TimeoutHelper.getInstance();
			
			ds = new DropShadowFilter(0, 0, 0, 1, 5, 5, 1, 1);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
			interests.container = myContainer;
			bucketList.container = myContainer;
		}
		
		
		/**
		 * 
		 * @param	hp HeartPoint - position of you are here icon
		 */
		public function show(hp:Point):void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}			
			
			heartPoint = hp;
			
			clip.title.y = -clip.title.height;
			clip.subTitle.y = -clip.subTitle.height;
			clip.pinch.scaleX = clip.pinch.scaleY = 0;			
			pinchShowing = true;
			
			clip.map.scaleX = clip.map.scaleY = 1.4;
			clip.map.x = 517;
			clip.map.y = 260;
			clip.map.alpha = 0;
			clip.map.cityNames.alpha = 0;
			clip.map.roads.alpha = 0;
			clip.map.regionNames.alpha = 1;
			
			//disable/enable Next
			if (intManager.interests.length > 0) {
				clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, nextClicked);
				TweenMax.to(clip.btnNext, .5, { alpha:1 } );
			}else {
				clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, nextClicked);
				TweenMax.to(clip.btnNext, .5, { alpha:.3 } );
			}
			
			tranGes.addEventListener(org.gestouch.events.GestureEvent.GESTURE_BEGAN, onGesture);
			tranGes.addEventListener(org.gestouch.events.GestureEvent.GESTURE_CHANGED, onGesture);
			tranGes.addEventListener(org.gestouch.events.GestureEvent.GESTURE_ENDED, onGestureEnded);
			
			TweenMax.to(clip.title, .3, { y:0 } );
			TweenMax.to(clip.subTitle, .3, { y:159, delay:.15, onComplete:showInterests } );
		}
		
		
		public function hide():void
		{
			tranGes.removeEventListener(org.gestouch.events.GestureEvent.GESTURE_BEGAN, onGesture);
			tranGes.removeEventListener(org.gestouch.events.GestureEvent.GESTURE_CHANGED, onGesture);
			tranGes.addEventListener(org.gestouch.events.GestureEvent.GESTURE_ENDED, onGestureEnded);
			tranGes.addEventListener(org.gestouch.events.GestureEvent.GESTURE_CANCELLED, onGestureEnded);
			
			//remove old markers
			while (markerContainer.numChildren) {
				markerContainer.removeChildAt(0);
			}
			
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			interests.hide();
			interests.removeEventListener(Interests.CHANGED, updateInterests);
			
			bucketList.kill();
		}
		
		
		/**
		 * limit map scaling
		 * @param	e
		 */
		private function onGestureEnded(e:org.gestouch.events.GestureEvent):void
		{
			var matrix:Matrix = clip.map.transform.matrix;
			
			if(lastPoint){
				if(clip.map.scaleX < 1.4){
					matrix.translate(-lastPoint.x, -lastPoint.y);
					matrix.scale(1.4/clip.map.scaleX, 1.4/clip.map.scaleX);
					matrix.translate(lastPoint.x, lastPoint.y);
					
					clip.map.transform.matrix = matrix;
				}
				
				if(clip.map.scaleX > 18){
					matrix.translate(-lastPoint.x, -lastPoint.y);
					matrix.scale(18/clip.map.scaleX, 18/clip.map.scaleX);
					matrix.translate(lastPoint.x, lastPoint.y);
					
					clip.map.transform.matrix = matrix;
				}
				//scale markers
			var n:int = markerContainer.numChildren;
			var s:Number = Math.max(1 / clip.map.scaleX, .1);
			for (var i:int = 0; i < n; i++) {
				markerContainer.getChildAt(i).scaleX = markerContainer.getChildAt(i).scaleY = s;
			}
			}
		}
		
		
		private function onGesture(e:org.gestouch.events.GestureEvent):void
		{			
			tim.buttonClicked();
			
			var matrix:Matrix = clip.map.transform.matrix;
			
			//findClose(tranGes.location);
			
			matrix.translate(tranGes.offsetX, tranGes.offsetY);
			clip.map.transform.matrix = matrix;
			
			if (tranGes.scale != 1){
				lastPoint = matrix.transformPoint(clip.map.globalToLocal(tranGes.location));
				matrix.translate(-lastPoint.x, -lastPoint.y);
				matrix.scale(tranGes.scale, tranGes.scale);
				matrix.translate(lastPoint.x, lastPoint.y);
				
				clip.map.transform.matrix = matrix;
			}
			if (pinchShowing) {
				pinchShowing = false;
				TweenMax.to(clip.pinch, .5, { scaleX:0, scaleY:0, ease:Back.easeIn } );
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
			var s:Number = Math.max(1 / clip.map.scaleX, .1);
			for (var i:int = 0; i < n; i++) {
				markerContainer.getChildAt(i).scaleX = markerContainer.getChildAt(i).scaleY = s;
			}
		}
		
		
		private function findClose(p:Point):void
		{
			var n:int = markerContainer.numChildren;
			var m:DisplayObject;
			var dist:Number;
			for (var i:int = 0; i < n; i++) {
				m = markerContainer.getChildAt(i);
				dist = ((p.x - m.x) * (p.x - m.x)) + ((p.y - m.y) * (p.y - m.y));	//distance squared - remove Math.sqrt() for speed ~20% faster
				if (dist < 900) {
					//30 pixels
					TweenMax.to(m, 0, { tint:0xff0000 } );
				}
			}
					
		}
		
		
		private function showInterests():void
		{
			bucketList.show();//bucketList first so it's under interests
			bucketList.hide();
			
			
			//clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, nextClicked);
			
			interests.show();
			interests.addEventListener(Interests.CHANGED, updateInterests);
			
			TweenMax.to(clip.pinch, .5, { scaleX:1, scaleY:1, delay:1, ease:Back.easeOut } );
			TweenMax.to(clip.map, 1, { alpha:1, delay:1 } );
			
			if(heartPoint.x != 0){
				if (!heartContainer.contains(heart)) {
					heartContainer.addChild(heart);
				}
				heart.x = heartPoint.x;
				heart.y = heartPoint.y;
				heart.scaleX = heart.scaleY = 1;
				heart.alpha = 0;
				TweenMax.to(heart, 1, { alpha:1, delay:1.5 } );
				TweenMax.to(heart, .5, { scaleX:1.2, scaleY:1.2, delay:2.5});
				TweenMax.to(heart, .5, { scaleX:1, scaleY:1, delay:3});				
			}
		}
		private function killHeart():void
		{
			if (heartContainer.contains(heart)) {
				heartContainer.removeChild(heart);
			}
		}
		
		
		/**
		 * called from Main.addNewInterest
		 * called by listener whenever the selected interess changes
		 * gets the current array of interest objects based on the selection
		 * @param	e
		 */
		public function updateInterests(e:Event = null):void
		{	
			tim.buttonClicked();
			
			//all the interest objects based on the selected category
			currentInterests = mapData.getInterests(interests.interest);
			
			if (currentInterests.length == 0) {
				if (!heartContainer.contains(heart)) {
					heartContainer.addChild(heart);
					heart.scaleX = heart.scaleY = 0;
					heart.alpha = 0;
					TweenMax.to(heart, .5, { scaleX:1, scaleY:1, alpha:1 } );
				}
			}else {				
				if (heartContainer.contains(heart)) {
					TweenMax.to(heart, .5, { alpha:0, scaleX:0, scaleY:0, onComplete:killHeart } );
				}
			}
			
			//remove old markers
			while (markerContainer.numChildren) {
				markerContainer.removeChildAt(0);
			}
			
			var inList:Boolean;//used for placing red icon if the interest is in the bucket list already
			var useCategory:String;
			
			for (var i:int = 0; i < currentInterests.length; i++) {				
				var a:MovieClip;				
				
				//true if the user has this item already in their bucket list
				inList = intManager.hasInterest(currentInterests[i]);
				
				if (interests.interest == "Must See") {
					
					if (currentInterests[i].cat2 == "") {
						useCategory = "Must See";
					}else {
						useCategory = currentInterests[i].cat2;
					}
					
					switch(useCategory) {
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
					
				}else{
				
					//category is not must see - just use the icon based on the  category
					//use selected category: interests.interest
					
					switch(interests.interest) {
						
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
						case "Wineries and Breweries":
							if(currentInterests[i].cat1 == "Wineries" || currentInterests[i].cat2 == "Wineries" || currentInterests[i].cat3 == "Wineries"){
								if(inList){
									a = new iconWineriesRed();
								}else {
									a = new iconWineries();
								}
							}else {
								if(inList){
									a = new iconBreweriesRed();
								}else {
									a = new iconBreweries();
								}
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
				}
				
				//inject index of this interest - used when clicking on the icon - matches index in currentInterests array
				a.interestIndex = i; 
				
				markerContainer.addChild(a);				
				a.x = currentInterests[i].x;
				a.y = currentInterests[i].y;
				
				//scale marker - matches scaling in onGesture()
				a.scaleX = a.scaleY = Math.max(1 / clip.map.scaleX, .1);			
				
				a.filters = [ds];
				a.addEventListener(MouseEvent.CLICK, interestClicked, false, 0, true);
			}
			
			//disable/enable Next
			if (intManager.interests.length > 0) {
				clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, nextClicked);
				TweenMax.to(clip.btnNext, .5, { alpha:1 } );
			}else {
				clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, nextClicked);
				TweenMax.to(clip.btnNext, .5, { alpha:.3 } );
			}
			
			bucketList.update();
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
			tim.buttonClicked();
			
			var i:int = MovieClip(e.currentTarget).interestIndex;
			currentInterest = currentInterests[i];
			dispatchEvent(new Event(INTEREST_SELECTED));			
		}
		
		
		/**
		 * Callback from pressing the next button
		 * shows email
		 * @param	e
		 */
		private function nextClicked(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, nextClicked);
			dispatchEvent(new Event(NEXT));
		}		
		
	}
	
}