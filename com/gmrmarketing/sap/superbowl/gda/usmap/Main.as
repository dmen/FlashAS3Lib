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
		
		private var localCache:Array;
		
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
		
		
		/**
		 * Callback from refreshData()
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
			
			tweetManager.refresh();
			
			_scene.addEventListener( Scene3D.COMPLETE_EVENT, mapLoaded );
			map = _scene.addChildFromFile("usmap.zf3d");
		}
		
		
		private function dataError(e:IOErrorEvent):void{}		
		
		
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
				defaultIndex++;
				if (defaultIndex >= defaultColors.length) {
					defaultIndex = 0;
				}
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
			
			if(tweetManager.isReady()){
				tweetManager.start();
			}else {
				tweetManager.addEventListener(TweetManager.READY, startTweets, false, 0, true);
			}
			tweetManager.addEventListener(TweetManager.FINISHED, complete);
			
			//logo clips on stage
			team1.alpha = 0;
			team1.x = 200;
			team2.alpha = 0;
			team2.x = 600;
			
			//reset map to default rotation
			usa.setRotation(rotOb.ox, rotOb.oy, rotOb.oz);
			
			_scene.addEventListener( Scene3D.POSTRENDER_EVENT, renderEvent );			
			for (var i:int = 0; i < localCache.length; i++) {
				
				var t:Pivot3D = _scene.getChildByName(localCache[i].name);
				if (t) {					
					TweenMax.to(t, 2, { scaleZ:localCache[i].normalized * .6, delay:3+i*.35, ease:Elastic.easeOut } );
				}
				
				//normalized value is 1.5 - 15
				materialRef = _scene.getMaterialByName( String(localCache[i].name).toLowerCase() ) as Shader3D;
				if (materialRef) {					
					if(localCache[i].normalized < 8){
						materialRef.filters[0].color = 0xff2e5033;
					}else {
						materialRef.filters[0].color = 0xff1b3257;
					}
				}
			}
			
			TweenMax.to(team1, .5, { x:343, delay:2, alpha:1, ease:Back.easeOut } );
			TweenMax.to(team2, .5, { x:437, delay:2.1, alpha:1, ease:Back.easeOut } );
			
			rotOb.rotX = rotOb.ox;
			TweenMax.to(rotOb, 29, { rotX: -84, onUpdate:setMapRotation } );// , onComplete:complete } );	
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
		private function complete():void
		{
			tweetManager.removeEventListener(TweetManager.FINISHED, complete);
			dispatchEvent(new Event(FINISHED));//to player
		}
		
		
		public function cleanup():void
		{
			_scene.pause();

			tweetManager.stop();
			tweetManager.refresh();
			
			_scene.removeEventListener( Scene3D.POSTRENDER_EVENT, renderEvent );
			_scene.pause();
		}
	}	
}