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
			
			facts.push("A soccer field is called a 'pitch' because every regulation field is pitched – or sloped – 5 degrees upward from one end to the other");
			facts.push("The 2014 World Cup includes teams from 32 different countries, each made up of 23 players");
			facts.push("More than 3.2 billion people worldwide watched the 2010 World Cup");
			facts.push("There are 32 panels on a traditional soccer ball, one for each country in Europe");
			facts.push("SAP ambassador, Oliver Bierhoff ranks 9th all-time in goals scored for the German team with 37");
			facts.push("This year will feature matches taking place in 12 different cities, more than any other finals on record");
			facts.push("South America and European countries have won 9 titles each. No other continent has produced a world champion");
			facts.push("SAP ambassador, Oliver Bierhoff scored the first golden goal in the history of major international football");
			facts.push("The German team has an all-time international record of 515 wins and 191 losses");
			facts.push("In most countries, a soccer player's uniform is called a 'kit'");
			facts.push("The German Football Association was founded in Leipzig on Jan. 28, 1900");
			facts.push("Germany is one of the most successful national teams in international competitions, having won a total of three World Cups (1954, 1974, 1990) and three European Championships (1972, 1980, 1996)");
			facts.push("Germany is the only nation to have won both the men's and women's World Cups");
			facts.push("The German National Team has appeared in the World Cup a total of 17 times");
			facts.push("The German team averages 2.23 goals for and 1.19 goals against in all-time international play");
			facts.push("Germany is in Group G along with Portugal, Ghana and the United States");
			
			rand();
			
			currFact = 0;
		}
		
		public function rand():void
		{
			facts = Utility.randomizeArray(facts);
		}
		
		public function getFact():String
		{
			var f:String = facts[currFact];
			currFact++;
			if (currFact >= facts.length) {
				currFact = 0;
			}
			//return "<b>" + f + "</b>";
			return f;
		}
	}
	
}