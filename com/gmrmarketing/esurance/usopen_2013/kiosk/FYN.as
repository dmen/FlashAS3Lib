package com.gmrmarketing.esurance.usopen_2013.kiosk
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.gmrmarketing.esurance.usopen_2013.Character;
	import com.gmrmarketing.esurance.usopen_2013.Progress;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class FYN extends EventDispatcher	
	{
		public static const GO_BACK:String = "backpressed";		
		public static const IMAGE_READY:String = "imageReady";//dispatched when image is ready for encoding
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var nameContainer:Sprite;
		private var theName:Array; //array of character objects
		private var isPaused:Boolean;		
		
		private var bmd:BitmapData;
		private var authToken:String;
		private var tim:TimeoutHelper;
		
		public function FYN()
		{
			clip = new mcFYN();
			tim = TimeoutHelper.getInstance();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(fName:String, lName:String, token:String):void
		{
			tim.buttonClicked();
			
			isPaused = true;
			
			authToken = token;//null or "" if there is no token
			if (authToken == "") {
				authToken = null;
			}
			
			nameContainer = new Sprite();	
			//mouse listeners added in resize()
			nameContainer.addEventListener(Event.ADDED_TO_STAGE, resize, false, 0, true);			
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.fName.text = fName;
			createName(lName.toLowerCase());			
			
			clip.addChild(nameContainer); //causes resize() to fire
			nameContainer.y = 190;
			nameContainer.x = 30;
		}
		
		
		public function hide():void
		{	
			tim.buttonClicked();
			
			if(nameContainer){
				nameContainer.removeEventListener(Event.ADDED_TO_STAGE, resize);
				while (nameContainer.numChildren) {
					nameContainer.removeChildAt(0);
				}
				if (clip) {
					if (clip.contains(nameContainer)) {
						clip.removeChild(nameContainer);
					}
				}
				
			}
			clip.btnPlay.removeEventListener(MouseEvent.MOUSE_DOWN, doPause);
			clip.btnPost.removeEventListener(MouseEvent.MOUSE_DOWN, beginFBPost);
			clip.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, backPressed);
						
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		public function createName(name:String):void
		{
			theName = new Array();
			for (var i:int = 0; i < name.length; i++) {
				var c:Character = new Character(name.substr(i, 1));				
				c.setContainer(nameContainer);				
				c.show(310 * i, 0);
				theName.push(c);
			}
		}
		
		
		/**
		 * Called once the name container has been added to the stage - resizes
		 * the container to fit the stage width properly
		 * @param	e
		 */
		private function resize(e:Event):void
		{
			var scaleFact:Number;
			
			if(nameContainer.width > 1800){
				scaleFact = 1800 / nameContainer.width;
				nameContainer.width = nameContainer.width * scaleFact;
				nameContainer.height = nameContainer.height * scaleFact;
			}
			
			if (nameContainer.width < 1200) {
				scaleFact = Math.min(1200 / nameContainer.width, 2);
				nameContainer.width = nameContainer.width * scaleFact;
				nameContainer.height = nameContainer.height * scaleFact;
			}
			
			var yCorrection:int = 80;
			var buffer:int = 40; //vertical space between the names
			var sp:int = Math.floor((800 - (clip.fName.height + buffer + nameContainer.height)) * .5);
			
			TweenMax.to(clip.fName, 1, { y:sp + yCorrection } );
			TweenMax.to(nameContainer, 1, { x:Math.floor((1920 - nameContainer.width) * .5), y:sp + clip.fName.height + buffer + yCorrection } );
			
			clip.btnPlay.addEventListener(MouseEvent.MOUSE_DOWN, doPause, false, 0, true);
			
			if (authToken == null) {
				clip.btnPost.theText.text = "send to email";
			}else {				
				clip.btnPost.theText.text = "post to facebook";
			}
			clip.btnPost.addEventListener(MouseEvent.MOUSE_DOWN, beginFBPost, false, 0, true);			
			clip.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, backPressed, false, 0, true);
			
			doPause();
		}
		
		
		private function backPressed(e:MouseEvent):void
		{
			tim.buttonClicked();
			dispatchEvent(new Event(GO_BACK));
		}
		
		
		private function doPause(e:MouseEvent = null):void
		{			
			tim.buttonClicked();
			clip.btnPlay.highlight.alpha = 1;
			TweenMax.to(clip.btnPlay.highlight, .5, { alpha:0 } );
			
			isPaused = !isPaused;
			var l:int = theName.length;
			var i:int;
			if (isPaused) {
				clip.btnPlay.theText.text = "rotate the letters";
				for (i = 0; i < l; i++) {
					theName[i].pause();
				}
			}else {			
				clip.btnPlay.theText.text = "stop rotating";
				for (i = 0; i < l; i++) {
					theName[i].play();
				}
			}
		}
		
		
		/**
		 * Called by pressing the post to FB button
		 * begins creating the image
		 * @param	e
		 */
		private function beginFBPost(e:MouseEvent):void
		{		
			tim.buttonClicked();
			clip.btnPost.highlight.alpha = 1;
			TweenMax.to(clip.btnPost.highlight, .5, { alpha:0 } );
			
			if (!isPaused) {
				doPause();
				TweenMax.delayedCall(1, createImage);
			}else{
				createImage();
			}
		}
		
		
		/**
		 * Takes screen grab of the stage and sends it to the encoder
		 */
		private function createImage():void
		{			
			//bmd = new BitmapData(1920, 1080);
			bmd = new BitmapData(1280, 720);
			
			var m:Matrix = new Matrix();
			var sc:Number = 1280 / 1920;
			m.scale(sc, sc);
			
			TweenMax.killTweensOf(clip.btnPost.highlight);
			
			clip.btnPlay.visible = false;
			clip.btnPost.visible = false;
			clip.btnBack.visible = false;
			
			bmd.draw(clip, m);
			
			clip.btnPlay.visible = true;
			clip.btnPost.visible = true;
			clip.btnBack.visible = true;
			
			clip.btnPost.highlight.alpha = 0;
			
			dispatchEvent(new Event(IMAGE_READY));
		}
		
		
		public function getImage():BitmapData
		{
			return bmd;
		}		
		
	}
	
}