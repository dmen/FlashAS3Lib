package com.gmrmarketing.miller.sxsw
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import com.greensock.TweenMax;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.display.BlendMode;
	import flash.utils.Timer;
	
	
	public class Orbs
	{
		private var orbs:Array;
		private var orbHolder:Sprite;
		private var container:DisplayObjectContainer;
		private var theBlur:BlurFilter;
		private var animTimer:Timer;
		
		
		public function Orbs()
		{
			theBlur = new BlurFilter(30, 30, 2);
			
			animTimer = new Timer(1500);
			animTimer.addEventListener(TimerEvent.TIMER, animateOrb, false, 0, true);
			
			orbHolder = new Sprite();
			orbs = new Array();
			//bottom
			orbs.push([2, 178, 161, 89, 17]);
			orbs.push([2, 277, 953, 993, 17]);
			orbs.push([2, 277, 1083, 773, 17]);
			orbs.push([2, 220, 1191, 766, 17]);
			orbs.push([2, 277, 1241, 929, 15]);
			orbs.push([2, 220, 1645, 249, 17]);
			orbs.push([2, 127, 1706, 422, 15]);
			orbs.push([1, 220, 1434, 898, 15]);
			orbs.push([1, 220, 1585, 1134, 15]);			
			//mid
			orbs.push([1, 191, 1533, 441, 25]);
			orbs.push([1, 160, 1615, 548, 25]);
			orbs.push([1, 127, 1144, 1118, 32]);
			orbs.push([1, 160, 1312, 1092, 25]);
			orbs.push([1, 220, 1458, 1022, 32]);
			orbs.push([1, 191, 1488, 913, 25]);
			orbs.push([1, 220, 1678, 828, 32]);
			orbs.push([1, 160, 1708, 708, 25]);
			//top
			orbs.push([1, 112, 56, 123, 54]);
			orbs.push([1, 220, 1247, 929, 54]);
			orbs.push([1, 220, 1387, 798, 54]);
			orbs.push([1, 191, 1567, 724, 54]);
			orbs.push([1, 191, 1747, 593, 54]);
			orbs.push([1, 220, 1017, 1062, 54]);
			orbs.push([2, 220, 1705, 986, 54]);
			orbs.push([1, 220, 1678, 998, 15]);
			orbs.push([1, 220, 1585, 881, 15]);
			
			for (var i:int = 0; i < orbs.length; i++) {
				var thisOrb:Array = orbs[i];
				var orbClip:MovieClip;
				if (thisOrb[0] == 1) {
					orbClip = new orb();
				}else {
					orbClip = new orb2();
				}
				orbClip.filters = [theBlur];
				orbClip.blendMode = BlendMode.ADD;
				orbHolder.addChild(orbClip);
				orbClip.width = orbClip.height = thisOrb[1];
				orbClip.x = thisOrb[2];
				orbClip.y = thisOrb[3];
				orbClip.alpha = thisOrb[4] / 100;
			}
		}
		
		
		public function show($container:DisplayObjectContainer):void
		{
			container = $container;
			container.addChild(orbHolder);
		}
		
		
		public function animate(on:Boolean = true):void
		{	
			if(on){
				animTimer.start();
			}else {
				animTimer.stop();
			}
		}
		
		private function animateOrb(e:TimerEvent):void
		{
			 var n:int = Math.floor(Math.random() * orbs.length);
			 var orb:MovieClip = MovieClip(orbHolder.getChildAt(n));
			 var oAlpha:Number = orbs[n][4] / 100;
			 var aTime:Number = (1 + Math.random()) * 2;
			 
			 TweenMax.to(orb, aTime, { alpha:.1, onComplete:resetOrb, onCompleteParams:[orb, oAlpha] } );			 
		}
		
		
		private function resetOrb(orb:MovieClip, alph:Number):void
		{
			TweenMax.to(orb, 1, { alpha:alph } );
		}
	}
	
}