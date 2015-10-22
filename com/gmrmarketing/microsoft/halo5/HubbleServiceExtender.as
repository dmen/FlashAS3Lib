
/**
 * Unique Hubble service - modify this class per project
 * Version 1 - 9/22/2015
 * 			  10/14/2015 - added parameters to HubbleService constructor to allow passing userName and password	
 */

package com.gmrmarketing.microsoft.halo5
{
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.utilities.queue.HubbleService;	
	
	public class HubbleServiceExtender extends HubbleService
	{
		
		public function HubbleServiceExtender()
		{
			super("halo", "halo");//so we get specific token for this interaction
		}
		
		
		/**
		 * 
		 * @param	data Custom data to build response object. 
		 * Add an image property to send photo
		 * add an image2 property to send second photo
		 */
		override public function send(data:Object):void
		{
			var resp:Object = {"MethodData": { "InteractionId":251, "FieldResponses":[ { "FieldId":1912, "Response":data.email },{ "FieldId":1915, "Response":data.optIn },{ "FieldId":1948, "Response":data.storeID } ] } };
			
			var d:Object = { };
			d.data = data;//store the full original data for HubbleService to use
			d.resp = resp;//the unique response object for the initial post to NowPik
			d.photoFieldID = 1913;//the ID of the field used to submit the photo - photo stored in image property of data object
			d.photoFieldID2 = 1949;//the ID of the field used to submit the second photo - photo stored in image2 property of data object
			
			super.send(d);			
		}
		
	}
	
}