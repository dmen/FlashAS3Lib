package com.gmrmarketing.googlemaps
{
	import flash.events.EventDispatcher;
	import com.adobe.serialization.json.JSON;
	import com.gmrmarketing.googlemaps.LocalSearchItem;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.events.*;

	public class LocalSearch extends EventDispatcher
	{
		public static const SEARCH_COMPLETE:String = "localDataSearchCompleted";

		
		private var searchURL:String = "http://ajax.googleapis.com/ajax/services/search/local";
		private var searchAPIKey:String = "ABQIAAAAEmsJFo7jmBpA2NUE9158PxQ3wgJei0XVWFg16ktT0ft_DTvNSxQrRbAagvWpHi7foBaKa0XtE4E5Eg";
		
		//array of LocalSearchItem objects
		private var localItems:Array;
		
		
		
		public function LocalSearch() { }		
		
	
		/**
		 * 
		 * @param	searchString What to search for School, McDonalds, etc.
		 * @param	latlng  - center of search in comma delimited lat,long - defaults to New Berlin, WI
		 * @param	pagingValue Search returns a max of 8 - if you want records 9 - 18, use a start value of 9
		 */
		public function search(searchString:String, latlng:String = "42.976,-88.108", pagingValue:int = 0):void
		{
			var query:String = "?v=1.0";  

			//search term
			query += "&q=" + searchString;
			
			query += "&sll=" + latlng;

			//use startValue for paging the search results
			query += "&start=" + pagingValue;

			//result size 1-8
			query += "&rsz=8";

			//search listing type
			query += "&mrt=localonly";

			//api key
			query += "&key=" + searchAPIKey;

			var req:URLRequest = new URLRequest( + query);
			req.contentType = "text/xml; charset=utf-8";
			
			req.method = URLRequestMethod.POST;

			var l:URLLoader = new URLLoader();
			l.load(req);
			l.addEventListener(Event.COMPLETE, dataRetrieved, false, 0, true);
		}

		
		/**
		 * Deserializes the JSON response from Google and places the data
		 * into an array of LocalSearchItem objects
		 * @param	e
		 */
		private function dataRetrieved(e:Event)
		{
			var json:Object = JSON.decode("" + e.target.data);
			if(json.responseData != null) {
				var res:Array = json.responseData.results as Array
				localItems = new Array()
				for each(var data:Object in res) {
					
					var item:LocalSearchItem = new LocalSearchItem()
					
					item.title = data.title;
					item.titleNoFormatting = data.titleNoFormatting;
					item.url = data.url;
					item.latitude = data.lat;
					item.longitude = data.lng;
					item.streetAddress = data.streetAddress;
					item.city = data.city;
					item.region = data.region;
					item.country = data.country;
					item.phoneNumbers = data.phoneNumbers;
					item.ddUrl = data.ddUrl;
					item.ddUrlToHere = data.ddUrlToHere;
					item.ddUrlFromHere = data.ddUrlFromHere;
					item.staticMapUrl = data.staticMapUrl;
					item.listingType = data.listingType;
					item.content = data.content;
					
					localItems.push(item);
				}
				
				dispatchEvent(new Event(SEARCH_COMPLETE));
			}
		}
		
		
		/**
		 * Returns an array of LocalSearchItem objects
		 * @return
		 */
		public function getSearchItems():Array
		{
			return localItems;
		}
		
	}
	
}