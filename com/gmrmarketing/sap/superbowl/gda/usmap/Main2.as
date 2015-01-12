package com.gmrmarketing.sap.superbowl.gda.usmap
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.net.*;
	import com.gmrmarketing.sap.superbowl.gda.IModuleMethods
	import flare.basic.Scene3D;
	import flare.core.*;
	import flare.materials.Shader3D;
	import flare.materials.filters.TextureMapFilter;
	import flare.primitives.Plane;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Main2 extends MovieClip implements IModuleMethods
	{
		public static const READY:String = "ready"; //scheduler requires the READY event to be the string "ready"			
		public static const MAP_READY:String = "3Dready"; 
		
		private var _scene:Scene3D;
		private var _camera:Camera3D;
		private var map:Pivot3D;
		
		private var sentiment:Array;
		private var materialRef:Shader3D;
		private var grays:Array;
		private var grayIndex:int;
		private var rotOb:Object;
		private var usa:Pivot3D;
		
		private var stateGray:Array;
		private var stateGrayIndex:int;
		
		private var tweetManager:TweetManager; //manages getting and displaying the text tweets
		private var textContainer:Sprite;
		
		private var isMapLoaded:Boolean = false;
		
		private var localCache:Array;
		
		private var sceneContainer:Sprite;
		private var sceneBMD:BitmapData;
		private var sceneImage:Bitmap;
		
		public function Main2()
		{
			sceneContainer = new Sprite();
			
			_scene = new Scene3D(sceneContainer);
			_scene.clearColor = new Vector3D ();
			//_scene.setViewport(0, -800, 768, 512);
			_scene.antialias = 8;
			//_scene.pause();			
			
			//default coloring of all states - before sentiment colors are applied
			grays = new Array(0xff8677af, 0xff6c58a6, 0xff442f80, 0xff6550a2, 0xff7d6cac, 0xff634ea2);
			
			//SAP grays - for the low value states so grays don't match each other
			stateGray = new Array(0xaaaaaa, 0xbbbbbb, 0xcccccc, 0xdddddd, 0xeeeeee);
			
			sceneBMD = new BitmapData(640, 600, true, 0x00000000);
			sceneImage = new Bitmap(sceneBMD);
			
			textContainer = new Sprite();
			
			tweetManager = new TweetManager();//gets text tweets and starts to display them in textContainer
			tweetManager.setContainer(textContainer);
			
			addChild(sceneImage);
			sceneContainer.y = -800;//3d scene off screen top
			addChild(sceneContainer);
			
			//init();
		}
		
		
		public function init(initValue:String = ""):void
		{
			sceneImage.alpha = 0;
			_scene.resume();
			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/netbase/GameDayAnalytics?data=USMapSentiment"+"&abc="+String(new Date().valueOf()));
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		//called from show
		private function loadMap():void
		{
			map = _scene.addChildFromFile("usmap.zf3d");
			_scene.addEventListener( Scene3D.COMPLETE_EVENT, mapLoaded );
		}
		public function isReady():Boolean
		{
			return localCache != null;
		}
		
		private function mapLoaded(e:Event):void
		{
			_scene.removeEventListener( Scene3D.COMPLETE_EVENT, mapLoaded );
			usa = _scene.getChildByName("usamap2.dae");
			
			grayIndex = 0;
			_scene.forEach(setDefaultColor);//set all states to a range of grays and scaleZ of 1
			
			//_scene.camera.fieldOfView = 65;
			//_scene.camera.setRotation(59.19, 10, 1.78);
			rotOb = new Object();
			rotOb.mapRotXo = usa.getRotation().x;//original map rotation values - used in kill
			rotOb.mapRotYo = usa.getRotation().y;	
			rotOb.mapRotZo = usa.getRotation().z;
			
			rotOb.mapRotX = usa.getRotation().x;//used for tweening
			rotOb.mapRotY = usa.getRotation().y;	
			rotOb.mapRotZ = usa.getRotation().z;
			
			isMapLoaded = true;
			dispatchEvent(new Event(MAP_READY));
			show2();
		}
		
		/**
		 * forEach call from mapLoaded()
		 * sets the default scale and color for each state
		 * @param	p
		 */
		private function setDefaultColor(p:Pivot3D):void
		{
			//if(String(p.name).toLowerCase() != "plane"){
				p.scaleZ = 1;
			//}
			materialRef = _scene.getMaterialByName( String(p.name).toLowerCase() ) as Shader3D;
			if(materialRef){
				materialRef.filters[0].color = grays[grayIndex];
				grayIndex++;
				if (grayIndex >= grays.length) {
					grayIndex = 0;
				}
			}
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			if (localCache) {
				sentiment = localCache.concat();
				dispatchEvent(new Event(READY));//will call show() 
			}
		}
		
		
		
		/**
		 * Called once the call to USMapSentiment has processed
		 * @param	e
		 */
		private function dataLoaded(e:Event):void
		{
			stateGrayIndex = 0;
			
			var json:Object = JSON.parse(e.currentTarget.data);
			sentiment = new Array();
			
			//switch names to match 3d map versions
			for (var i:int = 0; i < json.length; i++) {
				if (String(json[i].name).indexOf(" ") != -1) {					
					json[i].name = String(json[i].name).replace(" ", "_");
				}
				sentiment.push( { name:json[i].name, pos:json[i].pos } );
				
			}
			
			normalize();
			sentiment.reverse();
			
			localCache = sentiment.concat();
			
			//show(); //TESTING
			dispatchEvent(new Event(READY));//will call show() 
		}
		
		
		private function toFlorida():void
		{
			//slowly rotate map up and left - toward Cali
			TweenMax.to(rotOb, 20, {mapRotX:-105, onUpdate:setMapRotation} );
			//TweenMax.to(_scene.camera, 25, { fieldOfView:65} );	
		}
		
		
		private function setMapRotation():void
		{
			usa.setRotation(rotOb.mapRotX, rotOb.mapRotY,  rotOb.mapRotZ);
		}
		
		
			
			
		
		/**
		 * Uses Math.log to first smooth the data, then does a linear
		 * distrbution between newRangeMin and newRangeMax
		 */
		private function normalize():void
		{
			var newRangeMin:Number = 1.5;
			var newRangeMax:Number = 15;
			
			var min:int = 500;
			var max:int = 0;
			
			for (var i:int = 0; i < sentiment.length; i++) {				
				//normalize value using a logarithm
				sentiment[i].normalized = Math.max(Math.log(sentiment[i].pos), .2);
				
				if (sentiment[i].normalized < min) {
					min = sentiment[i].normalized;
				}
				if (sentiment[i].normalized > max) {
					max = sentiment[i].normalized;
				}
				
			}
			
			for (i = 0; i < sentiment.length; i++) {
				sentiment[i].normalized = (newRangeMax - newRangeMin) / (max - min) * (sentiment[i].normalized - max) + newRangeMax;
			}
		}
		
		
		/**
		 * Call with a forEach to iterate the objects contained in the Pivot3D object
		 * use like: _scene.forEach(doTrace);
		 * 
		 * @param	p
		 */
		private function doTrace(p:Pivot3D):void
		{
			trace(p.name);
		}		
		
		
		/**
		 * ISChedulerMethods
		 * Called once READY is dispatched
		 */
		public function show():void
		{
			if (!isMapLoaded) {
				//first time through
				loadMap();
			}else {				
				_scene.forEach(setDefaultColor);//set all states to a range of grays and scaleZ of 1
				rotOb.mapRotX = rotOb.mapRotXo;
				rotOb.mapRotY = rotOb.mapRotYo;	
				rotOb.mapRotZ = rotOb.mapRotZo;
				usa.setRotation(rotOb.mapRotXo, rotOb.mapRotYo, rotOb.mapRotZo );//reset map rotation
				dispatchEvent(new Event(MAP_READY));
				show2();
			}
		}
		
		
		//called from mapLoaded()
		private function show2():void
		{
			_scene.addEventListener( Scene3D.POSTRENDER_EVENT, renderEvent );
			//addEventListener(Event.ENTER_FRAME, renderEvent);
			
			if (!contains(textContainer)) {
				addChild(textContainer);
			}
			
			tweetManager.refresh();
			
			for (var i:int = 0; i < sentiment.length; i++) {
				
				var t:Pivot3D = _scene.getChildByName(sentiment[i].name);
				if(t){
					TweenMax.to(t, 1, { scaleZ:sentiment[i].normalized, delay:.5 * i, ease:Bounce.easeOut } );
				}
				
				materialRef = _scene.getMaterialByName( String(sentiment[i].name).toLowerCase() ) as Shader3D;
				if (materialRef) {
					if(sentiment[i].normalized < 4){
						materialRef.filters[0].color = stateGray[stateGrayIndex];//gray
						stateGrayIndex++;
						if (stateGrayIndex >= stateGray.length) {
							stateGrayIndex = 0;
						}
					}else if (sentiment[i].normalized < 9) {
						materialRef.filters[0].color = 0xeeb400;//orange
					}else {
						materialRef.filters[0].color = 0x008fd3;//blue
					}
				}
			}			
			
			//slowly rotate map up and left - toward Cali
			TweenMax.to(rotOb, 21, { mapRotX: -115, mapRotY:-10, onUpdate:setMapRotation, onComplete:toFlorida} );
			//TweenMax.to(_scene.camera, 22, { z:70} );			
		}
		
		
		//listener is added in show2()
		private function renderEvent(e:Event):void 
		{			
			// if you want to draw with alpha.
			_scene.clearColor.setTo( 0, 0, 0 );
			_scene.clearColor.w = 0;
			//_scene.render();
			// render to bitmap data.
			_scene.context.drawToBitmapData( sceneBMD );
			
			if (sceneImage.alpha < 1) {
				sceneImage.alpha += .03;
			}else {
				sceneImage.alpha = 1;
			}			
		}
		
		
		
		
		
		
		public function cleanup():void
		{
			tweetManager.stop();
			tweetManager.refresh();
			_scene.removeEventListener( Scene3D.POSTRENDER_EVENT, renderEvent );
			_scene.pause();
		}
	}
	
}