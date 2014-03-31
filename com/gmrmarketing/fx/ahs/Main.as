package com.gmrmarketing.fx.ahs
{		
	import away3d.events.MouseEvent3D;
	import away3d.materials.utils.HeightMapDataChannel;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.*;	
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.*;
	import com.greensock.TweenLite;
	import com.greensock.plugins.*;
	import com.greensock.easing.*;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import fl.video.*;
	import flash.media.Camera;
	import flash.display.BlendMode;
	import com.gmrmarketing.fx.ahs.ImageSave;
	import flash.external.ExternalInterface;
	
	
	
	public class Main extends MovieClip
	{
		private var vidInitialRotation:int = 30;
		private var p2:MovieClip;
		
		private var backChannel:SoundChannel;
		private var vol:SoundTransform;
		private var backSound:Sound;
		private var handSound:Sound;
		private var clickSound:Sound;
		private var screamSound:Sound;
		//private var celloSound:Sound;
		private var expScreamSound:Sound;		
		
		private var formURL:String; //passed from loader - FlashVar
		private var postURL:String; //passed from loader - FlashVar
		
		private var bMask:MovieClip; //blood mask
		
		private var atP2:Boolean = false;
		
		private const VID_BASE_URL:String = "http://gmrappdevelopers.s3.amazonaws.com/FXHorrorShow/";
		private var curVid:String;
		
		private var cam:Camera;
		private var camVid:Video;
		//true if user presses vid 3 button and allows camera actions - checked in update()
		private var camAllowed:Boolean = false; 
		private var camImageData:BitmapData;
		private var camImage:Bitmap;
		private var camMatrix:Matrix;	
		
		private var camDialog:MovieClip; //lib clip		
		private var whisperSound:Sound; //lib sound
		private var whisperVol:SoundTransform;
		private var whisperChan:SoundChannel;
		private var scarePicTimer:Timer; //for taking the fright pic
		private var countdownTimer:Timer;
		private var ledTimer:Timer;
		private var curCount:int;
		
		private var imageSaver:ImageSave;//for saving cam image
		private var saveData:BitmapData;
		private var scareClipContainer:MovieClip;
		
		//actual width and height of the camera object - after setting to 640x480 - set in getCam()
		private var camWidth:int;
		private var camHeight:int;
		
		private var FBShareURL:String; //set in imageWasSaved() once the ID comes back from the web service
		
		//private var whichFear:int; // 1 - 4 from the fear dial
		//private var whichFears:Array = new Array("Ants", "Cockroaches", "Blood", "Fire");
		//private var fearCacher:Loader;
		
		
		public function Main() 
		{
			TweenPlugin.activate([GlowFilterPlugin]);
			
			bMask = new bloodMask(); //lib clip
			bMask.stop();			
			
			vid.vid.bufferTime = 7;
			bg.title.bufferTime = 2;
			
			scare.visible = false;
			scare.y = 1304;
			
			saveData = new BitmapData(640, 480);
			
			camImageData = new BitmapData(401, 265, true, 0x00000000); //for the template on step 3
			camImage = new Bitmap(camImageData);
			
			imageSaver = new ImageSave();
			imageSaver.addEventListener(ImageSave.DID_POST, imageWasSaved, false, 0, true);
			imageSaver.addEventListener(ImageSave.DID_NOT_POST, imageWasNotSaved, false, 0, true);
			
			vid.vid.getVideoPlayer(vid.vid.activeVideoPlayerIndex).smoothing = true;
			bg.title.getVideoPlayer(bg.title.activeVideoPlayerIndex).smoothing = true;
			
			//door with hand
			p2 = new page2();
			p2.x = -120;			
			
			camDialog = new camDialogue();
			camDialog.x = 110;
			camDialog.y = 139;
			
			scareClipContainer = new scarePicHolder();
			scareClipContainer.x = 160;
			scareClipContainer.y = 116;
			
			scarePicTimer = new Timer(850, 1);
			scarePicTimer.addEventListener(TimerEvent.TIMER, takeScarePicture, false, 0, true);
			
			countdownTimer = new Timer(1000);
			
			//hide expressions of fright stuff...
			//vid.expText.visible = false;
			//vid.s3.visible = false;
			
			//init();
			
			//call from JavaScript - called by ved's player - restarts bg sound
			//when video window is closed
			ExternalInterface.addCallback("vidWindowClosed", vidWindowClosed);
		}
		
		
		
		/**
		 * Called by the preloader
		 * formURL is the passed in FlashVar for the Sign up form
		 * id is the passed in FlashVar for the jump to page
		 */
		public function init($formURL:String = null, postURL:String = null, id:String = ""):void
		{
			atP2 = false;
			curVid = "";
			
			if (contains(p2)) {
				removeChild(p2);
				addChild(bg);
				addChild(vid);
				p2.signUp.removeEventListener(MouseEvent.CLICK, gotoForm);
				p2.signUp.removeEventListener(MouseEvent.MOUSE_OVER, glowSignUp);
				p2.signUp.removeEventListener(MouseEvent.MOUSE_OUT, unglowSignUp);
			}
			
			formURL = $formURL;
			if (formURL == null) {
				formURL = "/";
			}
			
			imageSaver.setPostURL(postURL);
			
			vol = new SoundTransform(1);
			whisperVol = new SoundTransform(.25);
			
			if(backSound == null){
				backSound = new bgSound(); //bg sound on page 1
				handSound = new handSoundFX(); //effect for text hands on page 2
				clickSound = new mouseClickFX(); //click sound for enter on page 1
				screamSound = new scream(); //lower left face/scream sound on page 2
				//celloSound = new cello();
				whisperSound = new whisper(); //cam dialog audio test sound
				expScreamSound = new expScream();
				
				backChannel = backSound.play(0, 999, vol);				
			}			
			
			bMask.addEventListener("bloodDone", removeBloodMask, false, 0, true);
			//bMask.cacheAsBitmap = true;
			
			//updates 3D rotations based on mouse pos
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);			
			
			bg.title.addEventListener(Event.COMPLETE, loopTitle, false, 0, true);
			
			bg.let.buttonMode = true;
			bg.let.addEventListener(MouseEvent.MOUSE_OVER, playLetUsIn, false, 0, true);
			bg.let.addEventListener(MouseEvent.MOUSE_OUT, stopLetUsIn, false, 0, true);
			bg.let.addEventListener(MouseEvent.CLICK, letUsIn, false, 0, true);
			
			//fear transition
			/*
			bg.fearDial.btn1.buttonMode = true;
			bg.fearDial.btn2.buttonMode = true;
			bg.fearDial.btn3.buttonMode = true;
			bg.fearDial.btn4.buttonMode = true;
			bg.fearDial.btn1.addEventListener(MouseEvent.CLICK, chooseFear, false, 0, true);
			bg.fearDial.btn2.addEventListener(MouseEvent.CLICK, chooseFear, false, 0, true);
			bg.fearDial.btn3.addEventListener(MouseEvent.CLICK, chooseFear, false, 0, true);
			bg.fearDial.btn4.addEventListener(MouseEvent.CLICK, chooseFear, false, 0, true);
			*/
			
			vid.rotationY = vidInitialRotation;
			vid.vid.addEventListener(Event.COMPLETE, loopVid, false, 0, true);
			//vidShadow.rotationY = vidInitialRotation;
			
			//plays the title and main vid
			playS1Vid();			
			loopTitle();
			
			//vid selectors under video			
			vid.s1.buttonMode = true;
			vid.s2.buttonMode = true;
			vid.s3.buttonMode = true;
			vid.expText.buttonMode = true;
			vid.s1.addEventListener(MouseEvent.CLICK, playS1Vid, false, 0, true);
			vid.s1.addEventListener(MouseEvent.MOUSE_OVER, glowVidButton, false, 0, true);
			vid.s1.addEventListener(MouseEvent.MOUSE_OUT, noGlowVidButton, false, 0, true);
			vid.s2.addEventListener(MouseEvent.CLICK, playS2Vid, false, 0, true);
			vid.s2.addEventListener(MouseEvent.MOUSE_OVER, glowVidButton, false, 0, true);
			vid.s2.addEventListener(MouseEvent.MOUSE_OUT, noGlowVidButton, false, 0, true);
			vid.s3.addEventListener(MouseEvent.CLICK, showCamDialog, false, 0, true);
			vid.s3.addEventListener(MouseEvent.MOUSE_OVER, glowVidButton, false, 0, true);
			vid.s3.addEventListener(MouseEvent.MOUSE_OUT, noGlowVidButton, false, 0, true);
			vid.expText.addEventListener(MouseEvent.CLICK, showCamDialog, false, 0, true);
			
			showNav();			
			moveMarker(null, "Home");
			
			if (id == "ExpressionOfFright") {
				moveMarker(null, id);				
				showCamDialog();
			}
			if (id == "HouseCalls") {
				moveMarker(null, id);				
				letUsIn();
			}
			
			//chooseFear();
		}		
		
		/*
		private function chooseFear(e:MouseEvent = void):void
		{
			//reset all the buttons
			bg.fearDial.btn1.gotoAndStop(1);
			bg.fearDial.btn2.gotoAndStop(1);
			bg.fearDial.btn3.gotoAndStop(1);
			bg.fearDial.btn4.gotoAndStop(1);
			
			if (e != null) {
				//gets 1 - 4 from the button name
				whichFear = parseInt(String(e.currentTarget.name).substr(3, 1));
				bg.fearDial["btn" + whichFear].gotoAndStop(2);
				bg.fearDial.theText.text = whichFears[whichFear - 1];				
			}else {
				whichFear = 0;
				bg.fearDial.theText.text = "";
			}
		}
		*/
		
		
		private function showNav():void
		{
			bg.nav.y = -297;
			TweenLite.to(bg.nav, 1, { alpha:1, y:-287 } );			
			
			bg.nav.btnReal.buttonMode = true;
			bg.nav.btnExp.buttonMode = true;
			//bg.nav.btnDont.buttonMode = true;
			bg.nav.btnLet.buttonMode = true;
			
			bg.nav.btnReal.addEventListener(MouseEvent.MOUSE_OVER, glowVidButton, false, 0, true);
			bg.nav.btnReal.addEventListener(MouseEvent.MOUSE_OUT, noGlowVidButton, false, 0, true);
			bg.nav.btnReal.addEventListener(MouseEvent.CLICK, moveMarker, false, 0, true);
			bg.nav.btnReal.addEventListener(MouseEvent.CLICK, letUsIn, false, 0, true);
			
			bg.nav.btnExp.addEventListener(MouseEvent.MOUSE_OVER, glowVidButton, false, 0, true);
			bg.nav.btnExp.addEventListener(MouseEvent.MOUSE_OUT, noGlowVidButton, false, 0, true);
			bg.nav.btnExp.addEventListener(MouseEvent.CLICK, moveMarker, false, 0, true);
			bg.nav.btnExp.addEventListener(MouseEvent.CLICK, showCamDialog, false, 0, true);
			
			//bg.nav.btnDont.addEventListener(MouseEvent.MOUSE_OVER, glowVidButton, false, 0, true);
			//bg.nav.btnDont.addEventListener(MouseEvent.MOUSE_OUT, noGlowVidButton, false, 0, true);
			//bg.nav.btnDont.addEventListener(MouseEvent.CLICK, gotoDontPickItUp, false, 0, true);
			
			bg.nav.btnLet.addEventListener(MouseEvent.MOUSE_OVER, glowVidButton, false, 0, true);
			bg.nav.btnLet.addEventListener(MouseEvent.MOUSE_OUT, noGlowVidButton, false, 0, true);
			bg.nav.btnLet.addEventListener(MouseEvent.CLICK, moveMarker, false, 0, true);
			bg.nav.btnLet.addEventListener(MouseEvent.CLICK, gotoForm, false, 0, true);
			
			//remove any glow
			TweenLite.to(bg.nav.btnReal, 1, { glowFilter: { color:0xcc9933, alpha:0, blurX:10, blurY:10, strength:2 }} );
			TweenLite.to(bg.nav.btnExp, 1, { glowFilter: { color:0xcc9933, alpha:0, blurX:10, blurY:10, strength:2 }} );
			//TweenLite.to(bg.nav.btnDont, 1, { glowFilter: { color:0xcc9933, alpha:0, blurX:10, blurY:10, strength:2 }} );
			TweenLite.to(bg.nav.btnLet, 1, {glowFilter:{color:0xcc9933, alpha:0, blurX:10, blurY:10, strength:2}});
		}
		
		
		private function removeMenuListeners():void
		{
			if (contains(bg)) {				
				bg.nav.btnReal.removeEventListener(MouseEvent.MOUSE_OVER, glowVidButton);
				bg.nav.btnReal.removeEventListener(MouseEvent.MOUSE_OUT, noGlowVidButton);
				bg.nav.btnReal.removeEventListener(MouseEvent.CLICK, moveMarker);
				bg.nav.btnReal.removeEventListener(MouseEvent.CLICK, letUsIn);
				
				bg.nav.btnExp.removeEventListener(MouseEvent.MOUSE_OVER, glowVidButton);
				bg.nav.btnExp.removeEventListener(MouseEvent.MOUSE_OUT, noGlowVidButton);
				bg.nav.btnExp.removeEventListener(MouseEvent.CLICK, moveMarker);
				bg.nav.btnExp.removeEventListener(MouseEvent.CLICK, showCamDialog);
				
				//bg.nav.btnDont.removeEventListener(MouseEvent.MOUSE_OVER, glowVidButton);
				//bg.nav.btnDont.removeEventListener(MouseEvent.MOUSE_OUT, noGlowVidButton);
				
				bg.nav.btnLet.removeEventListener(MouseEvent.MOUSE_OVER, glowVidButton);
				bg.nav.btnLet.removeEventListener(MouseEvent.MOUSE_OUT, noGlowVidButton);
				bg.nav.btnLet.removeEventListener(MouseEvent.CLICK, moveMarker);
				bg.nav.btnLet.removeEventListener(MouseEvent.CLICK, gotoForm);
			}
		}
		
		private function moveMarker(e:MouseEvent = null, id:String = null):void
		{
			if (atP2) {
				if(id == null){
					p2.nav.marker.y = e.currentTarget.y + 5;
				}else {
					if (id == "ExpressionsOfFright") {
						p2.nav.marker.y = p2.nav.btnExp.y + 5;
					}
				}
			}else{
				if(id == null){
					bg.nav.marker.y = e.currentTarget.y + 5;
				}else {
					if (id == "Home") {
						bg.nav.marker.y = bg.nav.btnHome.y + 5;
					}
					if (id == "ExpressionsOfFright") {
						bg.nav.marker.y = bg.nav.btnExp.y + 5;
					}
					if (id == "HouseCalls") {
						bg.nav.marker.y = bg.nav.btnReal.y + 5;
					}
				}
			}
		}
		
		
		/**
		 * Called from pressing the button in the video player
		 * or expressions of fright in the nav
		 * @param	e
		 */
		private function showCamDialog(e:MouseEvent = null):void
		{
			moveMarker(null, "ExpressionsOfFright");
			fadeOutBGSound();
			vid.vid.volume = 0;
			
			curCount = 5;
			
			if (!contains(camDialog)) {
				addChild(camDialog);
				camDialog.alpha = 0;
				TweenLite.to(camDialog, .5, { alpha:1 } );
			}
			
			camDialog.btnCancel.buttonMode = true;
			camDialog.btnStart.buttonMode = true;			
			
			camDialog.btnCancel.addEventListener(MouseEvent.CLICK, hideCamDialog, false, 0, true);
			camDialog.btnStart.addEventListener(MouseEvent.CLICK, camDialogFrameTwo, false, 0, true);			
		}
		
		
		private function camDialogFrameTwo(e:MouseEvent):void
		{
			camDialog.btnStart.removeEventListener(MouseEvent.CLICK, camDialogFrameTwo);
			camDialog.gotoAndStop(2);
			
			camDialog.cont.alpha = 0;			
			TweenLite.to(camDialog.cont, 1, { alpha:1, delay:7, onComplete:addContinueListener } );
			
			//loop the whisper sound
			whisperChan = whisperSound.play(0, 999);
			whisperChan.soundTransform = whisperVol;
		}
		
		
		private function addContinueListener():void
		{
			camDialog.btnContinue.buttonMode = true;
			camDialog.btnContinue.addEventListener(MouseEvent.CLICK, camDialogFrameThree, false, 0, true);
		}
		
		
		private function camDialogFrameThree(e:MouseEvent):void
		{
			camDialog.btnContinue.removeEventListener(MouseEvent.CLICK, camDialogFrameThree);
			camDialog.gotoAndStop(3);
			
			camDialog.recComplete.alpha = 0;
			camDialog.recComplete.progBar.scaleX = 0;
			
			camDialog.btnRecord.buttonMode = true;
			camDialog.btnRecord.addEventListener(MouseEvent.CLICK, camDialogBeginRecording, false, 0, true);			
			camDialog.countdown.visible = false;
			camDialog.redLED.alpha = 0;
			camDialog.vidContainer.addChild(camImage);
			getCam();
		}
		
		
		/**
		 * clicked the record button
		 * @param	e
		 */
		private function camDialogBeginRecording(e:MouseEvent):void
		{
			camDialog.btnRecord.removeEventListener(MouseEvent.CLICK, camDialogBeginRecording);
			camDialog.countdown.visible = true;
			
			countdownTimer.addEventListener(TimerEvent.TIMER, decrementCount, false, 0, true);
			countdownTimer.start();
			
			fadeUp();//led
		}
		
		
		private function fadeDown():void
		{
			TweenLite.to(camDialog.redLED, .5, { alpha:.1, onComplete:fadeUp } );
		}
		
		
		private function fadeUp():void
		{
			TweenLite.to(camDialog.redLED, .5, { alpha:1, onComplete:fadeDown } );
		}
		
		
		private function decrementCount(e:TimerEvent):void
		{
			curCount--;
			camDialog.countdown.text = String(curCount);
			
			if (curCount == 0) {
				TweenLite.killTweensOf(camDialog.redLED);
				
				countdownTimer.stop();
				countdownTimer.removeEventListener(TimerEvent.TIMER, decrementCount);
				
				//per pete remove the progress bar for now...
				doScare();
				//TweenLite.to(camDialog.recComplete, 1, { alpha:1, onComplete:beginProgress } );
			}
		}
		
		
		private function beginProgress():void
		{
			TweenLite.to(camDialog.recComplete.progBar, .5, { scaleX:.75, onComplete:doScare } );
		}
		
		
		/**
		 * Called by clicking cancel in the dialog and by camListener()
		 * 
		 * @param	e
		 */
		private function hideCamDialog(e:MouseEvent = null):void
		{
			//release the cam
			if(camVid){
				camVid.attachCamera(null);
			}
			
			countdownTimer.stop();
			countdownTimer.removeEventListener(TimerEvent.TIMER, decrementCount);
			camDialog.btnCancel.removeEventListener(MouseEvent.CLICK, hideCamDialog);			
			
			TweenLite.to(camDialog, .5, { alpha:0, onComplete:killCamDialog } );
			
			fadeInBGSound();
			vid.vid.volume = 1;
			
			//reset marker in nav to home button
			if (atP2) {
				p2.nav.marker.y = p2.nav.btnReal.y + 5;
			}else{
				bg.nav.marker.y = bg.nav.btnHome.y + 5;
			}
		}
		
		
		private function killCamDialog():void
		{
			TweenLite.killTweensOf(camDialog.cont);
			if (contains(camDialog)) {
				removeChild(camDialog);
			}
			camDialog.gotoAndStop(1);
		}
		
		
		
		/**
		 * Called from hideCamDialog() once the user allows the camera
		 * @param	e
		 */
		private function doScare():void
		{	
			scarePicTimer.start();//calls takeScarePic after n ms
			
			scare.scare.gotoAndStop(1);
			scare.alpha = 1;
			
			setChildIndex(scare, this.numChildren - 1);
			scare.visible = true;
			expScreamSound.play();
			
			scare.y = 450;
			scare.scare.gotoAndPlay(2);
			TweenLite.to(scare, 1, { alpha:0, delay:1, overwrite:0, onComplete:hideScare } );
		}
		
		
		private function hideScare():void
		{			
			scare.y = 1304;
			whisperChan.stop();
		}
		
		
		private function getCam():void
		{			
			cam = Camera.getCamera();
			cam.addEventListener(StatusEvent.STATUS, camListener, false, 0, true);
			
			cam.setQuality(0, 80);
			cam.setMode(640, 480, 30);
			
			camWidth = cam.width;
			camHeight = cam.height;
			
			camVid = new Video(640,480);
			camVid.attachCamera(cam);
			
			//for scaling video into the preview template on step 3
			camMatrix = new Matrix();
			camMatrix.scale(401 / 640, 265 / 480);
		}
		
		
		/**
		 * Called by Status Event on Camera
		 * Sets the camAllowed boolean which is used in update()
		 * @param	e
		 */
		private function camListener(e:StatusEvent):void
		{
			cam.removeEventListener(StatusEvent.STATUS, camListener);
			camAllowed = e.code == "Camera.Unmuted" ? true : false;			
		}
		
		
		private function takeScarePicture(e:TimerEvent):void
		{			
			saveData.draw(camVid);
			var ov:BitmapData = new overlay();
			saveData.draw(ov);
			
			var ba:ByteArray = imageSaver.getJpeg(saveData);
			var s:String = imageSaver.getBase64(ba);
			imageSaver.postImage(s);
			
			hideCamDialog();
			
			//show the image in the container
			scareClipContainer.thePic.addChild(new Bitmap(saveData));
			
			scareClipContainer.btnClose.buttonMode = true;
			scareClipContainer.btnClose.addEventListener(MouseEvent.CLICK, closeScareClipContainer, false, 0, true);
			
			scareClipContainer.fbBar.alpha = 0;
			scareClipContainer.fbBar.theText.text = "";
			
			scareClipContainer.alpha = 0;
			addChild(scareClipContainer);
			TweenLite.to(scareClipContainer, 1, { alpha:1 } );
		}
		
		
		private function closeScareClipContainer(e:MouseEvent = null):void
		{
			scareClipContainer.btnClose.removeEventListener(MouseEvent.CLICK, closeScareClipContainer);
			scareClipContainer.fbBar.btnFB.removeEventListener(MouseEvent.CLICK, startFacebookPost);
			TweenLite.to(scareClipContainer, 1, { alpha:0, onComplete:killScareClipContainer } );
		}
		private function killScareClipContainer():void
		{
			removeChild(scareClipContainer);
		}
		
		
		/**
		 * Called by clicking Facebook button on scare image
		 * @param	e
		 */
		private function startFacebookPost(e:MouseEvent):void
		{
			ExternalInterface.call("checkLog", FBShareURL);
			ExternalInterface.addCallback("wallPostSucceeded", wallPostGood);
			ExternalInterface.addCallback("wallPostFailed", wallPostBad);
		}
		private function wallPostGood():void
		{
			scareClipContainer.fbBar.theText.text = "Thank you! Your wall post was successful";			
		}
		private function wallPostBad():void
		{
			scareClipContainer.fbBar.theText.text = "Sorry - there was an error posting to your wall. Please try again";			
		}
		
		//callbacks from saving the image
		private function imageWasSaved(e:Event):void
		{
			FBShareURL = imageSaver.getResponse();
			//FBShareURL = "http://fxhorrorshow.gmrstage.com/Scare?id=" + id;
			
			scareClipContainer.fbBar.theText.text = "<- Click to share on Facebook";
			scareClipContainer.fbBar.alpha = 0;
			TweenLite.to(scareClipContainer.fbBar, 1, { alpha:1 } );
			
			scareClipContainer.fbBar.btnFB.buttonMode = true;
			scareClipContainer.fbBar.btnFB.addEventListener(MouseEvent.CLICK, startFacebookPost, false, 0, true);
		}
		
		private function imageWasNotSaved(e:Event):void
		{
			trace("save error");
		}
		
		
		private function playS1Vid(e:MouseEvent = null):void
		{
			if(curVid != "montage.flv"){
				curVid = "montage.flv";
				fadeInBGSound();
				playNewVid();
			}
		}
		private function playS2Vid(e:MouseEvent = null):void
		{
			if(curVid != "mainVid.flv"){
				curVid = "mainVid.flv";
				fadeOutBGSound();
				playNewVid();
			}
		}
		private function glowVidButton(e:MouseEvent):void
		{
			TweenLite.to(e.currentTarget, 1, {glowFilter:{color:0xcc9933, alpha:1, blurX:10, blurY:10, strength:2}});
		}
		private function noGlowVidButton(e:MouseEvent):void
		{
			TweenLite.to(e.currentTarget, 1, {glowFilter:{color:0xcc9933, alpha:0, blurX:10, blurY:10, strength:2}});
		}
		private function playNewVid():void
		{
			var v:String = VID_BASE_URL + curVid;
			vid.vid.source = v;
			
			vid.loading.visible = true;
			vid.loading.scaleX = vid.loading.scaleY = 1;
			vid.loading.x = -48;
			vid.loading.y = -18;
			
			vid.vid.addEventListener(VideoEvent.READY, mainVidReady, false, 0, true);
			vid.vid.addEventListener(VideoEvent.PLAYING_STATE_ENTERED, mainVidPlaying, false, 0, true);
			
			addEventListener(Event.ENTER_FRAME, rotateLoader, false, 0, true);
			
			vid.vid.playWhenEnoughDownloaded();
		}
		
		
		/**
		 * Called by READY event - happens when the first frame of the video is showing - make the
		 * loader preview smaller and place in the corner
		 * @param	e
		 */
		private function mainVidReady(e:VideoEvent):void
		{			
			vid.vid.removeEventListener(VideoEvent.READY, mainVidReady);
			vid.loading.scaleX = vid.loading.scaleY = .5;
			vid.loading.x = 180;
			vid.loading.y = 110;
		}
		
		
		
		/**
		 * Called by PLAYING_STATE_ENTERED event - once enough of the video is downloaded and
		 * play begins - hides the loading indicator
		 * @param	e
		 */
		private function mainVidPlaying(e:VideoEvent = null):void
		{			
			vid.loading.visible = false;
			vid.vid.removeEventListener(VideoEvent.PLAYING_STATE_ENTERED, mainVidPlaying);
			removeEventListener(Event.ENTER_FRAME, rotateLoader);
		}	
		
		
		private function rotateLoader(e:Event):void
		{
			vid.loading.circ.rotation += 2;
		}		
		
		
		
		/**
		 * Called by ENTER_FRAME
		 * rotates the bg and video according to mouse pos
		 * @param	e
		 */
		private function update(e:Event):void
		{
			if(!atP2){
				bg.rotationY = (480 - mouseX) / 30;
				bg.rotationX = (375 - mouseY) / 50;
				
				vid.rotationY = vidInitialRotation - ((480 - mouseX) / 40);
				vid.rotationX = -(375 - mouseY) / 50;
				
				//vidShadow.rotationY = vidInitialRotation - ((480 - mouseX) / 40);
				//vidShadow.rotationX = -(375 - mouseY) / 50;			
			}
			
			if (camAllowed) {				
				camImageData.draw(camVid, camMatrix);
			}
			
		}
		
		
		
		/**
		 * Called by MOUSE_OVER on the button
		 * @param	e
		 */
		private function playLetUsIn(e:MouseEvent):void
		{			
			bg.letUs.play();
			bg.letUs.addEventListener(Event.COMPLETE, loopLetUsIn, false, 0, true);
		}
		
		
		
		/**
		 * Called by MOUSE_OUT on the button
		 * @param	e
		 */
		private function stopLetUsIn(e:MouseEvent):void
		{
			bg.letUs.seek(0);
			bg.letUs.stop();
		}
		
		
		
		/**
		 * Called by COMPLETE on the main video
		 * @param	e
		 */
		private function loopVid(e:Event = null):void
		{			
			//vid.vid.seek(0);
			vid.vid.playWhenEnoughDownloaded();			
		}
		
		
		
		/**
		 * Called by COMPLETE when the title video loops
		 * @param	e
		 */
		private function loopTitle(e:Event = null):void
		{			
			//bg.title.seek(0);
			bg.title.playWhenEnoughDownloaded();
		}
		
		
		
		/**
		 * Called by COMPLETE when the button video loops
		 * @param	e
		 */
		private function loopLetUsIn(e:Event):void
		{			
			bg.letUs.play();
		}
		
		
		
		/**
		 * Page 2 - house calls
		 * Called by pressing the let us in on home page
		 * or Let us In in the menu nav
		 * @param	e
		 */
		private function letUsIn(e:MouseEvent = null):void
		{
			removeMenuListeners();
			
			clickSound.play();
			
			bg.title.removeEventListener(Event.COMPLETE, loopTitle);
			//removeEventListener(Event.ENTER_FRAME, update);
			vid.vid.removeEventListener(Event.COMPLETE, loopVid);
			bg.letUs.removeEventListener(Event.COMPLETE, loopLetUsIn);			
			bg.let.removeEventListener(MouseEvent.MOUSE_OVER, playLetUsIn);
			bg.let.removeEventListener(MouseEvent.MOUSE_OUT, stopLetUsIn);
			bg.let.removeEventListener(MouseEvent.CLICK, letUsIn);
			
			//bg.fearDial.btn1.removeEventListener(MouseEvent.CLICK, chooseFear);
			//bg.fearDial.btn2.removeEventListener(MouseEvent.CLICK, chooseFear);
			//bg.fearDial.btn3.removeEventListener(MouseEvent.CLICK, chooseFear);
			//bg.fearDial.btn4.removeEventListener(MouseEvent.CLICK, chooseFear);
			
			//removes enter frame to stop rotation on buffering and hides buffering
			mainVidPlaying();
			
			//vid.vid.getVideoPlayer(vid.vid.activeVideoPlayerIndex).close();
			//bg.title.getVideoPlayer(bg.title.activeVideoPlayerIndex).close();
			//bg.letUs.getVideoPlayer(bg.letUs.activeVideoPlayerIndex).close();
			
			vid.vid.stop();
			bg.title.stop();
			bg.letUs.stop();
			//vid.vid.closeVideoPlayer(vid.vid.activeVideoPlayerIndex);
			//bg.title.closeVideoPlayer(bg.title.activeVideoPlayerIndex);
			//bg.letUs.closeVideoPlayer(bg.letUs.activeVideoPlayerIndex);
			
			p2.scream.getVideoPlayer(p2.scream.activeVideoPlayerIndex).smoothing = true;
			p2.areYouReady.getVideoPlayer(p2.areYouReady.activeVideoPlayerIndex).smoothing = true;
			
			addChild(p2);
			addChild(bMask);
			bMask.y = -100;
			bMask.x = -300;
			bMask.width += 300;
			p2.mask = bMask;
			
			showNavP2();
			
			bMask.gotoAndPlay(2);
			atP2 = true;		
		}
		
		
		private function showNavP2():void
		{
			//show the nav marker in its proper spot next to house calls
			p2.nav.marker.y = p2.nav.btnReal.y + 5;
			
			p2.nav.btnHome.buttonMode = true;
			//p2.nav.btnReal.buttonMode = true;
			p2.nav.btnExp.buttonMode = true;
			//p2.nav.btnDont.buttonMode = true;
			p2.nav.btnLet.buttonMode = true;
			
			p2.nav.btnHome.addEventListener(MouseEvent.MOUSE_OVER, glowVidButton, false, 0, true);
			p2.nav.btnHome.addEventListener(MouseEvent.MOUSE_OUT, noGlowVidButton, false, 0, true);
			p2.nav.btnHome.addEventListener(MouseEvent.CLICK, init, false, 0, true);
			
			p2.nav.btnExp.addEventListener(MouseEvent.MOUSE_OVER, glowVidButton, false, 0, true);
			p2.nav.btnExp.addEventListener(MouseEvent.MOUSE_OUT, noGlowVidButton, false, 0, true);
			p2.nav.btnExp.addEventListener(MouseEvent.CLICK, moveMarker, false, 0, true);
			p2.nav.btnExp.addEventListener(MouseEvent.CLICK, showCamDialog, false, 0, true);
			
			//p2.nav.btnDont.addEventListener(MouseEvent.MOUSE_OVER, glowVidButton, false, 0, true);
			//p2.nav.btnDont.addEventListener(MouseEvent.MOUSE_OUT, noGlowVidButton, false, 0, true);
			//p2.nav.btnDont.addEventListener(MouseEvent.CLICK, gotoDontPickItUp, false, 0, true);
			
			p2.nav.btnLet.addEventListener(MouseEvent.MOUSE_OVER, glowVidButton, false, 0, true);
			p2.nav.btnLet.addEventListener(MouseEvent.MOUSE_OUT, noGlowVidButton, false, 0, true);
			p2.nav.btnLet.addEventListener(MouseEvent.CLICK, moveMarker, false, 0, true);
			p2.nav.btnLet.addEventListener(MouseEvent.CLICK, gotoForm, false, 0, true);
		}
		
		private function lowerBGSound(e:Event = null):void
		{
			TweenLite.to(vol, 2, { volume:.3, onUpdate:reapplySoundTransform } );
		}
		
		private function fadeOutBGSound(e:Event = null):void
		{
			TweenLite.to(vol, 2, { volume:0, onUpdate:reapplySoundTransform } );
		}
		
		private function fadeInBGSound(e:Event = null):void
		{
			TweenLite.to(vol, 2, { volume:1, onUpdate:reapplySoundTransform } );
		}
		
		private function reapplySoundTransform():void
		{
			backChannel.soundTransform = vol;
		}
		
		/**
		 * Called from JavaScript
		 */
		private function vidWindowClosed():void
		{
			fadeInBGSound();
		}
		
		
		/**
		 * 
		 * @param	e mask done event from last frame of mask clip
		 */
		private function removeBloodMask(e:Event):void
		{	
			removeChild(bg);
			removeChild(vid);
			removeChild(bMask);
			p2.mask = null;
			
			p2.signUp.addEventListener(MouseEvent.CLICK, gotoForm, false, 0, true);
			p2.signUp.addEventListener(MouseEvent.MOUSE_OVER, glowSignUp, false, 0, true);
			p2.signUp.addEventListener(MouseEvent.MOUSE_OUT, unglowSignUp, false, 0, true);
			p2.signUp.buttonMode = true;
			
			//playHandVid();
			p2.scream.play();
			screamSound.play();
			
			p2.houseCalls.addEventListener(HouseCalls.HOUSE_CALL_STARTED, fadeOutBGSound, false, 0, true);
			p2.houseCalls.addEventListener(HouseCalls.HOUSE_CALL_STOPPED, fadeInBGSound, false, 0, true);
			
			//Fear Transition
			//used fears flvPlayback component on the stage - x,y: -80, -40     1600x900
			/*
			if(whichFear != 0){
				p2.fears.alpha = 0;
				//p2.fears.source = VID_BASE_URL + "feartran" + whichFear + ".flv";
				p2.fears.source = "assets/feartran" + whichFear + ".flv";
				p2.fears.addEventListener(MetadataEvent.CUE_POINT, fearCue, false, 0, true);
				p2.fears.addEventListener(VideoEvent.PLAYING_STATE_ENTERED, fearTranPlaying, false, 0, true);
				p2.fears.playWhenEnoughDownloaded();
			}
			*/
		}
		/*
		private function fearTranPlaying(e:VideoEvent):void
		{
			p2.fears.alpha = 1;
			p2.fears.removeEventListener(VideoEvent.PLAYING_STATE_ENTERED, fearTranPlaying);
		}
		private function fearCue(e:MetadataEvent):void
		{		
			if (e.info.name == "theend") {
				p2.fears.removeEventListener(MetadataEvent.CUE_POINT, fearCue);
				TweenLite.to(p2.fears, .5, { alpha:0, onComplete:killFearTransition } );
			}
		}
		private function killFearTransition():void
		{			
			p2.fears.stop();
			p2.fears.seek(0);
		}
		*/
		
		private function playHandVid():void
		{
			//play the hands video
			p2.areYouReady.play();
			handSound.play();
		}
		
		
		private function gotoForm(e:MouseEvent):void
		{	
			navigateToURL(new URLRequest("/registrants/create"), "_self");			
		}
		
		
		private function gotoDontPickItUp(e:MouseEvent):void
		{
			navigateToURL(new URLRequest("/registrants/PhoneNotify"), "_self");
		}
		
		
		private function glowSignUp(e:MouseEvent):void
		{
			playHandVid();			
			TweenLite.to(p2.signUpText, 1, {glowFilter:{color:0xcc9933, alpha:1, blurX:30, blurY:30, strength:2}});
		}
		
		
		private function unglowSignUp(e:MouseEvent):void
		{
			TweenLite.to(p2.signUpText, 1, {glowFilter:{color:0xcc9933, alpha:0, blurX:30, blurY:30}});
		}
		
	}
	
}