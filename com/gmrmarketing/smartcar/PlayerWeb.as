package com.gmrmarketing.smartcar
{	
	import com.gmrmarketing.speed.Controls;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import away3d.animators.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.primitives.*;
	import away3d.materials.*;
	import away3d.core.utils.Cast;
	import away3d.cameras.*;
	import away3d.loaders.*;
	import away3d.lights.*;
	import away3d.core.render.Renderer;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import away3d.events.Loader3DEvent;
	import away3d.loaders.data.GeometryData;
	import away3d.loaders.data.MaterialData;
	import away3d.loaders.utils.MaterialLibrary;
	import flash.geom.*;	
	import flash.net.URLLoader;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.media.SoundChannel;	
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.display.MovieClip;
	import com.gmrmarketing.website.VPlayer;
	import flash.display.StageDisplayState;
	import flash.system.LoaderContext;
	import flash.ui.Mouse;
	
	public class PlayerWeb extends MovieClip
	{
		private var bassChannel:SoundChannel;
		private var drumChannel:SoundChannel;
		private var guitarChannel:SoundChannel;
		private var synthChannel:SoundChannel;
		
		private var player:VPlayer;
		
		private var appliedMap:BitmapData; //the composed final texture applied to the car
		
		private var view:View3D;
		private var myScene:Scene3D;
		private var camera:Camera3D;
		private var meshContainer:ObjectContainer3D;
		private var mat:PhongBitmapMaterial;	
		private var car:Loader3D;
		
		private var carBody:Object3D;
		private var flWheel:Object3D;
		private var frWheel:Object3D;
		private var blWheel:Object3D;
		private var brWheel:Object3D;
		
		//for loading the user created car texture
		private var texLoader:Loader;
		private var texURL:String;
		
		private var control:MovieClip;
		private var aStart:Object;
		private var aEnd:Object;
		
		private var controlMode:Boolean = false;
		private var audioSelection:Array;
		private var vol:SoundTransform;
			
		private var vidList:XMLList;
		private var loader:URLLoader;
		private var currentIndex:int; //set to -1 in fileLoaded()
		private var vid:String;; //url to the bg video - set in playNextVideo()		
		private var meshLoaded:Boolean = false;
		private var meshPercent:Number;
		private var texturePercent:Number; //0-1 percentage of texture downloaded
		
		private var theLabel:MovieClip;
		
		
		
		public function PlayerWeb()
		{
			texLoader = new Loader();
			loader = new URLLoader();
			
			player = new VPlayer(5);
			player.autoSizeOff();
			player.showVideo(this);
			player.setVidSize( { width:1280, height:720 } );
			
			theLabel = new nameLabel(); //library clip
			theLabel.x = 22;
			theLabel.y = 595;
			theLabel.alpha = .6;
			
			//final map applied to car - matches base map dimensions
			appliedMap = new BitmapData(1500, 1500);			
			
			camera = new Camera3D({zoom:37, focus:30, x:0, y:45, z:-83});
			camera.lookAt(new Vector3D(0, 0, 0));			
			
			myScene = new Scene3D();
			view = new View3D( { scene:myScene, camera:camera } );
			
			addChild(view);			
			
			vol = new SoundTransform(0);		
		}
		
		
		/**
		 * Called from preloader - WebPlayer
		 * @param	id String id from FlashVars - queryParam
		 */		
		public function init(id:String):void
		{	
			loader.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, xmlNotFound, false, 0, true);
			loader.load(new URLRequest(StaticData.GET_VIDEO_BY_ID_URL + id));
		}
		
		
		private function xmlLoaded(e:Event):void
		{				
			var xml:XML = new XML(e.target.data);			
			vidList = xml.video;
			
			playVideo();
		}
		
		
		private function xmlNotFound(e:IOErrorEvent):void
		{
			trace("IOError:", e);
		}
		
		
		private function playVideo():void
		{
			texURL = vidList.wrapImageUrl;
			
			audioSelection = new Array();
			
			var audSel:Array =  vidList.tracks.split(",");			
			for (var i:int = 0; i < 4; i++) {
				audioSelection[i] = parseInt(audSel[i]);
			}
			
			theText.text = vidList.license;
			theLabel.theName.text = vidList[currentIndex].first_name;
				
				var city:String = vidList[currentIndex].city;
				var state:String = vidList[currentIndex].state;
				var lab:String;
				
				if (city != "") {
					lab = city;
				}
				if (state != "") {
					if(city != ""){
						lab += ", "	+ state;
					}else {
						lab = state;
					}
				}
				
			theLabel.theCity.text = lab;
			
			var scene:String = vidList.video;
			switch(scene) {
				case "city":
					vid = "assets/smart_city.f4v";
					break;
				case "suburbs":
					vid = "assets/smart_suburbs.f4v";
					break;
				case "beach":
					vid = "assets/smart_beach.f4v";
					break;
				case "nightlife":
					vid = "assets/smart_nightlife.f4v";
					break;				
			}
			
			//for waiting for buffer full message			
			player.addEventListener(VPlayer.STATUS_RECEIVED, traceStatus);
			player.playVideo(vid);			
		}
		
		
		/**
		 * Listens for a Buffer Full and starts loading the car model once received
		 * @param	e
		 */
		private function traceStatus(e:Event):void
		{	
			if (player.getStatus() == "NetStream.Buffer.Full") {
				player.pauseVideo(); //so it buffers - start playing it once the car is loaded
				player.removeEventListener(VPlayer.STATUS_RECEIVED, traceStatus);
				
				if(!meshLoaded){
					//load the car model once the buffer is full
					car = Collada.load("smart2.xml"); //.xml for web - or need to add .dae to mime types
					car.addEventListener(Loader3DEvent.LOAD_SUCCESS, modelLoaded, false, 0, true);
					car.addEventListener(Loader3DEvent.LOAD_PROGRESS, modelLoading, false, 0, true);
				}else {
					modelLoaded();
				}
			}
		}
		
		
		private function modelLoading(e:Loader3DEvent):void
		{
			meshPercent = e.loader.bytesLoaded / e.loader.bytesTotal;
			dispatchEvent(new Event("modelLoadingProgress"));
		}
		
		public function getMeshPercentLoaded():Number
		{
			return meshPercent;
		}
		
		/**
		 * Called when the collada model has finished loading
		 * Loads the texture map in texURL
		 * 
		 * @param	e
		 */
		private function modelLoaded(e:Loader3DEvent = null):void
		{	
			//dispatchEvent(new Event("modelLoadingProgress"));
			car.removeEventListener(Loader3DEvent.LOAD_SUCCESS, modelLoaded);
			car.removeEventListener(Loader3DEvent.LOAD_PROGRESS, modelLoading);
					
			if (!meshLoaded) {
				meshLoaded = true;
			
				meshContainer = ObjectContainer3D(e.loader.handle);
				
				var shad:BitmapMaterial = new BitmapMaterial(new playerShadow());
				shad.alpha = .75;
				var myPlane:Plane = new Plane( { material:shad, rotationX: 0, z: -5, y: -1, height:140 } );
				meshContainer.addChild(myPlane);
				
				carBody = meshContainer.getChildByName("ID9");
				
				flWheel = meshContainer.getChildByName("ID45");
				blWheel = meshContainer.getChildByName("ID36");
				frWheel = meshContainer.getChildByName("ID27");
				brWheel = meshContainer.getChildByName("ID18");
			}
			
			//load texture map created by user
			//Policy file for WEB VERSION
			var lc:LoaderContext = new LoaderContext(true);
			lc.checkPolicyFile = true;
			texLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, textureLoaded, false, 0, true);
			texLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, textureLoading, false, 0, true);
			texLoader.load(new URLRequest(texURL), lc);
		}
		
		
		private function textureLoading(e:ProgressEvent):void
		{			
			texturePercent = e.bytesLoaded / e.bytesTotal;
			dispatchEvent(new Event("textureLoadingProgress"));
		}
			
		public function getTexturePercentLoaded():Number
		{
			return texturePercent;
		}
		
		/**
		 * Called once the user created texture has loaded
		 * maps the car with the texture and then adds it to the scene
		 * Adds enterFrame listener so update() is called
		 * Begins playing the video and audio
		 * @param	e
		 */
		private function textureLoaded(e:Event):void
		{
			dispatchEvent(new Event("allDataLoaded"));
			
			var imData:BitmapData = Bitmap(texLoader.content).bitmapData;
			
			var licenseImage:BitmapData = getLicenseImage();

			appliedMap.draw(new baseMap());
			appliedMap.copyPixels(licenseImage, licenseImage.rect, new Point(216, 1377), null, null, true);
			appliedMap.copyPixels(licenseImage, licenseImage.rect, new Point(698,766), null, null, true);
			appliedMap.copyPixels(imData, imData.rect, new Point(0, 0), new baseMask(), new Point(0, 0), true);
			appliedMap.draw(new baseShadow());
			
			mat = new PhongBitmapMaterial( appliedMap);
			mat.smooth = true;
			var matData:MaterialData = meshContainer.materialLibrary.getMaterial("ID3");
			matData.material = mat;			
			
			shot1();
			player.addEventListener(VPlayer.CUE_RECEIVED, handleCue, false, 0, true);
			
			myScene.addChild(meshContainer);
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);		
			
			addChild(theLabel);
			player.resumeVideo();
			playAudio(audioSelection);
			fadeInSound();
		}
		
		
		public function getLicenseImage():BitmapData
		{
			var fieldData:BitmapData = new BitmapData(108, 34, true, 0x00000000);
			
			var fieldMatrix:Matrix = new Matrix();
			fieldMatrix.scale(108 / theText.textWidth, 34 / theText.textHeight);
			if (theText.text.length < 7) {
				var diff:int = 7 - theText.text.length;
				for (var i:int = 0; i < diff; i++) {
					theText.appendText(" ");
				}
			}
			fieldData.draw(theText, fieldMatrix);
			return fieldData;
		}
	
		
		/**
		 * Renders the view
		 * Called by EnterFrame listener
		 * 
		 * @param	e Event ENTER_FRAME
		 */
		private function update(e:Event):void
		{		
			//spin the wheels			
			flWheel.rotationX += 12;
			frWheel.rotationX += 12;
			blWheel.rotationX += 12;
			brWheel.rotationX += 12;			
			
			view.render();
		}
				
		
		/**
		 * Called once texture is loaded
		 * opening shot with car driving at you
		 */
		private function shot1():void
		{	
			camera.x = 83;
			camera.y = 45;
			camera.z = -83;			
			camera.zoom = 37;
			camera.focus = 30;		
			
			meshContainer.x = -216;
			meshContainer.y = -114;
			meshContainer.z = 238;			
			meshContainer.rotationX = 0;
			meshContainer.rotationY = -53;
			meshContainer.rotationZ = 20;
			
			view.x = 100;
			view.y = 500;
			
			camera.lookAt(new Vector3D(0, 0, 0));
			
			TweenMax.to(camera, 2.5, { zoom:100, focus:59, delay:.6 } );			
			TweenMax.to(meshContainer, 2.5, {delay:.6, overwrite:0, x:-132, y:-154, z:282, rotationX:12, rotationY:-65, rotationZ:26, ease:Linear.easeNone});
		}
		/**
		 * mostly stationary - car does a slight push forward
		 */
		private function shot2():void
		{
			TweenMax.killAll();
			
			camera.x = 83;
			camera.y = 45;
			camera.z = -83;			
			camera.zoom = 89;
			camera.focus = 30;
			
			meshContainer.x = -53;
			meshContainer.y = -62;
			meshContainer.z = 166;			
			meshContainer.rotationX = -9;
			meshContainer.rotationY = -1;
			meshContainer.rotationZ = 10;
			
			TweenMax.to(meshContainer, 2.45, {overwrite:0, x:-53, y:-62, z:157, rotationX:-9, rotationY:-1, rotationZ:10});
		}
		//close up of front wheel
		private function shot3():void
		{
			TweenMax.killAll();
			
			camera.x = 40;
			camera.y = 7;
			camera.z = -128;			
			camera.zoom = 38;
			camera.focus = 41;
			
			meshContainer.x = 48;
			meshContainer.y = 1;
			meshContainer.z = 4;			
			meshContainer.rotationX = 11;
			meshContainer.rotationY = -46;
			meshContainer.rotationZ = 6;
			
			camera.lookAt(new Vector3D(0, 0, 0));
			
			TweenMax.to(camera, 1.8, { zoom:30 } );
		}
		//car moves left to right
		private function shot4():void
		{	
			TweenMax.killAll();
			
			camera.x = 84;
			camera.y =  29;
			camera.z =  -164;
			camera.zoom =  46;
			camera.focus =  66;
			
			meshContainer.x = -161;
			meshContainer.y = -32;
			meshContainer.z = 202;
			meshContainer.rotationX = -1;
			meshContainer.rotationY = -109;
			meshContainer.rotationZ = 1;
			
			camera.lookAt(new Vector3D(0, 0, 0));
			
			TweenMax.to(meshContainer, 1.5, {x:111, y:-21, z:219, rotationX:-1, rotationY:-109, rotationZ:1});
		}
		
		//car parking between two other cars
		private function shot5():void
		{
			TweenMax.killAll();
			camera.x = 0;
			camera.y =  0;
			camera.z =  -83;
			camera.zoom =  37;
			camera.focus =  30;
			
			meshContainer.x = -9;
			meshContainer.y = 44;
			meshContainer.z = 337;
			meshContainer.rotationX = 90;
			meshContainer.rotationY = 0;
			meshContainer.rotationZ = 0;			
			
			view.y = -30;
			view.x = 700;
			
			camera.lookAt(new Vector3D(0, 0, 0));
			
			TweenMax.to(meshContainer, 2, { y: -120} );			
			TweenMax.to(meshContainer, 1.5, { overwrite:0, x:112, y: -162, z:347, rotationY: -20, rotationZ:90, delay:2 } );
		}
		
		//360 around the car
		private function shot6():void
		{			
			TweenMax.killAll();
			
			camera.x = 220;
			camera.y = -74;
			camera.z = -9;
			camera.zoom = 52;
			camera.focus = 48;		
			
			meshContainer.x = 137;
			meshContainer.y = -129;
			meshContainer.z = 226
			
			meshContainer.rotationX = 0;
			meshContainer.rotationY = 103;
			meshContainer.rotationZ = 0;			
			
			view.y = 0;
			view.x = 0;
			
			camera.lookAt(new Vector3D(19, -58, 254), new Vector3D(0, 1, 0));
			
			TweenMax.to(meshContainer, 3.4, { rotationY:280, y:"-10", ease:Linear.easeInOut } );
			TweenMax.to(camera, 3.4, { zoom:40 } );
		}
		
		//U-Turn
		private function shot7():void
		{			
			TweenMax.killAll();
			
			camera.x = 220;
			camera.y = -74;
			camera.z = -9;
			camera.zoom = 20;
			camera.focus = 50;		
			
			meshContainer.x = -222;
			meshContainer.y = -101;
			meshContainer.z = 470
			
			meshContainer.rotationX = -16;
			meshContainer.rotationY = 103;
			meshContainer.rotationZ = -6;			
			
			view.y = 0;
			view.x = 0;
			
			camera.lookAt(new Vector3D(0, 0, 0));
			
			//first spot of turn
			TweenMax.to(meshContainer, 1, { x: -240, y: -55, z:359, rotationX: -20, rotationY:77, rotationZ: -6, ease:Linear.easeNone } );
			TweenMax.to(camera, 1, { focus:58 } );
			
			//second spot of turn
			TweenMax.to(meshContainer, .7, { x: -210, y: -49, z:266, rotationX: -8, rotationY: -2, rotationZ: -30, delay:1, overwrite:0, ease:Linear.easeNone } );
			
			//third
			TweenMax.to(meshContainer, .7, { x: -108, y: -89, z:158, rotationX: -6, rotationY: -83, rotationZ: -34, delay:1.7, overwrite:0, ease:Linear.easeNone } );
			
			//fourth
			TweenMax.to(meshContainer, 1, { x: -27, y: -151, z:171, rotationX: -6, rotationY: -95, rotationZ: -34, delay:2.4, overwrite:0, ease:Linear.easeNone } );			
		}
		
		//Car comes at you for license plate zoom
		private function shot8()
		{
			TweenMax.killAll();
			
			camera.x = -33;
			camera.y = 22;
			camera.z = 137;
			camera.zoom = 31;
			camera.focus = 52;
			
			camera.lookAt(new Vector3D(0, 0, 0),new Vector3D(0,1,0));			
			
			meshContainer.x = -129;
			meshContainer.y = -157;
			meshContainer.z = -231;
			
			meshContainer.rotationX = -22;
			meshContainer.rotationY = -170;
			meshContainer.rotationZ = -10;
			
			view.x =  0;
			view.y =  0;
			
			TweenMax.to(meshContainer, 1, { x: -67, y: -52, z:22, rotationX: -22, rotationY: -170, rotationZ: -10, ease:Linear.easeNone } );
		}
		
		private function shot9():void
		{
			TweenMax.killAll();
			
			camera.x = -33;
			camera.y = 22;
			camera.z = 137;
			camera.zoom = 31;
			camera.focus = 52;
			
			meshContainer.x = -74;
			meshContainer.y = -61;
			meshContainer.z = 50;
			
			meshContainer.rotationX = 20;
			meshContainer.rotationY = 10;
			meshContainer.rotationZ = -10;
			
			view.x = 0;
			view.y = 0;
			
			TweenMax.to(meshContainer, 2.75, { x: -145, y: -268, z: -500, rotationX:20, rotationY:6, rotationZ: -12, ease:Linear.easeNone } );			
		}
		
		
		/**
		 * black at end
		 */
		private function shot10():void
		{
			meshContainer.x = 40000;
			view.render();
			removeEventListener(Event.ENTER_FRAME, update);			
			fadeOutSound();
		}
		
		/**
		 * Called from TweenMax in fadeOutSound()
		 */
		private function vidComplete():void
		{			
			dispatchEvent(new Event("videoCompleted"));
		}
		
		/**
		 * Cues come at the last frame of each section
		 * @param	e
		 */
		private function handleCue(e:Event):void
		{
			var cn:String = player.getCueName();			
			
			if (cn == "C1") {
				shot2();
			}
			if (cn == "C2") {
				shot3();
			}
			if (cn == "C3") {
				shot4();
			}
			if (cn == "C4") {
				shot5();
			}
			if (cn == "C5") {
				shot6();
			}
			if (cn == "C6") {
				shot7();
			}
			if (cn == "C7") {
				shot8();
			}
			if (cn == "C8") {
				shot9();
			}
			if (cn == "C9") {
				shot10();
			}
		}
		
		
		private function doPlay(e:MouseEvent):void
		{
			player.resumeVideo();
		}
		private function doPause(e:MouseEvent):void
		{
			player.pauseVideo();
		}
		private function doRewind(e:MouseEvent):void
		{
			player.rewind();
		}
		
		//END OF CONTROLS
		
		//AUDIO PLAYBACK
		private function playAudio(sel:Array):void
		{
			if(bassChannel){
				bassChannel.stop();
			}
			if(drumChannel){
				drumChannel.stop();
			}
			if(guitarChannel){
				guitarChannel.stop();
			}
			if(synthChannel){
				synthChannel.stop();
			}
			
			var snd:int = sel[0];
			switch(snd) {
				case 1:
					bassChannel = new bass1().play(0, 999);
					bassChannel.soundTransform = vol;
					break;	
				case 2:
					bassChannel = new bass2().play(0, 999);
					bassChannel.soundTransform = vol;
					break;
				case 3:
					bassChannel = new bass3().play(0, 999);
					bassChannel.soundTransform = vol;
					break;
				case 4:
					bassChannel = new bass4().play(0, 999);
					bassChannel.soundTransform = vol;
					break;
			}
			
			
			//DRUMS	
			snd = sel[1];
			switch(snd) {
				case 1:
					drumChannel = new drum1().play(0, 999);
					drumChannel.soundTransform = vol;
					break;	
				case 2:
					drumChannel = new drum2().play(0, 999);
					drumChannel.soundTransform = vol;
					break;
				case 3:
					drumChannel = new drum3().play(0, 999);
					drumChannel.soundTransform = vol;
					break;
				case 4:
					drumChannel = new drum4().play(0, 999);
					drumChannel.soundTransform = vol;
					break;
			}			
			
			//GUITAR	
			snd = sel[2];
			switch(snd) {
				case 1:
					guitarChannel = new guitar1().play(0, 999);
					guitarChannel.soundTransform = vol;
					break;	
				case 2:
					guitarChannel = new guitar2().play(0, 999);
					guitarChannel.soundTransform = vol;
					break;
				case 3:
					guitarChannel = new guitar3().play(0, 999);
					guitarChannel.soundTransform = vol;
					break;
				case 4:
					guitarChannel = new guitar4().play(0, 999);
					guitarChannel.soundTransform = vol;
					break;
			}
			
			//SYNTH
			snd = sel[3];
			switch(snd) {
				case 1:
					synthChannel = new synth1().play(0, 999);
					synthChannel.soundTransform = vol;
					break;	
				case 2:
					synthChannel = new synth2().play(0, 999);
					synthChannel.soundTransform = vol;
					break;
				case 3:
					synthChannel = new synth3().play(0, 999);
					synthChannel.soundTransform = vol;
					break;
				case 4:
					synthChannel = new synth4().play(0, 999);
					synthChannel.soundTransform = vol;
					break;
			}			
		}
		
		private function fadeInSound():void
		{
			TweenMax.to(vol, 1, { volume:1, onUpdate:reapplySoundTransform } );
		}
		private function fadeOutSound():void
		{
			TweenMax.to(vol, 4, { volume:0, onUpdate:reapplySoundTransform, onComplete:vidComplete } );
		}
		
		private function reapplySoundTransform():void
		{
			if(bassChannel){
				bassChannel.soundTransform = vol;
			}
			if(drumChannel){
				drumChannel.soundTransform = vol;
			}
			if(guitarChannel){
				guitarChannel.soundTransform = vol;
			}
			if(synthChannel){
				synthChannel.soundTransform = vol;
			}
		}
	}
	
}