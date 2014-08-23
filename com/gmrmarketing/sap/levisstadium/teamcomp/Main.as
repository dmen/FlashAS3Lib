package com.gmrmarketing.sap.levisstadium.teamcomp
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
		
		private var homeRing:MovieClip;
		private var homeTwitter:MovieClip;
		private var homeStats:MovieClip;
		private var homeSent:Sprite; //container for animated arc
		
		private var visRing:MovieClip;
		private var visTwitter:MovieClip;
		private var visStats:MovieClip;
		private var visSent:Sprite; //container for animated arc
		
		private var tweenObject:Object;
		private var localCache:Object;
		
		public function Main()
		{
			homeRing = new helmetRing();			
			homeTwitter = new whiteTop();			
			homeStats = new stats();			
			
			visRing = new helmetRing();
			visRing.helmet.scaleX = -1;
			TweenMax.to(visRing.helmet, 0, { colorTransform: { tint:0x058bd6, tintAmount:1 }} );			
			visTwitter = new whiteTop();			
			visStats = new stats();			
			
			homeSent = new Sprite();///home sentiment
			visSent = new Sprite();//visitor sentiment		
			
			//init("08/24/14");
		}
		
		
		
		/**
		 * ISChedulerMethods
		 * initValue is a date like 08/17/14
		 */
		public function init(initValue:String = ""):void
		{
			homeRing.x = -231;
			homeRing.y = 20;
			
			homeTwitter.x = -234;
			homeTwitter.y = 188;
			
			homeStats.x = -234;
			homeStats.y = 240;
			homeStats.scaleY = 0;
			
			visRing.x = 778;
			visRing.y = 20;
			
			visTwitter.x = 775;
			visTwitter.y = 188;
			
			visStats.x = 775;
			visStats.y = 240;			
			visStats.scaleY = 0;			
			
			if(!homeStats.contains(homeSent)){
				homeStats.addChild(homeSent);
			}
			if (!visStats.contains(visSent)) {
				visStats.addChild(visSent);
			}	
			
			teams.y = -241;
			
			tweenObject = { htSent:0, vtSent:0 };
				
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/netbase/teamcomparison?gamedate=" + initValue + "&abc="+String(new Date().valueOf()));
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
			//text in the middle that slides down
			teams.teamHome.text = json.Game[0].HomeTeam;
			teams.teamVisiting.text = json.Game[0].VisitingTeam;	
			
			var ht:Object;//Home
			var vt:Object;//Visiting
			if(json.Game[0].Teams[0].Stats[0].HomeOrVisiting == "Home"){
				ht = json.Game[0].Teams[0];
				vt = json.Game[0].Teams[1];
			}else {
				ht = json.Game[0].Teams[1];
				vt = json.Game[0].Teams[0];
			}
			
			homeTwitter.teamName.text = ht.TeamShortName;
			homeTwitter.twitterHandle.text = ht.TeamTwitterHandle;			
			
			homeStats.wins.theText.text = ht.Stats[0].Wins;
			homeStats.losses.theText.text = ht.Stats[0].Losses;
			homeStats.week.theText.text = json.Game[0].WeekNumber;
			
			homeStats.wins.scaleX = homeStats.wins.scaleY = 0;
			homeStats.losses.scaleX = homeStats.losses.scaleY = 0;
			homeStats.week.scaleX = homeStats.week.scaleY = 0;
			
			visTwitter.teamName.text = vt.TeamShortName;
			visTwitter.twitterHandle.text = vt.TeamTwitterHandle;
			
			visStats.wins.theText.text = vt.Stats[0].Wins;
			visStats.losses.theText.text = vt.Stats[0].Losses;
			visStats.week.theText.text = json.Game[0].WeekNumber;
			
			visStats.wins.scaleX = visStats.wins.scaleY = 0;
			visStats.losses.scaleX = visStats.losses.scaleY = 0;
			visStats.week.scaleX = visStats.week.scaleY = 0;
			
			addChild(homeRing);
			addChild(homeTwitter);
			addChild(homeStats);
			
			addChild(visRing);
			addChild(visTwitter);
			addChild(visStats);
			
			TweenMax.to(homeRing, 1, { x:41, ease:Back.easeOut } );
			TweenMax.to(homeTwitter, 1, { x:36, ease:Back.easeOut, delay:.25 } );
			TweenMax.to(homeStats, 1, { x:36, scaleY:1, ease:Back.easeOut, delay:.5 } );
			
			TweenMax.to(homeStats.wins, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.25 } );
			TweenMax.to(homeStats.losses, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.3 } );
			TweenMax.to(homeStats.week, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.35 } );
			
			TweenMax.to(visRing, 1, { x:514, ease:Back.easeOut, delay:.25 } );
			TweenMax.to(visTwitter, 1, { x:509, ease:Back.easeOut, delay:.5 } );
			TweenMax.to(visStats, 1, { x:509, scaleY:1, ease:Back.easeOut, delay:.75 } );
			
			TweenMax.to(visStats.wins, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.65 } );
			TweenMax.to(visStats.losses, .5, { scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.55 } );
			TweenMax.to(visStats.week, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.5 } );
			
			TweenMax.to(teams, 1, { y:91, ease:Back.easeOut, delay:1 } );
			
			//draw filled in white background circles first
			draw_arc(homeStats.graphics, 65, 128, 26, 0, 360, 6, 0xffffff);
			draw_arc(visStats.graphics, 65, 128, 26, 0, 360, 6, 0xffffff);
			
			tweenObject.htSent = 0;
			tweenObject.vtSent = 0;
			
			homeStats.theSentiment.theText.text = 0;
			visStats.theSentiment.theText.text = 0;
			
			if (ht.Stats[0].NetbaseSentiment < 0) {
				homeSent.scaleX = -1;
				homeSent.x = 130;
				tweenObject.htNegSent = true;
			}else {
				homeSent.scaleX = 1;
				homeSent.x = 0;
				tweenObject.htNegSent = false;
			}
				
			if (vt.Stats[0].NetbaseSentiment < 0) {
				visSent.scaleX = -1;		
				visSent.x = 130;
				tweenObject.vtNegSent = true;
			}else {
				visSent.scaleX = 1;
				visSent.x = 0;
				tweenObject.vtNegSent = false;
			}	
			
			TweenMax.to(tweenObject, 5, { htSent:Math.abs(ht.Stats[0].NetbaseSentiment * 3.6), delay:1, onUpdate:drawHSent } );
			TweenMax.to(tweenObject, 5, { vtSent:Math.abs(vt.Stats[0].NetbaseSentiment * 3.6), delay:1, onUpdate:drawVSent} );		
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
			removeChild(homeRing);
			removeChild(homeTwitter);
			removeChild(homeStats);
			
			removeChild(visRing);
			removeChild(visTwitter);
			removeChild(visStats);
			
			homeStats.graphics.clear();
			visStats.graphics.clear();
			
			homeSent.graphics.clear();
			visSent.graphics.clear();
		}
		
		
		private function dataLoaded(e:Event):void
		{
			json = JSON.parse(e.currentTarget.data);
			localCache = json;
			//show();//TESTING
			dispatchEvent(new Event(READY));
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			if (localCache) {
				json = localCache;
				dispatchEvent(new Event(READY));
			}else{
				dispatchEvent(new Event(ERROR));
			}
		}
		
		
		private function drawHSent():void
		{
			draw_arc(homeSent.graphics, 65, 128, 26, 0, tweenObject.htSent, 6, 0xedb01a);
			if(tweenObject.htNegSent){
				homeStats.theSentiment.theText.text = Math.round(-tweenObject.htSent / 3.6);
			}else {
				homeStats.theSentiment.theText.text = Math.round(tweenObject.htSent / 3.6);				
			}			
		}
		
		
		private function drawVSent():void
		{
			draw_arc(visSent.graphics, 65, 128, 26, 0, tweenObject.vtSent, 6, 0x058bd6);
			if (tweenObject.vtNegSent) {
				visStats.theSentiment.theText.text = Math.round(-tweenObject.vtSent / 3.6);
			}else{
				visStats.theSentiment.theText.text = Math.round(tweenObject.vtSent / 3.6);
			}
			
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