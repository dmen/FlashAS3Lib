package com.gmrmarketing.sap.superbowl.gda.usmap
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
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
	
	
	public class Main extends MovieClip implements IModuleMethods
	{
		public static const FINISHED:String = "finished";
		
		private var _scene:Scene3D;
		private var _camera:Camera3D;
		private var map:Pivot3D;
		
		private var materialRef:Shader3D;
		private var defaultColors:Array;
		private var defaultIndex:int;//used to iterate defaultColors in setDefaultColor()
		private var rotOb:Object;//used for animating rotation
		private var usa:Pivot3D;
		
		private var tweetManager:TweetManager; //manages getting and displaying the text tweets
		private var textContainer:Sprite;//holds the tweet clips
		
		private var isMapLoaded:Boolean = false;
		
		private var localCache:Array; //array of objects
		
		private var sceneContainer:Sprite;
		private var sceneBMD:BitmapData;
		private var sceneImage:Bitmap;
		private var shadow:Bitmap;
		private var TESTING:Boolean = false;
		
		
		public function Main()
		{
			sceneContainer = new Sprite();
			
			_scene = new Scene3D(sceneContainer);
			_scene.clearColor = new Vector3D ();
			_scene.antialias = 16;
			
			//default coloring of all states - before sentiment colors are applied
			defaultColors = new Array(0xff8677af, 0xff6c58a6, 0xff442f80, 0xff6550a2, 0xff7d6cac, 0xff634ea2);
			defaultIndex = 0;			
			
			sceneBMD = new BitmapData(640, 896, true, 0x00000000);
			sceneImage = new Bitmap(sceneBMD);
			shadow = new Bitmap(new mapShadow());
			
			textContainer = new Sprite();
			rotOb = new Object();
			
			tweetManager = new TweetManager();//gets text tweets and starts to display them in textContainer
			tweetManager.setContainer(textContainer);
			
			addChildAt(sceneImage, 1);
			sceneImage.y = -170;
			addChildAt(shadow, 1);
			shadow.alpha = 0;
			//sceneContainer.y = -800;//3d scene off screen top
			addChild(sceneContainer);
			addChild(textContainer)//tweets
			
			team1.alpha = 0;
			team1.x = 200;
			team2.alpha = 0;
			team2.x = 600;
			
			if(TESTING){
				init();
			}
		}
		
		
		public function init(initValue:String = ""):void
		{
			refreshData();			
		}
		
		
		private function refreshData():void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sapsb49api.thesocialtab.net/api/GameDay/GetCachedFeed?feed=USMapVolumeNFC");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, nfcLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		private function nfcLoaded(e:Event):void
		{
			resetLocalCache();
			
			var json:Object = JSON.parse(e.currentTarget.data);			
			
			for (var i:int = 0; i < json.length; i++) {
				for (var j:int = 0; j < localCache.length; j++) {
					if (localCache[j].abbr == json[i].StateCode) {
						localCache[j].pos = json[i].Total;
						localCache[j].side = "nfc";
						break;
					}
				}								
			}
			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sapsb49api.thesocialtab.net/api/GameDay/GetCachedFeed?feed=USMapVolumeAFC");
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
		 * Callback from refreshData()
		 * @param	e
		 */
		private function dataLoaded(e:Event):void
		{
			var json:Object = JSON.parse(e.currentTarget.data);
			
			for (var i:int = 0; i < json.length; i++) {
				for (var j:int = 0; j < localCache.length; j++) {
					if (localCache[j].abbr == json[i].StateCode) {
						if(json[i].Total > localCache[j].pos){
							localCache[j].side = "afc";
							localCache[j].pos = json[i].Total;
						}
						break;
					}
				}								
			}
			
			normalize();
			localCache.reverse();			
			
			tweetManager.refresh();
			
			_scene.addEventListener( Scene3D.COMPLETE_EVENT, mapLoaded );
			map = _scene.addChildFromFile("usmap.zf3d");
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			resetLocalCache();
		}		
		
		
		public function isReady():Boolean
		{
			return localCache != null && usa != null;
		}
		
		
		private function mapLoaded(e:Event):void
		{
			_scene.removeEventListener( Scene3D.COMPLETE_EVENT, mapLoaded );
			usa = _scene.getChildByName("usamap2.dae");
			
			_camera = _scene.camera;
			_camera.fieldOfView = 54;
			
			//_camera.viewPort = new Rectangle(0, -800, 640, 600);
			
			rotOb.ox = usa.getRotation().x;//original values used in cleanup()
			rotOb.oy = usa.getRotation().y;	
			rotOb.oz = usa.getRotation().z;
			
			if (TESTING) {
				show();
			}
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
			
			if (materialRef) {
				materialRef.filters[0].color = defaultColors[defaultIndex];
				//trace(materialRef.filters[0].level);
				defaultIndex++;
				if (defaultIndex >= defaultColors.length) {
					defaultIndex = 0;
				}
			}
		}		
		
		
		/**
		 * Uses Math.log to first smooth the data, then does a linear
		 * distrbution between newRangeMin and newRangeMax
		 * adds a normalized key to each localCache object
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
		
		
		private function startTweets(e:Event):void
		{
			tweetManager.removeEventListener(TweetManager.READY, startTweets);
			tweetManager.start();			
		}
		
		
		public function show():void
		{			
			_scene.resume();//cleanup() calls scene.pause()			
			_scene.forEach(setDefaultColor);//set all states to default			
			sceneImage.alpha = 0;
			shadow.alpha = 0;
			
			
			
			//logo clips on stage
			team1.alpha = 0;
			team1.x = 200;
			team2.alpha = 0;
			team2.x = 600;
			
			//reset map to default rotation			
			usa.setRotation(rotOb.ox, rotOb.oy, rotOb.oz);
			
			_scene.addEventListener( Scene3D.POSTRENDER_EVENT, renderEvent );			
			for (var i:int = 0; i < localCache.length; i++) {
				
				var t:Pivot3D = _scene.getChildByName(localCache[i].long);
				if (t) {	
					if(localCache[i].normalized > 8){
						TweenMax.to(t, 2, { scaleZ:localCache[i].normalized * .6, delay:2 + i * .025, ease:Elastic.easeOut } );
					}
				}
				
				//normalized value is 1.5 - 15
				materialRef = _scene.getMaterialByName( String(localCache[i].long).toLowerCase() ) as Shader3D;
				if (materialRef) {					
					if(localCache[i].side == "nfc"){
						materialRef.filters[0].color = 0x497428;//seahawksgreen
					}else {
						materialRef.filters[0].color = 0x001b3c;//patriots blue
					}
				}
			}
			
			TweenMax.to(team1, .5, { x:343, delay:2, alpha:1, ease:Back.easeOut } );
			TweenMax.to(team2, .5, { x:437, delay:2.1, alpha:1, ease:Back.easeOut } );
			TweenMax.delayedCall(4.5, pauseScene);
			//_scene.pause();
			rotOb.rotX = rotOb.ox;
			//TweenMax.to(rotOb, 29, { rotX: -84, onUpdate:setMapRotation } );// , onComplete:complete } );	
		}
		private function pauseScene():void
		{
			if(tweetManager.isReady()){
				tweetManager.start();
			}else {
				tweetManager.addEventListener(TweetManager.READY, startTweets, false, 0, true);
			}
			tweetManager.addEventListener(TweetManager.FINISHED, complete);
			_scene.pause();
		}
		
		private function setMapRotation():void
		{
			usa.setRotation(rotOb.rotX, rotOb.oy,  rotOb.oz);
		}		
		
		
		private function renderEvent(e:Event):void 
		{			
			//trace(_scene.viewPort);
			// if you want to draw with alpha.
			_scene.clearColor.setTo( 0, 0, 0 );
			_scene.clearColor.w = 0;
			//_scene.render();
			// render to bitmap data.
			_scene.context.drawToBitmapData( sceneBMD );
			_scene.context.clear();
			if (sceneImage.alpha < 1) {
				sceneImage.alpha += .03;
				shadow.alpha += .018;
			}else {
				sceneImage.alpha = 1;
				shadow.alpha = .6;
			}			
		}
		
		
		/**
		 * Callback for tweetManager finished listener
		 * added in show()
		 */
		private function complete(e:Event):void
		{
			tweetManager.removeEventListener(TweetManager.FINISHED, complete);
			dispatchEvent(new Event(FINISHED));//to player
		}
		
		
		public function cleanup():void
		{
			tweetManager.stop();
			tweetManager.refresh();
			
			_scene.removeEventListener( Scene3D.POSTRENDER_EVENT, renderEvent );
			_scene.pause();
			
			team1.alpha = 0;
			team1.x = 200;
			team2.alpha = 0;
			team2.x = 600;
			
			shadow.alpha = 0;
			
			sceneBMD.fillRect(sceneBMD.rect, 0);
		}
		
		
		private function resetLocalCache():void
		{
			//reset localCache
			//abbr for data from service, long matches name in 3d map, side is for afc or nfc whichever has the max value
			localCache = new Array( { abbr:"AL", long:"Alabama", pos:0, side:"" }, { abbr:"AK", long:"Alaska", pos:0, side:"" }, { abbr:"AZ", long:"Arizona", pos:0, side:"" }, { abbr:"AR", long:"Arkansas", pos:0, side:"" }, { abbr:"CA", long:"California", pos:0, side:"" }, { abbr:"CO", long:"Colorado", pos:0, side:"" }, { abbr:"CT", long:"Connecticut", pos:0, side:"" }, { abbr:"DE", long:"Delaware", pos:0, side:"" }, { abbr:"FL", long:"Florida", pos:0, side:"" }, { abbr:"GA", long:"Georgia", pos:0, side:"" }, { abbr:"HI", long:"Hawaii", pos:0, side:"" }, { abbr:"ID", long:"Idaho", pos:0, side:"" }, { abbr:"IL", long:"Illinois", pos:0, side:"" }, { abbr:"IN", long:"Indiana", pos:0, side:"" }, { abbr:"IA", long:"Iowa", pos:0, side:"" }, { abbr:"KS", long:"Kansas", pos:0, side:"" }, { abbr:"KY", long:"Kentucky", pos:0, side:"" }, { abbr:"LA", long:"Louisiana", pos:0, side:"" }, { abbr:"ME", long:"Maine", pos:0, side:"" }, { abbr:"MD", long:"Maryland", pos:0, side:"" }, { abbr:"MA", long:"Massachusetts", pos:0, side:"" }, { abbr:"MI", long:"Michigan", pos:0, side:"" }, { abbr:"MN", long:"Minnesota", pos:0, side:"" }, { abbr:"MS", long:"Mississippi", pos:0, side:"" }, { abbr:"MO", long:"Missouri", pos:0, side:"" }, { abbr:"MT", long:"Montana", pos:0, side:"" }, { abbr:"NE", long:"Nebraska", pos:0, side:"" }, { abbr:"NV", long:"Nevada", pos:0, side:"" }, { abbr:"NH", long:"New_Hampshire", pos:0, side:"" }, { abbr:"NJ", long:"New_Jersey", pos:0, side:"" }, { abbr:"NM", long:"New_Mexico", pos:0, side:"" }, { abbr:"NY", long:"New_York", pos:0, side:"" }, { abbr:"NC", long:"North_Carolina", pos:0, side:"" }, { abbr:"ND", long:"North_Dakota", pos:0, side:"" }, { abbr:"OH", long:"Ohio", pos:0, side:"" }, { abbr:"OK", long:"Oklahoma", pos:0, side:"" }, { abbr:"OR", long:"Oregon", pos:0, side:"" }, { abbr:"PA", long:"Pennsylvania", pos:0, side:"" }, { abbr:"RI", long:"Rhode_Island", pos:0, side:"" }, { abbr:"SC", long:"South_Carolina", pos:0, side:"" }, { abbr:"SD", long:"South_Dakota", pos:0, side:"" }, { abbr:"TN", long:"Tennessee", pos:0, side:"" }, { abbr:"TX", long:"Texas", pos:0, side:"" }, { abbr:"UT", long:"Utah", pos:0, side:"" }, { abbr:"VT", long:"Vermont", pos:0, side:"" }, { abbr:"VA", long:"Virginia", pos:0, side:"" }, { abbr:"WA", long:"Washington", pos:0, side:"" }, { abbr:"WV", long:"West_Virginia", pos:0, side:"" }, { abbr:"WI", long:"Wisconsin", pos:0, side:"" }, { abbr:"WY", long:"Wyoming", pos:0, side:"" } );
		}
	}	
}