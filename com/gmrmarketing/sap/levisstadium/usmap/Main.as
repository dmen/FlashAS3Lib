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
		
		
		public function Main()
		{
			_scene = new Scene3D(this);
			//_scene.setViewport(0, 0, 1280,720);
			_scene.antialias = 8;
			//_scene.pause();
			
			grays = new Array(0x181818, 0x222222, 0x333333, 0x404040, 0x4a4a4a);
			stateGray = new Array(0xaaaaaa, 0xbbbbbb, 0xcccccc, 0xdddddd, 0xeeeeee);
			
			videoData = new BitmapData(768, 512, false, 0x000000);
			
			_videoPlaneTexture = new Texture3D(videoData, true);
			_videoPlaneTexture.mipMode = Texture3D.MIP_NONE;
			
			_videoPlaneMaterial = new Shader3D("_videoPlaneMaterial", [new TextureMapFilter(_videoPlaneTexture)], false);
			_videoPlaneMaterial.twoSided = false;
			_videoPlaneMaterial.build();
			
			map = _scene.addChildFromFile("usmap4.zf3d");
			_scene.addEventListener( Scene3D.COMPLETE_EVENT, mapLoaded );
		}
		
		
		private function mapLoaded(e:Event):void
		{		
			usa = _scene.getChildByName("usamap2.dae");
			_scene.getChildByName("Plane").setMaterial(_videoPlaneMaterial);
			
			grayIndex = 0;
			_scene.forEach(setDefaultColor);
			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/netbase/GameDayAnalytics?data=USMapSentiment");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
			
			//_scene.camera.fieldOfView = 65;
			//_scene.camera.setRotation(59.19, 10, 1.78);
			rotOb = new Object();			
			rotOb.rotX = _scene.camera.getRotation().x;
			rotOb.rotY = _scene.camera.getRotation().y;
			rotOb.rotZ = _scene.camera.getRotation().z;
			rotOb.mapRotX = usa.getRotation().x;
			rotOb.mapRotY = usa.getRotation().y;	
			rotOb.mapRotZ = usa.getRotation().z	
		}
		
		
		private function setDefaultColor(p:Pivot3D):void
		{
			materialRef = _scene.getMaterialByName( String(p.name).toLowerCase() ) as Shader3D;
			if(materialRef){
				materialRef.filters[0].color = grays[grayIndex];
				grayIndex++;
				if (grayIndex >= grays.length) {
					grayIndex = 0;
				}
			}
		}
		
		
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
			
			for (i = 0; i < sentiment.length; i++) {
				var t:Pivot3D = _scene.getChildByName(sentiment[i].name);
				TweenMax.to(t, 1, { scaleZ:sentiment[i].normalized, delay:.5 * i, ease:Bounce.easeOut } );
				
				materialRef = _scene.getMaterialByName( String(sentiment[i].name).toLowerCase() ) as Shader3D;
				if (materialRef) {
					if(sentiment[i].normalized < 6){
						materialRef.filters[0].color = stateGray[stateGrayIndex];//gray
						stateGrayIndex++;
						if (stateGrayIndex >= stateGray.length) {
							stateGrayIndex = 0;
						}
					}else if (sentiment[i].normalized < 13) {
						materialRef.filters[0].color = 0xeeb400;//orange
					}else {
						materialRef.filters[0].color = 0x008fd3;//blue
					}
				}
			}
			
			
			addEventListener(Event.ENTER_FRAME, videoUpdate, false, 0, true);
			
			//slowly rotate map up and left - toward Cali
			TweenMax.to(rotOb, 15, { mapRotX: -115, mapRotY:-10, onUpdate:setMapRotation, onComplete:toFlorida} );
			//TweenMax.to(_scene.camera, 22, { fieldOfView:70} );			
		}
		
		private function toFlorida():void
		{
			//slowly rotate map up and left - toward Cali
			TweenMax.to(rotOb, 20, {mapRotX:-100, mapRotY:5, onUpdate:setMapRotation} );
			//TweenMax.to(_scene.camera, 25, { fieldOfView:65} );	
		}
		
		private function setMapRotation():void
		{
			usa.setRotation(rotOb.mapRotX, rotOb.mapRotY,  rotOb.mapRotZ);
		}
		/*
		private function setCameraRotation():void
		{
			_scene.camera.setRotation(rotOb.rotX, rotOb.rotY, rotOb.rotZ);
		}
		*/
		
		
		
		public function videoUpdate(e:Event):void
		{
			videoData.draw(vid);
			_videoPlaneTexture.bitmapData = videoData;
			_videoPlaneTexture.uploadTexture();
		}
		
		/*
			var b:BitmapData = new BitmapData(64, 64, false, color);
			var t:Texture3D = new Texture3D();
			t.bitmapData = b;
			maskShader.filters[0].texture = t;
		*/
		
		/**
		 * Uses Math.log to first smooth the data, then does a linear
		 * distrbution between newRangeMin and newRangeMax
		 */
		private function normalize():void
		{
			var newRangeMin:Number = 2;
			var newRangeMax:Number = 20;
			
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
		 */
		public function setConfig(config:String):void
		{
			
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function show():void
		{
		
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function hide():void
		{
			
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function doStop():void
		{
			
		}
	}
	
}