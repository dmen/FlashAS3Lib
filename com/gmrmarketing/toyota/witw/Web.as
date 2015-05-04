/**
 * used by Social.as
 */
package com.gmrmarketing.toyota.witw
{
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.*;
	import flash.display.*;	
	import com.gmrmarketing.utilities.Strings;
	import com.gmrmarketing.utilities.SwearFilter;
	
	
	public class Web extends EventDispatcher
	{
		public static const REFRESH_COMPLETE:String = "refreshComplete";
		
		private const MAX_IMAGES:int = 44;//max number of images loaded each refresh (11 image areas)
		private const MAX_MESSAGES:int = 50;//max number of messages per refresh (10 image areas)
		
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
		 * called from constructor and Social.hide()
		 * Dispatches REFRESH_COMPLETE when finished
		 */
		public function refresh():void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://wall.thesocialtab.net/SocialPosts/GetPosts?ProgramID=72&count=50");
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
			var n:int = Math.min(MAX_MESSAGES, posts.length);			
			
			var m:String;
			for (var i:int = 0; i < n; i++) {
				
				m = posts[i].Text;
				
				m = m.replace(/&lt;/g, "<");
				m = m.replace(/&gt;/g, "<");
				m = m.replace(/&amp;/g, "&");
				while (m.indexOf("http://") != -1){
					m = Strings.removeChunk(m, "http://");
				}
				while (m.indexOf("https://") != -1){
					m = Strings.removeChunk(m, "https://");
				}
				m = SwearFilter.cleanString(m); //remove any major swears	
				
				allMessages.push({message:m, user:posts[i].AuthorName});
				if (allMessages.length > MAX_MESSAGES) {
					allMessages.shift();
				}
			}
			
			allMessages.sort(aSort);//sort by message length	
			refreshImageList();
		}
		
		
		//custom sort function used in array.sort above
		private function aSort(a:Object, b:Object):int
		{
			if (a.message.length > b.message.length) {
				return -1;
			}else {
				return 1;
			}
		}
		
		
		
		/////// IMAGES		
		/**
		 * called from messagesLoaded() starts the newest list of images downloading
		 */
		public function refreshImageList():void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://wall.thesocialtab.net/SocialPosts/GetPosts?ProgramID=72&onlyimages=true&count=50");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, imageListLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, imageDataError, false, 0, true);
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
			var n:int = Math.min(MAX_IMAGES, posts.length);	
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
			bmp.smoothing = true;
			
			var bmd:BitmapData = new BitmapData(245, 245, false, 0x58595B);	
			
			var r:Number = Math.min(245 / bmp.width, 245 / bmp.height);			
			var mat:Matrix = new Matrix();
			mat.scale(r, r);
			
			//get final image size to use for centering
			//var bmpw:int = Math.floor(bmp.width * r);
			//var bmph:int = Math.floor(bmp.height * r);
			//center image in the space
			//mat.translate(Math.floor((245 - bmpw) * .5), Math.floor((245 - bmph) * .5));
			
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
			if (allImages.length > MAX_IMAGES) {
				allImages.shift();
			}
			loadNextImage();
		}
		
		
		/**
		 * Called if an error occurs downloading the image
		 * @param	e
		 */
		private function imageError(e:IOErrorEvent):void
		{
			loadNextImage();
		}
		
		
		/**
		 * Called if an IO error occurs getting the message list
		 * @param	e
		 */
		private function dataError(e:IOErrorEvent):void	
		{
			refreshImageList();
		}
		
		/**
		 * Called if an IO error occurs getting the image list
		 * @param	e
		 */
		private function imageDataError(e:IOErrorEvent):void
		{
			
		}
		
	}
	
}