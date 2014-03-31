package com.gmrmarketing.jimbeam.devilscut
{
		
	public class TextOptions 
	{
		private var strings:Array;
		private var bullets:Array;
		private var index:int;
		
		
		public function TextOptions()
		{
			bullets = new Array("I.", "II.", "III.");
			
			strings = new Array();
			
			strings.push("Say 'I love you' to complete strangers");
			strings.push("Call your boss, just to make a few things clear");
			strings.push("Get a tattoo");
			strings.push("Organize a spontaneous road trip to Mexico");
			strings.push("Lose your belt somehow");
			strings.push("Totally kill it at karaoke - without a karaoke machine");
			strings.push("Propose marriage to a coworker");
			strings.push("Perform a sexy dance on a balcony");
			strings.push("Hit on the bartender");
			strings.push("Convince a dancer to tip you a dollar");
			strings.push("Leave the party early...for all the right reasons");
			strings.push("Unleash a YouTube video explaining how you're winning");			
			strings.push("Convince everyone in the bar to offer you a drink");
			strings.push("Call a phone number on a bathroom wall");
			strings.push("Charter a jet to Vegas or New Orleans");
			strings.push("Make your way backstage - sans passes");
			strings.push("Create your own beach");
			strings.push("Perform a drum solo on whatever's in front of you");
			
			randomize();
		}
		
		
		public function randomize():void
		{
			var newArray:Array = new Array();
			
			while(strings.length > 0){
				newArray.push(strings.splice(Math.floor(Math.random() * strings.length), 1)[0]);
			}
			
			strings = newArray;
			index = 0;
		}
		
		
		public function getString():String
		{
			var theString:String = strings[index];
			index++;
			if (index >= strings.length) {
				index = 0;
			}
			return theString;
		}
		
	}
	
}