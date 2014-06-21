package com.gmrmarketing.sap.levisstadium.tagcloud
{	
	
	public class WordCloud
	{
		private var words_two:Array;
		private var words_three:Array;
		private var words_four:Array;
		private var words_five:Array;
		private var words_six:Array;
		private var words_seven:Array;
		private var words_eight:Array;
		private var words_nine:Array;
		
		
		public function WordCloud()
		{
			words_two = new Array();
			words_three = new Array();
			words_four = new Array();
			words_five = new Array();
			words_six = new Array();
			words_seven = new Array();
			words_eight = new Array();
			words_nine = new Array();
			
			words_two.push("to", "an", "be", "no", "on", "at", "it", "ad", "do", "go", "id", "ma", "my", "ok", "so", "we");
			
			words_three.push("Man", "Arm", "Dog", "Bar", "Van", "Sex", "Car", "Ant", "War", "Rat", "Hot", "New", "Egg", "Gay", "Cow");
			words_three.push("Mom", "Bad", "Gun", "Big", "Lie", "cry", "sky", "ski", "sly", "son", "Sun", "cue", "Cab", "cut");
			words_three.push("had", "hey", "hip", "his", "Hoe", "hog", "wow", "web", "Wet", "wig");
			
			words_four.push("Road", "Legs", "Tank", "List", "Hurt", "City", "Town", "Open", "lure", "Arid", "info", "know", "site", "Eyes");
			words_four.push("Face", "Farm", "Lite", "dark", "Fear", "Vain", "Want", "wish", "tell", "Flee", "care", "Drug", "damp", "lick");
			words_four.push("Babe", "bald", "bomb", "Boom", "butt", "warm", "Weed", "wept", "wood", "game", "gene", "Girl", "gown", "Gram");
			
			words_five.push("Dirty", "Kinky", "Large", "Rules", "Paris", "Laser", "Bagel", "Apple", "North", "Korea", "China");
			words_five.push("Drugs", "Names", "Steak", "Syria", "cruel", "Anger", "moist", "slick", "clean", "puffy", "Pulse");			
			words_five.push("puked", "Pupil", "Eagle", "eject", "Ebony", "exact", "exile", "latex", "Laser", "leash", "shave");			
		
			words_six.push("Frozen", "Thawed", "Plague", "Zombie", "Gaping", "School", "Frugal", "Florid", "Friend");
			words_six.push("Russia", "French", "Device", "threat", "Subtle", "Listen", "Tongue", "Cancer");
			words_six.push("aboard", "acumen", "afloat", "agreed", "gagged", "ganged", "garden", "geisha", "gelato");
			words_six.push("ghouls", "nailed", "napkin", "napalm", "newton", "nipple", "normal", "nuzzle", "nympho");
			
			words_seven.push("Chicago", "Seattle", "Atlanta", "Scandal", "Punched", "Exposed", "Catalog");
			words_seven.push("Brother", "reality", "Lesbian", "Disdain", "Mundane", "Emulate", "Condemn");
			words_seven.push("Censure", "Vaccine", "Country", "Cabbage", "calorie", "calming", "Comfort", "Morning");			
			words_seven.push("facials", "factoid", "falcons", "fanfare", "fascism", "feeling", "fervent");			
			words_seven.push("festive", "fiddler", "fiestas", "fingers", "fireman", "fission", "flaccid", "forbode");			
			
			words_eight.push("New York", "Sidewalk", "Internet", "Military", "Monsanto", "Decadent", "anthesis", "ambushed");			
			words_eight.push("Magnetic", "majority", "malarial", "mandated", "Manifest", "marooned", "mechanic", "Meatloaf");
			words_eight.push("Megabits", "mentally", "Meteoric", "Vagabond", "valuable", "vaunting", "slippery");
			words_eight.push("bachelor", "backflow", "backlash", "backroom", "bailouts", "bankrupt", "barbwire");
			words_eight.push("barefoot", "bareback", "basilica", "damaging", "dampened", "darkness", "daughter", "debating");
			
			words_nine.push("Milwaukee", "Evergreen", "Hamburger", "Technology", "Marijuana", "Exemplary", "Reclusive", "fantastic", "Anonymous");
			words_nine.push("dangerous", "Right-Now", "dampeners", "Debutante", "decimeter", "decrement");			
		}
		
		
		public function getWord(w:int, h:int):String
		{
			var word:String ;
			var whRatio:Number = Math.min(w, h) / Math.max(w, h);
			
			if (whRatio > .85) {
				word = words_two[Math.floor(Math.random() * words_two.length)];
			}else if (whRatio > .75) {
				word = words_three[Math.floor(Math.random() * words_three.length)];
			}else if (whRatio > .65) {
				word = words_four[Math.floor(Math.random() * words_four.length)];
			}else if (whRatio > .5) {
				word = words_five[Math.floor(Math.random() * words_five.length)];
			}else if (whRatio > .4) {
				word = words_six[Math.floor(Math.random() * words_six.length)];
			}else if (whRatio > .3) {
				word = words_seven[Math.floor(Math.random() * words_seven.length)];
			}else if (whRatio > .2) {
				word = words_eight[Math.floor(Math.random() * words_eight.length)];
			}else {
				word = words_nine[Math.floor(Math.random() * words_nine.length)];
			}
			
			
			//if (Math.random() < .3) {
				//return word.toLowerCase();
			//}else{
				return word.toUpperCase();
			//}
		}
	}
	
}