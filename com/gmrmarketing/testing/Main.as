//SpriteSheet generator
//
package com.gmrmarketing.testing
{
	import com.gmrmarketing.utilities.AIRFile;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import com.adobe.images.PNGEncoder;
	import flash.filesystem.*;
	import flash.net.FileReference;
	import flash.net.FileFilter;

	
	
	public class Main extends MovieClip
	{
		private var loader:Loader;
		private var swf:MovieClip;
		private var frame:int;
		private var spriteSheet:BitmapData;
		private var curX:int;
		private var curY:int;
		private var fileRef:FileReference;
		
		public function Main() 
		{
			btnOpen.addEventListener(MouseEvent.CLICK, browseFile, false, 0, true);
			btnSave.addEventListener(MouseEvent.CLICK, begin, false, 0, true);
		}		
		
		private function browseFile(e:MouseEvent):void
		{
			fileRef = new FileReference();
			fileRef.addEventListener(Event.SELECT, fileSelected, false, 0, true);
			var swfFilter:FileFilter = new FileFilter("SWF Files","*.swf");
			fileRef.browse([swfFilter]);
		}
		
		private function fileSelected(e:Event):void
		{
			fileRef.addEventListener(Event.COMPLETE, fileRefLoaded, false, 0, true);
			fileRef.load();
		}
		
		private function fileRefLoaded(e:Event):void
		{
			var data:ByteArray = fileRef["data"];
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.allowLoadBytesCodeExecution = true;
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, fileLoaded, false, 0, true);
			loader.loadBytes(data, loaderContext);
		}

		private function fileLoaded(e:Event):void
		{
			swf = MovieClip(e.currentTarget.content);
			swf.gotoAndStop(1);
			imFrames.text = String(swf.totalFrames);
			imWidth.text = String(loader.contentLoaderInfo.width);
			imHeight.text = String(loader.contentLoaderInfo.height);
			
			//addChild(swf);
			
			frame = 1;	
			curX = 0;
			curY = 0;
		}
		
		private function begin(e:MouseEvent):void
		{
			spriteSheet = new BitmapData(parseInt(sheetWidth.text), parseInt(sheetHeight.text), true, 0x00000000);
			getNextFrame();
		}
		
		private function getNextFrame():void
		{
			swf.gotoAndStop(frame);
			
			//increment sub animation in ball movieClip
			/*
			swf.ball.nextFrame();
			if (swf.ball.currentFrame >= swf.ball.totalFrames) {
				swf.ball.gotoAndStop(1);
			}			
			*/
			imageSwf();
			frame++;
			curX += loader.contentLoaderInfo.width;
			if (curX >= spriteSheet.width) {
				curX = 0;
				curY += loader.contentLoaderInfo.height;
			}
			if (frame <= swf.totalFrames) {
				getNextFrame();
			}else {
				//complete - write out the image
				var ba:ByteArray = PNGEncoder.encode(spriteSheet);
				var file:File = File.desktopDirectory.resolvePath(fileName.text);
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeBytes(ba);
				fileStream.close();
			}
		}		
		
		/**
		 * Takes a bitmap image of the current frame of the swf
		 */
		private function imageSwf():void
		{			
			var tmp:BitmapData = new BitmapData(loader.contentLoaderInfo.width, loader.contentLoaderInfo.height, true, 0x00000000);
			tmp.draw(swf);			
			spriteSheet.copyPixels(tmp, new Rectangle(0, 0, tmp.width, tmp.height), new Point(curX, curY), null, null, true);			
		}
	}
	
}