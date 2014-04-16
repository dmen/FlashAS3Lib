package com.gmrmarketing.bcbs.findyourbalance
{	
	import flash.display.*;
	import com.gmrmarketing.intel.girls20.ComboBox;
	import flash.events.*;
	
	
	public class ControllerQuestion_2 extends EventDispatcher
	{
		public static const Q2:String = "Q2Complete";
		public static const NO_Q2:String = "Q2NoAnswer";
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var combo:ComboBox;
		
		public function ControllerQuestion_2()
		{
			clip = new mcQuestion2();
			
			combo = new ComboBox("Choose Answer");
			combo.populate(["Individual coverage", "Medicare coverage", "Small employer coverage (for your employees)", "Not interested"]);
			clip.addChild(combo);
			combo.x = 415;
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
			combo.reset();
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
				dispatchEvent(new Event(NO_Q2));
			}else {
				dispatchEvent(new Event(Q2));
			}
		}
		
		
	}
	
}