package com.gmrmarketing.wrigley.gumergency 
{
	import flash.display.*;	
	import flash.events.*;	
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.Utility;
	import flash.utils.Timer;
	
	
	public class Results extends EventDispatcher
	{
		public static const SHOWING:String = "resultsShowing";
		public static const COMPLETE:String = "resultsComplete";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var odors:Array;
		private var timer:Timer;
		
		
		public function Results()
		{
			clip = new mcResults();
			clip.y = 388;
			
			odors = new Array("Coffee", "Chicken", "Salted Nuts", "Chocolate", "Salmon", "Shark", "Popcorn", "Canadian Maple", "Bacon", "Sausage");
			odors.push("Hot Dogs", "Bratwurst", "Kentucky Bluegrass", "Sulfur", "Quarter Pounder with Cheese", "Orange Juice");
			odors.push("Fried Egg", "Bologna", "Italian Cooking", "Pan Fried Noodles", "Kung Pao Chicken", "Mashed Potatoes", "French Fries");
			odors.push("Drama", "Asphalt", "Blue Cheese", "Hot Wings", "Mushroom Gravy", "Mustard", "Dill Pickle", "Chicken Fried Steak");
			odors.push("Waffles", "Tossed Salad", "Pancakes", "Macaroni and Cheese", "Raccoon", "Squirrel", "Adhesive Bandage", "Finger Nails");
			odors.push("Beef Stew", "Veggie Burger", "Donuts", "Sasquatch", "Garlic", "American Cheese", "Celery", "Ranch Dressing");
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(level:int, percent:Number):void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.alpha = 0;
			
			clip.theLevel.text = "BREATHCON " + String(level);
			
			var res:String = "";
			var numOdors:int;
			
			switch(level) {
				case 1:
					res = "Kissable, with a hint of bad breath. Your diet of nothing but stinky foods has taken a toll in toxicity. Next time, make it a close encounter of the fresh kind.";
					/*
					if (percent < .5) {
						res = "You've got a mild case of Gumergency.";
					}else {
						res = "Your Gumergency is mild, but on the verge of blossoming into something larger and more unpredictable.";
					}
					numOdors = 2;
					*/
					break;
				case 2:
					res = "Your breath is on a slippery slope my friend. Funky foods and ineffective freshening agents will be your undoing. Extinguish the odor immediately and face the day.";
					/*
					if (percent < .5) {
						res = "You've got a solid case of Gumergency.";
						numOdors = 3;
					}else {
						res = "You're Gumergency needs immediate attention.";
						numOdors = 4;
					}	
					*/
					break;
				case 3:
					res = "Your words are breathtaking, and that is NOT a compliment.\nThis serious problem calls for a serious solution. Keep Excel close-by and keep your friends and family from running far away.";
					/*
					res ="You've got full-blown Gumergency!"
					numOdors = 5;
					*/
					break;
			}
			/*
			//ODORS
			res += "\n\n";
			res += "Odors Detected:\n";
			odors = Utility.randomizeArray(odors);
			for (var i:int = 0; i < numOdors-1; i++) {
				res += odors[i] + ", ";
			}
			res = res.substr(0, res.length - 2);
			res += " & " + odors[i];
			*/
			clip.theText.text = res;			
			
			TweenMax.to(clip, 2, { alpha:.9, onComplete:wait } );
		}
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function wait():void
		{
			dispatchEvent(new Event(SHOWING));
			
			container.stage.addEventListener(KeyboardEvent.KEY_DOWN, checkKey, false, 0, true);
			
			timer = new Timer(60000, 1);
			timer.addEventListener(TimerEvent.TIMER, timedOut, false, 0, true);
			timer.start();
		}
		
		
		private function checkKey(e:KeyboardEvent):void
		{
			if (Keys.KEYS.indexOf(e.charCode) != -1) {
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, timedOut);
				container.stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkKey);
				dispatchEvent(new Event(COMPLETE));
			}			
		}
		
		private function timedOut(e:TimerEvent):void
		{
			container.stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkKey);
			timer.removeEventListener(TimerEvent.TIMER, timedOut);
			dispatchEvent(new Event(COMPLETE));
		}
		
		
	}
	
}