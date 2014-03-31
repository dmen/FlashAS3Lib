package com.gmrmarketing.ufc.fightcard
{
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;	
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import com.dynamicflash.util.Base64;
	import flash.utils.ByteArray;
	import com.adobe.images.JPGEncoder;
	import flash.net.URLVariables;
	import flash.net.URLLoader;
	import flash.net.URLRequestMethod;
	import flash.net.URLRequest;
	import flash.events.*;
	import com.greensock.TweenLite;
	
	
	public class CardPreview extends EventDispatcher
	{
		public static const CLOSE_PREVIEW:String = "closeThePreview";
		public static const CARD_COMPLETE:String = "cardCompleted";
		public static const CARD_SUBMITTED:String = "cardWasSubmitted";
		
		private var clip:MovieClip; //previewer lib clip
		private var theCard:MovieClip;
		private var container:DisplayObjectContainer;
		
		private var userBitmapData:BitmapData;
		private var userBitmap:Bitmap;
		
		private var shadow:DropShadowFilter;
		private var nameFormatter:TextFormat;
		
		private var template:int; //card num (1-4) set in show, used by headlineChanged()
		private var fbID:String; //facebook ID, populated in show() - from flashvars
		
		private var currentHeadline:Bitmap;
		
		
		
		public function CardPreview()
		{
			clip = new previewer();
			
			shadow = new DropShadowFilter(0, 0, 0, 1, 5, 5, 1, 2);
			nameFormatter = new TextFormat();	
		}
		
		
		/**
		 * Shows the card
		 * 
		 * @param	$container Container to place clip in
		 * @param	template Card number 1-4
		 * @param	userPic Full size (600x800) image from camPic
		 * @param	lastName Users last name
		 * @param	fbID FaceBook ID - passed in when outline is done - from Main.outlineDone() 
		 * @param	isPreview True if just previewing  - shows a close button when true
		 */
		public function show($container:DisplayObjectContainer, $template:int, userPic:BitmapData, lastName:String, $fbID:String = "", isPreview:Boolean = false):void
		{
			container = $container;
			template = $template;
			fbID = $fbID;
			
			var m:Matrix = new Matrix();
			var p:Point;
			
			switch(template) {
				case 1:					
					theCard = new jones_card();
					userBitmapData = new BitmapData(256, 341, true, 0x00000000);
					m.scale(256 / userPic.width, 341 / userPic.height);
					p = new Point(141, 103);
					nameFormatter.italic = false;
					break;
				case 2:
					theCard = new alves_card();					
					userBitmapData = new BitmapData(256, 341, true, 0x00000000);
					m.scale(256 / userPic.width, 341 / userPic.height);
					p = new Point(144, 23);
					nameFormatter.italic = true;
					break;
				case 3:
					theCard = new edgar_card();
					userBitmapData = new BitmapData(307,410, true, 0x00000000);
					m.scale(307 / userPic.width, 410 / userPic.height);
					p = new Point(125,122);
					nameFormatter.italic = true;
					break;
				case 4:
					theCard = new cruz_card();
					userBitmapData = new BitmapData(200, 266, true, 0x00000000);
					m.scale(200 / userPic.width, 266 / userPic.height);
					p = new Point(198, 131);
					nameFormatter.italic = false;
					break;
			}
			
			userBitmapData.draw(userPic, m, null, null, null, true);
			userBitmap = new Bitmap(userBitmapData);
			userBitmap.filters = [shadow];			
			
			theCard.bg.theText.autoSize = TextFieldAutoSize.CENTER;
			theCard.bg.theText.text = lastName;
			
			//card width is 400 - fit in 380 for a 10 pixel edge 
			if (theCard.bg.theText.textWidth > 380) {
				var d:Number = 380 / theCard.bg.theText.textWidth;
				theCard.bg.theText.scaleX = d;				
			}
			
			theCard.bg.theText.setTextFormat(nameFormatter);  //italic or not			
			theCard.bg.theText.x = Math.round((400 - theCard.bg.theText.width) / 2);			
			theCard.addChildAt(userBitmap, 1);			
			
			userBitmap.x = p.x;
			userBitmap.y = p.y;
			
			userBitmap.mask = theCard.camMask;			
			
			theCard.x = 60;
			theCard.y = 130;
			theCard.filters = [shadow];
			
			if (isPreview) {
				clip.s4.stepText.text = "final card";
				clip.s4.headlineText.text = "PREVIEW";
				
				clip.btnClose.alpha = 1;
				clip.btnClose.addEventListener(MouseEvent.CLICK, closePreview, false, 0, true);
				clip.btnClose.buttonMode = true;				
				
				clip.btnBack.alpha = 0;
				clip.btnBack.removeEventListener(MouseEvent.CLICK, closePreview);
				
				clip.btnDone.alpha = 0;
				clip.btnDone.removeEventListener(MouseEvent.CLICK, cardComplete);
			}else {
				
				//final step
				
				clip.s4.stepText.text = "Step 4";
				clip.s4.headlineText.text = "SUBMIT YOUR CARD";
				
				clip.btnBack.alpha = 1;
				clip.btnBack.addEventListener(MouseEvent.CLICK, closePreview, false, 0, true);
				clip.btnBack.buttonMode = true;
				
				clip.btnClose.removeEventListener(MouseEvent.CLICK, closePreview);
				clip.btnClose.alpha = 0;
				
				clip.btnDone.alpha = 1;
				clip.btnDone.addEventListener(MouseEvent.CLICK, cardComplete, false, 0, true);
				clip.btnDone.buttonMode = true;
			}
			
			clip.theHeadlines.addEventListener(Event.CHANGE, headlineChanged, false, 0, true);
			
			clip.addChild(theCard);			
			container.addChild(clip);
			clip.alpha = 0;
			TweenLite.to(clip, 1, { alpha:1 } );
			
			headlineChanged();
		}
		
		
		/**
		 * Called when Back to Editing is pressed
		 * @param	e
		 */
		public function closePreview(e:MouseEvent):void
		{			
			trace("dispatch close");
			dispatchEvent(new Event(CLOSE_PREVIEW));
		}
		
		
		public function hide():void
		{
			if (clip) {
				if(container){
					if (container.contains(clip)) {
						container.removeChild(clip);
						theCard.removeChild(userBitmap);
						userBitmap = null;
						userBitmapData = null;
						theCard.filters = [];
					}
				}
			}
			
		}
		
		
		/**
		 * 
		 * @param	e CHANGE event from dropdown
		 */
		private function headlineChanged(e:Event = null):void
		{
			if (currentHeadline) {
				if (theCard.contains(currentHeadline)) {
					theCard.removeChild(currentHeadline);
					currentHeadline = null;
				}
			}
			
			var cNum:int
			if(clip.theHeadlines.selectedItem != null){
				cNum = clip.theHeadlines.selectedItem.data;
			}else {
				cNum = 1;
			}
			
			var theY:int = 0;
			var theX:int = 0;
			var theDepth:int = theCard.numChildren; //headline goes above everything unless otherwise set
			//jones headlines at y:39
			switch(cNum) {
				case 1:
					//Bring It
					switch(template) {
						case 1:
							//jones							
							currentHeadline = new Bitmap(new jones_bring());
							theY = 39;
							theDepth = 1;
							break;
						case 2:
							//alves
							currentHeadline = new Bitmap(new alves_bring());
							break;
						case 3:
							//edgar
							currentHeadline = new Bitmap(new edgar_bring());
							break;
						case 4:
							//cruz
							currentHeadline = new Bitmap(new cruz_bring());
							theX = 17;
							theY = 66;
							break;
					}
					break;
				case 2:					
					//two ultimate fighters one epic battle
					switch(template) {
						case 1:
							//jones							
							currentHeadline = new Bitmap(new jones_ulttwo());
							theDepth = 1;
							theY = 39;
							break;
						case 2:
							//alves
							currentHeadline = new Bitmap(new alves_ulttwo());
							break;
						case 3:
							//edgar
							currentHeadline = new Bitmap(new edgar_ulttwo());
							break;
						case 4:
							//cruz
							currentHeadline = new Bitmap(new cruz_ulttwo());
							theX = 7;
							theY = 62;
							break;
					}
					break;
				case 3:
					//A battle for the ages
					switch(template) {
						case 1:
							//jones							
							currentHeadline = new Bitmap(new jones_ages());
							theDepth = 1;
							theY = 39;
							break;
						case 2:
							//alves
							currentHeadline = new Bitmap(new alves_ages());
							break;
						case 3:
							//edgar
							currentHeadline = new Bitmap(new edgar_ages());
							break;
						case 4:
							//cruz
							currentHeadline = new Bitmap(new cruz_ages());
							theY = 40;
							break;
					}					
					break;
				case 4:
					//the ultimate matchup					
					switch(template) {
						case 1:
							//jones							
							currentHeadline = new Bitmap(new jones_ultmatch());
							theDepth = 1;
							theY = 39;
							break;
						case 2:
							//alves
							currentHeadline = new Bitmap(new alves_ultmatch());
							break;
						case 3:
							//edgar
							currentHeadline = new Bitmap(new edgar_ultmatch());
							break;
						case 4:
							//cruz
							currentHeadline = new Bitmap(new cruz_ultmatch());							 
							theY = 38;
							break;
					}	
					break;
				case 5:
					//this is gonna hurt
					switch(template) {
						case 1:
							//jones							
							currentHeadline = new Bitmap(new jones_hurt());
							theDepth = 1;
							theY = 39;
							break;
						case 2:
							//alves
							currentHeadline = new Bitmap(new alves_hurt());
							break;
						case 3:
							//edgar
							currentHeadline = new Bitmap(new edgar_hurt());
							break;
						case 4:
							//cruz
							currentHeadline = new Bitmap(new cruz_hurt());
							theX = 7; 
							theY = 56;
							break;
					}	
					break;
			}
			
			theCard.addChildAt(currentHeadline, theDepth);
			currentHeadline.y = theY;
			currentHeadline.x = theX;
		}
		
		
		/**
		 * Called when the Done button is pressed
		 * @param	e
		 */
		private function cardComplete(e:MouseEvent):void
		{
			clip.btnBack.removeEventListener(MouseEvent.CLICK, closePreview);				
			clip.btnDone.removeEventListener(MouseEvent.CLICK, cardComplete);
			dispatchEvent(new Event(CARD_COMPLETE));
		}
		
		
		/**
		 * Called by Main once the card is complete
		 */
		public function sendToService():void
		{
			var request:URLRequest = new URLRequest("http://Comcastufccard.thesocialtab.net/Home/SubmitPhoto");
			
			var im:BitmapData = new BitmapData(400, 570, true, 0x00000000);
			im.draw(theCard, null, null, null, null, true);
			var imS:String = getBase64(im);
			
			var vars:URLVariables = new URLVariables();
			vars.imageBuffer = imS;
			vars.registrantId = fbID;			
			
			request.data = vars;			
			request.method = URLRequestMethod.POST;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, sendError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, sendDone, false, 0, true);
			lo.load(request);
		}
		
		private function sendError(e:IOErrorEvent):void
		{
			
		}
		private function sendDone(e:Event):void
		{
			trace(e.target.data);
			//if (e.target.data = "success") {
				dispatchEvent(new Event(CARD_SUBMITTED));
			//}
		}
		
		
		/**
		 * Returns a base64 encoded string of the incoming bitmapdata
		 * @param	bmpd
		 * @param	q
		 * @return
		 */
		private function getBase64(bmpd:BitmapData, q:int = 80):String
		{			
			var encoder:JPGEncoder = new JPGEncoder(q);
			var ba:ByteArray = encoder.encode(bmpd);
			return Base64.encodeByteArray(ba);
		}		
		
	}
	
}