/**
 * Requires AIR 3.1
 * Uses new core JSON object
 * 
 * instantiated by Main
 */

package com.sagecollective.corona.atp
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
		public static const PHOTO_POSTING:String = "photoCurrentlyPosting";
		public static const PHOTO_POSTED:String = "photoPostedToFacebook";
		public static const LOGIN_FAIL:String = "facebookLoginFailed";
	
		private const APP_ID:String = "240204919390950";//corona beach house
		private var photo:Bitmap;
		
		private var wait:Timer;
		private var links:Array; //two links to post in the FB message

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
		public function init(bmp:Bitmap, $links:Array):void
		{			
			links = $links;
			
			//trace("FB init()");
			var scaled:BitmapData = new BitmapData(810, 540);//size to send to FB
			var m:Matrix = new Matrix();
			m.scale(scaled.width / bmp.width, scaled.height / bmp.height);
			scaled.draw(bmp, m, null, null, null, true);
			photo = new Bitmap(scaled);
			
			FacebookDesktop.init(APP_ID, initHandler);
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
				FacebookDesktop.logout(logoutCallback," http://coronaatp.thesocialtab.net/Home/");
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
			if(res){
				dispatchEvent(new Event(PHOTO_POSTING));
				wait.start(); //start timer to call postPhoto() in 100ms
				//gives time fordispatch to bring up dialog
			}else {
				//trace("FB loginCallback FAIL");
				dispatchEvent(new Event(LOGIN_FAIL));
			}
		}
		
		
		private function postPhoto(e:TimerEvent):void
		{
			var mess:String = "Hello from the Corona Beach House. Wish you were here...\n" + links[0] + "\n" + links[1];
			var params:Object = {image:photo, message:mess, fileName:'FILE_NAME'};
			FacebookDesktop.api("me/photos", photoPostCallback, params);
		}		
		
		
		/**
		 * Callback from completing photo post
		 * @param	success
		 * @param	fail
		 */
		private function photoPostCallback(success:Object, fail:Object){
			//trace("wallPostCallback()", success, fail);
			if(success){
				dispatchEvent(new Event(PHOTO_POSTED));
			}
			FacebookDesktop.logout(logoutCallback, " http://coronaatp.thesocialtab.net/Home/");
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