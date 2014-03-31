package com.gmrmarketing.pm
{
	import flash.display.MovieClip;
	import flash.events.*;
	
	public class TheMenu extends MovieClip
	{		
		
		public function TheMenu()
		{			
			enableMenu();			
			addEventListener(Event.ADDED_TO_STAGE, dispatchDefault);
		}
		
		
		public function enableMenu():void
		{			
			btnOverview.addEventListener(MouseEvent.CLICK, overviewClicked, false, 0, true);			
			btnComponents.addEventListener(MouseEvent.CLICK, componentsClicked, false, 0, true);		
			btnRequirements.addEventListener(MouseEvent.CLICK, requirementsClicked, false, 0, true);			
			btnBenefits.addEventListener(MouseEvent.CLICK, benefitsClicked, false, 0, true);
			btnSetup.addEventListener(MouseEvent.CLICK, setupClicked, false, 0, true);
			
			btnOverview.buttonMode = true;			
			btnComponents.buttonMode = true;
			btnRequirements.buttonMode = true;
			btnBenefits.buttonMode = true;
			btnSetup.buttonMode = true;
		}	
		
		private function overviewClicked(e:MouseEvent = null):void
		{
			indicator.y = btnOverview.y;
			dispatchEvent(new MenuEvent(MenuEvent.MENU_EVENT, {btn:"overview"}));
		}
		
		private function componentsClicked(e:MouseEvent = null):void
		{
			indicator.y = btnComponents.y;
			dispatchEvent(new MenuEvent(MenuEvent.MENU_EVENT, {btn:"components"}));
		}
		
		private function requirementsClicked(e:MouseEvent = null):void
		{
			indicator.y = btnRequirements.y;
			dispatchEvent(new MenuEvent(MenuEvent.MENU_EVENT, {btn:"requirements"}));
		}
		
		private function benefitsClicked(e:MouseEvent = null):void
		{
			indicator.y = btnBenefits.y;
			dispatchEvent(new MenuEvent(MenuEvent.MENU_EVENT, {btn:"benefits"}));
		}
		
		private function setupClicked(e:MouseEvent = null):void
		{
			indicator.y = btnSetup.y;
			dispatchEvent(new MenuEvent(MenuEvent.MENU_EVENT, {btn:"setup"}));
		}
		
		private function dispatchDefault(e:Event):void
		{			
			removeEventListener(Event.ADDED_TO_STAGE, dispatchDefault);
			overviewClicked();
		}
	}	
}