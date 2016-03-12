/**
 * Unique Hubble service - modify this class per project
 * Version 1 - 9/22/2015
 * 
 * Properties of the data object sent to send()
 * image - Base64 encoded String - used by the HubbleService.submitPhoto() method
 * email, name, etc. Any properties used to construct the JSON in the send() method
 * printed - If printed == true then the PrintAPI will be called
 */
package com.gmrmarketing.esurance.sxsw_2016.photobooth
{
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.utilities.queue.HubbleService;
	
	public class HubbleServiceExtender extends HubbleService
	{		
		
		public function HubbleServiceExtender()
		{
			super();
		}
		
		
		//data is original data from app, with qNumTries property added by the Queue
		override public function send(data:Object):void
		{
			//Build the JSON response object from the incoming app data
			var resp:Object = { "MethodData": { "InteractionId":288, "FieldResponses":[ { "FieldId":2232, "Response":data.rfid }]}};
			
			
			data.photoFieldID = 2234;			
			
			data.printed = false;
			
			data.responseObject = resp;
			
			/*
			var d:Object = new Object();
			d.data = data;//store the full original data for HubbleService to use
			d.resp = resp;//the response object for the initial post to Hubble
			d.photoFieldID = 2112;//the ID of the field used to submit the photo
			
			super.send(d);	
			*/
			
			
			super.send(data);
		}
	}
	
}