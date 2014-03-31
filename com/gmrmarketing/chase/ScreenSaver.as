package com.gmrmarketing.chase
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class ScreenSaver
	{
		private var bg:MovieClip;
		private var city:MovieClip;
		private var goSign1:MovieClip;
		private var goSign2:MovieClip;
		private var paySign1:MovieClip;
		private var paySign2:MovieClip;		
		private var paySign3:MovieClip;
		private var smallLogo:MovieClip;
		private var bigLogo:MovieClip;
		private var tapInto:MovieClip;
		private var tapBtn:MovieClip;
		
		private var container:DisplayObjectContainer;
		
		private var tim:Timer;
		
		
		public function ScreenSaver($container:DisplayObjectContainer)
		{
			container = $container;
			
			//library clips
			bg = new ss_blueBG();
			city = new ss_city();
			goSign1 = new ss_paygo1();
			goSign2 = new ss_paygo2();
			paySign1 = new ss_paysave1();
			paySign2 = new ss_paysave2();
			paySign3 = new ss_paysave3();
			smallLogo = new logoSmall();
			bigLogo = new logoBig();
			tapInto = new textTapInto();
			tapBtn = new btnTap();
		}
		
		
		public function show(e:TimerEvent = null):void
		{		
			if(!container.contains(bg)){
				bg.alpha = 0;
				container.addChild(bg);
			}
			
			city.alpha = 0;
			container.addChild(city);
			city.rotationX = 45;
			
			goSign1.x = 789;
			goSign1.y = 732;
			goSign1.alpha = 0;
			container.addChild(goSign1);			
			
			goSign2.x = 1332;
			goSign2.y = 478;
			goSign2.alpha = 0;
			container.addChild(goSign2);			
			
			paySign1.x = 383;
			paySign1.y = 569;
			paySign1.alpha = 0;
			container.addChild(paySign1);			
			
			paySign2.x = 1176;
			paySign2.y = 673;
			paySign2.alpha = 0;
			container.addChild(paySign2);			
			
			paySign3.x = 1517;
			paySign3.y = 717;
			paySign3.alpha = 0;
			container.addChild(paySign3);
			
			smallLogo.x = 1579;
			smallLogo.y = 79;
			smallLogo.alpha = 0;
			container.addChild(smallLogo);
			
			tapInto.x = 54;
			tapInto.y = 69;
			tapInto.alpha = 0;
			container.addChild(tapInto);			
			
			tapBtn.x = 664;
			tapBtn.y = 886;
			tapBtn.alpha = 0;
			container.addChild(tapBtn);
			
			bigLogo.x = 543;
			bigLogo.y = 460;
			if (container.contains(bigLogo)) {
				TweenMax.to(bigLogo, 1, { alpha:0, delay:1 } );
			}
			
			TweenMax.to(bg, 2, { alpha:1 } );
			TweenMax.to(smallLogo, 1, { alpha:1, delay:1} );
			TweenMax.to(tapInto, 1, { alpha:1, delay:1 } );
			TweenMax.to(tapBtn, 1, { alpha:1, delay:1 } );
			TweenMax.to(city, 2, { alpha:1, rotationX:0, delay:1.5, onComplete:showTags } );
		}
				
		
		private function showTags():void
		{		
			paySign1.scaleY = 0;
			TweenMax.to(paySign1, 1.5, { scaleY:1, alpha:1, ease:Elastic.easeOut } );
			goSign1.scaleY = 0;
			TweenMax.to(goSign1, 1.5, { scaleY:1, alpha:1, delay:.5, ease:Elastic.easeOut } );
			paySign2.scaleY = 0;
			TweenMax.to(paySign2, 1.5, { scaleY:1, alpha:1, delay:1, ease:Elastic.easeOut } );
			goSign2.scaleY = 0;
			TweenMax.to(goSign2, 1.5, { scaleY:1, alpha:1, delay:1.5, ease:Elastic.easeOut } );
			paySign3.scaleY = 0;
			TweenMax.to(paySign3, 1.5, { scaleY:1, alpha:1, delay:2, ease:Elastic.easeOut } );
			
			tim = new Timer(5000, 1);
			tim.addEventListener(TimerEvent.TIMER, removeTags, false, 0, true);
			tim.start();
		}		
		
		
		private function removeTags(e:TimerEvent):void
		{
			TweenMax.to(paySign1, 1, { scaleY:0, alpha:0, ease:Back.easeIn } );
			TweenMax.to(paySign2, 1, { scaleY:0, alpha:0, ease:Back.easeIn } );
			TweenMax.to(paySign3, 1, { scaleY:0, alpha:0, ease:Back.easeIn } );
			TweenMax.to(goSign1, 1, { scaleY:0, alpha:0, ease:Back.easeIn } );
			TweenMax.to(goSign2, 1, { scaleY:0, alpha:0, ease:Back.easeIn } );
			
			tim = new Timer(3000, 1);
			tim.addEventListener(TimerEvent.TIMER, showTags2, false, 0, true);
			tim.start();
		}		
		
		
		private function showTags2(e:TimerEvent):void
		{			
			goSign1.y = -300;
			goSign1.scaleY = 1;
			goSign2.y = -300;
			goSign2.scaleY = 1;
			
			paySign1.y = -300;
			paySign1.scaleY = 1;
			paySign2.y = -300;
			paySign2.scaleY = 1;
			paySign3.y = -300;
			paySign3.scaleY = 1;
			
			TweenMax.to(goSign1, 1, { y:732, alpha:1, ease:Back.easeOut } );
			TweenMax.to(goSign2, 1, { y:478, alpha:1, delay:.25, ease:Back.easeOut } );
			TweenMax.to(paySign1, 1, { y:569, alpha:1, delay:.5, ease:Back.easeOut } );
			TweenMax.to(paySign2, 1, { y:673, alpha:1, delay:.75, ease:Back.easeOut } );
			TweenMax.to(paySign3, 1, { y:717, alpha:1, delay:1, ease:Back.easeOut } );
			
			tim = new Timer(5000, 1);
			tim.addEventListener(TimerEvent.TIMER, removeTags2, false, 0, true);
			tim.start();
		}
		
		
		private function removeTags2(e:TimerEvent):void
		{			
			TweenMax.to(goSign1, 1, { alpha:0 } );
			TweenMax.to(goSign2, 1, { alpha:0, delay:.25 } );
			TweenMax.to(paySign1, 1, { alpha:0, delay:.5 } );
			TweenMax.to(paySign2, 1, { alpha:0, delay:.75 } );
			TweenMax.to(paySign3, 1, { alpha:0, delay:1 } );
			TweenMax.to(tapInto, 1, { alpha:0, delay:1 } );
			TweenMax.to(tapBtn, 1, { alpha:0, delay:1 } );
			TweenMax.to(smallLogo, 1, { alpha:0, delay:1 } );
			
			
			TweenMax.to(city, 2, { alpha:0, rotationX:45, delay:1.25 } );
			
			bigLogo.alpha = 0;
			container.addChild(bigLogo);
			TweenMax.to(bigLogo, 2, { alpha:1, delay:1.5 } );
			
			tim = new Timer(6000, 1);
			tim.addEventListener(TimerEvent.TIMER, show, false, 0, true);
			tim.start();
		}
		
		
		public function hide():void
		{
			if(tim){
				tim.reset();
			}
			TweenMax.killAll();
			
			if (container) {
				if(container.contains(bg)){
					container.removeChild(bg);
					container.removeChild(city);
					container.removeChild(goSign1);
					container.removeChild(goSign2);					
					container.removeChild(paySign1);					
					container.removeChild(paySign2);					
					container.removeChild(paySign3);	
					container.removeChild(tapBtn);	
					container.removeChild(tapInto);					
					container.removeChild(smallLogo);					
				}
				if (container.contains(bigLogo)) {
					container.removeChild(bigLogo);
				}
			}
		}
		
	}
	
}