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
		
		
		public function Main()
		{
			homeRing = new helmetRing();
			homeRing.x = -231;
			homeRing.y = 20;
			homeTwitter = new whiteTop();
			homeTwitter.x = -234;
			homeTwitter.y = 188;
			homeStats = new stats();
			homeStats.x = -234;
			homeStats.y = 240;
			
			visRing = new helmetRing();
			visRing.helmet.scaleX = -1;
			TweenMax.to(visRing.helmet, 0, { colorTransform: { tint:0x058bd6, tintAmount:1 }} );
			visRing.x = 778;
			visRing.y = 20;
			visTwitter = new whiteTop();
			visTwitter.x = 775;
			visTwitter.y = 188;
			visStats = new stats();
			visStats.x = 775;
			visStats.y = 240;
			
			teams.y = -241;
			
			homeSent = new Sprite();
			homeStats.addChild(homeSent);
			
			visSent = new Sprite();
			visStats.addChild(visSent);
			
			tweenObject = { htSent:0, vtSent:0 };
			
			setConfig("08/17/14");
		}
		
		
		
		/**
		 * ISChedulerMethods
		 * config is a date like 08/17/14
		 */
		public function setConfig(config:String):void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/netbase/teamcomparison?gamedate=" + config);
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
			
			visTwitter.teamName.text = vt.TeamShortName;
			visTwitter.twitterHandle.text = vt.TeamTwitterHandle;
			
			visStats.wins.theText.text = vt.Stats[0].Wins;
			visStats.losses.theText.text = vt.Stats[0].Losses;
			visStats.week.theText.text = json.Game[0].WeekNumber;
			
			addChild(homeRing);
			addChild(homeTwitter);
			addChild(homeStats);
			
			addChild(visRing);
			addChild(visTwitter);
			addChild(visStats);
			
			TweenMax.to(homeRing, 1, { x:41, ease:Back.easeOut } );
			TweenMax.to(homeTwitter, 1, { x:36, ease:Back.easeOut, delay:.25 } );
			TweenMax.to(homeStats, 1, { x:36, ease:Back.easeOut, delay:.5 } );
			
			TweenMax.to(visRing, 1, { x:514, ease:Back.easeOut } );
			TweenMax.to(visTwitter, 1, { x:509, ease:Back.easeOut, delay:.25 } );
			TweenMax.to(visStats, 1, { x:509, ease:Back.easeOut, delay:.5 } );
			
			TweenMax.to(teams, 1, { y:91, ease:Back.easeOut, delay:1 } );
			
			//draw filled in white background circles first
			draw_arc(homeStats.graphics, 65, 128, 26, 0, 360, 6, 0xffffff);
			draw_arc(visStats.graphics, 65, 128, 26, 0, 360, 6, 0xffffff);
			
			tweenObject.htSent = 0;
			tweenObject.vtSent = 0;
			
			homeStats.theSentiment.theText.text = 0;
			visStats.theSentiment.theText.text = 0;
			
			TweenMax.to(tweenObject, 5, { htSent:ht.Stats[0].NetbaseSentiment * 3.6, delay:1, onUpdate:drawHSent } );
			TweenMax.to(tweenObject, 5, { vtSent:vt.Stats[0].NetbaseSentiment * 3.6, delay:1, onUpdate:drawVSent} );
		
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
		
		
		private function dataLoaded(e:Event):void
		{
			json = JSON.parse(e.currentTarget.data);
			//show();//TESTING
			dispatchEvent(new Event(READY));
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			dispatchEvent(new Event(ERROR));
		}
		
		
		private function drawHSent():void
		{
			draw_arc(homeSent.graphics, 65, 128, 26, 0, tweenObject.htSent, 6, 0xedb01a);
			homeStats.theSentiment.theText.text = Math.round(tweenObject.htSent/3.6);
		}
		
		
		private function drawVSent():void
		{
			draw_arc(visSent.graphics, 65, 128, 26, 0, tweenObject.vtSent, 6, 0x058bd6);
			visStats.theSentiment.theText.text = Math.round(tweenObject.vtSent/3.6)
		}
		
		
		private function draw_arc(g:Graphics, center_x:int, center_y:int, radius:int, angle_from:int, angle_to:int, lineThickness:Number, lineColor:Number):void
		{
			g.clear();
			g.lineStyle(1, lineColor, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			
			var angle_diff:Number = (angle_to) - (angle_from);
			var steps:int = angle_diff * 2; // 2 is precision... use higher numbers for more.
			var angle:Number = angle_from;
			
			var halfT:Number = lineThickness / 2; // Half thickness used to determine inner and outer points
			var innerRad:Number = radius - halfT; // Inner radius
			var outerRad:Number = radius + halfT; // Outer radius
			
			var px_inner:Number = getX(angle, innerRad, center_x); //sub 90 here and below to rotate the arc to start at 12oclock
			var py_inner:Number = getY(angle, innerRad, center_y); 
			
			g.beginFill(lineColor, 1);
			g.moveTo(px_inner, py_inner);
			
			var i:int;
			
			// drawing the inner arc
			for (i = 1; i <= steps; i++) {
							angle = angle_from + angle_diff / steps * i;
							g.lineTo( getX(angle, innerRad, center_x), getY(angle, innerRad, center_y));
			}
			
			// drawind the outer arc
			for (i = steps; i >= 0; i--) {
							angle = angle_from + angle_diff / steps * i;
							g.lineTo( getX(angle, outerRad, center_x), getY(angle, outerRad, center_y));
			}
			
			g.lineTo(px_inner, py_inner);
			g.endFill();
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