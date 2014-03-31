package com.gmrmarketing.chase
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import com.greensock.TweenMax;
	
	public class IpadMain extends MovieClip
	{
		public function IpadMain()
		{
			btn1.addEventListener(MouseEvent.MOUSE_DOWN, url1, false, 0, true);
			btn2.addEventListener(MouseEvent.MOUSE_DOWN, url2, false, 0, true);
			btn3.addEventListener(MouseEvent.MOUSE_DOWN, url3, false, 0, true);
			btn4.addEventListener(MouseEvent.MOUSE_DOWN, url4, false, 0, true);
		}
		
		private function url1(e:MouseEvent):void
		{
			btn1.alpha = .5;
			TweenMax.to(btn1, .5, { alpha:0 } );
			navigateToURL(new URLRequest("https://creditcards.chase.com/freedom/Default.aspx"), "_blank");
		}
		
		private function url2(e:MouseEvent):void
		{
			btn2.alpha = .5;
			TweenMax.to(btn2, .5, { alpha:0 } );
			navigateToURL(new URLRequest("http://www.facebook.com/ChaseFreedom"), "_blank");
		}
		
		private function url3(e:MouseEvent):void
		{
			btn3.alpha = .5;
			TweenMax.to(btn3, .5, { alpha:0 } );
			navigateToURL(new URLRequest("http://www.youtube.com/user/ChaseFreedom"), "_blank");
		}
		
		private function url4(e:MouseEvent):void
		{
			btn4.alpha = .5;
			TweenMax.to(btn4, .5, { alpha:0 } );
			navigateToURL(new URLRequest("https://locator.chase.com/"), "_blank");
		}
	}
	
}