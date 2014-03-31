/**
 * Requires AIR 3.1
 * Uses new core JSON object
 * 
 * instantiated by Main
 */

package com.gmrmarketing.jimbeam.boldchoice
{
	import com.gmrmarketing.utilities.Utility;
	import com.facebook.graph.FacebookMobile;	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.geom.Matrix;
	import flash.media.StageWebView;

	public class Facebook extends EventDispatcher
	{
		public static const PHOTO_POSTING:String = "photoCurrentlyPosting";
		public static const PHOTO_POSTED:String = "photoPostedToFacebook";
		public static const LOGIN_FAIL:String = "facebookLoginFailed";
	
		private const APP_ID:String = "189368524512102";
		private var photo:Bitmap;
		
		private var wait:Timer;
		private var links:Array; //two links to post in the FB message
		
		private var container:DisplayObjectContainer;
		private var webView:StageWebView;
		
		private var correct:int;//questions correct and total - set in init()
		private var total:int;
		

		public function Facebook()
		{
			wait = new Timer(100, 1);
			wait.addEventListener(TimerEvent.TIMER, postPhoto, false, 0, true);
		}
		
		
		/**
		 * Call to bring up the login dialog
		 * full size card image is incoming - 1350x900
		 * scales to 810x540
		 */
		public function init($container:DisplayObjectContainer, $webView:StageWebView, numCorrect:int, numTotal:int):void
		{	
			container = $container;
			webView = $webView;
			correct = numCorrect;
			total = numTotal;
			
			FacebookMobile.init(APP_ID, initHandler);
		}
		
		
		/**
		 * Callback from opening login dialog
		 * If the user is already logged in, calls logout first
		 * @param	result
		 * @param	fail
		 */
		private function initHandler(result:Object = null, fail:Object = null):void
		{
			//trace("fb initHandler = ", result, fail);
			if (fail != null) {	
				Utility.iterateObject(fail.error);
				FacebookMobile.logout(logoutCallback, "http://jimbeamboldchoice.thesocialtab.net/facebook/");
			}else{
				FacebookMobile.login(loginCallback, container.stage, ["publish_stream"], webView);
			}
		}
		
		
		/**
		 * Callback from logging out - res is true when logout is successful
		 * @param	res
		 */
		private function logoutCallback(res:Object):void
		{
			//trace("logoutCallback",res);
			initHandler();
		}
		
		
		private function logoutCallback2(res:Object):void
		{
			//trace("lgoutCallback2",res);
		}
		
		
		/**
		 * Callback from logging in
		 * Uploads the bitmap passed to init() to the app's album on the users page
		 * @param	res
		 * @param	fail
		 */
		private function loginCallback(res:Object, fail:Object):void
		{			
			if(res){
				dispatchEvent(new Event(PHOTO_POSTING));
				wait.start(); //start timer to call postPhoto() in 100ms
				//gives time for dispatch to bring up dialog
			}else {
				
				dispatchEvent(new Event(LOGIN_FAIL));
			}
		}
		
		
		private function postPhoto(e:TimerEvent):void
		{			
			var params:Object = { link:"https://www.facebook.com/JimBeam/app_189368524512102", picture:"http://digimedia.gmrmarketing.com/JimBeamBoldChoice/icon.png", message:"I scored a " + String(correct) + " out of " + String(total) + " in Jim Beam's Bold Choice Trivia! Think you know Bold choices in sports & music? Play Jim Beam’s Bold Choice Trivia and find out!", caption:"Jim Beam's Bold Choice Trivia" };
			FacebookMobile.api("me/feed", photoPostCallback, params, 'POST');
		}		
		
		
		/**
		 * Callback from completing photo post
		 * @param	success
		 * @param	fail
		 */
		private function photoPostCallback(success:Object, fail:Object){
			//trace("wallPostCallback()", success, fail);
			if (success) {
				Utility.iterateObject(success[0]);
				Utility.iterateObject(success[1]);
				Utility.iterateObject(success[2]);
				Utility.iterateObject(success[3]);
				Utility.iterateObject(success[4]);
				dispatchEvent(new Event(PHOTO_POSTED));
			}
			
			FacebookMobile.logout(logoutCallback2, "http://jimbeamboldchoice.thesocialtab.net/facebook/");
		}
		
		
		/**
		 * Called by Main.init()
		 * closeLogin method added by DM
		 */
		public function closeWindow():void
		{
			//FacebookDesktop.closeLogin();
		}

	}
	
}