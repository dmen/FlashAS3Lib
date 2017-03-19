package  com.gmrmarketing.warnerBrothers.jlphotobooth
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Intro extends EventDispatcher
	{
		private var clip:MovieClip;
		private var _container:DisplayObjectContainer;
		
		
		public function Intro()
		{
			clip = new mcIntro();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			_container = c;
		}
		
		
		public function show():void
		{
			if (!_container.contains(clip)){
				_container.addChild(clip);
			}
			
			clip.logoA.scaleX = clip.logoA.scaleY = 0;
			clip.logoB.scaleX = clip.logoB.scaleY = 0;
			clip.logoC.scaleX = clip.logoC.scaleY = 0;
			clip.logoD.scaleX = clip.logoD.scaleY = 0;
			clip.logoE.scaleX = clip.logoE.scaleY = 0;
			clip.logoF.scaleX = clip.logoF.scaleY = 0;
			
			clip.choose.alpha = 0;
			clip.choose.y = 600;
			
			TweenMax.to(clip.logoA, .5, {scaleX:1, scaleY:1, ease:Back.easeOut});
			TweenMax.to(clip.logoB, .5, {scaleX:1, scaleY:1, delay:.1, ease:Back.easeOut});
			TweenMax.to(clip.logoC, .5, {scaleX:1, scaleY:1, delay:.2, ease:Back.easeOut});
			TweenMax.to(clip.logoD, .5, {scaleX:1, scaleY:1, delay:.3, ease:Back.easeOut});
			TweenMax.to(clip.logoE, .5, {scaleX:1, scaleY:1, delay:.4, ease:Back.easeOut});
			TweenMax.to(clip.logoF, .5, {scaleX:1, scaleY:1, delay:.5, ease:Back.easeOut});
			
			TweenMax.to(clip.choose, .5, {alpha:1, y:553, delay:.75, ease:Back.easeOut});
		}
	}
	
}