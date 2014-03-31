/**
 * document class for locations.fla / locations.swf
 * 
 * loads locations.xml
 * 
 * @author dmennenoh@gmrmarketing.com
 * 
 */

package com.gmrmarketing.website
{
	import flash.display.LoaderInfo; //for flashvars
	import flash.display.SpreadMethod;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.*;
	import flash.utils.Timer;
	import gs.TweenLite;
	import gs.easing.*;
	import gs.plugins.*;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.net.navigateToURL;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.filters.DropShadowFilter;
	import flash.external.ExternalInterface;
	

	public class Map extends MovieClip
	{
		private var xmlLoader:URLLoader = new URLLoader();
		private var theMap:map;
		private var mapXML:XML = new XML();
		private var mapLocations:XMLList;
		private var theInfo:info;
		private var infoBG:Sprite;
		private var dropShadow:DropShadowFilter;
		
		private var language:String;
		private var basePath:String;		
		private var galleryURL:String;
		private var galleryTitle:String;
		
		private var timerCheck:Timer;
		
		
		
		public function Map()
		{
			//flashvars
			if (loaderInfo.parameters.language == undefined) {
				language = "en"; //default to english
			}
			basePath = language + "/"; //prepended to image path from xml
			
			dropShadow = new DropShadowFilter(0, 0, 0x000000, .7, 6, 6);

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onStageResize);
			
			background.width = stage.stageWidth;
			background.height = stage.stageHeight;
			
			cubeLogo.addEventListener(MouseEvent.CLICK, gotoHomepage);
			cubeLogo.buttonMode = true;
		
			xmlLoader.addEventListener(Event.COMPLETE, xmlLoaded);
			xmlLoader.load(new URLRequest("locations.xml"));
			
			theMap = new map(); //library clips
			theInfo = new info();
			infoBG = new Sprite();
			theInfo.addChildAt(infoBG, 0);	
			
			//timerCheck = new Timer(3000, 1);
			//timerCheck.addEventListener(TimerEvent.TIMER, checkInfo, false, 0, true);
			
			
		}
		
		
		
		private function gotoHomepage(event:MouseEvent):void 
		{
			navigateToURL(new URLRequest("default.aspx"), "_parent");
		}
		
		
		
		private function onStageResize(event:Event = null):void
		{
			background.width = stage.stageWidth;
			background.height = stage.stageHeight;
			
			if(stage.stageWidth > theMap.width){
				theMap.x = ((stage.stageWidth - theMap.width) * .5) + (theMap.width * .5);
			}
		}
		
		
		/**
		 * Called once the locations.xml file is available
		 * 
		 * @param	e COMPLETE event
		 */
		private function xmlLoaded(e:Event):void
		{			
			xmlLoader.removeEventListener(Event.COMPLETE, xmlLoaded);
			mapXML = new XML(e.target.data);
			
			//use device fonts for chinese
			if (language == "ch") {
				theTitle.embedFonts = false;
			}
			theTitle.text = mapXML.title;			
			
			mapLocations = mapXML.location;			
			
			for each(var location:XML in mapLocations) {
				if (location.@showing == "true") {
					theMap[location.@mapmarker].alpha = 1;
					theMap[location.@mapmarker].addEventListener(MouseEvent.MOUSE_OVER, showInfo);					
				}else {
					theMap[location.@mapmarker].alpha = 0;
				}
			}
			
			theMap.alpha = 0;
			theMap.x = 516;
			theMap.y = 374;
			theMap.scaleX = theMap.scaleY = .5;
			addChild(theMap);
			
			TweenLite.to(theMap, 1, { scaleX:1, scaleY:1, alpha:1 } );
			onStageResize();
		}
		
		
		
		/**
		 * Called by mouse_over on a map marker
		 * 
		 * @param	e
		 */
		private function showInfo(e:MouseEvent):void
		{
			var cit:String = e.currentTarget.name;			
			var theInf:XMLList = mapLocations.(@mapmarker == cit);
				
			if (!contains(theInfo)) { 
				addChild(theInfo);
			}
		
			if (theInf.y > -500) {
				TweenLite.killTweensOf(theInfo);
				theInfo.alpha = 0;
			}
			
			//use device fonts for chinese
			if (language == "ch") {
				theInfo.cityName.embedFonts = false;
				theInfo.address.embedFonts = false;
			}			
			
			theInfo.cityName.htmlText = theInf.city;			
			theInfo.address.htmlText = theInf.address + "<br/>" + theInf.phone;
			theInfo.galleryButton.galleryText.htmlText = theInf.photo.@linkName;
			galleryURL = theInf.photo.@url;
			galleryTitle =  theInf.city;			
			var boxHeightAdjust:int;

			if(theInf.photo != undefined){
				trace("SHOW PHOTO " + theInf.photo)
				//theInfo.address.htmlText += "<br><a href=\""+theInf.photo.@url+"\">"+theInf.photo.@linkName+"</a>" ;
				//turn on some button here
				theInfo.galleryButton.visible = true;
				theInfo.galleryButton.buttonMode = true;
				boxHeightAdjust = theInfo.galleryButton.height + 30;
				theInfo.galleryButton.addEventListener(MouseEvent.CLICK, shadowbox_open_url,false,0,true);
			}else{
				trace("NO PHOTO")
				boxHeightAdjust = 25;
				theInfo.galleryButton.visible = false;
			}
			
			theInfo.address.y = theInfo.cityName.y + theInfo.cityName.textHeight + 10;			
				
			
			theInfo.address.autoSize = TextFieldAutoSize.LEFT;
			theInfo.cityName.autoSize = TextFieldAutoSize.LEFT;
			
			var dotLoc:Point = theMap.localToGlobal(new Point(e.currentTarget.x, e.currentTarget.y));
			
			theInfo.x = dotLoc.x;
			theInfo.y = dotLoc.y;
			theInfo.alpha = 0;
			theInfo.scaleX = theInfo.scaleY = .8;
			
			//timerCheck.start();
			
			infoBG.graphics.clear();
			infoBG.graphics.beginFill(0xFFFFFF, 1);
			infoBG.graphics.drawRoundRect(-15, -12, theInfo.address.width + 35, theInfo.address.y + theInfo.address.textHeight + boxHeightAdjust, 10);
			infoBG.filters = [dropShadow];
			
			
			TweenLite.to(theInfo, .4, { scaleX:1, scaleY:1, alpha:1, onComplete:addMouseListener} );
		}
		private function shadowbox_open_url(e:MouseEvent):void {
			// You need to call the extrnal interface in this case javascript.
			// openShadowbox is the name of the javascript function that will handle the opening of my shadowbox window.
			// BE VERY carefull openshadowbox is not the same as openShadowbox.
			// then you write the content or url path in this case, the type of file, and the title of the window.
			ExternalInterface.call("openShadowbox",galleryURL,'iframe','');
		}	
		
		private function addMouseListener():void
		{
			background.addEventListener(MouseEvent.MOUSE_MOVE, removeInfo, false, 0, true);
			theMap.addEventListener(MouseEvent.MOUSE_MOVE, removeInfo, false, 0, true);			
		}
		
		
		private function removeInfo(e:MouseEvent = null):void
		{			
			background.removeEventListener(MouseEvent.MOUSE_MOVE, removeInfo);
			theMap.removeEventListener(MouseEvent.MOUSE_MOVE, removeInfo);
			TweenLite.to(theInfo, .3, { alpha:0, scaleX:.8, scaleY:.8, onComplete:moveInfo, overwrite:0 } );			
		}
		
		private function moveInfo():void
		{
			theInfo.y = -1000;
		}
	}
}	

