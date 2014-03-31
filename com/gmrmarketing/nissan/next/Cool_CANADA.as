/**
 * Instantiated by Main.as
 */
package com.gmrmarketing.nissan.next
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import com.gmrmarketing.nissan.next.CoolMessage;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	
	
	
	public class Cool_CANADA extends EventDispatcher
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var messageContainer:Sprite;
		private var messages:XMLList;
		private var loader:URLLoader;
		
		private var quadrants:Array;
		private var curQuad:int;
		
		private var messTimer:Timer;
		private var messIndex:int;
		
		private var coolMessages:Array; //all current messages
		private var serviceURL:String;
		
		
		
		public function Cool_CANADA($serviceURL:String)
		{			
			serviceURL = $serviceURL;
			
			messageContainer = new Sprite();
			quadrants = new Array(new Rectangle(0, 25, 1000, 35), new Rectangle(0, 430, 1000, 40), new Rectangle(0, 130, 1000, 25), new Rectangle(0, 540, 1000, 20));
			curQuad = 0;
			coolMessages = new Array();
			
			messTimer = new Timer(3000);
			messTimer.addEventListener(TimerEvent.TIMER, addMessage);
			
			messIndex = 0;
			clip = new coolClipLogo(); //lib clip
			loader = new URLLoader();
		}
		
		
		public function show($container:DisplayObjectContainer, useLogo:Boolean = true):void
		{
			TweenMax.killTweensOf(messageContainer); //prevents delayed kill() call
			TweenMax.killTweensOf(clip);
			kill();
			
			container = $container;
			
			if (!container.contains(messageContainer)) {
				container.addChild(messageContainer);				
			}
			if (useLogo) {
				if (!container.contains(clip)) {
					container.addChild(clip);
				}
			}else {
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
			}
			
			messageContainer.alpha = 1;
			clip.alpha = 1;
			getMessages();
		}
		
		
		public function hide():void
		{			
			messTimer.reset();
			TweenMax.to(messageContainer, 1, { alpha:0, onComplete:kill } );
			if(container){
				if(container.contains(clip)){
					TweenMax.to(clip, 1, { alpha:0 } );
				}
			}
		}
		
		
		private function kill():void
		{			
			for (var i:int = 0; i < coolMessages.length; i++) {
				//var cm:CoolMessage = coolMessages.splice(0, 1)[0];
				coolMessages[i].kill();
			}
			if(container){
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
				if(container.contains(messageContainer)){
					container.removeChild(messageContainer);				
				}
			}			
		}
		
		
		private function getMessages():void
		{
			loader.addEventListener(Event.COMPLETE, gotMessages, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, getError, false, 0, true);
			try {
				loader.load(new URLRequest(serviceURL));
			}catch (e:Error) {
				
			}
		}
		
		private function getError(e:IOErrorEvent):void
		{
			
		}
		
		private function gotMessages(e:Event):void
		{
			messages = new XML(e.target.data).PICPosts.PICPost;
			if(messages.length()){
				addMessage();
				messTimer.start();
			}
		}
		
		
		private function addMessage(e:TimerEvent = null):void
		{			
			if (coolMessages.length < 4) {
				
				var nameString:String = String(messages[messIndex].name).toUpperCase(); //first last
				//var sp:int = nameString.indexOf(" ");
				//var fn:String = nameString.substr(0, sp);
				//var ln:String = nameString.substr(sp + 1, 1);
				//nameString += ", " + String(messages[messIndex].city).toUpperCase() + ", " + String(messages[messIndex].state).toUpperCase();
				nameString = "";
				
				var np:Point = getNewPoint();
				var c:CoolMessage = new CoolMessage(messageContainer, messages[messIndex].mess, nameString, np.x, np.y);
				c.addEventListener(CoolMessage.FINISHED, removeMessage, false, 0, true);
				coolMessages.push(c);
				
				messIndex++;
				if (messIndex >= messages.length()) {
					messIndex = 0;
				}
			}			
		}
		
		
		/**
		 * Gets a new point within the next quadrant
		 * @return New Point
		 */
		private function getNewPoint():Point
		{
			var rect:Rectangle = quadrants[curQuad];
			var tx:int = rect.x + Math.random() * rect.width;
			var ty:int = rect.y + Math.random() * rect.height;
			
			curQuad++;
			if (curQuad >= quadrants.length) {
				curQuad = 0;
			}
			
			return new Point(tx, ty);
		}
		
		
		/**
		 * Called by listener on the CoolMessage object
		 * Called once the message has been destroyed by its kill() method
		 * Removes the object from the array
		 * @param	e
		 */
		private function removeMessage(e:Event):void
		{
			var i:int = coolMessages.indexOf(e.currentTarget);
			
			if (i != -1) {
				coolMessages.splice(i, 1);
			}
		}
		
	}
	
}