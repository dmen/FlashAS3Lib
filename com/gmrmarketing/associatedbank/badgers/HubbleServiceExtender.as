/**
 * Unique Hubble service - modify this class per project
 * Version 1 - 9/22/2015
 * 
 * Properties of the data object sent to send()
 * gif - Base64 encoded String - used by the HubbleService.submitPhoto() method
 * email, name, etc. Any properties used to construct the JSON in the send() method
 * printed - If printed == true then the PrintAPI will be called
 */
package com.gmrmarketing.associatedbank.badgers
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
		 *Data Object from Form.data:
		 * 
		   data.askEmail = clip.c1.currentFrame == 2 ? 5177 : 5178;
			
			//data.numInParty = clip.inParty.text;
			
			data.over18 =  clip.c7.currentFrame == 2 ? 5183 : 5184;
			
			data.fname = clip.fname.text;
			data.lname = clip.lname.text;
			data.email = clip.email.text;
			data.mobile = clip.mobile.text;
			data.zip = clip.zip.text;
			
			data.acknowledge = clip.c3.currentFrame == 2 ? 5304 : 5305;
			data.permission = clip.c13.currentFrame == 2 ? 5200 : 5201;
			data.currentCustomer =  clip.c9.currentFrame == 2 ? 5194 : 5195;
			data.checking = clip.c11.currentFrame == 2 ? 5196 : 5197;			
			data.willingToBeContacted = clip.c5.currentFrame == 2 ? 5198 : 5199;
			data.futureCommunication = clip.c15.currentFrame == 2 ? 5181 : 5182;
			
			//REMOVED
			//form 2		 - 	
			data.ackEmail1 = clip2.c15.currentFrame == 2 ? 5306 : 5307;
			data.fname1 = clip2.fname1.text;
			data.email1 = clip2.email1.text;
			
			data.ackEmail2 = clip2.c17.currentFrame == 2 ? 5308 : 5309;
			data.fname2 = clip2.fname2.text;
			data.email2 = clip2.email2.text;
			
		 */
		override public function send(data:Object):void
		{
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
			
			/*
			if (data.ackEmail1 == 5306) {
				resp.MethodData.FieldResponses.push( { "FieldId":2148, "ResponseID": 5306, "Response":"I agreel" });			
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":2148, "ResponseID": 5307, "Response":"I disagree" });
			}
			
			if (data.ackEmail2 == 5308) {
				resp.MethodData.FieldResponses.push( { "FieldId":2151, "ResponseID": 5308, "Response":"I agreel" });			
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":2151, "ResponseID": 5309, "Response":"I disagree" });
			}
			*/
			data.printed = true;
			
			var d:Object = new Object();
			d.data = data;//store the full original data for HubbleService to use
			d.resp = resp;//the response object for the initial post to Hubble
			d.photoFieldID = 2112;//the ID of the field used to submit the photo
			
			
			
			super.send(d);			
		}
	}
	
}