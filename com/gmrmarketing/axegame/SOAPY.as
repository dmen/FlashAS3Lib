package com.gmrmarketing.axegame
{
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLRequestHeader;
	import flash.system.Security;

	public class SOAPY
	{
		//private const SERVICE_URL:String = "http://staging2.radweblive.com/staging/axesoccer/services/AxeSoccerWS.svc";
		//private const SERVICE_URL:String = "https://axesoccer.com/Services/AxeSoccerWS.svc";
		private var myURL:String;
		private var myKey:String;
		
		/**
		 * CONSTRUCTOR
		 */
		public function SOAPY(svcurl:String, key:String) 
		{						
			myURL = svcurl;	
			myKey = key;
		}		
		
		
		
		/**
		 * Builds a URLRequest Object for sending to the AXE web service
		 * 
		 * @param	method String GetTotalPoints, BeginSoloGame, FinishSoloGame, BeginChallengeGame, FinishChallengeGame
		 * @return URLRequest - SOAP Envelope
		 */		
		public function buildEnvelope(method:String, uid:String = null, gameid:String = null, h2hid:String = null, score:String = null):URLRequest
		{			
			var req:URLRequest = new URLRequest(myURL);
			//var req:URLRequest = new URLRequest(SERVICE_URL);

			req.contentType = "text/xml; charset=utf-8";
			req.requestHeaders.push(new URLRequestHeader("SOAPAction", "http://tempuri.org/IAxeSoccerWS/" + method));
			req.method = URLRequestMethod.POST;
			
			//Envelope Begin
			var envelope:String = "<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\">";
			
			//header
			//envelope += "<s:Header><Action s:mustUnderstand=\"1\" xmlns=\"http://schemas.microsoft.com/ws/2005/05/addressing/none\">http://tempuri.org/IAxeSoccerWS/BeginSoloGame</Action></s:Header>";
			
			envelope += "<s:Body>";
			envelope += "<" + method + " xmlns=\"http://tempuri.org/\"><passKey>" + myKey + "</passKey>";
			
			if (uid != null) {
				envelope += "<registrantId>" + uid + "</registrantId>";
			}
			if (gameid != null) {
				envelope += "<gameId>" + gameid + "</gameId>";				
			}
			if (h2hid != null) {
				envelope += "<headToHeadId>" + h2hid + "</headToHeadId>";
			}
			if (score != null) {
				envelope += "<score>" + score + "</score>";
			}
			
			envelope += "</" + method + "></s:Body></s:Envelope>"			
			
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
		public function parseGame(SOAPReply:String):Object
		{				
			var xm:XMLList = parseReply(SOAPReply);
			
			var ret:Object = new Object();
			ret.gameId = xm.descendants(new QName("http://tempuri.org/", "gameId"));			
			ret.game1 = xm.descendants(new QName("http://tempuri.org/", "imageSet1"));			
			ret.game2 = xm.descendants(new QName("http://tempuri.org/", "imageSet2"));			
			ret.game3 = xm.descendants(new QName("http://tempuri.org/", "imageSet3"));
			
			return ret;			
		}
		
		
		
		/**
		 * Gets initial value inside the <return> tags
		 * 
		 * @param	SOAPReply
		 * @return
		 */
		public function parseReply(SOAPReply:String):XMLList
		{			
			var myPattern:RegExp;
			var retString:String;
			
			var st:String = SOAPReply;
			myPattern = /&lt;/g; 
			retString = st.replace(myPattern, "<");
			myPattern = /&gt;/g;
			retString = retString.replace(myPattern, ">");			
			
			var xm:XML = new XML(retString);			
			
			var nodeName:QName = new QName("http://tempuri.org/", "return");
			
			return xm.descendants(nodeName);
		}

	}	
}