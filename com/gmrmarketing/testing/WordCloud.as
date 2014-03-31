package com.gmrmarketing.testing
{	
	
	public class WordCloud
	{
		private var shortWords:Array;
		private var mediumWords:Array;
		private var longWords:Array;
		
		
		public function WordCloud()
		{
			shortWords = new Array();
			mediumWords = new Array();
			longWords = new Array();
			
			//3,4
			shortWords.push("Man", "Arm", "Dog", "Bar", "Van", "Sex", "Car", "Ants", "Lies", "War", "Rat", "Hot", "New", "Road");
			shortWords.push("Eggs", "Legs", "Gay", "Cow", "Tank", "List", "Hurt", "City", "Town", "Open", "Gun", "Face", "Farm", "Lite");
			shortWords.push("Mom", "Bad", "Guns", "big", "Ron", "road", "Big");
			
			//5,6,7
			mediumWords.push("Frozen", "Thawed", "Plague", "Zombie", "Gaping", "Vaccine", "Dirty", "Kinky", "Large", "Rules");
			mediumWords.push("Chicago", "Seattle", "School", "Paris", "Laser", "Bagel", "Atlanta", "Drugs", "Scandal", "Punched");
			mediumWords.push("Names", "Exposed", "Steak", "Friend", "Apple", "North", "Korea", "China", "Russia", "Syria", "French");
			mediumWords.push("Device", "threat", "Brother", "reality", "Lesbian");
			
			//8+
			longWords.push("Milwaukee", "Los Angeles", "Independence", "Helicopter", "Country", "Evergreen", "New Orleans");
			longWords.push("New York", "Headlights", "Sidewalk", "Hamburger", "Technology", "Internet", "Right-Now", "Listen");
			longWords.push("Monsanto", "Military", "Marijuana", "fantastic", "dangerous");			
		}
		
		
		public function getWord(w:int, h:int):String
		{
			var word:String ;
			var whRatio:Number = Math.min(w, h) / Math.max(w, h);
			
			if (whRatio > .7) {
				word = shortWords[Math.floor(Math.random() * shortWords.length)];
			}else if (whRatio > .4) {
				word = mediumWords[Math.floor(Math.random() * mediumWords.length)];
			}else {
				word = longWords[Math.floor(Math.random() * longWords.length)];
			}
			
			
			//if (Math.random() < .3) {
				//return word.toLowerCase();
			//}else{
				return word;
			//}
		}
	}
	
}