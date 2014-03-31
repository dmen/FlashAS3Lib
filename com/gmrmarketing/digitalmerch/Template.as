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
	import com.greensock.easing.*;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import com.gmrmarketing.digitalmerch.JukeAnim; //used for glowing the juke box
	import com.gmrmarketing.digitalmerch.BoltAnim; //used for animating the bolts
	import com.gmrmarketing.utilities.Tracer;
	
	public class Template extends MovieClip
	{
		private var theContext:SoundLoaderContext;		
		private var track:Sound;		
		private var channel:SoundChannel;
		private var vol:SoundTransform;
		
		private var soundFile:String;
		private var isMuted:Boolean = false;
		
		private var anim:JukeAnim;
		private var bolts:BoltAnim;
		private var tracer:Tracer;
		
		
		public function Template()
		{
			//tracer = new Tracer(this);
			//tracer.activate();
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
			if(loaderInfo.parameters.signatureText != null){
				theSignature.text = loaderInfo.parameters.signatureText;
				theSignature.y = Math.min(564, theCopy.y + theCopy.textHeight + 26);
			}
			
			//Font Size
			var ts:int = 41; //default font size to 41
			if (loaderInfo.parameters.balloonFontSize != null) {
				ts = Number(loaderInfo.parameters.balloonFontSize);
			}
			
			var tf:TextFormat = new TextFormat();
			tf.size = ts;
			var leading:int = 0 - ((ts - 18) / 2);
			tf.leading = leading;
			
			if (loaderInfo.parameters.balloonText != null) {
				balloon.theText.autoSize = TextFieldAutoSize.LEFT;			
				balloon.theText.text = loaderInfo.parameters.balloonText;
				balloon.theText.setTextFormat(tf);
				
				var bh:int = balloon.balloon.height;			
				var th:int = balloon.theText.textHeight;
				var hs:int = Math.floor((bh - th) * .5);			
				
				balloon.theText.y = balloon.balloon.y + hs;
			}
			
			//Text Y Adjustment
			if (loaderInfo.parameters.yAdjust != null) {
				balloon.theText.y += Number(loaderInfo.parameters.yAdjust);
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
			
			btnReplay.alpha = 0;
			btnMute.buttonMode = true;
			btnMute.addEventListener(MouseEvent.CLICK, muteSound, false, 0, true);
			
			balloon.scaleX = balloon.scaleY = 0;
			TweenLite.to(balloon, 1, { scaleX:1, scaleY:1, ease:Bounce.easeOut } );
			
			TweenLite.to(theTitle, 1, { alpha:1 } );
			TweenLite.to(theCopy, 1, { alpha:1, delay:.5 } );
			TweenLite.to(theSignature, 1, { alpha:1, delay:1 } );			
			
			anim = new JukeAnim(glow1);//only used by the jukebox card			
			//bolts = new BoltAnim(balloon);
		}
		
		
		private function playSound(e:MouseEvent = null):void
		{			
			track = new Sound(); //must make a new sound object each time a track is played
			track.load(new URLRequest(soundFile), theContext);
			channel = track.play();
			channel.addEventListener(Event.SOUND_COMPLETE, soundComplete, false, 0, true);
			
			TweenLite.to(btnReplay, 1, { alpha:0 });
			btnReplay.buttonMode = false;
			btnReplay.removeEventListener(MouseEvent.CLICK, playSound);
		}
		
		
		private function muteSound(e:MouseEvent):void
		{
			isMuted = !isMuted;
			vol.volume = isMuted ? 0 : 1;
			channel.soundTransform = vol;
		}
		
		private function soundComplete(e:Event):void
		{
			channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			
			TweenLite.to(btnReplay, 1, { alpha:1 });			
			btnReplay.buttonMode = true;
			btnReplay.addEventListener(MouseEvent.CLICK, playSound, false, 0, true);
		}
		
	}	
}