package com.gmrmarketing.digitalmerch
{
	import flash.display.LoaderInfo; //for flashvars
	import flash.display.MovieClip;
	import flash.events.*;	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import com.greensock.TweenLite;
	import com.greensock.TimelineLite;
	import com.greensock.easing.*;
	
	
	
	
	public class Juke extends MovieClip
	{
		private var theContext:SoundLoaderContext;		
		private var track:Sound;		
		private var channel:SoundChannel;
		private var vol:SoundTransform;
		
		private var soundFile:String;
		private var isMuted:Boolean = false;
		
		private var glowTimeline:TimelineLite;
		
		public function Juke()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event):void
		{
			soundFile = loaderInfo.parameters.soundURL;
			if(loaderInfo.parameters.titleText != null){
				theTitle.text = loaderInfo.parameters.titleText;
			}
			if(loaderInfo.parameters.copyText != null){
				theCopy.text = loaderInfo.parameters.copyText;
			}
			if(loaderInfo.parameters.signatureText){
				theSignature.text = loaderInfo.parameters.signatureText;
				theSignature.y = Math.min(564, theCopy.y + theCopy.textHeight + 26);
			}
			
			theTitle.alpha = 0;
			theCopy.alpha = 0;
			theSignature.alpha = 0;
			
			theContext = new SoundLoaderContext(3000); //set buffer to three seconds
			channel = new SoundChannel();
			track = new Sound();
			vol = new SoundTransform(1, 0);
			
			if(soundFile != null){
				playSound();
			}
			
			btnMute.buttonMode = true;
			btnMute.addEventListener(MouseEvent.CLICK, muteSound, false, 0, true);
			
			balloon.scaleX = balloon.scaleY = 0;			
			
			TweenLite.to(balloon, 1, { scaleX:1, scaleY:1, ease:Bounce.easeOut, onComplete:jukeAnim } );
			
			TweenLite.to(theTitle, 1, { alpha:1 } );
			TweenLite.to(theCopy, 1, { alpha:1, delay:.5 } );
			TweenLite.to(theSignature, 1, { alpha:1, delay:1 } );
			
			glowTimeline = new TimelineLite( { onComplete:jukeAnim } );
			glowTimeline.append(new TweenLite(glow1, 1, { alpha:0 } ));
			glowTimeline.append(new TweenLite(glow1, 1, { alpha:.4, delay:1 } ));
		}
		
		
		private function playSound():void
		{
			track = new Sound(); //must make a new sound object each time a track is played
			track.load(new URLRequest(soundFile), theContext);
			channel = track.play();
		}
		
		
		private function muteSound(e:MouseEvent):void
		{
			isMuted = !isMuted;
			vol.volume = isMuted ? 0 : 1;
			channel.soundTransform = vol;
		}
		
		
		private function jukeAnim():void
		{
			glowTimeline.gotoAndPlay(0);			
		}
		
		
	}	
}