package com.gmrmarketing.comcast.streamgame2017
{
	import flash.events.*;
	import flash.display.*;
	import flash.net.*;
	
	
	public class Config extends EventDispatcher
	{
		public static const CLOSED:String = "configClosed";
		private var so:SharedObject;
		private var clip:MovieClip;
		private var _container:DisplayObjectContainer;
		private var percents:Array;
		
		
		public function Config()
		{
			clip = new mcConfig();
			clip.x = 150;
			clip.y = 150;
			
			so = SharedObject.getLocal("comcastStreamConfig");
			
			if (so.data.percents == null){
				percents = [10, 30];//three stars, two stars - one star is calculated
			}else{
				percents = so.data.percents;
			}
	
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			_container = c;
		}
		
		
		public function get data():Array
		{
			var p:Array = [Number(percents[0] / 100.0), Number(percents[1] / 100.0)];
			return p;
		}
		
		
		public function show():void
		{
			if (!_container.contains(clip)){
				_container.addChild(clip);
			}
			
			clip.three.text = percents[0].toString();
			clip.two.text = percents[1].toString();
			clip.one.text = int(100 - (percents[0] + percents[1])).toString();
			
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeConfig, false, 0, true);
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, saveConfig, false, 0, true);
			
			clip.addEventListener(Event.ENTER_FRAME, recalc, false, 0, true);
		}
		
		
		private function closeConfig(e:MouseEvent):void
		{
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeConfig);
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, saveConfig);
			clip.removeEventListener(Event.ENTER_FRAME, recalc);
			
			if (_container.contains(clip)){
				_container.removeChild(clip);
			}
			dispatchEvent(new Event(CLOSED));
		}
		
		
		private function saveConfig(e:MouseEvent):void
		{
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeConfig);
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, saveConfig);
			
			percents = [parseInt(clip.three.text), parseInt(clip.two.text)];
			so.data.percents = percents;
			so.flush();
			
			if (_container.contains(clip)){
				_container.removeChild(clip);
			}
			
			dispatchEvent(new Event(CLOSED));
		}
		
		
		private function recalc(e:Event):void
		{
			clip.one.text = int(100 - (parseInt(clip.three.text) + parseInt(clip.two.text))).toString();
		}
		
	}
	
}