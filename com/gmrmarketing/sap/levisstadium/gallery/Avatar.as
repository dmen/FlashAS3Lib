package com.gmrmarketing.sap.levisstadium.gallery
{	
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.Utility;
	
	public class Avatar extends EventDispatcher
	{
		private var avatar:MovieClip;
		private var tweenOb:Object;
		private var arc:Sprite;
		
		public function Avatar(container:DisplayObjectContainer, image:BitmapData, loc:Array)
		{
			avatar = new ring();//lib clip
			//addChild(a);
			//a.x = 124;
			//a.y = 159;

			var b:Bitmap = new Bitmap(image);
			avatar.addChildAt(b,0);
			b.x = -75;//image is 150 x 176
			b.y = -88;

			var m:MovieClip = new masker();
			avatar.addChildAt(m, 1);
			b.mask = m;
			
			arc = new Sprite();
			avatar.addChild(arc);
			
			container.addChild(avatar);
			avatar.x = loc[0] - 100;
			avatar.y = loc[1] - 50;
			
			avatar.scaleX = avatar.scaleY = 0;
			avatar.alpha = 0;
			
			tweenOb = new Object();
			TweenMax.to(avatar, 1, { x:loc[0], y:loc[1], scaleX:1, scaleY:1, alpha:1, ease:Back.easeOut } );
			tweenOb.a = 0;
			TweenMax.to(tweenOb, 5, { a:360, onUpdate:drawArc } );
		}
		
		private function drawArc():void
		{
			Utility.drawArc(arc.graphics, 0, 0, 68, 0, tweenOb.a, 18, 0xedb01a, 1);
		}
	}
	
}