package com.sitedaniel.text
{
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.EventDispatcher;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.text.Font;
	import flash.display.LoaderInfo;
	
    public class FontControl extends EventDispatcher
    {  
        private var _loader:Loader;
        private var _domain:ApplicationDomain;		
		private var assetFont:Class;
		
        public function FontControl() 
		{
        }
		
		
        public function load(path:String):void
        {           
            _loader = new Loader();            
            _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _loadComplete);
            _loader.load(new URLRequest(path));
        }
 
		
        private function _loadComplete(e:Event):void
        {     
			var tSender : LoaderInfo = LoaderInfo(e.target);
			assetFont = tSender.applicationDomain.getDefinition("theFont") as Class;
			Font.registerFont(AssetFont);	
			
			dispatchEvent(new Event(Event.COMPLETE));
            //Font.registerFont(_domain.getDefinition("theFont") as Class);
        } 
		
		public function getFont():Class
		{
			return AssetFont;
		}
 
    }
}
 