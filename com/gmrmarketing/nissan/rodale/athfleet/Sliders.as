package com.gmrmarketing.nissan.rodale.athfleet
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;	
	import com.gmrmarketing.utilities.SliderV;
	import com.greensock.TweenMax;
	import com.greensock.easing.*
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Sliders extends EventDispatcher
	{
		public static const SUBMITTED:String = "SlidersComplete";
		public static const CLIP_ADDED:String = "slidersClipAdded";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var xml:XML;
		private var athletes:Array;
		private var sliderInstances:Array; //instance of SliderV		
		private var athDialog:MovieClip; //lib clip
		private var blackBack:MovieClip; //lib clip for behind athDialog
		private var differenceTotals:Array; //array of arrays - subbarrays contain two elements
		//the index in the athletes array, and the difference total for the sliders
		private var timeoutHelper:TimeoutHelper;
		
		
		
		public function Sliders($container:DisplayObjectContainer) 
		{
			container = $container;
			
			athDialog = new dlgAthletes();
			athDialog.x = 960;
			athDialog.y = 510;
			blackBack = new blackBG();
			
			timeoutHelper = TimeoutHelper.getInstance();
			
			clip = new sliders(); //lib clip			
		}
		
		
		public function init(theXML:XML):void
		{
			xml = theXML;
			
			athletes = new Array();
			sliderInstances = new Array();
			
			//parse athletes into athletes array
			//each item in athletes is an array with two elemenets. The first is the athletes name
			//the second is an array of values, one for each slider
			for each (var athlete:XML in xml.athletes.athlete) {				
				var a:Array = new Array();
				a.push(athlete.@name);				
				a.push(String(athlete.sliders).split(","));				
				athletes.push(a);
			}			
			
			//create sliders
			for each (var slider:XML in xml.sliders.slider) {
				var aSlider:MovieClip = new theSlider(); //library clip
				
				aSlider.x = parseInt(slider.@x);
				aSlider.y = parseInt(slider.@y);
				aSlider.titleField.text = slider.@title;
				var b:Array = String(slider).split(",");
				aSlider.topField.text = b[0];
				aSlider.bottomField.text = b[1];
				
				clip.addChild(aSlider);
				
				//sets the stripes color to gray
				aSlider.track.stripes.gotoAndStop(15); 
				
				var sliderV:SliderV = new SliderV(aSlider.slide, aSlider.track);				
				sliderInstances.push(sliderV);
			}			
		}
		
		
		public function show(theName:String):void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.alpha = 0;			
			clip.nameField.text = "Welcome " + theName;
			
			//athlete bio buttons
			clip.btnA.addEventListener(MouseEvent.MOUSE_DOWN, bioPressed, false, 0, true);
			clip.btnB.addEventListener(MouseEvent.MOUSE_DOWN, bioPressed, false, 0, true);
			clip.btnC.addEventListener(MouseEvent.MOUSE_DOWN, bioPressed, false, 0, true);
			clip.btnD.addEventListener(MouseEvent.MOUSE_DOWN, bioPressed, false, 0, true);
			clip.btnE.addEventListener(MouseEvent.MOUSE_DOWN, bioPressed, false, 0, true);
			
			clip.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, submitPressed, false, 0, true);
			
			for (var i:int = 0; i < sliderInstances.length; i++) {
				sliderInstances[i].addEventListener(SliderV.DRAGGING, updateColor, false, 0, true);
				sliderInstances[i].addEventListener(SliderV.END_DRAG, pulseSlider, false, 0, true);
			}
			
			timeoutHelper.buttonClicked();
			
			TweenMax.to(clip, 1, { alpha:1, onComplete:clipAdded } );
		}
		
		private function clipAdded():void
		{
			dispatchEvent(new Event(CLIP_ADDED));
		}
		
		
		public function hide():void
		{
			//athlete bio buttons
			clip.btnA.removeEventListener(MouseEvent.MOUSE_DOWN, bioPressed);
			clip.btnB.removeEventListener(MouseEvent.MOUSE_DOWN, bioPressed);
			clip.btnC.removeEventListener(MouseEvent.MOUSE_DOWN, bioPressed);
			clip.btnD.removeEventListener(MouseEvent.MOUSE_DOWN, bioPressed);
			clip.btnE.removeEventListener(MouseEvent.MOUSE_DOWN, bioPressed);
			
			clip.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, submitPressed);
			
			for (var i:int = 0; i < sliderInstances.length; i++) {
				sliderInstances[i].addEventListener(SliderV.DRAGGING, updateColor);
				sliderInstances[i].addEventListener(SliderV.END_DRAG, pulseSlider);
			}
			
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		/**
		 * Returns the athlets array - an array of subarrays
		 * each sub array contains 2 items, the athletes name
		 * and an array of slider values
		 * @return
		 */
		public function getAthletes():Array
		{
			return athletes;
		}
		
		
		/**
		 * Returns differenceTotals an array of arrays - subbarrays contain two elements
		 * the index in the athletes array, and the difference total for the sliders
		 * @return
		 */
		public function getTotals():Array
		{
			return differenceTotals;
		}
		
		
		private function bioPressed(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			//var s:MovieClip = MovieClip(e.currentTarget);
			//TweenMax.to(s, 0, {glowFilter:{color:0xd02035, alpha:1, blurX:39, blurY:39, strength:2, quality:2, inner:true}});
			//TweenMax.to(s, .5, {glowFilter:{color:0xd02035, alpha:0, blurX:39, blurY:39, strength:2, quality:2, inner:true, overwrite:0}});		
			
			clip.addChild(blackBack);					
			blackBack.alpha = 0;
			
			clip.addChild(athDialog);
			
			switch(MovieClip(e.currentTarget).name) {
				case "btnA":
					athDialog.gotoAndStop(1);
					break;
				case "btnB":
					athDialog.gotoAndStop(2);
					break;
				case "btnC":
					athDialog.gotoAndStop(3);
					break;
				case "btnD":
					athDialog.gotoAndStop(4);
					break;
				case "btnE":
					athDialog.gotoAndStop(5);
					break;
			}
			
			
			athDialog.alpha = 1;
			athDialog.scaleX = athDialog.scaleY = .75;
			
			TweenMax.to(athDialog, .5, {  scaleX:1, scaleY:1, ease:Back.easeOut } );	
			TweenMax.to(blackBack, .5, { alpha:.78, delay:.3 } );
			
			athDialog.buttonClose.addEventListener(MouseEvent.MOUSE_DOWN, closeAthDialog, false, 0, true);
		}
		
		
		private function closeAthDialog(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			TweenMax.to(blackBack, .2, { alpha:0 } );
			TweenMax.to(athDialog, .5, { delay:.2, scaleX:.75, scaleY:.75, alpha:0, ease:Back.easeIn, onComplete:killAthDialog } );
			athDialog.buttonClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeAthDialog);
		}
		
		
		private function killAthDialog():void
		{
			clip.removeChild(athDialog);
			clip.removeChild(blackBack);
		}
		
		
		/**
		 * Called when a slider is being dragged 
		 * Colors the lines in the track
		 * @param	e
		 */
		private function updateColor(e:Event):void
		{	
			var cur:Number = e.currentTarget.getPosition();
			var track:MovieClip = e.currentTarget.getTrack();
			track.stripes.gotoAndStop(Math.floor(30 * cur));
		}
		
		
		/**
		 * Called when a slider is released
		 * @param	e
		 */
		private function pulseSlider(e:Event):void
		{		
			timeoutHelper.buttonClicked();
			var s:MovieClip = e.currentTarget.getSlider();
			TweenMax.to(s, 0, {glowFilter:{color:0xffffff, alpha:1, blurX:39, blurY:39, strength:2, quality:2, inner:true}});
			TweenMax.to(s, .5, {glowFilter:{color:0xffffff, alpha:0, blurX:39, blurY:39, strength:2, quality:2, inner:true, overwrite:0}});
		}
		
		
		
		private function submitPressed(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			clip.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, submitPressed);
			
			//slider values
			var userValues:Array = new Array();
			
			var i:int;			
			
			//place each slider value into userValues
			for (i = 0; i < sliderInstances.length; i++) {				
				userValues.push(1 - sliderInstances[i].getPosition());
			}			
			
			//iterate through athletes array to compare differences
			var thisAthlete:Array;
			differenceTotals = new Array();
			
			for (i = 0; i < athletes.length; i++) {
				
				thisAthlete = athletes[i][1]; //the athletes value array
				
				//the sum of the differences of athletes slider picks compared to users slider picks
				var thisTot:Number = 0;				
				
				for (var j:int = 0; j < thisAthlete.length; j++) {
					thisTot += Math.abs(thisAthlete[j] - userValues[j]);
				}
				
				//store each index and total in differenceTotals - need athlete index for after the array is sorted
				differenceTotals.push([i, thisTot]);
				
			}
			
			sort(differenceTotals);
			dispatchEvent(new Event(SUBMITTED));
		}		
		
		
		
		/**
		 * Simple Bubble Sort
		 * Modified to sort sub arrays within totals
		 * @param	arr - unsorted array 
		 */
		private function sort(arr:Array):void
		{
			var iLen:int = arr.length;			
			var temp:Array;
			
			for(var i:int = 0; i < iLen; i++) {
				for (var j:int = iLen - 1; j > i; j-- )
				{
					if (arr[j - 1][1] > arr[j][1]){
						temp = arr[j - 1];
						arr[j - 1] = arr[j];
						arr[j] = temp;
					}
				}
			}
		}
		
	}
	
}