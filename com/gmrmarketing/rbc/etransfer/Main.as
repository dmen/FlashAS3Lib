package com.gmrmarketing.rbc.etransfer
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import com.greensock.TweenMax;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.ui.Mouse;
	import com.gmrmarketing.telus.karaoke.Form;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	
	public class Main extends MovieClip
	{
		private var intro:Intro;
		private var form:Form;
		private var privacy:Privacy;
		private var dialog:Dialog;
		private var video:Video;
		private var saved:Saved;
		private var thanks:Thanks;
		private var admin:Admin;
		private var queue:Queue;
		private var cq:CornerQuit;
		private var adminButton:CornerQuit;
		private var mainContainer:Sprite;
		private var topContainer:Sprite;
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			mainContainer = new Sprite();
			topContainer = new Sprite();
			
			addChild(mainContainer);
			addChild(topContainer);

			intro = new Intro();
			intro.setContainer(mainContainer);
			
			form = new Form();
			form.setContainer(mainContainer);
			
			privacy = new Privacy();
			privacy.setContainer(mainContainer);
			
			video = new Video();
			video.setContainer(mainContainer);
			
			saved = new Saved();
			saved.setContainer(mainContainer);
			
			thanks = new Thanks();
			thanks.setContainer(mainContainer);
			
			dialog = new Dialog();
			dialog.setContainer(mainContainer);
			
			admin = new Admin();
			admin.setContainer(topContainer);
			
			cq = new CornerQuit();
			cq.init(topContainer, "ur");
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
			
			adminButton = new CornerQuit();
			adminButton.init(topContainer, "ul");
			adminButton.addEventListener(CornerQuit.CORNER_QUIT, showAdmin, false, 0, true);
			
			queue = new Queue();
			queue.addEventListener(Queue.DEBUG_MESSAGE, newDebugMessage, false, 0, true);
			
			init();
		}
		
		private function init():void
		{
			intro.show();		
			intro.addEventListener(Intro.GET_STARTED, showForm, false, 0, true);
			intro.addEventListener(Intro.TERMS, showTerms, false, 0, true);
		}
		
		private function showForm(e:Event):void
		{			
			intro.removeEventListener(Intro.GET_STARTED, showForm);
			intro.removeEventListener(Intro.TERMS, showTerms);
			form.addEventListener(Form.SHOWING, removeIntro, false, 0, true);
			form.addEventListener(Form.SHOW_TERMS, showTerms, false, 0, true);
			form.addEventListener(Form.RESTART, doRestart, false, 0, true);
			form.addEventListener(Form.NO_TERMS, noTerms, false, 0, true);
			form.addEventListener(Form.BLANK_FIELDS, blankFields, false, 0, true);
			form.addEventListener(Form.BAD_EMAIL, badEmail, false, 0, true);
			form.addEventListener(Form.FORM_GOOD, formGood, false, 0, true);
			
			form.show();
		}
		
		private function removeIntro(e:Event):void
		{			
			intro.hide();			
		}
		
		//terms and conditions
		private function showTerms(e:Event):void
		{			
			privacy.addEventListener(Privacy.CLOSE_PRIVACY, hidePrivacy, false, 0, true);
			privacy.show();
		}
		
		private function hidePrivacy(e:Event):void
		{			
			privacy.hide();
		}
		
		private function noTerms(e:Event):void
		{
			dialog.show("YOU MUST ACCEPT THE TERMS AND CONDITIONS");
		}
		
		private function noGender(e:Event):void
		{
			dialog.show("PLEASE CHOOSE YOUR GENDER");
		}
		
		private function blankFields(e:Event):void
		{
			dialog.show("ALL FIELDS ARE REQUIRED");
		}
		
		private function badEmail(e:Event):void
		{
			dialog.show("INVALID EMAIL ADDRESS");
		}
		
		private function formGood(e:Event):void
		{
			form.removeEventListener(Form.SHOWING, removeIntro);
			form.removeEventListener(Form.SHOW_TERMS, showTerms);
			form.removeEventListener(Form.RESTART, doRestart);
			form.removeEventListener(Form.NO_TERMS, noTerms);
			form.removeEventListener(Form.BLANK_FIELDS, blankFields);
			form.removeEventListener(Form.BAD_EMAIL, badEmail);
			form.removeEventListener(Form.FORM_GOOD, formGood);	
			
			video.addEventListener(Video.VID_SHOWING, vidShowing, false, 0, true);
			video.addEventListener(Video.VID_RESET, doRestart, false, 0, true);
			video.addEventListener(Video.DONE_RECORDING, videoDone, false, 0, true);
			video.addEventListener(Video.REVIEW, videoReview, false, 0, true);
			
			video.show(form.getData().guid);
		}
		
		
		private function vidShowing(e:Event):void
		{
			form.hide();
		}
		
		
		private function videoReview(e:Event):void
		{
			trace("Main.videoReview");
			var vidPath:String = queue.getVideoPath() + form.getData().guid + ".flv";
			trace(vidPath);
			video.doReview(vidPath);
		}
		
		/**
		 * called when stop recording is pressed, or when
		 * the 15 sec timer times out
		 * @param	e Video.DONE_RECORDING
		 */
		private function videoDone(e:Event):void
		{			
			video.removeEventListener(Video.VID_SHOWING, vidShowing);
			video.removeEventListener(Video.VID_RESET, doRestart);
			video.removeEventListener(Video.DONE_RECORDING, videoDone);
			video.removeEventListener(Video.REVIEW, videoReview);
			
			saved.addEventListener(Saved.SHOWING, removeVideo, false, 0, true);
			saved.addEventListener(Saved.PRESSED, showThanks, false, 0, true);
			saved.show();
			
			
			//send data and vid to bb
			queue.addToQueue(form.getData());
		}
		
		/**
		 * Called when the save video screen is showing 
		 * removes the video screen
		 * @param	e
		 */
		private function removeVideo(e:Event):void
		{
			video.hide();			
		}
		
		/**
		 * Called when the continue button is pressed in the saved screen
		 * @param	e
		 */
		private function showThanks(e:Event):void
		{
			thanks.addEventListener(Thanks.THANKS_DONE, doRestart, false, 0, true);
			thanks.show();//shows thanks for 5 sec.
		}
		
		
		private function killVideo(e:Event):void
		{			
			video.hide();
		}
		
		
		/**
		 * Called by pressing the restart button at upper right
		 * or when the Thanks screen finishes
		 * @param	e
		 */
		private function doRestart(e:Event):void
		{
			form.removeEventListener(Form.SHOWING, removeIntro);
			form.removeEventListener(Form.SHOW_TERMS, showTerms);
			form.removeEventListener(Form.RESTART, doRestart);
			form.removeEventListener(Form.NO_TERMS, noTerms);
			form.removeEventListener(Form.BLANK_FIELDS, blankFields);
			form.removeEventListener(Form.BAD_EMAIL, badEmail);
			form.removeEventListener(Form.FORM_GOOD, formGood);
			
			video.removeEventListener(Video.VID_SHOWING, vidShowing);
			video.removeEventListener(Video.VID_RESET, doRestart);
			video.removeEventListener(Video.DONE_RECORDING, videoDone);
			
			thanks.removeEventListener(Thanks.THANKS_DONE, doRestart);
			
			saved.hide();
			form.hide();
			video.hide();
			thanks.hide();
			
			init();
		}
		
		
		private function newDebugMessage(e:Event):void
		{			
			if(admin.isShowing()){
				admin.displayDebug(queue.getDebugMessage());
			}
		}
		
		private function debug(mess:String):void
		{
			if(admin.isShowing()){
				admin.displayDebug(mess);
			}
		}
				
		
		private function quitApplication(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		
		private function showAdmin(e:Event):void
		{
			admin.show();
		}
		
		private function adminMoveToTop():void
		{
			if (admin.isShowing()) {
				admin.moveToTop();
			}
		}
	}
	
}