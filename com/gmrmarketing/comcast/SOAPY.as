package com.gmrmarketing.comcast
{
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLRequestHeader;
	

	public class SOAPY
	{		
		//private const SERVICE_URL:String = "http://staging2.radweblive.com/staging/comcastsweeps/webservice.asmx";
		private var myURL:String;

		
		/**
		 * CONSTRUCTOR
		 */
		public function SOAPY(svcURL:String) 
		{
			myURL = svcURL;
		}		

		
		/**
		 * Builds a URLRequest Object for sending to the web service
		 * 
		 * @param	method String method name to call on the service
		 * @return URLRequest - SOAP Envelope
		 */		
		public function buildEnvelope(uid:String, entries:String):URLRequest
		{			
			var req:URLRequest = new URLRequest(myURL + "/webservice.asmx");

			req.contentType = "text/xml; charset=utf-8";
			req.requestHeaders.push(new URLRequestHeader("SOAPAction", "http://tempuri.org/SubmitEntry"));
			req.method = URLRequestMethod.POST;
			
			//Envelope Begin
			var envelope:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>";
			
			envelope += "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">";
			
			envelope += "<soap:Body>";
			envelope += "<SubmitEntry xmlns=\"http://tempuri.org/\">";
			
			
			envelope += "<psUserName>ComcastSweeps</psUserName>";
			envelope += "<psPassword>Sw33psComC@st</psPassword>";
			envelope += "<psRID>" + uid + "</psRID>";
			envelope += "<psEntries>" + entries + "</psEntries>";
			
			envelope += "</SubmitEntry></soap:Body></soap:Envelope>"			
			
			req.data = envelope;
			
			return req;
		}
		
		
		
		/**
		 * Gets the data for starting a solo or challenge game
		 * returns an object containing gameId, game1, game2, game3 properties
		 * 
		 * @param	SOAPReply
		 * @return	Object
		 */
		public function parse(SOAPReply:String):Object
		{				
			var xm:XMLList = new XMLList(SOAPReply);			
			var ret:Object = new Object();
			ret.success = xm.descendants(new QName("http://tempuri.org/", "SubmitEntryResult"));
			return ret;			
		}

	}	
}