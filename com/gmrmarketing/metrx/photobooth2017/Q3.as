package com.gmrmarketing.metrx.photobooth2017
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Q3 extends EventDispatcher
	{
		public static const COMPLETE:String = "q3Complete";
		public static const HIDDEN:String = "q3Hidden";
		private var clip:MovieClip;
		private var _container:DisplayObjectContainer;
		private var answers:Array;
		
		
		public function Q3()
		{
			clip = new quiz_q3();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			_container = c;
		}
		
		
		public function get points():Number
		{
			var p:Number = 0;
			for (var i:int = 0; i < 4; i++){
				if (answers[i] == 1){
					p += .5;
				}
			}
			return p;
		}
		
		
		public function show():void
		{
			if (!_container.contains(clip)){
				_container.addChild(clip);
			}
			
			answers = [0, 0, 0, 0];
			
			clip.tread.x = 1920;//216
			clip.question.alpha = 0;
			clip.sub.alpha = 0;
			clip.a1.x = 1920;//932
			clip.a2.x = 1920;//932
			clip.a3.x = 1920;//932
			clip.a4.x = 1920;//932
			
			clip.pic.x = 2500;//0
			clip.pic.scaleX = clip.pic.scaleY = 1;
			clip.btnNext.alpha = 0;
			
			clip.a1.addEventListener(MouseEvent.MOUSE_DOWN, quesAnswered, false, 0, true);
			clip.a2.addEventListener(MouseEvent.MOUSE_DOWN, quesAnswered, false, 0, true);
			clip.a3.addEventListener(MouseEvent.MOUSE_DOWN, quesAnswered, false, 0, true);
			clip.a4.addEventListener(MouseEvent.MOUSE_DOWN, quesAnswered, false, 0, true);		
			
			allWhite();
			
			TweenMax.to(clip.tread, .5, {x:216, ease:Expo.easeOut});
			TweenMax.to(clip.pic, .5, {x:684, ease:Expo.easeOut, delay:.1});
			TweenMax.to(clip.question, .5, {alpha:1, delay:.2});
			TweenMax.to(clip.sub, .5, {alpha:1, delay:.2});
			TweenMax.to(clip.a1, .5, {x:932, delay:.3});
			TweenMax.to(clip.a2, .5, {x:932, delay:.4});
			TweenMax.to(clip.a3, .5, {x:932, delay:.5});
			TweenMax.to(clip.a4, .5, {x:932, delay:.6, onComplete:startPicAnim});
		}
		
		
		public function hide():void
		{
			TweenMax.killTweensOf(clip.pic);
			clip.a1.removeEventListener(MouseEvent.MOUSE_DOWN, quesAnswered);
			clip.a2.removeEventListener(MouseEvent.MOUSE_DOWN, quesAnswered);
			clip.a3.removeEventListener(MouseEvent.MOUSE_DOWN, quesAnswered);
			clip.a4.removeEventListener(MouseEvent.MOUSE_DOWN, quesAnswered);
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
			var n:int = parseInt(m.name.substr(1, 1));//a1 - a4 becomes 1 - 4
			
			if (answers[n - 1] == 0){
				TweenMax.to(m.bg, .5, {colorTransform:{tint:0xE55F25, tintAmount:1}});
				answers[n - 1] = 1;
			}else{
				TweenMax.to(m.bg, .5, {colorTransform:{tint:0xFFFFFF, tintAmount:1}});
				answers[n - 1] = 0;
			}
			
			if (answers.indexOf(1) == -1){
				//nothing selected
				TweenMax.to(clip.btnNext, 1, {alpha:0});
				clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, nextPressed);
			}else{
				//at least one is selected
				TweenMax.to(clip.btnNext, 1, {alpha:1});
				clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, nextPressed, false, 0, true);
			}
			
		}
		
		
		private function allWhite():void
		{
			answers = [0, 0, 0, 0];
			TweenMax.to(clip.a1.bg, 0, {colorTransform:{tint:0xFFFFFF, tintAmount:1}});
			TweenMax.to(clip.a2.bg, 0, {colorTransform:{tint:0xFFFFFF, tintAmount:1}});
			TweenMax.to(clip.a3.bg, 0, {colorTransform:{tint:0xFFFFFF, tintAmount:1}});
			TweenMax.to(clip.a4.bg, 0, {colorTransform:{tint:0xFFFFFF, tintAmount:1}});
		}
		
		
		private function nextPressed(e:MouseEvent):void
		{
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, nextPressed);
			dispatchEvent(new Event(COMPLETE));
		}
	}
	
}