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
package com.gmrmarketing.associatedbank.badgers
{
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.utilities.queue.HubbleService;
	
	public class HubbleServiceExtender_nov extends HubbleService
	{		
		
		public function HubbleServiceExtender_nov()
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
			var resp:Object = { "MethodData": { "InteractionId":276, "FieldResponses":[ { "FieldId":2100, "Response":data.original.fname }, { "FieldId":2101, "Response":data.original.lname }, { "FieldId":2102, "Response":data.original.email }, { "FieldId":2103, "Response":data.original.email2 }, { "FieldId":2104, "Response":data.original.mobile }, { "FieldId":3231, "Response":data.original.numPeople }]}};
			
			if (data.original.firstTime == 5179){
				resp.MethodData.FieldResponses.push( { "FieldId":2095, "ResponseID": 5179, "Response":"Yes, this is the first time for everyone in our group." });
			}else if (data.original.firstTime == 5180){
				resp.MethodData.FieldResponses.push( { "FieldId":2095, "ResponseID": 5180, "Response":"Yes, this is the first time for some of us" });
			}else{
				resp.MethodData.FieldResponses.push( { "FieldId":2095, "ResponseID": 7004, "Response":"No, all of us have participated this season" });
			}
			 
			if (data.original.futureCommunication == 5177) {
				resp.MethodData.FieldResponses.push( { "FieldId":2094, "ResponseID": 5177, "Response":"I agree" });
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":2094, "ResponseID": 5178, "Response":"I disagree" });
			}
			
			if (data.original.willingToBeContacted == 5198) {
				resp.MethodData.FieldResponses.push( { "FieldId":2110, "ResponseID": 5198, "Response":"Yes" });			
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":2110, "ResponseID": 5199, "Response":"No" });
			}						
			
			if (data.original.over18 == 5183) {
				resp.MethodData.FieldResponses.push( { "FieldId":2099, "ResponseID": 5183, "Response":"Yes" });
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":2099, "ResponseID": 5184, "Response":"No" });	
			}
			
			if (data.original.currentCustomer == 5194) {
				resp.MethodData.FieldResponses.push( { "FieldId":2107, "ResponseID": 5194, "Response":"Yes" });
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":2107, "ResponseID": 5195, "Response":"No" });	
			}	
			
			if (data.original.checking == 5196) {
				resp.MethodData.FieldResponses.push( { "FieldId":2109, "ResponseID": 5196, "Response":"Yes" });
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":2109, "ResponseID": 5197, "Response":"No" });	
			}
			
			if (data.original.permission == 5200) {
				resp.MethodData.FieldResponses.push( { "FieldId":2111, "ResponseID": 5200, "Response":"I agree" });
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":2111, "ResponseID": 5201, "Response":"I disagree" });	
			}
			
			data.photoFieldID = 2112;			
			data.printed = true;			
			data.responseObject = resp;			
			
			super.send(data);//calls send in HubbleService
		}
	}
	
}