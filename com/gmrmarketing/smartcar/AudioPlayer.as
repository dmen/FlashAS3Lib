/**
 * Instantiated by Main
 * plays the audio selection retrieved from AudioSelector
 */

package com.gmrmarketing.smartcar
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.media.SoundChannel;
	import flash.events.TimerEvent;
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.errors.EOFError;
	
	//import library sounds so we can use them outside of the document class
	import bass1;
	import bass2;
	import bass3;
	import bass4;
	import drum1;
	import drum2;
	import drum3;
	import drum4;
	import guitar1;
	import guitar2;
	import guitar3;
	import guitar4;
	import synth1;
	import synth2;
	import synth3;
	import synth4;	
	

	public class AudioPlayer extends EventDispatcher
	{
		private var bassChannel:SoundChannel;
		private var drumChannel:SoundChannel;
		private var guitarChannel:SoundChannel;
		private var synthChannel:SoundChannel;
		
		//contains the visualizer graphic
		private var visHolder:Sprite;
		private var bytes:ByteArray;
		
		private var vizTimer:Timer;
		private var spectrumContainer:DisplayObjectContainer;
		
		private var lineColor:Number; //visualizer line color
		private var fillColor:Number; //visualizer fill color
		
		
		public function AudioPlayer($spectrumContainer:DisplayObjectContainer)
		{
			spectrumContainer = $spectrumContainer;
			
			bytes = new ByteArray();
			
			visHolder = new Sprite();
			visHolder.x = 3;
			visHolder.y = 950;
			visHolder.rotationY = -87;					
			
			vizTimer = new Timer(40);
		}
		
		
		/**
		 * Called from Main.menuClick() when the current tool is audio
		 * Stops all channels before swapping to new tool
		 */
		public function stopAll():void
		{
			if (bassChannel) {
				bassChannel.stop();
			}
			if (drumChannel) {
				drumChannel.stop();
			}
			if (guitarChannel) {
				guitarChannel.stop();
			}
			if (synthChannel) {
				synthChannel.stop();
			}
			vizTimer.stop();
			
			if(spectrumContainer.contains(visHolder)){
				spectrumContainer.removeChild(visHolder);
				vizTimer.removeEventListener(TimerEvent.TIMER, displayVisualizer);	
			}
		}
		
		
		/**
		 * Called by Main.updateFromTool() when tool = audio
		 * Plays the sounds indicated by the selection array
		 * array has 4 elements - bass, drum, guitar, synth
		 * each element can be 1-4 corresponding to which clip to play for that 'instrument'
		 * 
		 * @param	sel Array of 4 integer items - each on with range 1-4
		 */
		public function playSelection(sel:Array, scene:String):void
		{		
			if(!spectrumContainer.contains(visHolder)){
				spectrumContainer.addChild(visHolder);
				vizTimer.addEventListener(TimerEvent.TIMER, displayVisualizer, false, 0, true);	
				vizTimer.start();
			}
			
			//sets visualizer line and fill color depending on the selected scene			
			switch(scene) {
				case "city":
					lineColor = 0x577fff;
					fillColor = 0x112277;
					break;
				case "suburbs":
					lineColor = 0x32b53e;
					fillColor = 0x3da05b;
					break;
				case "beach":
					lineColor = 0xb85b36;
					fillColor = 0xb88f4d;
					break;
				case "nightlife":
					lineColor = 0x5555ff;
					fillColor = 0x222288;
					break;
			}
			
			
			//BASS
			if(bassChannel){
				bassChannel.stop();
			}
			switch(sel[0]) {
				case 1:
					bassChannel = new bass1().play(0, 999);
					break;	
				case 2:
					bassChannel = new bass2().play(0, 999);
					break;
				case 3:
					bassChannel = new bass3().play(0, 999);
					break;
				case 4:
					bassChannel = new bass4().play(0, 999);
					break;
			}			
			
			//DRUMS
			if(drumChannel){
					drumChannel.stop();
			}
			switch(sel[1]) {
				case 1:
					drumChannel = new drum1().play(0, 999);
					break;	
				case 2:
					drumChannel = new drum2().play(0, 999);
					break;
				case 3:
					drumChannel = new drum3().play(0, 999);
					break;
				case 4:
					drumChannel = new drum4().play(0, 999);
					break;
			}			
			
			//GUITAR
			if(guitarChannel){
				guitarChannel.stop();
			}
			switch(sel[2]) {
				case 1:
					guitarChannel = new guitar1().play(0, 999);
					break;	
				case 2:
					guitarChannel = new guitar2().play(0, 999);
					break;
				case 3:
					guitarChannel = new guitar3().play(0, 999);
					break;
				case 4:
					guitarChannel = new guitar4().play(0, 999);
					break;
			}
			
			//SYNTH
			if(synthChannel){
				synthChannel.stop();
			}
			switch(sel[3]) {
				case 1:
					synthChannel = new synth1().play(0, 999);
					break;	
				case 2:
					synthChannel = new synth2().play(0, 999);
					break;
				case 3:
					synthChannel = new synth3().play(0, 999);
					break;
				case 4:
					synthChannel = new synth4().play(0, 999);
					break;
			}
			
		}
		
		
		/**
		 * Called every 40ms by vizTimer listener
		 * draws into vizHolder.graphics
		 * @param	e
		 */
		private function displayVisualizer(e:TimerEvent):void
		{	
			SoundMixer.computeSpectrum(bytes, true);
			
			visHolder.graphics.clear();				
			visHolder.graphics.lineStyle(2, lineColor, 1);
			visHolder.graphics.beginFill(fillColor, .5);
			visHolder.graphics.moveTo(0, 0);
			var t:Number;
			
			var widthRatio:Number = 1800 / 512;
			
			for (var i:int = 0; i < 512; i += 2) {
				try{
					t = bytes.readFloat() * 350;					
					visHolder.graphics.lineTo(i * widthRatio, -t);					
				}
				catch (e:EOFError) {
					//trace("c");
				}
			}
			
			visHolder.graphics.lineTo(i * widthRatio, 0);
			visHolder.graphics.lineTo(0, 0);
		}
		
		
	}
	
}