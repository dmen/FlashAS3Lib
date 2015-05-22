//used by Main
package com.gmrmarketing.empirestate.ilny
{	
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import com.gmrmarketing.utilities.KenBurns;
	import flash.text.TextField;
	
	public class Background
	{
		private var myContainer:DisplayObjectContainer;
		private var sourceFolder:File;
		private var images:Array;//nativePath strings to each image in the bgimages folder
		private var names:Array;//array of file names for images in the images array
		private var bmds:Array;//bitmapData objects loaded from images array
		private var nameIndex:int;
		private var kb:KenBurns;
		private var loaded:Boolean;
		private var myTextField:TextField;
		
		public function Background()
		{
			kb = new KenBurns();			
			
			sourceFolder = File.applicationDirectory;
			sourceFolder = sourceFolder.resolvePath("bgimages/");
			
			var files:Array = sourceFolder.getDirectoryListing();
			
			loaded = false;
			bmds = [];
			images = [];
			names = [];
			nameIndex = 0;
			var fName:String;
			for (var i:int = 0; i < files.length; i++) {
				images.push(files[i].nativePath);
				
				fName = files[i].name;
				fName = fName.substr(0, fName.length - 4);				
				names.push(fName);
			}
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
			kb.container = myContainer;
		}
		
		
		public function set tField(t:TextField):void
		{
			myTextField = t;
			
			kb.addEventListener(KenBurns.CHANGE, nameChange);
			//}else {
				//kb.removeEventListener(KenBurns.CHANGE, nameChange);
			//}
		}
		
		
		public function show():void
		{
			if(!loaded){
				loadNextImage();
			}else {
				play();
			}
		}
		
		
		public function stop():void
		{
			kb.stop();
			kb.unload();
		}
		
		
		private function loadNextImage():void
		{
			if(images.length > 0){
				var im:String = images.shift();
				var l:Loader = new Loader();
				l.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded, false, 0, true);
				l.load(new URLRequest(im));
			}else {
				loaded = true;
				kb.images = bmds;
				play();
			}
		}
		
		
		private function imageLoaded(e:Event):void
		{
			var bmd:BitmapData = e.target.content.bitmapData;
			bmds.push(bmd);			
			loadNextImage();
		}
		
		
		private function play():void
		{			
			kb.show();
		}
		
		
		/**
		 * Called by CHANGE listener on KenBurns
		 * @param	e
		 */
		private function nameChange(e:Event):void
		{
			if(myTextField != null){
				myTextField.text = names[nameIndex];
			}
			nameIndex++;
			if (nameIndex >= names.length) {
				nameIndex = 0;
			}
		}
	}
	
}