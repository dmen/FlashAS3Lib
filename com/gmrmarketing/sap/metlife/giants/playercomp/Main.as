package com.gmrmarketing.sap.metlife.giants.playercomp
{
	import com.gmrmarketing.sap.metlife.ISchedulerMethods;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	public class Main extends MovieClip implements ISchedulerMethods
	{
		public static const FINISHED:String = "finished";//dispatched when the task is complete. Player will call cleanup() now
		
		private var localCache:Object;
		private var tempCache:Object;//until images are loaded
		private var myDate:String;
		private var picIndex:int; //used when loading player pics
		
		public function Main()
		{
			//init("10/12/14");//TESTING
		}
		
		
		/**
		 * ISchedulerMethods
		 * @param	initValue
		 */
		public function init(initValue:String = ""):void
		{
			myDate = initValue;			
			refreshData();
		}
		
		
		/**
		 * ISchedulerMethods
		 */ 
		public function getFlareList():Array
		{
			var fl:Array = new Array();
			
			//title
			fl.push([273, 26, 727, "line", 3]);//x, y, to x, type, delay
			fl.push([283, 69, 714, "point", 3.3]);//x, y, to x, type, delay			
			
			//quote
			fl.push([154, 510, 855, "line", 7]);//x, y, to x, type, delay
			fl.push([163, 546, 846, "point", 7]);//x, y, to x, type, delay
			
			//player pic1
			fl.push([194, 93, 451, "line", 5.5]);//x, y, to x, type, delay
			fl.push([194, 304, 451, "point", 5.7]);//x, y, to x, type, delay
			
			//player pic2
			fl.push([564, 93, 822, "line", 5.5]);//x, y, to x, type, delay
			fl.push([564, 304, 822, "point", 5.7]);//x, y, to x, type, delay
			
			//player pic3
			fl.push([46, 93, 303, "line", 8.5]);//x, y, to x, type, delay
			fl.push([46, 304, 303, "point", 8.7]);//x, y, to x, type, delay
			//player pic4
			fl.push([375, 93, 634, "line", 9.5]);//x, y, to x, type, delay
			fl.push([375, 304, 634, "point", 9.7]);//x, y, to x, type, delay
			//player pic5
			fl.push([706, 93, 964, "line", 10.5]);//x, y, to x, type, delay
			fl.push([706, 304, 964, "point", 10.7]);//x, y, to x, type, delay
			return fl;
		}
		
		
		/**
		 * ISchedulerMethods
		 * Returns true if localCache has data in it
		 * ie if the service has completed successfully at least once
		 * @return
		 */
		public function isReady():Boolean
		{
			return localCache != null;
		}
		
		
		private function refreshData():void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sapmetlifeapi.thesocialtab.net/api/GameDay/GetPlayerHighlights?gamedate=" + myDate + "&abc=" + String(new Date().valueOf()));
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		
		private function dataLoaded(e:Event):void
		{
			tempCache = JSON.parse(e.currentTarget.data);
			
			var players:Array = tempCache.Game[0].Players;//array of five objects			 
			 
			//metricBG's start at 104 for #1 and 54 for #2,#3
			 
			//load stats into holders
			stats.sh1.theName.text = players[0].PlayerName + "/" + players[0].PlayerPositionShortName + " #" + players[0].Number;
			stats.sh1.stat1Title.text = players[0].Stats[0].PlayerPositionStatName;
			stats.sh1.stat1.text = players[0].Stats[0].PlayerPositionStatValue;
			stats.sh1.stat2Title.text = players[0].Stats[1].PlayerPositionStatName;
			stats.sh1.stat2.text = players[0].Stats[1].PlayerPositionStatValue;
			stats.sh1.stat3Title.text = players[0].Stats[2].PlayerPositionStatName;
			stats.sh1.stat3.text = players[0].Stats[2].PlayerPositionStatValue;
			 
			//////////
			 
			stats.sh2.theName.text = players[1].PlayerName + "/" + players[1].PlayerPositionShortName + " #" + players[1].Number;
			stats.sh2.stat1Title.text = players[1].Stats[0].PlayerPositionStatName;
			stats.sh2.stat1.text = players[1].Stats[0].PlayerPositionStatValue;
			stats.sh2.stat2Title.text = players[1].Stats[1].PlayerPositionStatName;
			stats.sh2.stat2.text = players[1].Stats[1].PlayerPositionStatValue;
			stats.sh2.stat3Title.text = players[1].Stats[2].PlayerPositionStatName;
			stats.sh2.stat3.text = players[1].Stats[2].PlayerPositionStatValue;
			 
			///////////
			 
			stats.sh3.theName.text = players[2].PlayerName + "/" + players[2].PlayerPositionShortName + " #" + players[2].Number;
			stats.sh3.stat1Title.text = players[2].Stats[0].PlayerPositionStatName;
			stats.sh3.stat1.text = players[2].Stats[0].PlayerPositionStatValue;
			stats.sh3.stat2Title.text = players[2].Stats[1].PlayerPositionStatName;
			stats.sh3.stat2.text = players[2].Stats[1].PlayerPositionStatValue;
			stats.sh3.stat3Title.text = players[2].Stats[2].PlayerPositionStatName;
			stats.sh3.stat3.text = players[2].Stats[2].PlayerPositionStatValue;
			 
			/////////////
			 
			stats.sh4.theName.text = players[3].PlayerName + "/" + players[3].PlayerPositionShortName + " #" + players[3].Number;
			stats.sh4.stat1Title.text = players[3].Stats[0].PlayerPositionStatName;
			stats.sh4.stat1.text = players[3].Stats[0].PlayerPositionStatValue;
			stats.sh4.stat2Title.text = players[3].Stats[1].PlayerPositionStatName;
			stats.sh4.stat2.text = players[3].Stats[1].PlayerPositionStatValue;
			stats.sh4.stat3Title.text = players[3].Stats[2].PlayerPositionStatName;
			stats.sh4.stat3.text = players[3].Stats[2].PlayerPositionStatValue;			
			 
			///////////////
			 
			stats.sh5.theName.text = players[4].PlayerName + "/" + players[4].PlayerPositionShortName + " #" + players[4].Number;
			stats.sh5.stat1Title.text = players[4].Stats[0].PlayerPositionStatName;
			stats.sh5.stat1.text = players[4].Stats[0].PlayerPositionStatValue;					
			stats.sh5.stat2Title.text = players[4].Stats[1].PlayerPositionStatName;
			stats.sh5.stat2.text = players[4].Stats[1].PlayerPositionStatValue;			
			stats.sh5.stat3Title.text = players[4].Stats[2].PlayerPositionStatName;
			stats.sh5.stat3.text = players[4].Stats[2].PlayerPositionStatValue;			
			
			setStatBGs();
			
			picIndex = 0;
			loadNextPlayerPic();
		}
		
		
		/**
		 * Sets the gray bars behind the stats to reveal just the text in the stat
		 */
		private function setStatBGs():void
		{
			stats.sh1.stat1BG.x -= stats.sh1.stat1BG.width - stats.sh1.stat1.textWidth - 40;
			stats.sh1.stat2BG.x -= stats.sh1.stat2BG.width - stats.sh1.stat2.textWidth - 40;
			stats.sh1.stat3BG.x -= stats.sh1.stat3BG.width - stats.sh1.stat3.textWidth - 40;
			
			stats.sh2.stat1BG.x -= stats.sh2.stat1BG.width - stats.sh2.stat1.textWidth - 40;
			stats.sh2.stat2BG.x -= stats.sh2.stat2BG.width - stats.sh2.stat2.textWidth - 40;
			stats.sh2.stat3BG.x -= stats.sh2.stat3BG.width - stats.sh2.stat3.textWidth - 40;
			
			stats.sh3.stat1BG.x -= stats.sh3.stat1BG.width - stats.sh3.stat1.textWidth - 40;
			stats.sh3.stat2BG.x -= stats.sh3.stat2BG.width - stats.sh3.stat2.textWidth - 40;
			stats.sh3.stat3BG.x -= stats.sh3.stat3BG.width - stats.sh3.stat3.textWidth - 40;
			
			stats.sh4.stat1BG.x -= stats.sh4.stat1BG.width - stats.sh4.stat1.textWidth - 40;
			stats.sh4.stat2BG.x -= stats.sh4.stat2BG.width - stats.sh4.stat2.textWidth - 40;
			stats.sh4.stat3BG.x -= stats.sh4.stat3BG.width - stats.sh4.stat3.textWidth - 40;
			
			stats.sh5.stat1BG.x -= stats.sh5.stat1BG.width - stats.sh5.stat1.textWidth - 40;
			stats.sh5.stat2BG.x -= stats.sh5.stat2BG.width - stats.sh5.stat2.textWidth - 40;
			stats.sh5.stat3BG.x -= stats.sh5.stat3BG.width - stats.sh5.stat3.textWidth - 40;
		}
		
		
		private function loadNextPlayerPic():void
		{	
			var url:String = tempCache.Game[0].Players[picIndex].PhotoURL;
			
			var l:Loader = new Loader();
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, imLoaded, false, 0, true);			
			l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imError, false, 0, true);			
			l.load(new URLRequest(url));
		}
		
		
		private function imLoaded(e:Event):void
		{
			var im:Bitmap = Bitmap(e.target.content);
			im.smoothing = true;
			im.width = 253;
			im.height = 207;
			
			switch(picIndex) {
				case 0:
					while (stats.sh1.picHolder.numChildren) {
						stats.sh1.picHolder.removeChildAt(0);
					}
					stats.sh1.picHolder.addChild(im);
					break;
				case 1:
					while (stats.sh2.picHolder.numChildren) {
						stats.sh2.picHolder.removeChildAt(0);
					}
					stats.sh2.picHolder.addChild(im);
					break;
				case 2:
					while (stats.sh3.picHolder.numChildren) {
						stats.sh3.picHolder.removeChildAt(0);
					}
					stats.sh3.picHolder.addChild(im);
					break;
				case 3:
					while (stats.sh4.picHolder.numChildren) {
						stats.sh4.picHolder.removeChildAt(0);
					}
					stats.sh4.picHolder.addChild(im);
					break;
				case 4:
					while (stats.sh5.picHolder.numChildren) {
						stats.sh5.picHolder.removeChildAt(0);
					}
					stats.sh5.picHolder.addChild(im);
					break;
			}
			
			picIndex++;
			if (picIndex <= 4) {
				loadNextPlayerPic();
			}else {
				localCache = tempCache;
				//show();//TESTING
			}			
		}
		
		
		private function imError(e:IOErrorEvent):void
		{
			picIndex++;
			loadNextPlayerPic();//try to get the rest of the images
		}
		
		
		private function dataError(e:IOErrorEvent):void	
		{
			setStatBGs();
		}
		
		
		/**
		 * ISchedulerMethods
		 * Called when the task is placed onscreen
		 */
		public function show():void
		{
			theVideo.play();
			
			var players:Array = localCache.Game[0].Players;//array of five objects		
			
			//animate bar behind pts/game metric
			TweenMax.to(stats.sh1.stat1BG, 1, { x:String((104 - stats.sh1.stat1BG.x) * (players[0].Stats[0].PlayerPositionStatValue / 20)), delay:1 } );
			TweenMax.to(stats.sh2.stat1BG, 1, { x:String((104 - stats.sh2.stat1BG.x) * (players[1].Stats[0].PlayerPositionStatValue / 20)), delay:1 } );
			
			//animate bar behind yds metric
			TweenMax.to(stats.sh1.stat2BG, 1, { x:String((54 - stats.sh1.stat2BG.x) * (players[0].Stats[1].PlayerPositionStatValue / 2500)), delay:1 } );
			TweenMax.to(stats.sh2.stat2BG, 1, { x:String((54 - stats.sh2.stat2BG.x) * (players[1].Stats[1].PlayerPositionStatValue / 2500)), delay:1 } );
			
			//animate bar behind tds metric
			TweenMax.to(stats.sh1.stat3BG, 1, { x:String((54 - stats.sh1.stat3BG.x) * (players[0].Stats[2].PlayerPositionStatValue / 50)), delay:1 } );
			TweenMax.to(stats.sh2.stat3BG, 1, { x:String((54 - stats.sh2.stat3BG.x) * (players[1].Stats[2].PlayerPositionStatValue / 50)), delay:1 } );
			
			TweenMax.to(stats, .5, { x: -797, delay:8, onComplete:animateBars } );			
		}
		
		
		/**
		 * Called by TweenMax
		 * animates the metric BG bars on the second screen of players
		 */
		private function animateBars():void
		{
			var players:Array = localCache.Game[0].Players;//array of five objects		
			
			//animate bar behind pts/game metric
			TweenMax.to(stats.sh3.stat1BG, 1, { x:String((104 - stats.sh3.stat1BG.x) * (players[2].Stats[0].PlayerPositionStatValue / 20)), delay:1 } );
			TweenMax.to(stats.sh4.stat1BG, 1, { x:String((104 - stats.sh4.stat1BG.x) * (players[3].Stats[0].PlayerPositionStatValue / 20)), delay:1 } );
			TweenMax.to(stats.sh5.stat1BG, 1, { x:String((104 - stats.sh5.stat1BG.x) * (players[4].Stats[0].PlayerPositionStatValue / 20)), delay:1 } );
			
			//animate bar behind yds metric
			TweenMax.to(stats.sh3.stat2BG, 1, { x:String((54 - stats.sh3.stat2BG.x) * (players[2].Stats[1].PlayerPositionStatValue / 2500)), delay:1 } );
			TweenMax.to(stats.sh4.stat2BG, 1, { x:String((54 - stats.sh4.stat2BG.x) * (players[3].Stats[1].PlayerPositionStatValue / 2500)), delay:1 } );
			TweenMax.to(stats.sh5.stat2BG, 1, { x:String((54 - stats.sh5.stat2BG.x) * (players[4].Stats[1].PlayerPositionStatValue / 2500)), delay:1 } );
			
			//animate bar behind tds metric
			TweenMax.to(stats.sh3.stat3BG, 1, { x:String((54 - stats.sh3.stat3BG.x) * (players[2].Stats[2].PlayerPositionStatValue / 50)), delay:1 } );
			TweenMax.to(stats.sh4.stat3BG, 1, { x:String((54 - stats.sh4.stat3BG.x) * (players[3].Stats[2].PlayerPositionStatValue / 50)), delay:1 } );
			TweenMax.to(stats.sh5.stat3BG, 1, { x:String((54 - stats.sh5.stat3BG.x) * (players[4].Stats[2].PlayerPositionStatValue / 50)), delay:1 } );
			
			TweenMax.delayedCall(10, complete);
		}
		
		
		private function complete():void
		{
			dispatchEvent(new Event(FINISHED));
		}
		
		
		/**
		 * ISchedulerMethods
		 * 
		 */
		public function cleanup():void
		{
			//reset statBG positions			
			stats.sh1.stat1BG.x = 104;
			stats.sh1.stat2BG.x = 54;
			stats.sh1.stat3BG.x = 54;
			
			stats.sh2.stat1BG.x = 104;
			stats.sh2.stat2BG.x = 54;
			stats.sh2.stat3BG.x = 54;
			
			stats.sh3.stat1BG.x = 104;
			stats.sh3.stat2BG.x = 54;
			stats.sh3.stat3BG.x = 54;
			
			stats.sh4.stat1BG.x = 104;
			stats.sh4.stat2BG.x = 54;
			stats.sh4.stat3BG.x = 54;
			
			stats.sh5.stat1BG.x = 104;
			stats.sh5.stat2BG.x = 54;
			stats.sh5.stat3BG.x = 54;			
			
			stats.x = 191; //reset to the first screen
			refreshData();
			theVideo.seek(0);
			theVideo.stop();
		}
		
		
	}
}