package com.gmrmarketing.rbc
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import gs.TweenLite;
	import gs.plugins.*;
	import com.gmrmarketing.rbc.ScreenSaver;
	import com.gmrmarketing.kiosk.*;	
	import flash.events.TimerEvent;	
	import flash.utils.Timer;
	import flash.system.fscommand;
	
	public class EnergyGuide extends MovieClip
	{
		private var topTab:MovieClip;
		private var midTab:MovieClip;
		private var botTab:MovieClip;
		
		private var enerG:MovieClip;
		
		private var slider:MovieClip;
		private var sliderOffset:int;
		private var sliderCenter:Number;
		private var sliderRatio:Number;
		
		private var curTab:MovieClip;
		
		//min, max killowat hours for each appliance
		private var dryerRange:Array = new Array(95, 492);
		private var dishwasherRange:Array = new Array(190, 472);
		private var fridgeRange:Array = new Array(285, 484);
		private var curRange:Array;
		
		private var sideText:annualCostSideText; //side text above and below cost indicator
		private var costIndicator:kwhText_big2;
		
		private const ENERGY_RATE:Number = .1044; //average cost per KwH
		
		private var ss:ScreenSaver;
		private var ssHelper:ScreenSaverHelper;	
		private var helper:KioskHelper;
		
		
		/**
		 * CONSTRUCTOR
		 */
		public function EnergyGuide()
		{
			TweenPlugin.activate([DropShadowFilterPlugin, BevelFilterPlugin]);
			
			var helper:KioskHelper = KioskHelper.getInstance();
			helper.eightCornerInit(this, "lllr", false, 1360, 768);
			helper.addEventListener(KioskEvent.EIGHT_CLICKS, quit);
			
			//add the three tabs
			topTab = new tab_top();
			midTab = new tab_middle();
			botTab = new tab_bottom();
			
			sideText = new annualCostSideText();
			costIndicator = new kwhText_big2();
			
			addChildAt(topTab, 0);
			addChildAt(botTab, 1);
			addChildAt(midTab, 2); //show midTab first
			
			topTab.x = botTab.x = midTab.x = 29;
			topTab.y = botTab.y = midTab.y = 23;
			
			TweenLite.to(topTab, 0, { dropShadowFilter: { color:0x000000, alpha:1, blurX:10, blurY:10, distance:5 }} );
			TweenLite.to(midTab, 0, { dropShadowFilter: { color:0x000000, alpha:1, blurX:10, blurY:10, distance:5 }} );
			TweenLite.to(botTab, 0, {dropShadowFilter:{color:0x000000, alpha:1, blurX:10, blurY:10, distance:5}});
			
			topTab.addEventListener(MouseEvent.MOUSE_OVER, topClick);
			midTab.addEventListener(MouseEvent.MOUSE_OVER, midClick);
			botTab.addEventListener(MouseEvent.MOUSE_OVER, botClick);
			
			curTab = midTab; //the one on top
			curRange = dishwasherRange;
			
			//add enerGuide
			enerG = new enerGuide();
			addChildAt(enerG, 3);
			enerG.x = 404;
			enerG.y = 43;
			TweenLite.to(enerG, 0, { dropShadowFilter: { color:0x000000, alpha:.6, blurX:8, blurY:8, distance:5 }} );
			
			//add slider
			slider = new triMove();
			addChildAt(slider, 4);
			slider.x = 500;
			slider.y = 390;
			sliderCenter = slider.width / 2;
			TweenLite.to(slider, 0, {dropShadowFilter:{color:0x000000, alpha:.6, blurX:8, blurY:8, distance:3}, bevelFilter:{blurX:2, blurY:2, strength:1, distance:1}});
			slider.addEventListener(MouseEvent.MOUSE_DOWN, sliderDown, false, 0, true);
			
			//add side text & cost indicator
			addChildAt(sideText, 5);
			addChildAt(costIndicator, 6);
			sideText.x = 1034;
			sideText.y = 237;
			costIndicator.x = 1053;
			costIndicator.y = 329;
			
			
			//general mouse up to catch mouseUp's outside the triangle
			addEventListener(MouseEvent.MOUSE_UP, sliderUp);
			
			ss = new ScreenSaver();
			ssHelper = ScreenSaverHelper.getInstance();
			ssHelper.attractInit(this, 30000);
			ssHelper.addEventListener(KioskEvent.START_ATTRACT, runScreenSaver);
			
			//get it going to update fields
			topClick();
		}
		
		
		/**
		 * Called by the screen saver helper when the timeout period expires
		 * 
		 * @param	e START_ATTRACT KioskEvent
		 */
		private function runScreenSaver(e:Event = null)
		{			
			if(!ss.isRunning()){
				ss.show(this);
				ssHelper.attractStop(); //stop checking when running the SS
				addEventListener(MouseEvent.MOUSE_DOWN, stopSaver, false, 0, true);
			}
		}
		
		
		/**
		 * Called when the screen saver is clicked on
		 * Calls stopSaver to fade out the saver and then kill it
		 * 
		 * @param	e CLICK MouseEvent
		 */
		private function stopSaver(e:MouseEvent)
		{
			ss.kill();
			ssHelper.attractStart();
			this.removeEventListener(MouseEvent.MOUSE_DOWN, stopSaver);
		}
		
		
		
		/**
		 * Tab clicks
		 * Brings the clicked tab forward, sets the curRange and calls calcRatio
		 * to calculate the slider ratio for the given range and update the fields
		 * 
		 * @param	e MouseEvent
		 */
		private function topClick(e:MouseEvent = null)
		{		
			curTab.gotoAndStop(1);
			swapChildren(curTab, topTab);
			curTab = topTab;
			curRange = dryerRange;
			curTab.gotoAndPlay(2);
			calcRatio();
		}
		
		
		private function midClick(e:MouseEvent = null)
		{		
			curTab.gotoAndStop(1);
			swapChildren(curTab, midTab);
			curTab = midTab;
			curRange = dishwasherRange;
			curTab.gotoAndPlay(2);
			calcRatio();
		}
		
		
		private function botClick(e:MouseEvent = null)
		{		
			curTab.gotoAndStop(1);
			swapChildren(curTab, botTab);
			curTab = botTab;
			curRange = fridgeRange;
			curTab.gotoAndPlay(2);
			calcRatio();
		}
		
		
		
		
		/**
		 * Calculates the slider ratio
		 * The ratio of pixels over the length of the slider to the current range of kwh being used
		 * 
		 * Called each time one of the tabs is clicked - as a new kwh range is used
		 */
		private function calcRatio()
		{
			var totalPixels = enerG.powerBar.width - 16;	//subtract 16 for the 8 pixel wide bars on each end		
			sliderRatio = totalPixels / (curRange[1] - curRange[0]);
			enerG.minkwh.theText.text = curRange[0];
			enerG.maxkwh.theText.text = curRange[1];
			updateKwh();
		}
		
		
		
		/**
		 * Called when the slider (blue triangle) is clicked on
		 * Calculates the mouse offset so that the slider doesn't jump when it's clicked
		 * adds the enterFrame to call slideSlider as it's being dragged
		 * 
		 * @param	e
		 */
		private function sliderDown(e:MouseEvent)
		{
			slider.addEventListener(Event.ENTER_FRAME, slideSlider, false, 0, true);			
			sliderOffset = mouseX - slider.x;
		}
		
		
		
		/**
		 * Removes the lslider istener when mouse button is released
		 * 
		 * @param	e
		 */
		private function sliderUp(e:MouseEvent)
		{			
			slider.removeEventListener(Event.ENTER_FRAME, slideSlider);
		}
		
		
		
		/**
		 * Called by enterFrame whenever  the slider is being dragged
		 * 
		 * Moves the slider and calls updateKwh() to update the fields
		 * 
		 * @param	e EnterFrame event
		 */
		private function slideSlider(e:Event)
		{		
			slider.x = mouseX - sliderOffset;
			//left limit
			if (slider.x + sliderCenter < enerG.x + enerG.powerBar.x + 8)
			{
				slider.x = enerG.x + enerG.powerBar.x - sliderCenter + 8;
			}
			//right limit
			if (slider.x + sliderCenter > enerG.x + enerG.powerBar.x + enerG.powerBar.width - 8)
			{
				slider.x = enerG.x + enerG.powerBar.x + enerG.powerBar.width - sliderCenter - 8;
			}
			
			updateKwh();
		}
		
		
		
		/**
		 * Calculates the killowat hours and energy cost
		 * based on the triangles position on the slider
		 * 
		 * called from slideSlider() whenever the slider is being dragged
		 * 
		 * @param	e 
		 */
		private function updateKwh()
		{
			var sliderPos = (slider.x + (slider.width / 2)) - (enerG.x + enerG.powerBar.x + 8);	
			var theKWH:int = Math.round(sliderPos / sliderRatio + curRange[0]);
			enerG.energKWH.theText.text = theKWH;
			var totalCost:String = String(ENERGY_RATE * theKWH);
			var dotPos = totalCost.lastIndexOf(".");
			var dispString:String = totalCost.substr(0, dotPos + 3);
			
			if (dispString.length - dotPos == 2) 
			{
				dispString += "0";
			}
			costIndicator.theText.text = "$" + dispString;
		}
		
		
		private function quit(e:KioskEvent)
		{
			fscommand("quit");
		}
		
	}
	
}