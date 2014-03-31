package com.sitedaniel.text
{
    import flash.display.*;
 	import flash.events.*;
 	import flash.text.*;
 	import flash.errors.*;
 	import flash.system.*;
 	import flash.net.*;
	
 	public class LoadFont extends EventDispatcher {
 	 	public static const COMPLETE:String = "complete";
 	 	public static const ERROR:String = "error loading font";
 	 	
		private var loader:Loader = new Loader();
 	 	private var _fontsDomain:ApplicationDomain;
 	 	private var _fontName:Array;
		
 	 	public function LoadFont():void 
		{ 	 	 	 	 	 	
 	 	 	loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, font_ioErrorHandler);
 	 	 	loader.contentLoaderInfo.addEventListener(Event.COMPLETE,finished); 	 	 	
 	 	}
		
 	 	public function load(url:String):void 
		{
 	 	 	var request:URLRequest = new URLRequest(url);
 	 	 	loader.load(request);
 	 	}
		 
		
 	 	private function finished(evt:Event):void 
		{
 	 	 	_fontsDomain = loader.contentLoaderInfo.applicationDomain;
 	 	 	Font.registerFont(getFontClass("theFont"));
 	 	 	dispatchEvent(new Event(LoadFont.COMPLETE));
 	 	}
		
		
 	 	private function font_ioErrorHandler(evt:Event):void 
		{
 	 	 	dispatchEvent(new Event(LoadFont.ERROR));
		}		 
 	 
		
 	 	public function getFontClass(id:String):Class 
		{
 	 	 	return _fontsDomain.getDefinition(id) as Class;
 	 	}
		 
		
 	 	public function getFont():Font 
		{
 	 	 	var fontClass:Class = getFontClass("theFont");
 	 	 	return new fontClass as Font;
 	 	}
 	}

}
 