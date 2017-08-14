/**
 * Unique Hubble service - modify this class per project
 * Version 1 - 9/22/2015
 * 
 * Properties of the data object sent to send()
 * image - Base64 encoded String - used by the HubbleService.submitPhoto() method
 * email, name, etc. Any properties used to construct the JSON in the send() method
 * printed - If printed == true then the PrintAPI will be called
 */
package com.gmrmarketing.katyperry.witness
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
			var resp:Object = { "MethodData": { "InteractionId":496, "FieldResponses":[]}};			
			
			if (data.original.customer == true) {
				resp.MethodData.FieldResponses.push( { "FieldId":4152, "ResponseID": 8491, "Response":"Yes" });
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":4152, "ResponseID": 8492, "Response":"No" });	
			}
			
			if (data.original.isEmail == true) {
				resp.MethodData.FieldResponses.push( { "FieldId":4157, "Response":data.original.num });			
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":4155, "Response":data.original.num });	
				resp.MethodData.FieldResponses.push( { "FieldId":4156, "Response":data.original.opt });	
			}			
			
			data.photoFieldID = 4154;			
			data.printed = false;			
			data.responseObject = resp;
			
			super.send(data);
		}
	}
	
}