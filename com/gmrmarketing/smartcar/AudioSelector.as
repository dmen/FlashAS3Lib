/**
 * Instantiated from Main by menuClick()
 * 
 * Audio Tool - placed inside of Main movies toolContainer
 */
package com.gmrmarketing.smartcar
{
	import flash.display.MovieClip;
	import flash.events.*;
	import com.greensock.TweenMax;
	

	public class AudioSelector extends MovieClip
	{
		private var curBass:MovieClip = null;
		private var curGuitar:MovieClip = null;
		private var curDrums:MovieClip = null;
		private var curSynth:MovieClip = null;
		
		private var selection:Array;
		
		public function AudioSelector()
		{
			//contains the track selections: bass, drums, guitar, synth with each one being 1-4
			selection = new Array(0, 0, 0, 0);
		}
		
		public function init(se:Array):void
		{		
			selection = se;
			
			bass.btns.b1.addEventListener(MouseEvent.CLICK, bassBtnClicked, false, 0, true);
			bass.btns.b2.addEventListener(MouseEvent.CLICK, bassBtnClicked, false, 0, true);
			bass.btns.b3.addEventListener(MouseEvent.CLICK, bassBtnClicked, false, 0, true);
			bass.btns.b4.addEventListener(MouseEvent.CLICK, bassBtnClicked, false, 0, true);
			
			drums.btns.b1.addEventListener(MouseEvent.CLICK, drumBtnClicked, false, 0, true);
			drums.btns.b2.addEventListener(MouseEvent.CLICK, drumBtnClicked, false, 0, true);
			drums.btns.b3.addEventListener(MouseEvent.CLICK, drumBtnClicked, false, 0, true);
			drums.btns.b4.addEventListener(MouseEvent.CLICK, drumBtnClicked, false, 0, true);
			
			guitar.btns.b1.addEventListener(MouseEvent.CLICK, guitarBtnClicked, false, 0, true);
			guitar.btns.b2.addEventListener(MouseEvent.CLICK, guitarBtnClicked, false, 0, true);
			guitar.btns.b3.addEventListener(MouseEvent.CLICK, guitarBtnClicked, false, 0, true);
			guitar.btns.b4.addEventListener(MouseEvent.CLICK, guitarBtnClicked, false, 0, true);
			
			synth.btns.b1.addEventListener(MouseEvent.CLICK, synthBtnClicked, false, 0, true);
			synth.btns.b2.addEventListener(MouseEvent.CLICK, synthBtnClicked, false, 0, true);
			synth.btns.b3.addEventListener(MouseEvent.CLICK, synthBtnClicked, false, 0, true);
			synth.btns.b4.addEventListener(MouseEvent.CLICK, synthBtnClicked, false, 0, true);
			
			//set the buttons to highlighted/selected state
			if (selection[0] != 0) {
				curBass = bass.btns["b" + selection[0]];
				TweenMax.to(curBass, .25, { tint:0xff9900 } );
			}
			if (selection[1] != 0) {
				curDrums = drums.btns["b" + selection[1]];
				TweenMax.to(curDrums, .25, { tint:0xff9900 } );
			}
			if (selection[2] != 0) {
				curGuitar = guitar.btns["b" + selection[2]];
				TweenMax.to(curGuitar, .25, { tint:0xff9900 } );
			}
			if (selection[3] != 0) {
				curSynth = synth.btns["b" + selection[3]];
				TweenMax.to(curSynth, .25, { tint:0xff9900 } );
			}
			
			addEventListener(Event.REMOVED_FROM_STAGE, cleanUp, false, 0, true);
		}
		
		/**
		 * Returns an array of integers corresponding to the selected sound in each group
		 * Order is: bass, drum, guitar synth
		 * 
		 * @return Array of integers in the range 1 - 4
		 */
		public function getAudioSelection():Array
		{
			return selection;
		}
		
		
		private function bassBtnClicked(e:MouseEvent):void
		{
			var ind:int = parseInt( MovieClip(e.currentTarget).name.substr(1));
			
			if (curBass) {
				TweenMax.to(curBass, .25, { tint:0xffffff } );
			}
			
			if(selection[0] != ind){
				curBass = MovieClip(e.currentTarget);
				selection[0] = ind;	
				TweenMax.to(curBass, .25, { tint:0xff9900 } );
			}else {
				selection[0] = 0;
			}
			
			dispatchEvent(new Event("toolChange"));
		}
		
		private function drumBtnClicked(e:MouseEvent):void
		{
			var ind:int = parseInt(MovieClip(e.currentTarget).name.substr(1));
			
			if (curDrums) {
				TweenMax.to(curDrums, .25, { tint:0xffffff } );
			}
			
			if(selection[1] != ind){
				curDrums = MovieClip(e.currentTarget);
				selection[1] = ind
				TweenMax.to(curDrums, .25, { tint:0xff9900 } );
			}else {				
				selection[1] = 0;
			}
			
			dispatchEvent(new Event("toolChange"));
		}
		
		private function guitarBtnClicked(e:MouseEvent):void
		{
			var ind:int = parseInt(MovieClip(e.currentTarget).name.substr(1));
			
			if (curGuitar) {
				TweenMax.to(curGuitar, .25, { tint:0xffffff } );
			}
			
			if(selection[2] != ind){
				curGuitar = MovieClip(e.currentTarget);
				selection[2] = parseInt(curGuitar.name.substr(1));
				TweenMax.to(curGuitar, .25, { tint:0xff9900 } );
			}else {
				selection[2] = 0;
			}
			
			dispatchEvent(new Event("toolChange"));
		}
		
		private function synthBtnClicked(e:MouseEvent):void
		{
			var ind:int = parseInt(MovieClip(e.currentTarget).name.substr(1));
			
			if (curSynth) {
				TweenMax.to(curSynth, .25, { tint:0xffffff } );
			}
			
			if(selection[3] != ind){
				curSynth = MovieClip(e.currentTarget);
				selection[3] = parseInt(curSynth.name.substr(1));
				TweenMax.to(curSynth, .25, { tint:0xff9900 } );
			}else {
				selection[3] = 0;
			}
			
			dispatchEvent(new Event("toolChange"));
		}
		
		
		/**
		 * Called when this tool is removed from the stage
		 * @param	e
		 */
		private function cleanUp(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, cleanUp);
			
			bass.btns.b1.removeEventListener(MouseEvent.CLICK, bassBtnClicked);
			bass.btns.b2.removeEventListener(MouseEvent.CLICK, bassBtnClicked);
			bass.btns.b3.removeEventListener(MouseEvent.CLICK, bassBtnClicked);
			bass.btns.b4.removeEventListener(MouseEvent.CLICK, bassBtnClicked);
			
			drums.btns.b1.removeEventListener(MouseEvent.CLICK, drumBtnClicked);
			drums.btns.b2.removeEventListener(MouseEvent.CLICK, drumBtnClicked);
			drums.btns.b3.removeEventListener(MouseEvent.CLICK, drumBtnClicked);
			drums.btns.b4.removeEventListener(MouseEvent.CLICK, drumBtnClicked);
			
			guitar.btns.b1.removeEventListener(MouseEvent.CLICK, guitarBtnClicked);
			guitar.btns.b2.removeEventListener(MouseEvent.CLICK, guitarBtnClicked);
			guitar.btns.b3.removeEventListener(MouseEvent.CLICK, guitarBtnClicked);
			guitar.btns.b4.removeEventListener(MouseEvent.CLICK, guitarBtnClicked);
			
			synth.btns.b1.removeEventListener(MouseEvent.CLICK, synthBtnClicked);
			synth.btns.b2.removeEventListener(MouseEvent.CLICK, synthBtnClicked);
			synth.btns.b3.removeEventListener(MouseEvent.CLICK, synthBtnClicked);
			synth.btns.b4.removeEventListener(MouseEvent.CLICK, synthBtnClicked);
		}
				
	}
	
}