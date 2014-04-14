package com.gmrmarketing.bcbs.findyourbalance
{	
	import flash.display.*;
	import com.gmrmarketing.intel.girls20.ComboBox;
	import flash.events.*;
	
	
	public class ControllerQuestion_1 extends EventDispatcher
	{
		public static const Q1:String = "Q1Complete";
		public static const NO_Q1:String = "Q1NoAnswer";
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var combo:ComboBox;
		
		public function ControllerQuestion_1()
		{
			clip = new mcQuestion1();
			
			combo = new ComboBox("Choose Answer");
			combo.populate([1,3,5,7,9,50,75,100,500,10000]);
			clip.addChild(combo);
			combo.x = 483;
			combo.y = 290;		
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			combo.reset(); //shows reset message
			clip.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, submitClicked, false, 0, true);
		}
		
		
		public function getAnswer():String
		{
			return combo.getSelection();
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			clip.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, submitClicked);
		}
		
		
		private function submitClicked(e:MouseEvent):void
		{
			if (combo.getSelection() == "" || combo.getSelection() == combo.getResetMessage()) {
				dispatchEvent(new Event(NO_Q1));
			}else {
				dispatchEvent(new Event(Q1));
			}
		}
		
		
	}
	
}