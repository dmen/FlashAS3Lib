package com.gmrmarketing.toyota.witw
{
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.net.*;
	import flash.display.*;
	
	
	public class Web extends EventDispatcher
	{
		public static const REFRESH_COMPLETE:String = "refreshComplete";
		private const MAX_ITEMS:int = 44;//max number of images or messages loaded each refresh
		private var loadList:Array;//list of images being loaded
		private var allImages:Array;//array of Bitmaps
		private var allMessages:Array;//array of objects containing message,user properties
		private var imageData:Object; //username and source for the currently loading image
		
		
		public function Web()
		{
			allImages = [];
			allMessages = [];
			refresh();
		}
		
		
		/**
		 * Returns an array of Bitmaps
		 */
		public function get images():Array
		{
			return allImages;
		}
		
		
		/**
		 * Returns an array of objects containing message,user properties
		 */
		public function get messages():Array
		{
			return allMessages;
		}
		
		
		/**
		 * Refeshes the messages and images 
		 * Dispatches REFRESH_COMPLETE when finished
		 */
		public function refresh():void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://wall.thesocialtab.net/SocialPosts/GetPosts?ProgramID=66");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, messagesLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		
		private function messagesLoaded(e:Event):void
		{
			var o:Object = JSON.parse(e.currentTarget.data);
			var posts:Array = o.SocialPosts;
			var n:int = Math.min(MAX_ITEMS, posts.length);			
			
			for (var i:int = 0; i < n; i++) {
				allMessages.push({message:posts[i].Text, user:posts[i].AuthorName});
				if (allMessages.length > MAX_ITEMS) {
					allMessages.shift();
				}
			}
			
			refreshImageList();
		}
		
		
		/////// IMAGES
			
		public function refreshImageList():void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://wall.thesocialtab.net/SocialPosts/GetPosts?ProgramID=66&onlyimages=true");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, imageListLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		
		private function imageListLoaded(e:Event):void
		{
			var o:Object = JSON.parse(e.currentTarget.data);
			var posts:Array = o.SocialPosts;
			loadList = [];		
			var n:int = Math.min(MAX_ITEMS, posts.length);	
			for (var i:int = 0; i < n; i++) {
				loadList.push({url:posts[i].MediumResURL, user:posts[i].AuthorName, source:posts[i].Source});
			}			
			loadNextImage();
		}
		
		
		private function loadNextImage():void
		{
			if(loadList.length > 0){
				var data:Object = loadList.shift();
				//data for the currently loading image-used in imageLoaded()
				imageData = { user:data.user, source:data.source };
				var a:Loader = new Loader();
				a.load(new URLRequest(data.url));
				a.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
				a.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imageError);
			}else {				
				dispatchEvent(new Event(REFRESH_COMPLETE));
			}
		}		
		
		
		private function imageLoaded(e:Event):void
		{	
			var bmp:Bitmap = Bitmap(e.target.content);		
			var bmd:BitmapData = new BitmapData(245, 245, false, 0x000000);	
			
			var r:Number = Math.min(245 / bmp.width, 245 / bmp.height);			
			var mat:Matrix = new Matrix();
			mat.scale(r, r);
			
			bmd.draw(bmp, mat, null, null, null, true);			
			
			//draw data into image
			var m:MovieClip = new dataClip();//library clip
			m.theData.theText.text = "@" + imageData.user;			
			if (imageData.source == "Instagram") {
				m.theData.theSource.gotoAndStop(1);
			}else {
				m.theData.theSource.gotoAndStop(2);
			}			
			bmd.draw(m, null, null, null, null, true);
			
			var bit:Bitmap = new Bitmap(bmd);
			allImages.push(bit);
			
			//trim image list to max length
			if (allImages.length > MAX_ITEMS) {
				allImages.shift();
			}
			
			loadNextImage();
		}
		
		
		private function imageError(e:IOErrorEvent):void
		{
			loadNextImage();
		}
		
		
		private function dataError(e:IOErrorEvent):void	
		{
		}
		
	}
	
}