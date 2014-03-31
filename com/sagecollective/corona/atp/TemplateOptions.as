/**
 * Instantiated by Instructions
 */
package com.sagecollective.corona.atp
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.events.MouseEvent;
	import com.sagecollective.utilities.TimeoutHelper;
	
	
	public class TemplateOptions extends EventDispatcher
	{
		public static const TEMPLATE_PICKED:String = "templatePicked";
		public static const TAKE_PHOTO:String = "takePhotoClicked";
		public static const TEMPLATES_REMOVED:String = "templatesRemoved";		
		
		private var container:DisplayObjectContainer;
		
		private var template1:MovieClip;
		private var template2:MovieClip;
		private var template3:MovieClip;
		private var whichTemplate:int;
		
		private var timeoutHelper:TimeoutHelper;
		
		
		
		public function TemplateOptions($container:DisplayObjectContainer)
		{
			container = $container;
			timeoutHelper = TimeoutHelper.getInstance();
			
			template1 = new template_holder1(); //lib clips
			template2 = new template_holder2();
			template3 = new template_holder3();
		}
		
		
		public function show():void
		{
			whichTemplate = 0;
			
			template1.btnTakePic.alpha = 0;
			template2.btnTakePic.alpha = 0;
			template3.btnTakePic.alpha = 0;
			
			template1.x = 403;
			template1.y = 1120;// 790;
			
			template2.x = 819;
			template2.y = 1120;// 790;
			
			template3.x = 1227;
			template3.y = 1120;// 790;
			
			container.addChild(template1);
			container.addChild(template2);
			container.addChild(template3);
			
			TweenMax.to(template1, .5, { y:790, ease:Bounce.easeOut } );
			TweenMax.to(template2, .5, { y:790, ease:Bounce.easeOut, delay:.1 } );
			TweenMax.to(template3, .5, { y:792, ease:Bounce.easeOut, delay:.2 } );
			
			template1.addEventListener(MouseEvent.MOUSE_DOWN, t1Clicked, false, 0, true);
			template2.addEventListener(MouseEvent.MOUSE_DOWN, t2Clicked, false, 0, true);
			template3.addEventListener(MouseEvent.MOUSE_DOWN, t3Clicked, false, 0, true);
		}
		
		
		public function hide():void
		{
			if(container.contains(template1)){
				TweenMax.to(template1, .5, { y:1120, ease:Back.easeIn } );
				TweenMax.to(template2, .5, { y:1120, ease:Back.easeIn, delay:.1 } );
				TweenMax.to(template3, .5, { y:1120, ease:Back.easeIn, delay:.2, onComplete:killTemplates } );
			}
		}
		
		
		/**
		 * returns the picked template
		 * @return integer 1-3
		 */
		public function getTemplate():int
		{
			return whichTemplate;
		}
		
		
		/**
		 * Called from hide() once the templates are hidden
		 */
		private function killTemplates():void
		{
			container.removeChild(template1);
			container.removeChild(template2);
			container.removeChild(template3);
			
			dispatchEvent(new Event(TEMPLATES_REMOVED));
		}
		
		
		private function t1Clicked(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			if (whichTemplate == 1) {
				dispatchEvent(new Event(TAKE_PHOTO));
			}else {
				TweenMax.killAll();
				whichTemplate = 1;
				TweenMax.to(template1.btnTakePic, .5, { alpha:1 } );
				template2.btnTakePic.alpha = 0;
				template3.btnTakePic.alpha = 0;
				dispatchEvent(new Event(TEMPLATE_PICKED));
			}
		}
		
		
		private function t2Clicked(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			if (whichTemplate == 2) {
				dispatchEvent(new Event(TAKE_PHOTO));
			}else {
				TweenMax.killAll();
				whichTemplate = 2;
				TweenMax.to(template2.btnTakePic, .5, { alpha:1 } );
				template1.btnTakePic.alpha = 0;
				template3.btnTakePic.alpha = 0;
				dispatchEvent(new Event(TEMPLATE_PICKED));
			}
		}
		
		
		private function t3Clicked(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			if (whichTemplate == 3) {
				dispatchEvent(new Event(TAKE_PHOTO));
			}else {
				TweenMax.killAll();
				whichTemplate = 3;
				TweenMax.to(template3.btnTakePic, .5, { alpha:1 } );
				template1.btnTakePic.alpha = 0;
				template2.btnTakePic.alpha = 0;
				dispatchEvent(new Event(TEMPLATE_PICKED));
			}
		}
	}
	
}