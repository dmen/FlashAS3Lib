package com.gmrmarketing.sap.levisstadium.didyouknow
{	
	public class Facts 
	{
		private var facts:Array;
		private var index:int;
		
		public function Facts()
		{
			index = -1;
			facts = new Array();
			facts.push({"Subhead": "Levi's® Stadium is the first in the U.S. that is home to a professional football team to receive LEED Gold certification as new construction.","Body": "The stadium features a 27,000 square foot \"Green Roof\" on the top of the stadium’s suite tower."
		});
			facts.push( { "Subhead": "Levi's® Stadium by the Numbers", "Body": "More than 18,000 tons of steel were used to support the stadium, adding to the 75,000 tons in the overall build." } );
			facts.push( { "Subhead": "Levi's® Stadium by the Numbers", "Body": "15,000 man-hours were spent on\\nseat installation." } );
			facts.push( { "Subhead": "Levi's® Stadium by the Numbers", "Body": "There are 1,186 solar panels around\\nthe stadium covering\\n20,000 square feet." } );
			facts.push( { "Subhead": "Levi's® Stadium by the Numbers", "Body": "The stadium features the NFL's first collapsible field goal posts, which take about 30 minutes to remove."	} );
			facts.push( { "Subhead": "Levi's® Stadium by the Numbers", "Body": "The 16-bit video boards are 200 feet wide x 48 feet tall and use more than 281 trillion colors." } );
			facts.push( { "Subhead": "Levi's® Stadium by the Numbers", "Body": "The stadium features 800 concession points of sale for fans to purchase food, beverage and team merchandise." } );
			facts.push( { "Subhead": "The 49ers have retired 12 jerseys in the history of the organization.", "Body": "Nine of these players have been\\ninducted into the Pro Football\\nHall of Fame." } );
			facts.push( { "Subhead": "The 49ers are one of the most\\nwinning franchises in the\\nhistory of the NFL.", "Body": "With five Super Bowl Championships, the 49ers are tied for second most in the history of the NFL." } );
			facts.push( { "Subhead": "Levi's® Stadium currently seats 68,500 fans.", "Body": "But has the capacity to accommodate up to 75,000 for other premiere events like Super Bowl 50 occurring February 2016." } );
			facts.push( { "Subhead": "Levi’s® Stadium is the first stadium in North America designed to be net neutral to the grid.",	"Body": "That means every 49ers home game\\nwill be partially powered\\nby the sun!" } );
			facts.push( { "Subhead": "Levi's® Stadium features 40GB/s of available Internet bandwidth.", "Body": "That's more than 40X the capacity of any known U.S. Stadium." } );	
		}
		
		
		public function getFact():Object
		{
			index++;
			if (index >= facts.length) {
				index = 0;
			}
			return facts[index];
			
		}
	}
	
}