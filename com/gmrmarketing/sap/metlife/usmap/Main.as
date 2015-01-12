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
	import flash.system.Capabilities;
	
	public class Main extends MovieClip implements ISchedulerMethods
	{
		public static const FINISHED:String = "finished";
		
		private var _scene:Scene3D;
		private var map:Pivot3D;
		
		private var materialRef:Shader3D;
		private var usa:Pivot3D;		
		
		private var tweetManager:TweetManager; //manages getting and displaying the text tweets
		private var textContainer:Sprite;//tweets container
		
		private var isMapLoaded:Boolean = false;
		
		private var localCache:Array;//state sentiment data from the service
		
		private var sceneContainer:Sprite;
		
		private var foreground:MovieClip;//titles clip from the library
		
		private var videoData:BitmapData;
		private var vidShader:Shader3D;
		private var _videoPlaneTexture:Texture3D;
		private var _videoPlaneMaterial:Shader3D;
		
		private var defaultColors:Array; //default colors before tweet colors are applied		
		private var defaultIndex:int;
		
		private var rotOb:Object; //used for tweening the map
		
		
		
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
			rotOb = new Object();
			
			defaultColors = new Array(0xDDDDDD, 0xEEEEEE, 0xBBBBBB, 0xCCCCCC, 0XAAAAAA, 0x999999, 0xACACAC, 0xDCDCDC);
			defaultIndex = 0;
			
			tweetManager = new TweetManager();//gets text tweets and starts to display them in textContainer
			tweetManager.setContainer(textContainer);
			
			addChild(sceneContainer);
			
			foreground = new titles();//lib clip
			addChild(foreground);
			
			if(CONFIG::SUITE){
				addEventListener(Event.ADDED_TO_STAGE, scaleScene);
			}
			//init();//TESTING
		}
		
		
		/**
		 * Scales the 3D scene to the monitor resolution
		 * only runs if the config constant SUITE is true
		 * @param	e
		 */
		private function scaleScene(e:Event):void
		{
			_scene.setViewport( 0, 0, Capabilities.screenResolutionX, Capabilities.screenResolutionY );
		}
		
		
		public function getFlareList():Array
		{
			var fl:Array = new Array();
			
			fl.push([180, 27, 824, "line", 5]);//x, y, to x, type, delay
			fl.push([198, 71, 682, "point", 5.5]);//x, y, to x, type, delay
			
			fl.push([283, 494, 722, "line", 8]);//x, y, to x, type, delay
			fl.push([295, 536, 709, "point", 8.3]);//x, y, to x, type, delay
			
			return fl;
		}
		
		
		/**
		 *  ISchedulerMethods
		 * Called on all tasks prior to showing any screens
		 * Only called once
		 * @param	initValue
		 */
		public function init(initValue:String = ""):void
		{
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
		 * Callback from service call in init()
		 * Populates localCache
		 * @param	e
		 */
		private function dataLoaded(e:Event):void
		{
			var json:Object = JSON.parse(e.currentTarget.data);
			localCache = new Array();
			
			//switch names to match 3d map versions
			for (var i:int = 0; i < json.length; i++) {
				if (String(json[i].name).indexOf(" ") != -1) {					
					json[i].name = String(json[i].name).replace(" ", "_");
				}
				localCache.push( { name:json[i].name, pos:json[i].pos } );
				
			}
			
			normalize();
			localCache.reverse();
			
			tweetManager.addEventListener(TweetManager.READY, dataReady);
			tweetManager.refresh();
			
			_scene.addEventListener( Scene3D.COMPLETE_EVENT, mapLoaded );
			map = _scene.addChildFromFile("usmap.zf3d");
		}
		
		
		private function dataError(e:IOErrorEvent):void { }	
		
		
		
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
		
		
		private function mapLoaded(e:Event):void
		{
			_scene.removeEventListener( Scene3D.COMPLETE_EVENT, mapLoaded );			
			usa = _scene.getChildByName("usamap2.dae");	
			
			rotOb.ox = usa.getRotation().x;//original values used in cleanup()
			rotOb.oy = usa.getRotation().y;	
			rotOb.oz = usa.getRotation().z;
			
			_scene.getChildByName("Plane").setMaterial(_videoPlaneMaterial);		
			
			//show();//TESTING
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
				//random scaleZ to get a little variation in the un-tweeted states
				t.scaleZ = 1;// + (Math.random() * 2);
			}
		}		
		
		
		private function dataReady(e:Event):void
		{
			tweetManager.removeEventListener(TweetManager.READY, dataReady);
			//tweetManager.start();
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
			
			for (var i:int = 0; i < localCache.length; i++) {				
				//normalize value using a logarithm
				localCache[i].normalized = Math.max(Math.log(localCache[i].pos), .2);
				
				if (localCache[i].normalized < min) {
					min = localCache[i].normalized;
				}
				if (localCache[i].normalized > max) {
					max = localCache[i].normalized;
				}
				
			}
			
			for (i = 0; i < localCache.length; i++) {
				localCache[i].normalized = (newRangeMax - newRangeMin) / (max - min) * (localCache[i].normalized - max) + newRangeMax;
			}
		}
		
		
		/**
		 * ISChedulerMethods
		 */		
		public function show():void
		{			
			_scene.show();
			_scene.resume();
			
			_scene.forEach(setDefaultColor);//set all states to default
			
			//reset map to default rotation
			usa.setRotation(rotOb.ox, rotOb.oy, rotOb.oz);
			
			theVideo.play();
			addEventListener(Event.ENTER_FRAME, renderEvent);//render video to 3d plane every frame
			
			//tweets container
			if (!contains(textContainer)) {
				addChild(textContainer);
			}
			tweetManager.start();
			for (var i:int = 0; i < localCache.length; i++) {
				
				var t:Pivot3D = _scene.getChildByName(localCache[i].name);
				if (t) {					
					TweenMax.to(t, 2, { scaleZ:localCache[i].normalized * .75, delay:3+i*.3, ease:Elastic.easeOut } );
				}
				
				//normalized value is 1.5 - 15
				materialRef = _scene.getMaterialByName( String(localCache[i].name).toLowerCase() ) as Shader3D;
				if (materialRef) {
					if(localCache[i].normalized < 1.7){
						materialRef.filters[0].color = 0xdefff4;
					}else if (localCache[i].normalized < 3.4) {
						materialRef.filters[0].color = 0xc3f4e2;
					}else if (localCache[i].normalized < 5.2) {
						materialRef.filters[0].color = 0xafe1d0;
					}else if (localCache[i].normalized < 6.75) {
						materialRef.filters[0].color = 0x96c9b6;
					}else if (localCache[i].normalized < 8.2) {
						materialRef.filters[0].color = 0x7aaa98;
					}else if (localCache[i].normalized < 10) {
						materialRef.filters[0].color = 0x6a9a87;
					}else if (localCache[i].normalized < 11.75) {
						materialRef.filters[0].color = 0x578775;
					}else {
						materialRef.filters[0].color = 0x4e8671;
					}
				}
			}
			
			rotOb.rotX = rotOb.ox;
			TweenMax.to(rotOb, 29, { rotX: -84, onUpdate:setMapRotation, onComplete:complete } );			
			//TweenMax.delayedCall(29, complete);
		}
		
		private function setMapRotation():void
		{
			usa.setRotation(rotOb.rotX, rotOb.oy,  rotOb.oz);
		}
		
		//listener is added in show2()
		private function renderEvent(e:Event):void 
		{	
			videoData.draw(theVideo);
			_videoPlaneTexture.bitmapData = videoData;
			if(_videoPlaneTexture.scene){
				_videoPlaneTexture.uploadTexture();
			}
		}
		
		
		private function complete():void
		{
			dispatchEvent(new Event(FINISHED));
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function cleanup():void
		{
			_scene.pause();
			_scene.hide();
			
			removeEventListener(Event.ENTER_FRAME, renderEvent);
			
			theVideo.seek(0);
			theVideo.stop();
			
			tweetManager.stop();
			tweetManager.refresh();
		}
		
	}
	
}