package com.gmrmarketing.testing
{
	import flash.display.LoaderInfo;
	import com.facebook.Facebook;
	import com.facebook.events.FacebookEvent;
	import com.facebook.net.FacebookCall;
	import com.facebook.data.users.FacebookUser;
	import com.facebook.data.users.GetInfoData;
	import com.facebook.commands.users.GetInfo;
	import com.facebook.utils.FacebookSessionUtil;
	import flash.display.MovieClip;
	import flash.events.Event;
		
	public class FacebookTest extends MovieClip
	{		
		private var fbook:Facebook;
		private var session:FacebookSessionUtil;
			
		private var API_KEY:String = "eda01f987148f812183dbd464cf89e5";
		private var SECRET_KEY:String = "5ba7c6e8efba4bcf7015539a67a93f28";
		
		public function FacebookTest():void
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		private function init(e:Event):void 
		{			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			session = new FacebookSessionUtil(API_KEY, SECRET_KEY, stage.loaderInfo);
			session.addEventListener(FacebookEvent.CONNECT, onConnect);
			session.addEventListener(FacebookEvent.WAITING_FOR_LOGIN, waiting);
			fbook = session.facebook;			
		}
		
		private function waiting(e:FacebookEvent):void
		{
			trace("waiting");
		}
		
		private function onConnect(e:FacebookEvent):void 
		{
			status.text = "Facebook API Ready";	
		}
		
		private function doneLoggingIn():void 
		{
			session.validateLogin();
		}
	
		private function sayHello():void 
		{
			var call:FacebookCall = fbook.post(new GetInfo([fbook.uid], ['first_name', 'last_name']));
			call.addEventListener(FacebookEvent.COMPLETE, handleGetInfoResponse);
		}
	
		private function handleGetInfoResponse(e:FacebookEvent):void 
		{
			var responseData:GetInfoData = e.data as GetInfoData;
			
			if (!responseData || e.error){ // an error occurred
				status.text = "Error";
				return;
			}
			
			var firstName:String = responseData.userCollection.getItemAt(0).first_name;
			var lastName:String = responseData.userCollection.getItemAt(0).last_name;
			
			output.text = "Hello " + firstName + " " + lastName;
		}
			
	}	
	
}