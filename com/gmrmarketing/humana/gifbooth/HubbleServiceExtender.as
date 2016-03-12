/**
 * Unique Hubble service - modify this class per project
 * Version 1 - 9/22/2015
 * 
 * Properties of the data object sent to HubbleService.send()
 * -------------------------------------------------------------
 * image - Base64 encoded String - main image being sent
 * image2 - Base64 String - if present this image will also be sent
 * printed - If printed is true then the PrintAPI will be called
 * 
 *  email, name, etc. Any properties used to construct the JSON response object
 */
package com.gmrmarketing.humana.gifbooth
{	
	import com.gmrmarketing.utilities.queue.HubbleService;
	
	public class HubbleServiceExtender extends HubbleService
	{		
		
		
		public function HubbleServiceExtender()
		{
			super();
		}
		
		
		/**
		 * @param	data Object
		 */
		override public function send(data:Object):void
		{	
			var resp:Object = { "MethodData": { "InteractionId":289, "FieldResponses":[ { "FieldId":2239, "Response":data.email }, { "FieldId":2240, "Response":data.phone }, { "FieldId":2242, "Response":data.opt1 }, { "FieldId":2243, "Response":data.opt2 }, { "FieldId":2244, "Response":data.opt3 }, { "FieldId":2245, "Response":data.opt4 }, { "FieldId":2246, "Response":data.opt5 }, { "FieldId":2241, "Response":true }, { "FieldId":2247, "Response":data.phone == "" ? false : true } ]}};
			
			data.responseObject = resp;
			
			data.photoFieldID = 2238;
			
			super.send(data);			
		}
	}
	
}