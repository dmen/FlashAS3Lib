package com.gmrmarketing.sap.metlife.usmap
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.getTimer;
	import com.gmrmarketing.sap.metlife.ISchedulerMethods;
	import flare.basic.*;
	import flare.core.*;
	import flare.materials.*;
	import flare.materials.filters.*;
	import flare.system.*;
	import flare.materials.Shader3D;
	import flare.primitives.Plane;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Main extends MovieClip implements ISchedulerMethods
	{
		public static const FINISHED:String = "finished";	
		public static const MAP_READY:String = "3Dready"; 
		
		private var _scene:Scene3D;
		private var _camera:Camera3D;
		private var map:Pivot3D;
		
		private var sentiment:Array;
		private var materialRef:Shader3D;
		private var rotOb:Object;
		private var usa:Pivot3D;		
		
		private var tweetManager:TweetManager; //manages getting and displaying the text tweets
		private var textContainer:Sprite;//tweets container
		
		private var isMapLoaded:Boolean = false;
		
		private var localCache:Array;
		
		private var sceneContainer:Sprite;
		
		private var foreground:MovieClip;//titles clip from the library
		
		private var videoData:BitmapData;
		private var vidShader:Shader3D;
		private var _videoPlaneTexture:Texture3D;
		private var _videoPlaneMaterial:Shader3D;
		
		private var defaultColors:Array; //default colors before tweet colors are applied		
		private var defaultIndex:int;
		
		public function Main()
		{
			sceneContainer = new Sprite();
			
			_scene = new Scene3D(sceneContainer);
			_scene.clearColor = new Vector3D ();
			_scene.antialias = 16;			
			
			videoData = new BitmapData(1008, 567, false, 0x000000);
			
			_videoPlaneTexture = new Texture3D(videoData, true);
			_videoPlaneTexture.mipMode = Texture3D.MIP_NONE;
			
			_videoPlaneMaterial = new Shader3D("_videoPlaneMaterial", [new TextureMapFilter(_videoPlaneTexture)], false);
			_videoPlaneMaterial.twoSided = false;
			_videoPlaneMaterial.build();
			
			textContainer = new Sprite();
			
			defaultColors = new Array(0xDDDDDD, 0xEEEEEE, 0xBBBBBB, 0xCCCCCC, 0XAAAAAA, 0x999999, 0xACACAC, 0xDCDCDC);
			defaultIndex = 0;
			
			//tweetManager = new TweetManager();//gets text tweets and starts to display them in textContainer
			//tweetManager.setContainer(textContainer);
			
			addChild(sceneContainer);
			
			foreground = new titles();//lib clip
			addChild(foreground);
			
			init();
		}
		
		
		/**
		 *  ISchedulerMethods
		 * @param	initValue
		 */
		public function init(initValue:String = ""):void
		{
			_scene.resume();
			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sapmetlifeapi.thesocialtab.net/api/GameDay/GetCachedFeed?feed=NYJetsUSMapSentiment"+"&abc="+String(new Date().valueOf()));
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		/**
		 * ISchedulerMethods
		 * Returns true if localCache has data in it
		 * ie if the service has completed successfully at least once
		 * @return
		 */
		public function isReady():Boolean
		{
			return localCache != null;
		}
		
		
		//called from show
		private function loadMap():void
		{
			map = _scene.addChildFromFile("usmap.zf3d");
			_scene.addEventListener( Scene3D.COMPLETE_EVENT, mapLoaded );
		}
		
		
		private function mapLoaded(e:Event):void
		{			
			_scene.removeEventListener( Scene3D.COMPLETE_EVENT, mapLoaded );
			
			usa = _scene.getChildByName("usamap2.dae");			
			_scene.getChildByName("Plane").setMaterial(_videoPlaneMaterial);			
			_scene.forEach(setDefaultColor);//set all states to default white
			
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
		 * Sets default color and scaleZ of all the states
		 * @param	p
		 */
		private function setDefaultColor(p:Pivot3D):void
		{	
			materialRef = _scene.getMaterialByName( String(p.name).toLowerCase() ) as Shader3D;
			var t:Pivot3D = _scene.getChildByName(p.name);
			
			if (materialRef && (p.name != "Plane")) {
				materialRef.filters[0].color = defaultColors[defaultIndex];
				defaultIndex++;
				if (defaultIndex >= defaultColors.length) {
					defaultIndex = 0;
				}
				t.scaleZ = 1 + (Math.random() * 2);
			}
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			if (localCache) {
				sentiment = localCache.concat();
			}
		}
		
		
		
		/**
		 * Callback from service call in init()
		 * @param	e
		 */
		private function dataLoaded(e:Event):void
		{			
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
			
			show(); //TESTING
		}
		
		
		private function toFlorida():void
		{
			//slowly rotate map up and left - toward Cali
			TweenMax.to(rotOb, 20, {mapRotX:-105, onUpdate:setMapRotation} );			
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
				_scene.forEach(setDefaultColor);//set all states to gray
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
			//_scene.addEventListener( Scene3D.POSTRENDER_EVENT, renderEvent );
			addEventListener(Event.ENTER_FRAME, renderEvent);
			
			//tweets container
			if (!contains(textContainer)) {
				addChild(textContainer);
			}
			
			//tweetManager.refresh();
			
			for (var i:int = 0; i < sentiment.length; i++) {
				
				var t:Pivot3D = _scene.getChildByName(sentiment[i].name);
				if(t){
					TweenMax.to(t, 2, { scaleZ:sentiment[i].normalized * .75, delay:3, ease:Elastic.easeOut } );
				}
				
				//normalized value is 1.5 - 15
				materialRef = _scene.getMaterialByName( String(sentiment[i].name).toLowerCase() ) as Shader3D;
				if (materialRef) {
					if(sentiment[i].normalized < 1.7){
						materialRef.filters[0].color = 0xdefff4;
					}else if (sentiment[i].normalized < 3.4) {
						materialRef.filters[0].color = 0xc3f4e2;
					}else if (sentiment[i].normalized < 5.2) {
						materialRef.filters[0].color = 0xafe1d0;
					}else if (sentiment[i].normalized < 6.75) {
						materialRef.filters[0].color = 0x96c9b6;
					}else if (sentiment[i].normalized < 8.2) {
						materialRef.filters[0].color = 0x7aaa98;
					}else if (sentiment[i].normalized < 10) {
						materialRef.filters[0].color = 0x6a9a87;
					}else if (sentiment[i].normalized < 11.75) {
						materialRef.filters[0].color = 0x578775;
					}else {
						materialRef.filters[0].color = 0x4e8671;
					}
				}
			}
		}
		
		
		//listener is added in show2()
		private function renderEvent(e:Event):void 
		{		
			videoData.draw(theVideo);
			_videoPlaneTexture.bitmapData = videoData;
			_videoPlaneTexture.uploadTexture();			
		}
		
		
		
		/**
		 * ISChedulerMethods
		 */
		public function cleanup():void
		{
			_scene.removeEventListener( Scene3D.POSTRENDER_EVENT, renderEvent );
			_scene.pause();
		}
	}
	
}