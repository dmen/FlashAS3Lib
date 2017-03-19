package com.gmrmarketing.metrx.photobooth2017
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Q2 extends EventDispatcher
	{
		public static const COMPLETE:String = "q2Complete";
		public static const HIDDEN:String = "q2Hidden";
		private var clip:MovieClip;
		private var _container:DisplayObjectContainer;
		private var answerA:int; //1 - 4
		private var answerB:int; //1 - 4
		
		
		public function Q2()
		{
			clip = new quiz_q2();
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
			
			answerA = undefined;
			answerB = undefined;
			
			clip.tread.x = 1920;//216
			clip.question.alpha = 0;
			clip.sub1.alpha = 0;
			clip.sub2.alpha = 0;
			clip.a1.x = 1920;
			clip.a2.x = 1920;
			clip.a3.x = 1920;
			clip.a4.x = 1920;
			
			clip.a5.x = 1920;
			clip.a6.x = 1920;
			clip.a7.x = 1920;
			clip.a8.x = 1920;
			
			clip.pic.x = 2400;
			clip.pic.scaleX = clip.pic.scaleY = 1;
			clip.btnNext.alpha = 0;
			
			clip.a1.addEventListener(MouseEvent.MOUSE_DOWN, quesAnswered, false, 0, true);
			clip.a2.addEventListener(MouseEvent.MOUSE_DOWN, quesAnswered, false, 0, true);
			clip.a3.addEventListener(MouseEvent.MOUSE_DOWN, quesAnswered, false, 0, true);
			clip.a4.addEventListener(MouseEvent.MOUSE_DOWN, quesAnswered, false, 0, true);
			
			clip.a5.addEventListener(MouseEvent.MOUSE_DOWN, quesAnswered, false, 0, true);
			clip.a6.addEventListener(MouseEvent.MOUSE_DOWN, quesAnswered, false, 0, true);
			clip.a7.addEventListener(MouseEvent.MOUSE_DOWN, quesAnswered, false, 0, true);
			clip.a8.addEventListener(MouseEvent.MOUSE_DOWN, quesAnswered, false, 0, true);
			
			TweenMax.to(clip.tread, .5, {x:216, ease:Expo.easeOut});
			TweenMax.to(clip.pic, .5, {x:445, ease:Expo.easeOut, delay:.1});
			
			TweenMax.to(clip.question, .5, {alpha:1, delay:.2});
			TweenMax.to(clip.sub1, .5, {alpha:1, delay:.3});
			TweenMax.to(clip.sub2, .5, {alpha:1, delay:.4});
			
			TweenMax.to(clip.a1, .5, {x:928, delay:.3});
			TweenMax.to(clip.a2, .5, {x:1142, delay:.4});
			TweenMax.to(clip.a3, .5, {x:1356, delay:.5});
			TweenMax.to(clip.a4, .5, {x:1570, delay:.6});
			
			TweenMax.to(clip.a5, .5, {x:928, delay:.3});
			TweenMax.to(clip.a6, .5, {x:1142, delay:.4});
			TweenMax.to(clip.a7, .5, {x:1356, delay:.5});
			TweenMax.to(clip.a8, .5, {x:1570, delay:.6, onComplete:startPicAnim});
		}
		
		
		public function hide():void
		{
			TweenMax.killTweensOf(clip.pic);
			
			clip.a1.removeEventListener(MouseEvent.MOUSE_DOWN, quesAnswered);
			clip.a2.removeEventListener(MouseEvent.MOUSE_DOWN, quesAnswered);
			clip.a3.removeEventListener(MouseEvent.MOUSE_DOWN, quesAnswered);
			clip.a4.removeEventListener(MouseEvent.MOUSE_DOWN, quesAnswered);
			
			clip.a5.removeEventListener(MouseEvent.MOUSE_DOWN, quesAnswered);
			clip.a6.removeEventListener(MouseEvent.MOUSE_DOWN, quesAnswered);
			clip.a7.removeEventListener(MouseEvent.MOUSE_DOWN, quesAnswered);
			clip.a8.removeEventListener(MouseEvent.MOUSE_DOWN, quesAnswered);
			
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, nextPressed);
			
			TweenMax.to(clip, .5, {x: -1920, onComplete:kill});
		}
		
		
		private function kill():void
		{
			dispatchEvent(new Event(HIDDEN));
			
			if (_container.contains(clip)){
				_container.removeChild(clip);
			}
		}
		
		
		private function startPicAnim():void
		{
			TweenMax.to(clip.pic, 3, {scaleX:1.03, scaleY:1.03, ease:Linear.easeNone, onComplete:endPicAnim});
		}
		
		
		private function endPicAnim():void
		{
			TweenMax.to(clip.pic, 3, {scaleX:1, scaleY:1, ease:Linear.easeNone, onComplete:startPicAnim});
		}
		
		
		private function quesAnswered(e:MouseEvent):void
		{
			var m:MovieClip = MovieClip(e.currentTarget);
			var n:int = parseInt(m.name.substr(1, 1));//a1 - a8 becomes 1 - 8
				
			if (n < 5){
				//1 - 4				
				answerA = n;
				allWhite(1);
			}else{
				//5 - 8				
				answerB = n;
				allWhite(2);
			}
			
			//enable the next button if both parts answered
			if (answerA && answerB){				
				TweenMax.to(clip.btnNext, 1, {alpha:1});
				clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, nextPressed, false, 0, true);
			}
			
			
			TweenMax.to(m.bg, .5, {colorTransform:{tint:0xE55F25, tintAmount:1}});
		}
		
		
		private function allWhite(group:int):void
		{
			if(group == 1){
				TweenMax.to(clip.a1.bg, 0, {colorTransform:{tint:0xFFFFFF, tintAmount:1}});
				TweenMax.to(clip.a2.bg, 0, {colorTransform:{tint:0xFFFFFF, tintAmount:1}});
				TweenMax.to(clip.a3.bg, 0, {colorTransform:{tint:0xFFFFFF, tintAmount:1}});
				TweenMax.to(clip.a4.bg, 0, {colorTransform:{tint:0xFFFFFF, tintAmount:1}});
			}else{
				TweenMax.to(clip.a5.bg, 0, {colorTransform:{tint:0xFFFFFF, tintAmount:1}});
				TweenMax.to(clip.a6.bg, 0, {colorTransform:{tint:0xFFFFFF, tintAmount:1}});
				TweenMax.to(clip.a7.bg, 0, {colorTransform:{tint:0xFFFFFF, tintAmount:1}});
				TweenMax.to(clip.a8.bg, 0, {colorTransform:{tint:0xFFFFFF, tintAmount:1}});
			}
		}
		
		
		private function nextPressed(e:MouseEvent):void
		{
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, nextPressed);
			dispatchEvent(new Event(COMPLETE));
		}
	}
	
}