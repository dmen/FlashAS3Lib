/**
 * Mananges the tags returned from the web service
 * Gets the tags and then creates the tags array
 */
package com.gmrmarketing.sap.levisstadium.tagcloud
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	
	
	public class TagCloud extends EventDispatcher
	{
		public static const TAGS_READY:String = "tagsLoaded";
		private var tags:Array; //array of objects with name and value properties (fontSize property added in tagsLoaded())
		private var tagIndex:int = 0; //index of current tag in tags
		private var totalTagCount:int; //total of all value properties in the tags array
		
		private var hText:MovieClip;//lib clips used for drawing text into
		private var vText:MovieClip;
		private var sampleSize:int;//used by measure() to return the size in grid units of each word image
		
		private var tagColors:Array;
		private var colorDec:int;
		private var colorIndex:int;
		private var currColor:int;
		
		private var loopCount:int;//used to force successive calls to getNextTag() further down the tag list
		//so that smaller fonts are used
		private var maxFont:int;
		private var minFont:int;
		
		
		public function TagCloud(ss:int, maxFontSize:int, minFontSize:int, colors:Array)
		{
			sampleSize = ss;
			maxFont = maxFontSize;
			minFont = minFontSize;
			
			tagColors = colors;			
			//tagColors = [0x000000];			
			hText = new mcHText();//lib
			vText = new mcVText();//lib	
			tags = new Array();		
			loopCount = 0;			
		}
		
		
		/**
		 * Returns the next tag from the tags array
		 * 
		 * tags have name,value,fontSize,imageh,imagev,widthh,heighth,widthv,heightv properties
		 */
		public function getNextTag():Object
		{
			var tag:Object = tags[tagIndex];
			tagIndex++;
			if (tagIndex >= tags.length) {
				loopCount++;
				tagIndex = 6 * loopCount;//move tagIndex further down the array on each iteration - forces smaller fonts
				tagIndex = Math.min(tagIndex, tags.length - 4);				
			}			
			return tag;
		}
		
		/**
		 * Returns the number of tags in the tags array
		 * @return int
		 */
		public function getNumTags():int
		{
			return tags.length;
		}
		
		
		/**
		 * Refreshes the tags array
		 */
		public function refreshTags():void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/Api/Netbase/GetTags");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, tagsLoaded, false, 0, true);
			l.load(r)
		}
		
		
		/**
		 * Callback for refreshTags()
		 * Creates the tags array of tag objects
		 * @param	e
		 */
		private function tagsLoaded(e:Event):void
		{			
			var j:Object = JSON.parse(e.currentTarget.data);
			tags = j.insights[0].dataset[0].set;
			tagIndex = 0;
			totalTagCount = 0;
			
			for (var i:int = 0; i < tags.length; i++) {				
				
				//normalize value using a logarithm
				tags[i].value = Math.log(tags[i].value);
				
				totalTagCount += tags[i].value;
			}
			
						
			//font size by tag weight - possible because of mormalizing the counts
			//var fontRatio:Number = maxFontSize / ((tags[0].value / totalTagCount) * 100);
			
			//even distribution of font size along the list
			var fontRatio:Number = maxFont / tags.length;
			
			colorDec = Math.ceil(tags.length / tagColors.length);			
			colorIndex = 0;
			currColor = 0;
			
			for (i = 0; i < tags.length; i++) {				
				//tags[i].fontSize = Math.max(12, Math.round(((tags[i].value / totalTagCount) * 100) * fontRatio));
				tags[i].fontSize = Math.max(minFont, Math.round(maxFont - fontRatio * i));				
				measure(tags[i]);//passed by reference so tag in array is modified by measure()
			}
			dispatchEvent(new Event(TAGS_READY));
		}
		
		
		/**
		 * Modifies the passed in tag object 
		 * adds imageh,imagev,widthh,heighth,widthv,heightv
		 * This is a horizontal and vertical image of the tag
		 * and size data for both versions
		 * @param	tag
		 */
		private function measure(tag:Object):void
		{
			var format:TextFormat = new TextFormat();
			format.size = tag.fontSize;
			format.color = tagColors[colorIndex];
			
			currColor++;
			if (currColor % colorDec == 0) {
				colorIndex++;
			}
			
			hText.theText.autoSize = TextFieldAutoSize.LEFT;
			vText.theText.autoSize = TextFieldAutoSize.RIGHT;
			
			hText.theText.text = tag.name;
			vText.theText.text = tag.name;
			
			hText.theText.setTextFormat(format);
			vText.theText.setTextFormat(format);
			
			//draw text into transparent horizontal bitmap
			var h:BitmapData = new BitmapData(hText.width, hText.height, true, 0x00FFFFFF);
			h.draw(hText, null, null, null, null, true);
			
			//draw text into transparent vertical bitmap
			var v:BitmapData = new BitmapData(vText.width, vText.height, true, 0x00FFFFFF);
			v.draw(vText, null, null, null, null, true);
			
			//get a rect containing all nontransparent pixels - this is the actual text
			var rh:Rectangle = h.getColorBoundsRect(0xff000000, 0x00000000, false);
			var rv:Rectangle = v.getColorBoundsRect(0xff000000, 0x00000000, false);
			
			//new bitmap at rect size - actual text size
			var nh:BitmapData = new BitmapData(rh.width, rh.height, true, 0x00000000);
			nh.copyPixels(h, rh, new Point(0, 0));
			
			var nv:BitmapData = new BitmapData(rv.width, rv.height, true, 0x00000000);
			nv.copyPixels(v, rv, new Point(0, 0));
			
			//want to return the grid units the text will need based on the
			//current sampleSize setting			
			var wh:int = Math.max(1, Math.ceil(nh.width / sampleSize));
			var hh:int = Math.max(1, Math.ceil(nh.height / sampleSize));
			
			var wv:int = Math.max(1, Math.ceil(nv.width / sampleSize));
			var hv:int = Math.max(1, Math.ceil(nv.height / sampleSize));
			
			tag.imageh = nh;//horizontal image
			tag.imagev = nv;//vertical image
			tag.widthh = wh;
			tag.heighth = hh;
			tag.widthv = wv;
			tag.heightv = hv;
			//return {imageh:nh, imagev:nv, widthh:wh, heighth:hh, widthv:wv, heightv:hv};
		}
	}
	
}