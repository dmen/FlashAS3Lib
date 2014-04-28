package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import com.gmrmarketing.utilities.Slider;
	
	
	public class ControllerRules extends EventDispatcher
	{
		private const URL:String = "http://bluecrosshorizon.thesocialtab.net/home/ProgramDetail/"; //need to append id
		public static const RULES_DONE:String = "closeRules";
		
		private var data:Object; //JSON
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var baseRules:String; //original rules with bracket variables in place
		private var slider:Slider;
		
		private var totalMove:int;
		private var moveRatio:Number;
		
		public function ControllerRules()
		{
			clip = new mcRules();
			
			baseRules = clip.theText.theRules.text;			
			
			totalMove = clip.theText.height - clip.theMask.height;
			moveRatio = 1 / totalMove;
			
			slider = new Slider(clip.slider, clip.track, "v");
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
			
			slider.reset();
			slider.addEventListener(Slider.DRAGGING, updateRules, false, 0, true);
			
			clip.theText.y = 75;
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeRules, false, 0, true);
		}
		
		
		private function closeRules(e:MouseEvent):void
		{
			dispatchEvent(new Event(RULES_DONE));
		}
		
		
		private function updateRules(e:Event):void
		{
			var slidePos:Number = slider.getPosition(); //0 - 1
			clip.theText.y = 75 - (slidePos / moveRatio);
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			slider.removeEventListener(Slider.DRAGGING, updateRules);
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeRules);
		}
		
		/**
		 * called from main when the ip dialog closes
		 * @param	id
		 */
		public function getRuleData(id:int):void
		{
			var request:URLRequest = new URLRequest(URL + String(id));			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			
			request.requestHeaders.push(hdr);
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, gotData, false, 0, true);
			//lo.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);			
			lo.load(request);
		}
		
		
		private function gotData(e:Event):void
		{			
			data = JSON.parse(e.currentTarget.data);
			
			var startTime:RegExp = /\[START_TIME\]/g;
			var startDate:RegExp = /\[START_DATE\]/g;
			var endTime:RegExp = /\[END_TIME\]/g;
			var endDate:RegExp = /\[END_DATE\]/g;
			var evAddr:RegExp = /\[EVENT_ADDRESS\]/g;
			var drawTime:RegExp = /\[DRAWING_TIME\]/g;
			var prizeDesc:RegExp = /\[PRIZE_DESC\]/g;
			var deadline:RegExp = /\[ENTRY_DEADLINE\]/g;
			
			var newRules:String = baseRules.replace(startTime, data.startTime);
			newRules = newRules.replace(startDate, data.startDate);
			newRules = newRules.replace(endTime, data.endTime);
			newRules = newRules.replace(endDate, data.endDate);
			newRules = newRules.replace(evAddr, data.eventAddress);
			newRules = newRules.replace(drawTime, data.drawingTime);		
			newRules = newRules.replace(prizeDesc, data.dailyPrizeDescr);		
			newRules = newRules.replace(deadline, data.entryDeadline);
			
			clip.theText.theRules.text = newRules;
		}		
		
	}
	
}