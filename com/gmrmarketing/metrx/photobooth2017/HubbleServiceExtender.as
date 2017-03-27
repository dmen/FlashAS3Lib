/**
 * Unique Hubble service - modify this class per project
 * Version 1 - 9/22/2015
 * 
 * Properties of the data object sent to send()
 * image - Base64 encoded String - used by the HubbleService.submitPhoto() method
 * email, name, etc. Any properties used to construct the JSON in the send() method
 * printed - If printed == true then the PrintAPI will be called
 */
package  com.gmrmarketing.metrx.photobooth2017
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
		 * Original object data sent to queue is in the original property of the incoming data object
		 * @param	data
		 */
		override public function send(data:Object):void
		{
			//Build the JSON response object from the incoming app data
			var resp:Object = { "MethodData": { "InteractionId":424, "FieldResponses":[ { "FieldId":3510, "Response":data.original.fname }, { "FieldId":3511, "Response":data.original.lname }, { "FieldId":3512, "Response":data.original.email }, { "FieldId":3513, "Response":data.original.optin }]}};
			
			//Q1
			switch(data.original.q1){
				case 1:
					resp.MethodData.FieldResponses.push( { "FieldId":3501, "ResponseID": 7330, "Response":"EVERY DAY" });					
					break;
				case 2:
					resp.MethodData.FieldResponses.push( { "FieldId":3501, "ResponseID": 7331, "Response":"A FEW TIMES A WEEK" });
					break;
				case 3:
					resp.MethodData.FieldResponses.push( { "FieldId":3501, "ResponseID": 7332, "Response":"ONCE A WEEK" });
					break;
				case 4:
					resp.MethodData.FieldResponses.push( { "FieldId":3501, "ResponseID": 7333, "Response":"A FEW TIMES A MONTH" });
					break;
				case 5:
					resp.MethodData.FieldResponses.push( { "FieldId":3501, "ResponseID": 7334, "Response":"RARELY IF EVER" });
					break;
			}
			
			//Q2
			switch(data.original.q2[0]){
				case 1:
					resp.MethodData.FieldResponses.push( { "FieldId":3502, "ResponseID": 7335, "Response":"LOW" });					
					break;
				case 2:
					resp.MethodData.FieldResponses.push( { "FieldId":3502, "ResponseID": 7336, "Response":"MODERATE" });
					break;
				case 3:
					resp.MethodData.FieldResponses.push( { "FieldId":3502, "ResponseID": 7337, "Response":"HIGH" });
					break;
				case 4:
					resp.MethodData.FieldResponses.push( { "FieldId":3502, "ResponseID": 7338, "Response":"VERY HIGH" });
					break;
			}
			
			switch(data.original.q2[1]){
				case 5:
					resp.MethodData.FieldResponses.push( { "FieldId":3503, "ResponseID": 7339, "Response":"LOW" });					
					break;
				case 6:
					resp.MethodData.FieldResponses.push( { "FieldId":3503, "ResponseID": 7340, "Response":"MODERATE" });
					break;
				case 7:
					resp.MethodData.FieldResponses.push( { "FieldId":3503, "ResponseID": 7341, "Response":"HIGH" });
					break;
				case 8:
					resp.MethodData.FieldResponses.push( { "FieldId":3503, "ResponseID": 7342, "Response":"VERY HIGH" });
					break;
			}
			
			//Q2B
			switch(data.original.q2b[0]){
				case 1:
					resp.MethodData.FieldResponses.push( { "FieldId":3504, "ResponseID": 7343, "Response":"LOW" });					
					break;
				case 2:
					resp.MethodData.FieldResponses.push( { "FieldId":3504, "ResponseID": 7344, "Response":"MODERATE" });
					break;
				case 3:
					resp.MethodData.FieldResponses.push( { "FieldId":3504, "ResponseID": 7345, "Response":"HIGH" });
					break;
				case 4:
					resp.MethodData.FieldResponses.push( { "FieldId":3504, "ResponseID": 7346, "Response":"VERY HIGH" });
					break;
			}
			
			switch(data.original.q2b[1]){
				case 5:
					resp.MethodData.FieldResponses.push( { "FieldId":3505, "ResponseID": 7347, "Response":"LOW" });					
					break;
				case 6:
					resp.MethodData.FieldResponses.push( { "FieldId":3505, "ResponseID": 7348, "Response":"MODERATE" });
					break;
				case 7:
					resp.MethodData.FieldResponses.push( { "FieldId":3505, "ResponseID": 7349, "Response":"HIGH" });
					break;
				case 8:
					resp.MethodData.FieldResponses.push( { "FieldId":3505, "ResponseID": 7350, "Response":"VERY HIGH" });
					break;
			}
			
			//Q3			
			if (data.original.q3[0] == 1){
				resp.MethodData.FieldResponses.push( { "FieldId":3506, "ResponseID": 7351, "Response":"DEVELOP SPEED" });		
			}
			if (data.original.q3[1] == 1){
				resp.MethodData.FieldResponses.push( { "FieldId":3506, "ResponseID": 7352, "Response":"BUILD ENDURANCE" });		
			}
			if (data.original.q3[2] == 1){
				resp.MethodData.FieldResponses.push( { "FieldId":3506, "ResponseID": 7353, "Response":"BUILD MUSCLE MASS" });		
			}
			if (data.original.q3[3] == 1){
				resp.MethodData.FieldResponses.push( { "FieldId":3506, "ResponseID": 7354, "Response":"LOSE BODY FAT" });		
			}
			
			
			//Q4
			if (data.original.q4[0] == 1){
				resp.MethodData.FieldResponses.push( { "FieldId":3507, "ResponseID": 7355, "Response":"LIFTING WEIGHTS" });		
			}
			if (data.original.q4[1] == 1){
				resp.MethodData.FieldResponses.push( { "FieldId":3507, "ResponseID": 7356, "Response":"RUNNING/CARDIO" });		
			}
			if (data.original.q4[2] == 1){
				resp.MethodData.FieldResponses.push( { "FieldId":3507, "ResponseID": 7357, "Response":"CROSSFIT TRAINING" });		
			}
			if (data.original.q4[3] == 1){
				resp.MethodData.FieldResponses.push( { "FieldId":3507, "ResponseID": 7358, "Response":"OTHER" });		
			}
			
			
			//Q5
			if (data.original.q5[0] == 1){
				resp.MethodData.FieldResponses.push( { "FieldId":3508, "ResponseID": 7359, "Response":"PROTEIN BARS" });		
			}
			if (data.original.q5[1] == 1){
				resp.MethodData.FieldResponses.push( { "FieldId":3508, "ResponseID": 7360, "Response":"WHEY PROTEIN POWDERS" });		
			}
			if (data.original.q5[2] == 1){
				resp.MethodData.FieldResponses.push( { "FieldId":3508, "ResponseID": 7361, "Response":"PERFORMANCE POWDERS" });		
			}
			if (data.original.q5[3] == 1){
				resp.MethodData.FieldResponses.push( { "FieldId":3508, "ResponseID": 7362, "Response":"PLANT-BASED PROTEIN POWDERS" });		
			}
			if (data.original.q5[4] == 1){
				resp.MethodData.FieldResponses.push( { "FieldId":3508, "ResponseID": 7363, "Response":"PERFORAMANCE SPORTS DRINKS" });		
			}
			if (data.original.q5[5] == 1){
				resp.MethodData.FieldResponses.push( { "FieldId":3508, "ResponseID": 7364, "Response":"I DON'T USE SUPPLEMENTS" });		
			}
			
			
			//Q6
			if (data.original.q6[0] == 1){
				resp.MethodData.FieldResponses.push( { "FieldId":3509, "ResponseID": 7365, "Response":"BUILD MUSCLE MASS" });		
			}
			if (data.original.q6[1] == 1){
				resp.MethodData.FieldResponses.push( { "FieldId":3509, "ResponseID": 7366, "Response":"LOSE BODY FAT" });		
			}
			if (data.original.q6[2] == 1){
				resp.MethodData.FieldResponses.push( { "FieldId":3509, "ResponseID": 7367, "Response":"MAINTAIN HEALTH" });		
			}
			if (data.original.q6[3] == 1){
				resp.MethodData.FieldResponses.push( { "FieldId":3509, "ResponseID": 7368, "Response":"AID TRAINING TO ACHIEVE A GOAL" });		
			}
			
			data.photoFieldID = 3557;			
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