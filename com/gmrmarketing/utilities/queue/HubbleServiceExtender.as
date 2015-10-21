/**
 * Unique Hubble service - modify this class per project
 * Version 1 - 9/22/2015
 * 
 * Properties of the data object sent to send()
 * gif - Base64 encoded String - used by the HubbleService.submitPhoto() method
 * email, name, etc. Any properties used to construct the JSON in the send() method
 * printed - If printed == true then the PrintAPI will be called
 */
package com.gmrmarketing.utilities.queue
{
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.utilities.queue.HubbleService;
	
	public class HubbleServiceExtender extends HubbleService
	{		
		
		public function HubbleServiceExtender()
		{
			super();
		}
		
		override public function send(data:Object):void
		{
			var resp:Object = { "AccessToken":token, "MethodData": { "InteractionId":230, "DeviceId":autoInc.guid, "DeviceResponseId":autoInc.nextNum, "ResponseDate":Utility.hubbleTimeStamp, "FieldResponses":[ { "FieldId":1705, "Response":data.email } ], "Latitude":"0", "Longitude":"0" }};
			
			var d:Object = new Object();
			d.data = data;//store the full original data for HubbleService to use
			d.resp = resp;//the response object for the initial post to Hubble
			d.photoFieldID = 1720;//the ID of the field used to submit the photo
			
			super.send(d);			
		}
	}
	
}