/**
 * Unique Hubble service - modify this class per project
 * Version 1 - 9/22/2015
 * 
 * Properties of the data object sent to send()
 * gif - Base64 encoded String - used by the HubbleService.submitPhoto() method
 * email, name, etc. Any properties used to construct the JSON in the send() method
 * printed - If printed == true then the PrintAPI will be called
 */
package com.gmrmarketing.associatedbank.mnwild
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
		 * 
		 * @param	data optIn,survey,over18,fname,lname,email,phone,zip,currentCustomer,checking,moreInfo,permission,image
		 */
		override public function send(data:Object):void
		{
			var resp:Object = { "MethodData": { "InteractionId":245, "FieldResponses":[ { "FieldId":1810, "Response":data.fname }, { "FieldId":1811, "Response":data.lname }, { "FieldId":1813, "Response":data.email }, { "FieldId":1816, "Response":data.phone }, { "FieldId":1817, "Response":data.zip }]}};
			
			if (data.optIn == 4520) {
				resp.MethodData.FieldResponses.push( { "FieldId":1807, "ResponseID": 4520, "Response":"I agree" });
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":1807, "ResponseID": 4521, "Response":"I disagree" });
			}
			
			if (data.survey == 4522) {
				resp.MethodData.FieldResponses.push( { "FieldId":1808, "ResponseID": 4522, "Response":"Yes, via email" });
			}else if (data.survey == 4523) {
				resp.MethodData.FieldResponses.push( { "FieldId":1808, "ResponseID": 4523, "Response":"Yes, via SMS" });
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":1808, "ResponseID": 4524, "Response":"No" });
			}
			
			if (data.over18 == 4525) {
				resp.MethodData.FieldResponses.push( { "FieldId":1809, "ResponseID": 4525, "Response":"Yes" });
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":1809, "ResponseID": 4526, "Response":"No" });	
			}
			
			if (data.currentCustomer == 4553) {
				resp.MethodData.FieldResponses.push( { "FieldId":1823, "ResponseID": 4553, "Response":"Yes" });
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":1823, "ResponseID": 4554, "Response":"No" });	
			}
			
			if (data.checking == 4555) {
				resp.MethodData.FieldResponses.push( { "FieldId":1824, "ResponseID": 4555, "Response":"Yes" });
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":1824, "ResponseID": 4556, "Response":"No" });	
			}
			
			if (data.moreInfo == 4557) {
				resp.MethodData.FieldResponses.push( { "FieldId":1825, "ResponseID": 4557, "Response":"Yes" });
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":1825, "ResponseID": 4558, "Response":"No" });	
			}
			
			if (data.permission == 4561) {
				resp.MethodData.FieldResponses.push( { "FieldId":1829, "ResponseID": 4561, "Response":"I agree" });
			}else {
				resp.MethodData.FieldResponses.push( { "FieldId":1829, "ResponseID": 4562, "Response":"I disagree" });	
			}
			
			var d:Object = new Object();
			d.data = data;//store the full original data for HubbleService to use
			d.resp = resp;//the response object for the initial post to Hubble
			d.photoFieldID = 1830;//the ID of the field used to submit the photo
			
			super.send(d);			
		}
	}
	
}