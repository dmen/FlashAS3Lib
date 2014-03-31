/**
 * Requires AIR 3.1
 * Uses new core JSON object
 * 
 * instantiated by Main
 */

package com.gmrmarketing.nissan.rodale.athfleet
{
	import com.facebook.graph.FacebookDesktop;	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.geom.Matrix;
	

	public class Facebook extends EventDispatcher
	{
		public static const DATA_POSTING:String = "photoCurrentlyPosting";
		public static const DATA_POSTED:String = "photoPostedToFacebook";
		public static const LOGIN_FAIL:String = "facebookLoginFailed";
	
		private const APP_ID:String = "321406214596720";
		private var wait:Timer;
		private var userName:String;
		private var athName:String;
		private var userCar:String;
		

		public function Facebook()
		{
			wait = new Timer(100, 1);
			wait.addEventListener(TimerEvent.TIMER, postPhoto, false, 0, true);
		}
		
		
		/**
		 * Call to bring up the login dialog		 
		 */
		public function init($userName:String, $athName:String, $userCar:String):void
		{				
			userName = $userName;
			athName = $athName;
			userCar = $userCar;
			FacebookDesktop.init(APP_ID, initHandler);
		}
		
		/**
		 * Called from Results if try again is picked
		 */
		public function closeLogin():void
		{
			FacebookDesktop.closeLogin();
		}
		
		
		/**
		 * Callback from opening login dialog
		 * If the user is already login, calls logout first
		 * @param	result
		 * @param	fail
		 */
		private function initHandler(result:Object, fail:Object):void
		{	
			//trace("FB init Handler:", result, fail);
			
			if (!fail) {		
				//trace("FB calling logout");
				FacebookDesktop.logout(logoutCallback,"http://nissanrodale2012.thesocialtab.net/");
			}
			
			FacebookDesktop.login(loginCallback, ["publish_stream"]);
		}
		
		
		/**
		 * Callback from logging out - res is true when logout is successful
		 * @param	res
		 */
		private function logoutCallback(res:Object):void
		{
			//trace("logoutCallback",res);	
		}
		
		
		/**
		 * Callback from logging in
		 * Uploads the bitmap passed to init() to the app's album on the users page
		 * @param	res
		 * @param	fail
		 */
		private function loginCallback(res:Object, fail:Object):void
		{
			//trace(loginCallback, res, fail);//fail = 'user-canceled' if user pressed cancel, or x close button on dialog
			if(res){
				dispatchEvent(new Event(DATA_POSTING));
				wait.start(); //start timer to call postPhoto() in 100ms
				//gives time fordispatch to bring up dialog
			}else {
				
				//trace("FB loginCallback FAIL");
				dispatchEvent(new Event(LOGIN_FAIL));
			}
		}
		
		
		private function postPhoto(e:TimerEvent):void
		{	
			var params:Object = {message: userName + " just took the Nissan Fitness Test and has similar interests as " + athName + " and may someday be driving a Nissan " + userCar, caption:"Nissan Rodale"};
			FacebookDesktop.api("me/feed", postCallback, params, 'POST');
		}
		
		
		/**
		 * Callback from completing photo post
		 * @param	success
		 * @param	fail
		 */
		private function postCallback(success:Object, fail:Object){
			if(success){
				dispatchEvent(new Event(DATA_POSTED));
			}
			FacebookDesktop.logout(logoutCallback, "http://nissanrodale2012.thesocialtab.net/");
		}
		
		
		/**
		 * Called by Main.init()
		 * closeLogin method added by DM
		 */
		public function closeWindow():void
		{
			FacebookDesktop.closeLogin();
		}

	}
	
}