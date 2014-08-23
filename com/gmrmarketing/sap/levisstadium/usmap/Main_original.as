package com.gmrmarketing.sap.levisstadium.usmap
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.net.*;
	import com.gmrmarketing.sap.levisstadium.ISchedulerMethods;
	import flare.basic.Scene3D;
	import flare.core.*;
	import flare.materials.Shader3D;
	import flare.materials.filters.TextureMapFilter;
	import flare.primitives.Plane;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Main extends MovieClip implements ISchedulerMethods
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
		
		private var videoData:BitmapData;
		private var vidShader:Shader3D;
		private var _videoPlaneTexture : Texture3D;
		private var _videoPlaneMaterial : Shader3D;
		
		private var stateGray:Array;
		private var stateGrayIndex:int;
		
		private var tweetManager:TweetManager; //manages getting and displaying the text tweets
		private var textContainer:Sprite;
		
		private var isMapLoaded:Boolean = false;
		private var image3D:Bitmap;
		
		private var localCache:Array;
		
		
		public function Main()
		{
			_scene = new Scene3D(this);
			_scene.clearColor = new Vector3D ();
			//_scene.setViewport(0, 0, 1280,720);
			_scene.antialias = 8;
			//_scene.pause();
			
			//default coloring of all states - before sentiment colors are applied
			grays = new Array(0x141414, 0x181818, 0x202020, 0x242424, 0x282828, 0x303030, 0x343434, 0x383838, 0x404040, 0x484848, 0x505050, 0x585858, 0x606060, 0x686868);
			
			//SAP grays - for the low value states so grays don't match each other
			stateGray = new Array(0xaaaaaa, 0xbbbbbb, 0xcccccc, 0xdddddd, 0xeeeeee);
			
			videoData = new BitmapData(768, 512, false, 0x000000);
			
			_videoPlaneTexture = new Texture3D(videoData, true);
			_videoPlaneTexture.mipMode = Texture3D.MIP_NONE;
			
			_videoPlaneMaterial = new Shader3D("_videoPlaneMaterial", [new TextureMapFilter(_videoPlaneTexture)], false);
			_videoPlaneMaterial.twoSided = false;
			_videoPlaneMaterial.build();
			
			textContainer = new Sprite();
			
			tweetManager = new TweetManager();//gets text tweets and starts to display them in textContainer
			tweetManager.setContainer(textContainer);
		}
		
		
		public function init(initValue:String = ""):void
		{
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
			map = _scene.addChildFromFile("usmap4.zf3d");
			_scene.addEventListener( Scene3D.COMPLETE_EVENT, mapLoaded );
		}
		
		private function mapLoaded(e:Event):void
		{					
			_scene.removeEventListener( Scene3D.COMPLETE_EVENT, mapLoaded );
			usa = _scene.getChildByName("usamap2.dae");
			_scene.getChildByName("Plane").setMaterial(_videoPlaneMaterial);
			
			grayIndex = 0;
			_scene.forEach(setDefaultColor);//set all states to a range of grays and scaleZ of 1
			
			//_scene.camera.fieldOfView = 65;
			//_scene.camera.setRotation(59.19, 10, 1.78);
			rotOb = new Object();
			rotOb.mapRotXo = usa.getRotation().x;//original map rotation values - used in kill
			rotOb.mapRotYo = usa.getRotation().y;	
			rotOb.mapRotZo = usa.getRotation().z;
			rotOb.mapRotX = usa.getRotation().x;
			rotOb.mapRotY = usa.getRotation().y;	
			rotOb.mapRotZ = usa.getRotation().z;
			
			isMapLoaded = true;
			dispatchEvent(new Event(MAP_READY));
			show2();
		}
		
		
		private function setDefaultColor(p:Pivot3D):void
		{
			if(String(p.name).toLowerCase() != "plane"){
				p.scaleZ = 1;
			}
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
		
		
		public function videoUpdate(vid:*):void
		{
			if(isMapLoaded){
				videoData.draw(vid);
				_videoPlaneTexture.bitmapData = videoData;
				_videoPlaneTexture.uploadTexture();
			}
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
			if(!isMapLoaded){
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
		
		
		/**
		 * ISChedulerMethods
		 */
		public function hide():void
		{
			
		}
		
		
		/**
		 * ISChedulerMethods
		 * called right before task is animated off stage
		 * makes a bitmap of the stage so the map and can slide off instead of just disappearing
		 */
		public function doStop():void
		{			
			removeEventListener(Event.ENTER_FRAME, videoUpdate);
			
			var bmd:BitmapData = new BitmapData(768, 512, false, 0x000000);
			_scene.context.clear();
			_scene.render();
			_scene.context.drawToBitmapData( bmd );
			image3D = new Bitmap(bmd);
			
			addChildAt(image3D, 0);
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function kill():void
		{
			tweetManager.kill();
			//videoData.dispose();
			removeChild(image3D);
			image3D.bitmapData.dispose();
			image3D = null;
			//_videoPlaneMaterial.dispose();
		}
	}
	
}