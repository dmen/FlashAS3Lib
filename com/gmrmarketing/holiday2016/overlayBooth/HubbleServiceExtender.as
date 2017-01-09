/**
 * Unique Hubble service - modify this class per project
 * Updated fields for Nov 2016
 * 
 * Version 1 - 9/22/2015
 * 
 * Properties of the data object sent to send():
 * 
 * image - Base64 encoded String - used by the HubbleService.submitPhoto() method
 * email, name, etc. Any properties used to construct the JSON in the send() method
 * printed - If printed == true then the PrintAPI will be called
 */
package com.gmrmarketing.holiday2016.overlayBooth
{
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.utilities.queue.HubbleService;
	
	public class HubbleServiceExtender extends HubbleService
	{		
		
		public function HubbleServiceExtender()
		{
			super();
		}
		
		
		/**
		 * Builds the custom response object to pass to NowPik
		 * 
		 * @param	data Object containing original and qNumTries properties
		 * data.original is the original object passed to Queue.add
		 * data.qNumTries is a property added by the queue to keep track of the total upload attempts
		 */
		override public function send(data:Object):void
		{			
			//Build the JSON response object from the incoming app data
			var resp:Object = { "MethodData": { "InteractionId":270, "FieldResponses":[ { "FieldId":2060, "Response":data.original.email }]}};
			
			data.photoFieldID = 2059;			
			data.printed = true;			
			data.responseObject = resp;			
			
			super.send(data);//calls send in HubbleService
		}
	}
	
}