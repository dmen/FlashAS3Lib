/**
 * Unique Hubble service - modify this class per project
 * Version 1 - 9/22/2015
 * 
 * Properties of the data object sent to send()
 * image - Base64 encoded String - used by the HubbleService.submitPhoto() method
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
		
		
		//data is original data from app, with qNumTries property added by the Queue
		override public function send(data:Object):void
		{
			//Build the JSON response object from the incoming app data
			var resp:Object = { "MethodData": { "InteractionId":276, "FieldResponses":[ { "FieldId":2100, "Response":data.fname }, { "FieldId":2101, "Response":data.lname }, { "FieldId":2102, "Response":data.email }, { "FieldId":2104, "Response":data.mobile }, { "FieldId":2106, "Response":data.zip }]}};
			
			if (data.askEmail == 5177) {
				resp.MethodData.FieldResponses.push( { "FieldId":2094, "ResponseID": 5177, "Response":"I agree" });
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":2094, "ResponseID": 5178, "Response":"I disagree" });
			}
			
			if (data.over18 == 5183) {
				resp.MethodData.FieldResponses.push( { "FieldId":2099, "ResponseID": 5183, "Response":"Yes" });
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":2099, "ResponseID": 5184, "Response":"No" });	
			}
			
			if (data.acknowledge == 5304) {
				resp.MethodData.FieldResponses.push( { "FieldId":2147, "ResponseID": 5304, "Response":"I agree" });			
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":2147, "ResponseID": 5305, "Response":"I disagree" });
			}
			
			if (data.permission == 5200) {
				resp.MethodData.FieldResponses.push( { "FieldId":2111, "ResponseID": 5200, "Response":"I agree" });
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":2111, "ResponseID": 5201, "Response":"I disagree" });	
			}
			
			if (data.currentCustomer == 5194) {
				resp.MethodData.FieldResponses.push( { "FieldId":2107, "ResponseID": 5194, "Response":"Yes" });
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":2107, "ResponseID": 5195, "Response":"No" });	
			}			
			
			if (data.checking == 5196) {
				resp.MethodData.FieldResponses.push( { "FieldId":2109, "ResponseID": 5196, "Response":"Yes" });
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":2109, "ResponseID": 5197, "Response":"No" });	
			}
			
			if (data.willingToBeContacted == 5198) {
				resp.MethodData.FieldResponses.push( { "FieldId":2110, "ResponseID": 5198, "Response":"Yes, via Email" });			
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":2110, "ResponseID": 5199, "Response":"No" });
			}				
				
			if (data.futureCommunication == 5181) {
				resp.MethodData.FieldResponses.push( { "FieldId":2096, "ResponseID": 5181, "Response":"Yes" });			
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":2096, "ResponseID": 5182, "Response":"No" });
			}
			
			data.photoFieldID = 2112;			
			
			data.printed = true;
			
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