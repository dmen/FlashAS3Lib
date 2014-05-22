package com.gmrmarketing.sap.ticker
{
	import com.gmrmarketing.utilities.Utility;
	
	public class SoccerFacts
	{
		private var facts:Array;
		private var currFact:int;
		
		public function SoccerFacts()
		{
			facts = new Array();
			facts.push("There are 32 panels on a traditional soccer ball, one for each country in Europe.");
			facts.push("Soccer balls are slightly oval-shaped. But the checkered board pattern creates an illusion of a perfect sphere.");
			facts.push("The original World Cup was made of papier-mâché, but it had to be replaced after the heavy rains of the 1950 World Cup.");
			facts.push("Soccer was illegal in Mississippi until 1991.");
			facts.push("The national sport of Canada is soccer.");
			facts.push("Many 3rd World villages cannot afford a soccer ball, so they play soccer with balls made from rags or disposable diapers.");
			facts.push("A professional soccer player runs 48 kilometers, or 3.9 miles, in an average soccer game.");
			facts.push("Until 1908, soccer balls were made from the inflated stomach tissue of executed Irish prisoners.");
			facts.push("In most countries, a soccer player’s uniform is called a 'kit.' The cleats are called 'hooves.'");
			facts.push("English soccer star David Beckham is a distant cousin of Texas congressman Louie Gohmert.");
			facts.push("The first American professional soccer league, the USSA, played from 1919 to 1921 and paid its players 35-cents for every goal scored.");
			facts.push("A soccer field is called a “pitch” because every regulation field is pitched — or sloped — 5 degrees upwards from one end to the other. The teams switch sides after each half so each team has to play slightly uphill for half the match.");
			facts.push("Soccer developed in London’s famed Newgate Prison in the early 1800s. Prisoners who had their hands cut off for crimes of theft came up with a sport that used only the feet. The game spread from there.");
			
			facts = Utility.randomizeArray(facts);
			
			currFact = 0;
		}
		
		
		public function getFact():String
		{
			var f:String = facts[currFact];
			currFact++;
			if (currFact >= facts.length) {
				currFact = 0;
			}
			return f;
		}
	}
	
}