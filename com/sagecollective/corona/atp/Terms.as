package com.sagecollective.corona.atp
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.sagecollective.utilities.SliderV;
	import flash.events.MouseEvent;
	import com.greensock.TweenMax;
	
	
	public class Terms extends EventDispatcher
	{		
		//dispatched so main can update the timeout object
		public static const TERMS_MOVED:String = "theTermsMoved";
		public static const TERMS_CLOSED:String = "theTermsWasClosed";
		
		private var termsSlider:SliderV;
		private var terms:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Terms()
		{
			
		}
		
		
		public function show($container:DisplayObjectContainer):void
		{
			container = $container;			
			dispatchEvent(new Event(TERMS_MOVED));
			
			terms = new theTerms(); //lib clip
			terms.alpha = 0;			
			container.addChild(terms);
			TweenMax.to(terms, .5, { alpha:1 } );
			termsSlider = new SliderV(terms.drag, terms.track);
			termsSlider.addEventListener(SliderV.DRAGGING, updateTerms, false, 0, true);
			terms.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeTerms, false, 0, true);
			
		}		
		
		
		//called from Main if the app times out
		public function hide():void
		{
			if(termsSlider){
				termsSlider.removeEventListener(SliderV.DRAGGING, updateTerms);
			}			
			if (terms) {
				terms.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeTerms);
				if (container.contains(terms)) {
					container.removeChild(terms);
				}
			}			
			terms = null;
			termsSlider = null;
		}
		
		
		private function updateTerms(e:Event):void
		{		
			dispatchEvent(new Event(TERMS_MOVED));
			terms.termsText.y = 286 - termsSlider.getPosition() * 3163;
		}		
		
		
		private function closeTerms(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			dispatchEvent(new Event(TERMS_MOVED));
			termsSlider.removeEventListener(SliderV.DRAGGING, updateTerms);
			terms.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeTerms);
			TweenMax.to(terms, 1, { alpha:0, onComplete:killTerms } );
		}
		
		
		private function killTerms():void
		{
			container.removeChild(terms);
			terms = null;
			termsSlider = null;
			dispatchEvent(new Event(TERMS_CLOSED));
		}
		
		
	}
	
}