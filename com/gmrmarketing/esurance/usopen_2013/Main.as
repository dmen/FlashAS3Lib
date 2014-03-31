//frame your name - facebook version

package com.gmrmarketing.esurance.usopen_2013
{
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import com.greensock.TweenLite;
	import com.gmrmarketing.utilities.ImageEncoder;
	
	
	public class Main extends MovieClip
	{
		private var nameContainer:Sprite;
		private var isPaused:Boolean;
		private var theName:Array; //array of character objects
		private var encoder:ImageEncoder;
		private var dialog:Dialog;
		private var progress:Progress;
		
		
		public function Main()
		{			
			isPaused = true;
			nameContainer = new Sprite();
			
			encoder = new ImageEncoder();
			encoder.addEventListener(ImageEncoder.COMPLETE, doneEncoding, false, 0, true);
			
			dialog = new Dialog();
			dialog.setContainer(this);
			
			progress = new Progress();
			progress.setContainer(this);
			
			nameContainer.addEventListener(Event.ADDED_TO_STAGE, resize, false, 0, true);	
			
			ExternalInterface.call("getName"); //call getName() function in JavaScript on the page
			
			ExternalInterface.addCallback("gotUserName", gotUserName);//so JS can call gotUserName()
			ExternalInterface.addCallback("postError", postError);
			ExternalInterface.addCallback("postOK", postOK);				
		}
			
		
		/**
		 * Called from the web page once the call to getName() is complete
		 * @param	name
		 */
		private function gotUserName(name:String):void
		{			
			var n:Array = name.split(" ");
			
			fName.theText.text = n[0];
			createName(String(n[1]).toLowerCase());			
			
			addChild(nameContainer);
			nameContainer.y = 190;
			nameContainer.x = 30;
		}
		
		
		public function createName(name:String):void
		{
			theName = new Array();
			for (var i:int = 0; i < name.length; i++) {
				var c:Character = new Character(name.substr(i, 1));				
				c.setContainer(nameContainer);				
				c.show(160 * i, 0);
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
			if(nameContainer.width > 700){
				var scaleFact:Number = 700 / nameContainer.width;
				nameContainer.width = nameContainer.width * scaleFact;
				nameContainer.height = nameContainer.height * scaleFact;
			}
			
			var yCorrection:int = -30;
			var buffer:int = 20; //vertical space betwee the names
			var sp:int = Math.floor((428 - (fName.height + buffer + nameContainer.height)) * .5);
			
			TweenLite.to(fName, 1, { y:sp + yCorrection } );
			TweenLite.to(nameContainer, 1, { x:Math.floor((760 - nameContainer.width) * .5), y:sp + fName.height + buffer + yCorrection } );
			
			btnPlay.addEventListener(MouseEvent.MOUSE_DOWN, doPause, false, 0, true);
			btnPost.addEventListener(MouseEvent.MOUSE_DOWN, beginFBPost, false, 0, true);
			doPause();
		}
		
		
		private function doPause(e:MouseEvent = null):void
		{
			btnPlay.alpha = 1;
			TweenLite.to(btnPlay, .5, { alpha:0 } );
			
			isPaused = !isPaused;
			var l:int = theName.length;
			var i:int;
			if (isPaused) {
				theButtons.theText.text = "rotate the letters";
				for (i = 0; i < l; i++) {
					theName[i].pause();
				}
			}else {			
				theButtons.theText.text = "stop rotating";
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
			btnPost.alpha = 1;
			TweenLite.to(btnPost, .5, { alpha:0 } );
			
			if (!isPaused) {
				doPause();
				TweenLite.delayedCall(1, createImage);
			}else{
				createImage();
			}
		}
		
		
		/**
		 * Takes screen grab of the stage and sends it to the encoder
		 */
		private function createImage():void
		{
			progress.show();
			progress.setMessage("Encoding...");
			
			var bmd:BitmapData = new BitmapData(760, 428);
			
			TweenLite.killTweensOf(btnPost);
			theButtons.visible = false;
			btnPlay.visible = false;
			btnPost.visible = false;
			bmd.draw(stage);
			theButtons.visible = true;
			btnPlay.visible = true;
			btnPost.visible = true;
			btnPost.alpha = 0;
			encoder.encode(bmd);			
		}
		
		
		/**
		 * called by listener on the encoder once encoding is complete
		 * posts the encoded image to the web service
		 * @param	e
		 */
		private function doneEncoding(e:Event):void
		{	
			progress.setMessage("Uploading...");			
			
			var hdr:URLRequestHeader = new URLRequestHeader("Content-type", "application/json");
			var hdr2:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			
			var b64:String = encoder.getEncoded();
			var js:String = JSON.stringify({ ImageData:b64 });
			
			var req:URLRequest = new URLRequest("http://esuranceusopen2013.thesocialtab.net/api/Image");
			req.data = js;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);
			req.method = URLRequestMethod.POST;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, imageError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, imagePosted, false, 0, true);
			lo.load(req);
		}
		
		
		private function imageError(e:IOErrorEvent):void
		{
			postError();
		}

		
		/**
		 * Called once the image has uploaded to gmr server
		 * does the FB post to the wall
		 * @param	e
		 */
		private function imagePosted(e:Event):void
		{
			var j:Object = JSON.parse(e.currentTarget.data);			
			
			progress.setMessage("Posting to Wall...");
			
			ExternalInterface.call("postImage", j.ImageUrl);
		}
		
		
		private function postError():void
		{
			progress.hide();
			dialog.show("An error has occured. Please try again.");
		}
		
		
		private function postOK():void
		{
			progress.hide();
			dialog.show("Success!\nThank You for sharing.");
		}
		
	}
	
}

