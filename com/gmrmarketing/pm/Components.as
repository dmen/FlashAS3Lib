package com.gmrmarketing.pm
{
	import flash.display.Loader;
	import flash.display.MovieClip;	
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.display.Bitmap;
		
	public class Components extends MovieClip	
	{
		private var myLoader:Loader; //for loading bar image
		private var compLoader:Loader; //for loading component (from clicking red target)
		private var theComponents:XML;
		private var xmlLoader:URLLoader;
		private var theVenue:String;
		private var facilityType:String;
		private var theBrand:String;
		private var loadedContent:MovieClip;
		
		public function Components()
		{
			loadedContent = new MovieClip();
			myLoader = new Loader();
			compLoader = new Loader();
			xmlLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, xmlLoaded); 
			xmlLoader.load(new URLRequest("components.xml"));
		}
		
		
		/**
		 * Called from the menuClicked() method in main.as
		 * 
		 * @param	venue
		 * @param	file
		 * @param	$facilityType aof or paof
		 * @param	$brand
		 */
		public function loadBar(venue:String, file:String, $facilityType:String, $brand:String):void
		{
			if (contains(loadedContent)) { removeChild(loadedContent);}
			theVenue = venue.toLowerCase();	
			
			facilityType = $facilityType;			
			theBrand = $brand;
			
			myLoader.load(new URLRequest(file));
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, barLoaded, false, 0, true);
			
			var comps:String = "To be an account with the Nightlife Program you must participate in the following Program components:<br/><br/><ul>";			
			
			comps += "<li>One-to-One Interactions</li><br/>";
			if (facilityType == "aof") {
				comps += "<li>Back Bar Sales</li><br/>";
			}
			comps += "<li>Temporary Visibility</li><br/>";
			if (facilityType == "aof") {
				comps += "<li>Permanent Visibility</li>";
			}
			comps += "</ul>";
			
			theText.htmlText = comps;
		}
		
		
		private function barLoaded(e:Event):void
		{
			var bit:Bitmap = e.target.content;
			if(bit != null){
				bit.smoothing = true;
			}
			myLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, barLoaded);
			addChild(myLoader);
			addHotSpots();
		}
		
		
		public function removeBar():void
		{
			if (contains(myLoader)) { removeChild(myLoader); }
		}
		
		
		private function xmlLoaded(e:Event):void
		{
			theComponents = new XML(e.target.data);			
		}
		
		
		private function addHotSpots():void
		{
			var brandComps:XMLList = theComponents.component.(brand == theBrand);
			//var theseComps:XMLList = brandComps.(facility == facilityType);
			
			for each (var comp:XML in brandComps)  {
				if(comp.facility == facilityType || comp.facility == "both"){
					var hotSpot:String = comp.coordinates.coord.(@id == theVenue);					
					var coord:Array = hotSpot.split(",");
					var targ:bullseye = new bullseye(); //library clip
					targ.x = coord[0];
					targ.y = coord[1];
					targ.file = comp.file;
					addChild(targ);
					targ.addEventListener(MouseEvent.CLICK, targetClicked, false, 0, true);
					targ.buttonMode = true;
				}
			}
		}
		
		
		private function targetClicked(e:MouseEvent):void
		{
			compLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, componentLoaded, false, 0, true);
			compLoader.load(new URLRequest(e.currentTarget.file));			
		}
		
		
		private function componentLoaded(e:Event):void
		{
			loadedContent = MovieClip(compLoader.content);
			
			addChild(loadedContent);
			loadedContent.btnClose.addEventListener(MouseEvent.CLICK, closeComponent, false, 0, true);
			loadedContent.btnClose.buttonMode = true;
		}
		
		
		private function closeComponent(e:MouseEvent):void
		{
			loadedContent.btnClose.removeEventListener(MouseEvent.CLICK, closeComponent);
			removeChild(loadedContent);
		}
		
	}
	
}