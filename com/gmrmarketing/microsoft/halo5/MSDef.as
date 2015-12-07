/**
 * Microsoft - Get Interaction Definition from NowPik
 * Used for populating store list dropdown
 */
package com.gmrmarketing.microsoft.halo5
{
	import flash.events.*;
	import flash.display.*;
	import flash.net.*;	
	
	
	public class MSDef extends EventDispatcher
	{
		public static const COMPLETE:String = "ID_complete";
		public static const ERROR:String = "ID_error";
		private const BASE_URL:String = "https://api.nowpik.com/api/";
		
		private var myData:Array;
		
		
		public function MSDef()
		{
			myData = [];
		}
		
				
		public function getInteractionDefinition(token:String):void
		{
			var js:String = JSON.stringify({"AccessToken":token});
			var req:URLRequest = new URLRequest(BASE_URL + "interaction/interactiondefinition");
			
			req.method = URLRequestMethod.POST;
			req.data = js;
			req.requestHeaders.push(new URLRequestHeader("Content-type", "application/json"));
			req.requestHeaders.push(new URLRequestHeader("Accept", "application/json"));
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, gotID, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, IDError, false, 0, true);
			lo.load(req);
		}
		
		
		/**
		 * Returns an array of objects
		 * each object has id,label, and value keys
		 */
		public function get data():Array
		{
			return myData;
		}
		
		
		private function gotID(e:Event):void
		{	
			var j:Object = JSON.parse(e.currentTarget.data);
			
			//array of objects with id,label,value properties (label and value are equal)
			myData = j.ResponseObject[0].steps[0].fields[0].options as Array;
			
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function IDError(e:IOErrorEvent):void
		{
			dispatchEvent(new Event(ERROR));
		}		
		
		
		public function get defaultStoreList():Array
		{
			var a:Array = [];
			
			a.push({"id":4684, "label":"5th Avenue Mall", "value":"5th Avenue Mall"});
			a.push({"id":4685, "label":"Ala Moana Center", "value":"Ala Moana Center"});
			a.push({"id":4686, "label":"Alderwood Mall", "value":"Alderwood Mall"});
			a.push({"id":4687, "label":"American Dream Meadowlands", "value":"American Dream Meadowlands"});
			a.push({"id":4688, "label":"Aventura Mall", "value":"Aventura Mall"});
			a.push({"id":4689, "label":"Baybrook Mall", "value":"Baybrook Mall"});
			a.push({"id":4690, "label":"Beechwood Place", "value":"Beechwood Place"});
			a.push({"id":4691, "label":"Bellview Square Mall", "value":"Bellview Square Mall"});
			a.push({"id":4692, "label":"Boise Town Square", "value":"Boise Town Square"});
			a.push({"id":4693, "label":"Bridgewater Commons", "value":"Bridgewater Commons"});
			a.push({"id":4694, "label":"Burlington Mall", "value":"Burlington Mall"});
			a.push({"id":4695, "label":"Chandler Fashion Center", "value":"Chandler Fashion Center"});
			a.push({"id":4696, "label":"Cherry Creek Mall", "value":"Cherry Creek Mall"});
			a.push({"id":4697, "label":"Cherry Hill Mall", "value":"Cherry Hill Mall"});
			a.push({"id":4698, "label":"Chinook Centre", "value":"Chinook Centre"});
			a.push({"id":4699, "label":"Christiana Mall", "value":"Christiana Mall"});
			a.push({"id":4700, "label":"City Creek Center", "value":"City Creek Center"});
			a.push({"id":4701, "label":"Dadeland Mall", "value":"Dadeland Mall"});
			a.push({"id":4702, "label":"Danbury Fair Shopping Center", "value":"Danbury Fair Shopping Center"});
			a.push({"id":4703, "label":"Destiny USA", "value":"Destiny USA"});
			a.push({"id":4704, "label":"Easton Town Center", "value":"Easton Town Center"});
			a.push({"id":4705, "label":"Fashion Mall at Keystone Crossing", "value":"Fashion Mall at Keystone Crossing"});
			a.push({"id":4706, "label":"Fashion Place Mall", "value":"Fashion Place Mall"});
			a.push({"id":4707, "label":"Fashion Show", "value":"Fashion Show"});
			a.push({"id":4708, "label":"Fashion Valley Mall", "value":"Fashion Valley Mall"});
			a.push({"id":4709, "label":"Fayette Mall", "value":"Fayette Mall"});
			a.push({"id":4710, "label":"Flatiron Crossing", "value":"Flatiron Crossing"});
			a.push({"id":4711, "label":"Freehold Raceway Mall", "value":"Freehold Raceway Mall"});
			a.push({"id":4712, "label":"Garden State Plaza", "value":"Garden State Plaza"});
			a.push({"id":4713, "label":"Glendale Galleria", "value":"Glendale Galleria"});
			a.push({"id":4714, "label":"Houston Galleria", "value":"Houston Galleria"});
			a.push({"id":4715, "label":"International Plaza", "value":"International Plaza"});
			a.push({"id":4716, "label":"Jordan Creek", "value":"Jordan Creek"});
			a.push({"id":4717, "label":"Kenwood Towne Centre", "value":"Kenwood Towne Centre"});
			a.push({"id":4718, "label":"King of Prussia Mall", "value":"King of Prussia Mall"});
			a.push({"id":4719, "label":"La Plaza Mall", "value":"La Plaza Mall"});
			a.push({"id":4720, "label":"Lakeside Shopping Center", "value":"Lakeside Shopping Center"});
			a.push({"id":4721, "label":"Lenox Square", "value":"Lenox Square"});
			a.push({"id":4722, "label":"Los Cerritos Center", "value":"Los Cerritos Center"});
			a.push({"id":4723, "label":"Mall in Columbia", "value":"Mall in Columbia"});
			a.push({"id":4724, "label":"Mall of America", "value":"Mall of America"});
			a.push({"id":4725, "label":"Mall of Louisiana", "value":"Mall of Louisiana"});
			a.push({"id":4726, "label":"Mayfair Mall", "value":"Mayfair Mall"});
			a.push({"id":4727, "label":"Metropolis at Metrotown", "value":"Metropolis at Metrotown"});
			a.push({"id":4728, "label":"Natick Mall", "value":"Natick Mall"});
			a.push({"id":4729, "label":"North Point Mall", "value":"North Point Mall"});
			a.push({"id":4730, "label":"North Star", "value":"North Star"});
			a.push({"id":4731, "label":"Northpark Center", "value":"Northpark Center"});
			a.push({"id":4732, "label":"Oak Park Mall", "value":"Oak Park Mall"});
			a.push({"id":4733, "label":"Oakbrook Center", "value":"Oakbrook Center"});
			a.push({"id":4734, "label":"Oakridge Centre", "value":"Oakridge Centre"});
			a.push({"id":4735, "label":"Oxmoor Center", "value":"Oxmoor Center"});
			a.push({"id":4739, "label":"Pacific Centre", "value":"Pacific Centre"});
			a.push({"id":4740, "label":"Pacific Place", "value":"Pacific Place"});
			a.push({"id":4741, "label":"Park Meadows Mall", "value":"Park Meadows Mall"});
			a.push({"id":4743, "label":"Park Place", "value":"Park Place"});
			a.push({"id":4744, "label":"Penn Square Mall", "value":"Penn Square Mall"});
			a.push({"id":4745, "label":"Perimiter Mall", "value":"Perimiter Mall"});
			a.push({"id":4746, "label":"Pioneer Place", "value":"Pioneer Place"});
			a.push({"id":4747, "label":"Pitt Street Mall", "value":"Pitt Street Mall"});
			a.push({"id":4748, "label":"Plaza Las Americas", "value":"Plaza Las Americas"});
			a.push({"id":4749, "label":"Providence Place", "value":"Providence Place"});
			a.push({"id":4750, "label":"Roosevelt Field Mall", "value":"Roosevelt Field Mall"});
			a.push({"id":4751, "label":"Ross Park ", "value":"Ross Park "});
			a.push({"id":4752, "label":"Scottsdale Fashion Square", "value":"Scottsdale Fashion Square"});
			a.push({"id":4753, "label":"Shops at Mission Viejo", "value":"Shops at Mission Viejo"});
			a.push({"id":4754, "label":"Shops at Northbridge", "value":"Shops at Northbridge"});
			a.push({"id":4755, "label":"Somerset Collection", "value":"Somerset Collection"});
			a.push({"id":4756, "label":"South Coast Plaza", "value":"South Coast Plaza"});
			a.push({"id":4757, "label":"Southgate Center at Edmonton", "value":"Southgate Center at Edmonton"});
			a.push({"id":4758, "label":"SouthPark Mall", "value":"SouthPark Mall"});
			a.push({"id":4759, "label":"Square One Shopping Centre", "value":"Square One Shopping Centre"});
			a.push({"id":4760, "label":"St. Johns Town Center", "value":"St. Johns Town Center"});
			a.push({"id":4761, "label":"St. Louis Galleria", "value":"St. Louis Galleria"});
			a.push({"id":4762, "label":"Stanford Shopping Center", "value":"Stanford Shopping Center"});
			a.push({"id":4763, "label":"Staten Island Mall", "value":"Staten Island Mall"});
			a.push({"id":4764, "label":"Stonebriar Centre", "value":"Stonebriar Centre"});
			a.push({"id":4765, "label":"The Domain", "value":"The Domain"});
			a.push({"id":4766, "label":"The Fashion Centre at Pentagon City", "value":"The Fashion Centre at Pentagon City"});
			a.push({"id":4767, "label":"The Florida Mall", "value":"The Florida Mall"});
			a.push({"id":4768, "label":"The Maine Mall", "value":"The Maine Mall"});
			a.push({"id":4769, "label":"The Mall at Millenia", "value":"The Mall at Millenia"});
			a.push({"id":4903, "label":"The Mall at Rockingham Park", "value":"The Mall at Rockingham Park"});
			a.push({"id":4904, "label":"The Oaks", "value":"The Oaks"});
			a.push({"id":4905, "label":"The Parks at Arlington", "value":"The Parks at Arlington"});
			a.push({"id":4906, "label":"The Shops at La Cantera", "value":"The Shops at La Cantera"});
			a.push({"id":4907, "label":"The Shops at Prudential Center", "value":"The Shops at Prudential Center"});
			a.push({"id":4908, "label":"The Streets at Southpoint", "value":"The Streets at Southpoint"});
			a.push({"id":4909, "label":"The Village at Corte Madera", "value":"The Village at Corte Madera"});
			a.push({"id":4910, "label":"The Westchester Mall", "value":"The Westchester Mall"});
			a.push({"id":4911, "label":"The Woodlands Mall", "value":"The Woodlands Mall"});
			a.push({"id":4912, "label":"Time Warner Center", "value":"Time Warner Center"});
			a.push({"id":4913, "label":"Town Center at Boca Raton", "value":"Town Center at Boca Raton"});
			a.push({"id":4914, "label":"Towson Town Center", "value":"Towson Town Center"});
			a.push({"id":4915, "label":"Twelve Oaks Mall", "value":"Twelve Oaks Mall"});
			a.push({"id":4916, "label":"Tysons Corner Center", "value":"Tysons Corner Center"});
			a.push({"id":4917, "label":"University Town Center", "value":"University Town Center"});
			a.push({"id":4918, "label":"University Village", "value":"University Village"});
			a.push({"id":4919, "label":"Walden Galleria", "value":"Walden Galleria"});
			a.push({"id":4920, "label":"Walt Whitman Shops", "value":"Walt Whitman Shops"});
			a.push({"id":4921, "label":"Washington Square", "value":"Washington Square"});
			a.push({"id":4922, "label":"West Edmonton Mall", "value":"West Edmonton Mall"});
			a.push({"id":4923, "label":"West Town Mall", "value":"West Town Mall"});
			a.push({"id":4924, "label":"Westfarms Mall", "value":"Westfarms Mall"});
			a.push({"id":4925, "label":"Westfield Century City", "value":"Westfield Century City"});
			a.push({"id":4926, "label":"Westfield Galleria", "value":"Westfield Galleria"});
			a.push({"id":4927, "label":"Westfield Montgomery", "value":"Westfield Montgomery"});
			a.push({"id":4928, "label":"Westfield San Francisco Centre", "value":"Westfield San Francisco Centre"});
			a.push({"id":4929, "label":"Westfield Southcenter", "value":"Westfield Southcenter"});
			a.push({"id":4930, "label":"Westfield Topanga", "value":"Westfield Topanga"});
			a.push({"id":4931, "label":"Westfield Valley Fair", "value":"Westfield Valley Fair"});
			a.push({"id":4932, "label":"Westroads Mall", "value":"Westroads Mall"});
			a.push({"id":4933, "label":"Willowbrook", "value":"Willowbrook"});
			a.push({"id":4934, "label":"Woodfield Mall", "value":"Woodfield Mall"});
			a.push({"id":4935, "label":"Woodland Hills Mall", "value":"Woodland Hills Mall"});
			a.push({"id":4936, "label":"Yonge Street Mall", "value":"Yonge Street Mall"});
			a.push({"id":4937, "label":"Yorkdale Shopping Centre", "value":"Yorkdale Shopping Centre"});
			
			return a;
		}
		
	}
	
}