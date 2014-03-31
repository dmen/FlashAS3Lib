package com.gmrmarketing.nissan.next
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.display.Loader;
	import flash.events.MouseEvent;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class ThreeModels extends EventDispatcher
	{
		public static const CAR_CLICKED:String = "carClicked";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var threeCars:Array;
		private var fleetXML:XML;
		private var currentIndex:int;
		private var aCar:XMLList;
		private var loader:Loader;
		private var theCars:Array;
		private var carID:String;
		
		
		public function ThreeModels()
		{
			clip = new threeCarClip(); //lib clip
			theCars = new Array();
		}
		
		
		/**
		 * Called from Main.whichCarDoneCalculating()
		 * @param	$container
		 * @param	threeCars - subArray containing difference value and car id
		 * @param	$fleetXML - all cars
		 */
		public function show($container:DisplayObjectContainer, $threeCars:Array, $fleetXML:XML):void
		{
			container = $container;
			threeCars = $threeCars;
			fleetXML = $fleetXML;
			
			clip.alpha = 0;
			container.addChild(clip);
			TweenMax.to(clip, .5, { alpha:1 } );
			
			currentIndex = 0;
			carID = "";
			theCars = new Array();
			getNextCar();
		}
	
		
		public function hide():void
		{
			TweenMax.to(clip, .75, { alpha:0, onComplete:kill } );
			
			for (var i:int = 0; i < theCars.length; i++) {
				TweenMax.to(theCars[i], .5, { alpha:0 } );
			}
		}
		
		
		private function kill():void
		{
			if(container){
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
			}
			var sp:MovieClip;
			while (theCars.length) {
				sp = theCars.splice(0, 1)[0]; //movieClip container
				while (sp.numChildren) {
					sp.removeChildAt(0);
				}
				if (container.contains(sp)) {
					container.removeChild(sp);
				}
			}
			theCars = new Array();
			if(loader){				
				loader.unload();
			}
		}
		
		
		
		private function getNextCar():void
		{
			if(currentIndex < threeCars.length){
				aCar = fleetXML.cars.car.(id == threeCars[currentIndex][1]);
				
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, carLoaded, false, 0, true);
				loader.load(new URLRequest("picassets/" + aCar.frontPic));				
			}
		}
		
		
		private function carLoaded(e:Event):void
		{
			var m:Bitmap = Bitmap(loader.content);
			m.smoothing = true;	
			m.y = 220;			
			m.x = 0;
			
			var circ:MovieClip = new threeCarCircle(); //library clip
			circ.modelName.htmlText = String(aCar.model).toUpperCase();
			circ.details.y = circ.modelName.y + circ.modelName.textHeight + 4;
			circ.x = 360;
			circ.y = 546;
			circ.scaleX = circ.scaleY = .8;
			
			var sp:MovieClip = new MovieClip();			
			
			sp.addChild(m);
			sp.addChild(circ);
			sp.id = threeCars[currentIndex][1];
			container.addChild(sp);
			
			theCars.push(sp);
			
			//439 is width of car front pic
			TweenMax.to(sp, .5, { x:12 + (439 * currentIndex), ease:Back.easeOut, onComplete:getNextCar } );
			
			sp.addEventListener(MouseEvent.MOUSE_DOWN, modelClicked, false, 0, true);
			
			currentIndex++;			
		}
		
		
		
		private function modelClicked(e:MouseEvent):void
		{
			carID = e.currentTarget.id;
			dispatchEvent(new Event(CAR_CLICKED));			
		}
		
		
		public function getCarId():String
		{
			return carID;
		}
	}
	
}