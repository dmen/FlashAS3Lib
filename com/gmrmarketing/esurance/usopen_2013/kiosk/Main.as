package com.gmrmarketing.esurance.usopen_2013.kiosk
{
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication; //for quitting
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	public class Main extends MovieClip
	{
		private var rfid:RFID;
		private var chooseApp:ChooseApp;
		private var dialog:Dialog;
		private var fyn:FYN;
		private var pic:Pic;
		private var imageHelper:ImageHelper;
		
		private var mainContainer:Sprite;
		private var dialogContainer:Sprite;
		private var cornerContainer:Sprite;
		private var cq:CornerQuit;
		
		private var tim:TimeoutHelper;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			//Mouse.hide();
			
			mainContainer = new Sprite();
			dialogContainer = new Sprite();
			cornerContainer = new Sprite();
			addChild(mainContainer);		
			addChild(dialogContainer);
			addChild(cornerContainer);
			
			rfid = new RFID();
			rfid.setContainer(mainContainer);			
			
			chooseApp = new ChooseApp();
			chooseApp.setContainer(mainContainer);
			
			fyn = new FYN();
			fyn.setContainer(mainContainer);
			
			pic = new Pic();
			pic.setContainer(mainContainer);
			
			dialog = new Dialog();
			dialog.setContainer(dialogContainer);
			
			imageHelper = new ImageHelper();
			
			cq = new CornerQuit();
			cq.init(cornerContainer, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApp, false, 0, true);
			
			tim = TimeoutHelper.getInstance();
			tim.addEventListener(TimeoutHelper.TIMED_OUT, doReset, false, 0, true);
			tim.init(120000);//2 min			
			
			init();
		}
		
		
		/**
		 * Shows the RFID / Intro screen
		 * called from constructor and doReset()
		 */
		private function init():void
		{
			tim.stopMonitoring();
			rfid.addEventListener(RFID.RFID_BAD, rfidError, false, 0, true);
			rfid.addEventListener(RFID.RFID_GOOD, rfidOK, false, 0, true);
			rfid.show();
		}
		
		
		private function rfidError(e:Event):void
		{			
			dialog.show("RFID not recognized - please register first");
		}
		
		
		private function rfidOK(e:Event = null):void
		{
			rfid.removeEventListener(RFID.RFID_BAD, rfidError);
			rfid.removeEventListener(RFID.RFID_GOOD, rfidOK);
			rfid.hide();
			
			//start monitoring for a timeout
			tim.startMonitoring();
			
			chooseApp.show();
			chooseApp.addEventListener(ChooseApp.FYN_PICKED, showFYN, false, 0, true);
			chooseApp.addEventListener(ChooseApp.PIC_PICKED, showPic, false, 0, true);
			chooseApp.addEventListener(ChooseApp.BACK_TO_RFID, doReset, false, 0, true);
		}
		
		
		private function showFYN(e:Event):void
		{
			chooseApp.removeEventListener(ChooseApp.FYN_PICKED, showFYN);
			chooseApp.removeEventListener(ChooseApp.PIC_PICKED, showPic);
			chooseApp.hide();
			
			var ud:Object = rfid.getUserData();
			
			fyn.show(ud.FirstName, ud.LastName, ud.AccessToken);			
			fyn.addEventListener(FYN.GO_BACK, backFromFYN, false, 0, true);			
			fyn.addEventListener(FYN.IMAGE_READY, beginFYNPost, false, 0, true);
		}
		
		
		private function backFromFYN(e:Event):void
		{
			fyn.hide();
			dialog.hide();
			fyn.removeEventListener(FYN.GO_BACK, backFromFYN);
			fyn.removeEventListener(FYN.IMAGE_READY, beginFYNPost);
			
			rfidOK();//shows app selection screen
		}
		
		
		/**
		 * Called when imageReady event is dispatched from FYN
		 * this is when the bitmapData object is ready - now we can encode
		 * @param	e
		 */
		private function beginFYNPost(e:Event):void
		{
			tim.stopMonitoring();
			dialog.progress("encoding image...");			
			imageHelper.addEventListener(ImageHelper.DONE_ENCODING, doFYNServerPost, false, 0, true);
			TweenMax.delayedCall(.5, delayedFYNEncode);
		}
		private function delayedFYNEncode():void
		{
			imageHelper.encode(fyn.getImage());
		}
		
		/**
		 * Called when the jpeg is done encoding		 * 
		 * @param	e
		 */
		private function doFYNServerPost(e:Event):void
		{
			dialog.progress("uploading to server...");
			
			var ud:Object = rfid.getUserData();
			
			imageHelper.removeEventListener(ImageHelper.DONE_ENCODING, doFYNServerPost);
			
			if (ud.AccessToken == null || ud.AccessToken == "") {
				imageHelper.addEventListener(ImageHelper.SERVER_UPLOAD_COMPLETE, fynPostComplete, false, 0, true);
			}else{
				imageHelper.addEventListener(ImageHelper.SERVER_UPLOAD_COMPLETE, doFYNFBPost, false, 0, true);
			}
			
			imageHelper.postEncoded(ud.Rfid, "MyPik_3");
		}
		
		/**
		 * Called when the image has uploaded to the server
		 * @param	e
		 */
		private function doFYNFBPost(e:Event):void
		{
			dialog.progress("posting to facebook...");
			
			imageHelper.removeEventListener(ImageHelper.SERVER_UPLOAD_COMPLETE, doFYNFBPost);
			imageHelper.addEventListener(ImageHelper.FB_POST_GOOD, fynPostComplete, false, 0, true);
			imageHelper.addEventListener(ImageHelper.SERVER_UPLOAD_ERROR, postError, false, 0, true);
			
			var ud:Object = rfid.getUserData();
			imageHelper.fynFBPost(ud.AccessToken);
		}
		
		
		private function fynPostComplete(e:Event):void
		{
			dialog.show("complete, thank you!");
			imageHelper.removeEventListener(ImageHelper.FB_POST_GOOD, fynPostComplete);
			imageHelper.removeEventListener(ImageHelper.SERVER_UPLOAD_COMPLETE, fynPostComplete);
			imageHelper.removeEventListener(ImageHelper.SERVER_UPLOAD_ERROR, postError);
			tim.startMonitoring();
		}
		
		
		private function showPic(e:Event):void
		{
			chooseApp.removeEventListener(ChooseApp.FYN_PICKED, showFYN);
			chooseApp.removeEventListener(ChooseApp.PIC_PICKED, showPic);
			chooseApp.hide();
			
			var ud:Object = rfid.getUserData();
			
			dialog.progress("loading your image...");
			
			pic.addEventListener(Pic.GO_BACK, backFromPic, false, 0, true);
			pic.addEventListener(Pic.IMAGE_READY, beginPicPost, false, 0, true);
			pic.addEventListener(Pic.MYPIK_LOADED, myPikLoaded, false, 0, true);
			pic.addEventListener(Pic.NO_IMAGE, noImage, false, 0, true);			
			pic.addEventListener(Pic.MYPIK_FAILED, myPikFail, false, 0, true);			
			pic.show(ud.Rfid, ud.AccessToken);
		}
		
		
		private function myPikLoaded(e:Event):void
		{
			pic.removeEventListener(Pic.MYPIK_LOADED, myPikLoaded);
			dialog.hide();
		}
		
		
		private function noImage(e:Event):void
		{			
			dialog.show("no image found for this RFID");
		}
		
		
		private function myPikFail(e:Event):void
		{			
			dialog.show("an error occured retrieving the image");
		}
		
		/**
		 * Called if the back button in the pic screen is pressed
		 * @param	e
		 */
		private function backFromPic(e:Event):void
		{
			pic.hide();
			dialog.hide();
			pic.removeEventListener(Pic.GO_BACK, backFromPic);
			pic.removeEventListener(Pic.IMAGE_READY, beginPicPost);
			pic.removeEventListener(Pic.MYPIK_LOADED, myPikLoaded);
			pic.removeEventListener(Pic.NO_IMAGE, noImage);
			pic.removeEventListener(Pic.MYPIK_FAILED, myPikFail);
			rfidOK();
		}
		
		
		/**
		 * Called when the user presses post to fb/ send to email in the overlay screen
		 * and the bitmap is ready for posting
		 * @param	e
		 */
		private function beginPicPost(e:Event):void
		{
			tim.stopMonitoring();
			dialog.progress("encoding image...");			
			imageHelper.addEventListener(ImageHelper.DONE_ENCODING, doMyPikServerPost, false, 0, true);
			
			TweenMax.delayedCall(.5, delayedMyPikEncode);//delay 1/2 sec so Encoding image shows in the dialog
		}
		
		private function delayedMyPikEncode():void
		{
			imageHelper.encode(pic.getImage());
		}
		
		
		private function doMyPikServerPost(e:Event):void
		{
			dialog.progress("uploading to server...");
			
			var ud:Object = rfid.getUserData();
			
			imageHelper.removeEventListener(ImageHelper.DONE_ENCODING, doMyPikServerPost);
			
			if (ud.AccessToken == null || ud.AccessToken == "") {
				imageHelper.addEventListener(ImageHelper.SERVER_UPLOAD_COMPLETE, fynPostComplete, false, 0, true);
			}else{
				imageHelper.addEventListener(ImageHelper.SERVER_UPLOAD_COMPLETE, doMyPikFBPost, false, 0, true);
			}
			imageHelper.postEncoded(ud.Rfid, "MyPik_2");
		}
		
		private function postError(e:Event):void
		{
			dialog.show("an error occured\nposting to facebook.\nplease try again.");
			imageHelper.removeEventListener(ImageHelper.FB_POST_GOOD, fynPostComplete);
			imageHelper.removeEventListener(ImageHelper.SERVER_UPLOAD_COMPLETE, fynPostComplete);
			imageHelper.removeEventListener(ImageHelper.SERVER_UPLOAD_ERROR, postError);
			tim.startMonitoring();
		}
		
		private function doMyPikFBPost(e:Event):void
		{
			dialog.progress("posting to facebook...");
			
			imageHelper.removeEventListener(ImageHelper.SERVER_UPLOAD_COMPLETE, doMyPikFBPost);
			imageHelper.addEventListener(ImageHelper.FB_POST_GOOD, fynPostComplete, false, 0, true);
			imageHelper.addEventListener(ImageHelper.SERVER_UPLOAD_ERROR, postError, false, 0, true);
			var ud:Object = rfid.getUserData();
			imageHelper.myPikFBPost(ud.AccessToken);
		}
		
		
		/**
		 * called when a timeout event happens from the TimeoutHelper object
		 * or back is pressed in the choose app screen
		 * @param	e
		 */
		private function doReset(e:Event):void
		{
			chooseApp.hide();
			dialog.hide();
			fyn.hide();			
			pic.hide();
			
			init();
		}
		
		private function quitApp(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
	}
	
}