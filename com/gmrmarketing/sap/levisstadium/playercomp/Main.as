package com.gmrmarketing.sap.levisstadium.playercomp
{
	import com.gmrmarketing.sap.levisstadium.ISchedulerMethods;
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	

	public class Main extends MovieClip implements ISchedulerMethods
	{
		public static const READY:String = "ready";
		public static const ERROR:String = "error";
		private var degToRad:Number = 0.0174532925; //PI / 180
		private var json:Object;
		
		private var p1Ring:MovieClip;
		private var p1Name:MovieClip;
		private var p1Stats:MovieClip;
		private var p1Sent:Sprite; //container for animated arc - sentiment
		private var p1Image:Bitmap;
		private var lastP1Image:Bitmap;//used with localCache
		
		private var p2Ring:MovieClip;
		private var p2Name:MovieClip;
		private var p2Stats:MovieClip;
		private var p2Sent:Sprite; //container for animated arc - sentiment
		private var p2Image:Bitmap;
		private var lastP2Image:Bitmap;//used with localCache
		
		private var tweenObject:Object;//for tweening arc
		private var theTitle:String; //QUARTERBACK" etc. Set in setConfig()
		
		private var icon:Bitmap;
		private var localCache:Object;
		
		
		public function Main()
		{
			p1Ring = new playerRing();			
			p2Ring = new playerRing();
			p1Name = new whiteTop();
			p1Stats = new stats();
			p2Name = new whiteTop();
			p2Stats = new stats();
			p1Sent = new Sprite();
			p2Sent = new Sprite();
			
			//init("08/24/14,QB");
		}
		
		
		
		/**
		 * ISChedulerMethods
		 * config is a String like 08/17/14,QB
		 */
		public function init(initValue:String = ""):void
		{
			var ar:Array = initValue.split(",");
			
			p1Ring.x = -231;
			p1Ring.y = 20;
			
			p1Name.x = -234;
			p1Name.y = 188;
			
			p1Stats.x = -234;
			p1Stats.y = 240;
			p1Stats.scaleY = 0;
			
			p2Ring.x = 778;
			p2Ring.y = 20;
			
			p2Name.x = 775;
			p2Name.y = 188;
			
			p2Stats.x = 775;
			p2Stats.y = 240;
			p2Stats.scaleY = 0;
			
			if(!p1Stats.contains(p1Sent)){
				p1Stats.addChild(p1Sent);
			}
			if(!p2Stats.contains(p2Sent)){
				p2Stats.addChild(p2Sent);
			}
			
			title.y = -241;
			
			tweenObject = { p1Sent:0, p2Sent:0 };
			
			//text in the middle that slides down
			switch(ar[1]) {
				case "QB":
					title.theTitle.text = "QUARTERBACK";
					title.sub1.text = "OFFENSE";
					title.sub2.text = "OFFENSE";
					icon = new Bitmap(new QBicon());
					break;
				case "WR":
					title.theTitle.text = "WIDE RECEIVER";
					title.sub1.text = "OFFENSE";
					title.sub2.text = "OFFENSE";
					icon = new Bitmap(new WRicon());
					break;
				case "TE":
					title.theTitle.text = "TIGHT END";
					title.sub1.text = "OFFENSE";
					title.sub2.text = "OFFENSE";
					icon = new Bitmap(new TEicon());
					break;
				case "RB":
					title.theTitle.text = "RUNNING BACK";
					title.sub1.text = "OFFENSE";
					title.sub2.text = "OFFENSE";
					icon = new Bitmap(new RBicon());
					break;
			}
			
			icon.x = 302;
			icon.y = -100;
			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/netbase/playercomparison?gamedate=" + ar[0] + "&position=" + ar[1]+"&abc="+String(new Date().valueOf()));
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		
		/**
		 * ISChedulerMethods
		 * Called once scheduler receives READY event
		 */
		public function show():void
		{			
			var p1:Object;//Player 1
			var p2:Object;//Player 2
			
			p1 = json.Game[0].Players[0];
			p2 = json.Game[0].Players[1];			
			
			p1Name.playerName.text = p1.PlayerName;	
			
			p1Stats.s1.theName.text = p1.Stats[1].PlayerPositionStatName;
			p1Stats.s1.value.text = p1.Stats[1].PlayerPositionStatValue;
			
			p1Stats.s2.theName.text = p1.Stats[2].PlayerPositionStatName;
			p1Stats.s2.value.text = p1.Stats[2].PlayerPositionStatValue;
			
			p1Stats.s3.theName.text = p1.Stats[3].PlayerPositionStatName;
			p1Stats.s3.value.text = p1.Stats[3].PlayerPositionStatValue;
			
			p2Name.playerName.text = p2.PlayerName;
			
			p2Stats.s1.theName.text = p2.Stats[1].PlayerPositionStatName;
			p2Stats.s1.value.text = p2.Stats[1].PlayerPositionStatValue;
			
			p2Stats.s2.theName.text = p2.Stats[2].PlayerPositionStatName;
			p2Stats.s2.value.text = p2.Stats[2].PlayerPositionStatValue;
			
			p2Stats.s3.theName.text = p2.Stats[3].PlayerPositionStatName;
			p2Stats.s3.value.text = p2.Stats[3].PlayerPositionStatValue;
			
			addChild(p1Ring);
			addChild(p1Name);
			addChild(p1Stats);
			
			p1Stats.s1.scaleX = p1Stats.s1.scaleY = 0;
			p1Stats.s2.scaleX = p1Stats.s2.scaleY = 0;
			p1Stats.s3.scaleX = p1Stats.s3.scaleY = 0;
			
			addChild(p2Ring);
			addChild(p2Name);
			addChild(p2Stats);
			
			p2Stats.s1.scaleX = p2Stats.s1.scaleY = 0;
			p2Stats.s2.scaleX = p2Stats.s2.scaleY = 0;
			p2Stats.s3.scaleX = p2Stats.s3.scaleY = 0;
			
			addChild(icon);
			
			TweenMax.to(p1Ring, 1, { x:41, ease:Back.easeOut } );
			TweenMax.to(p1Name, 1, { x:36, ease:Back.easeOut, delay:.25 } );
			TweenMax.to(p1Stats, 1, { x:36, scaleY:1, ease:Back.easeOut, delay:.5 } );
			
			TweenMax.to(p1Stats.s1, .5, { scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.25 } );			
			TweenMax.to(p1Stats.s2, .5, { scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.3 } );			
			TweenMax.to(p1Stats.s3, .5, { scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.35 } );			
			
			TweenMax.to(p2Ring, 1, { x:514, ease:Back.easeOut, delay:.25 } );
			TweenMax.to(p2Name, 1, { x:509, ease:Back.easeOut, delay:.5 } );
			TweenMax.to(p2Stats, 1, { x:509, scaleY:1, ease:Back.easeOut, delay:.75 } );
			
			TweenMax.to(p2Stats.s1, .5, { scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.6 } );			
			TweenMax.to(p2Stats.s2, .5, { scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.55 } );			
			TweenMax.to(p2Stats.s3, .5, { scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.5 } );	
			
			TweenMax.to(title, 1, { y:155, ease:Back.easeOut, delay:1 } );
			TweenMax.to(icon, 1, { y:60, ease:Back.easeOut, delay:2 } );
			
			//draw filled in white background circles first
			draw_arc(p1Stats.graphics, 65, 128, 26, 0, 360, 6, 0xffffff);
			draw_arc(p2Stats.graphics, 65, 128, 26, 0, 360, 6, 0xffffff);
			
			tweenObject.p1Sent = 0;
			tweenObject.p2Sent = 0;
			
			p1Stats.theSentiment.theText.text = 0;
			p2Stats.theSentiment.theText.text = 0;
			
			if (p1.Stats[0].PlayerPositionStatValue < 0) {
				p1Sent.scaleX = -1;
				p1Sent.x = 130;
				tweenObject.p1NegSent = true;
			}else {
				p1Sent.scaleX = 1;
				p1Sent.x = 0;
				tweenObject.p1NegSent = false;
			}
				
			if (p2.Stats[0].PlayerPositionStatValue < 0) {
				p2Sent.scaleX = -1;		
				p2Sent.x = 130;
				tweenObject.p2NegSent = true;
			}else {
				p2Sent.scaleX = 1;
				p2Sent.x = 0;
				tweenObject.p2NegSent = false;
			}			
						
			TweenMax.to(tweenObject, 5, { p1Sent:Math.abs(p1.Stats[0].PlayerPositionStatValue * 3.6), delay:1, onUpdate:drawP1Sent } );
			TweenMax.to(tweenObject, 5, { p2Sent:Math.abs(p2.Stats[0].PlayerPositionStatValue * 3.6), delay:1, onUpdate:drawP2Sent} );
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function hide():void
		{
			
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function doStop():void
		{
			
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function kill():void
		{
			//don't remove gray circle already in the clip
			while (p1Ring.numChildren > 1) {
				p1Ring.removeChildAt(1);
			}
			removeChild(p1Ring);
			removeChild(p1Name);
			removeChild(p1Stats);
			
			//don't remove gray circle already in the clip
			while (p2Ring.numChildren > 1) {
				p2Ring.removeChildAt(1);
			}
			removeChild(p2Ring);
			removeChild(p2Name);
			removeChild(p2Stats);
			
			icon.bitmapData.dispose();
			removeChild(icon);
			
			p1Stats.graphics.clear();
			p2Stats.graphics.clear();			
			p1Sent.graphics.clear();
			p2Sent.graphics.clear();
			/*
			if(p1Image){
				p1Image.bitmapData.dispose();
			}
			if(p2Image){
				p2Image.bitmapData.dispose();
			}
			p1Image = null;
			p2Image = null;
			*/
		}
		
		
		private function dataLoaded(e:Event):void
		{
			json = JSON.parse(e.currentTarget.data);
			localCache = json;
			
			var p1URL:String;
			var p2URL:String;
			
			p1URL = json.Game[0].Players[0].PhotoURL;
			p2URL = json.Game[0].Players[1].PhotoURL;
			
			if(p1URL){
				var p1Loader:Loader = new Loader();
				p1Loader.contentLoaderInfo.addEventListener(Event.COMPLETE, p1Loaded, false, 0, true);			
				p1Loader.load(new URLRequest(p1URL));
			}
			
			if(p2URL){
				var p2Loader:Loader = new Loader();
				p2Loader.contentLoaderInfo.addEventListener(Event.COMPLETE, p2Loaded, false, 0, true);			
				p2Loader.load(new URLRequest(p2URL));
			}
			
			//show();//TESTING
			dispatchEvent(new Event(READY));//will call show()
		}
		
		
		private function p1Loaded(e:Event):void
		{			
			p1Image = Bitmap(e.target.content);
			p1Image.smoothing = true;
			
			lastP1Image = Bitmap(e.target.content);
			lastP1Image.smoothing = true;
			
			var m:MovieClip = new ringMask();//lib clip
			p1Ring.addChild(p1Image);
			p1Ring.addChild(m);
			p1Image.mask = m;
		}
		
		
		private function p2Loaded(e:Event):void
		{			
			p2Image = Bitmap(e.target.content);
			p2Image.smoothing = true;
			
			lastP2Image = Bitmap(e.target.content);
			lastP2Image.smoothing = true;
			
			var m:MovieClip = new ringMask();//lib clip
			p2Ring.addChild(p2Image);
			p2Ring.addChild(m);
			p2Image.mask = m;
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			if (localCache) {
				json = localCache;				
			
				var m:MovieClip = new ringMask();//lib clip
				p1Ring.addChild(lastP1Image);
				p1Ring.addChild(m);
				lastP1Image.mask = m;				
			
				var m2:MovieClip = new ringMask();//lib clip
				p2Ring.addChild(lastP2Image);
				p2Ring.addChild(m2);
				lastP2Image.mask = m2;
				
				dispatchEvent(new Event(READY));
			}else{
				dispatchEvent(new Event(ERROR));
			}
		}
		
		/**
		 * Called by TweenMax - animates ring drawing and text
		 * 
		 */
		private function drawP1Sent():void
		{
			draw_arc(p1Sent.graphics, 65, 128, 26, 0, tweenObject.p1Sent, 6, 0xedb01a);
			//if(tweenObject.p1Sent > 0){
			if(tweenObject.p1NegSent){
				p1Stats.theSentiment.theText.text = Math.round(-tweenObject.p1Sent / 3.6);
			}else {
				p1Stats.theSentiment.theText.text = Math.round(tweenObject.p1Sent / 3.6);					
			}
			//}
		}
		
		
		private function drawP2Sent():void
		{
			draw_arc(p2Sent.graphics, 65, 128, 26, 0, tweenObject.p2Sent, 6, 0x058bd6);
			//if(tweenObject.p2Sent > 0){
			if(tweenObject.p2NegSent){
				p2Stats.theSentiment.theText.text = Math.round(-tweenObject.p2Sent / 3.6);
			}else {
				p2Stats.theSentiment.theText.text = Math.round(tweenObject.p2Sent / 3.6);					
			}
				
			//}
		}
		
		
		private function draw_arc(g:Graphics, center_x:int, center_y:int, radius:int, angle_from:int, angle_to:int, lineThickness:Number, lineColor:Number, alph:Number = 1):void
		{
			g.clear();
			//g.lineStyle(1, lineColor, alph, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			
			var angle_diff:Number = (angle_to) - (angle_from);
			var steps:int = angle_diff * 2; // 2 is precision... use higher numbers for more.
			var angle:Number = angle_from;
			
			var halfT:Number = lineThickness / 2; // Half thickness used to determine inner and outer points
			var innerRad:Number = radius - halfT; // Inner radius
			var outerRad:Number = radius + halfT; // Outer radius
			
			var px_inner:Number = getX(angle, innerRad, center_x); //sub 90 here and below to rotate the arc to start at 12oclock
			var py_inner:Number = getY(angle, innerRad, center_y); 
			
			if(angle_diff > 0){
				g.beginFill(lineColor, alph);
				g.moveTo(px_inner, py_inner);
				
				var i:int;
			
				// drawing the inner arc
				for (i = 1; i <= steps; i++) {
								angle = angle_from + angle_diff / steps * i;
								g.lineTo( getX(angle, innerRad, center_x), getY(angle, innerRad, center_y));
				}
				
				// drawing the outer arc
				for (i = steps; i >= 0; i--) {
								angle = angle_from + angle_diff / steps * i;
								g.lineTo( getX(angle, outerRad, center_x), getY(angle, outerRad, center_y));
				}
				
				g.lineTo(px_inner, py_inner);
				g.endFill();
			}
		}
		
		private function getX(angle:Number, radius:Number, center_x:Number):Number
		{
			return Math.cos((angle-90) * degToRad) * radius + center_x;
		}
		
		
		private function getY(angle:Number, radius:Number, center_y:Number):Number
		{
			return Math.sin((angle-90) * degToRad) * radius + center_y;
		}

	}
	
}