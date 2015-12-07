/**
 * Unique Hubble service - modify this class per project
 * Version 1 - 9/22/2015
 * 
 * 
 * Properties of the data object sent to HubbleService.send()
 * -------------------------------------------------------------
 * image - Base64 encoded String - main image being sent
 * image2 - Base64 String - if present this image will also be sent
 * printed - If printed == true then the PrintAPI will be called
 * 
 *  email, name, etc. Any properties used to construct the JSON response object
 */
package com.gmrmarketing.holiday2015
{	
	import com.gmrmarketing.utilities.queue.HubbleService;
	
	public class HubbleServiceExtender extends HubbleService
	{		
		
		public function HubbleServiceExtender()
		{
			super();
		}
		
		override public function send(data:Object):void
		{
			//create the response object sent to the interaction/interactionresponse - initial form post
			var resp:Object = { "MethodData": { "InteractionId":270, "FieldResponses":[ { "FieldId":2060, "Response":data.email } ]}};
			
			var d:Object = new Object();
			d.data = data;//store the full original data for HubbleService to use
			d.resp = resp;//the response object for the initial post
			d.photoFieldID = 2059;//the ID of the field used to submit the photo
			//add photoFieldID2 if an image2 property is present in the incoming data object
			
			super.send(d);			
		}
	}
	
}