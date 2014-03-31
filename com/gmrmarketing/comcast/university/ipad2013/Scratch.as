package com.gmrmarketing.comcast.university.ipad2013
{
	import flash.display.*;	
	import flash.events.*;
	import flash.geom.*;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.Utility;
	import flash.media.*;
	
	
	public class Scratch extends EventDispatcher
	{
		public static const SCRATCH_SHOWING:String = "scratchShowing";//game board is ready
		public static const NEW_ICON:String = "newIconScratched";//new icon fully revealed
		public static const SCRATCH_COMPLETE:String = "scratchComplete";//all done
		
		//this is the percentage of unscratched area remaining in order for the square to be considered "scratched-off"
		//ie if you used .3 for the multiplier, then 70% of the square would need to be scratched off
		private const SCRATCH_PERCENT:Number = (283 * 201) * .5;
		
		private var clip:MovieClip;//backgroung image
		private var icons:Array;
		private var masks:Array;
		private var container:DisplayObjectContainer;
		private var iconLocs:Array;
		private var brush:BitmapData;//lib clip
		private var currentIcon:MovieClip;//the icon being scratched
		private var bmd:BitmapData;//temp used in doScratch()
		private var scratched:Array; //the scratched icons
		private var fullyScratched:Array;
		
		private var scratch:Sound;
		private var scratchChannel:SoundChannel;
		private var scratchPlaying:Boolean;
		
		
		
		public function Scratch()
		{
			iconLocs = new Array([53, 228], [369, 228], [684, 228], [53, 460], [369, 460], [684, 460]);
			clip = new mcScratch();			
			scratch = new audScratch();
			brush = new brushBMD();
			scratchPlaying = false;
		}		
		
		private function buildIcons(prizingDisabled:Boolean):void
		{
			icons = new Array();
			var group1:Array = new Array();
			var group2:Array = new Array();
			var mc:MovieClip;
			
			/**
			 * make two random 'groups' of icons - then take the first 5 icons from group one
			 * now if prizing is disabled then just take the next icon from the group one - so there can't be a match
			 * if prizing is not disabled add an icon from the second group - for a possible match.
			 */
			
			 //1st group
			mc = new sc1();
			mc.name = "espn";
			group1.push(mc);
			mc = new sc2();
			mc.name = "hbo";
			group1.push(mc);
			mc = new sc3();
			mc.name = "internet";
			group1.push(mc);
			mc = new sc4();
			mc.name = "showtime";
			group1.push(mc);
			mc = new sc5();
			mc.name = "xfinity";
			group1.push(mc);
			mc = new sc6();
			mc.name = "tv";
			group1.push(mc);
			mc = new sc7();
			mc.name = "xod";
			group1.push(mc);
			
			//randomize the first group
			group1 = Utility.randomizeArray(group1);
			
			//now add the second group
			mc = new sc1();
			mc.name = "espn";
			group2.push(mc);
			mc = new sc2();
			mc.name = "hbo";
			group2.push(mc);
			mc = new sc3();
			mc.name = "internet";
			group2.push(mc);
			mc = new sc4();
			mc.name = "showtime";
			group2.push(mc);
			mc = new sc5();
			mc.name = "xfinity";
			group2.push(mc);
			mc = new sc6();
			mc.name = "tv";
			group2.push(mc);
			mc = new sc7();
			mc.name = "xod";
			group2.push(mc);
			
			group2 = Utility.randomizeArray(group2);
			
			//add the first 5 randomized icons from the 1st group
			for (var i:int = 0; i < 5; i++) {
				icons.push(group1.shift());
			}
			
			if (prizingDisabled) {
				//add next icon from the first group
				icons.push(group1.shift());
			}else {
				//add one from the second group				
				icons.push(group2.shift());
			}
			
			masks = new Array();
			masks.push(new Bitmap(new BitmapData(283, 201, true, 0x00ff0000)));
			masks.push(new Bitmap(new BitmapData(283, 201, true, 0x00ff0000)));
			masks.push(new Bitmap(new BitmapData(283, 201, true, 0x00ff0000)));
			masks.push(new Bitmap(new BitmapData(283, 201, true, 0x00ff0000)));
			masks.push(new Bitmap(new BitmapData(283, 201, true, 0x00ff0000)));
			masks.push(new Bitmap(new BitmapData(283, 201, true, 0x00ff0000)));
			masks.push(new Bitmap(new BitmapData(283, 201, true, 0x00ff0000)));					
			
			for (i = 0; i < 6; i++) {
				icons[i].addChild(masks[i]);
				icons[i].icon.mask = masks[i];
				masks[i].cacheAsBitmap = true;
				icons[i].icon.cacheAsBitmap = true;
			}			
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}		
		
		
		public function show(prizingDisabled:Boolean):void
		{
			var pList:String = "";
			
			scratched = new Array();
			fullyScratched = new Array();
			
			buildIcons(prizingDisabled);
			
			for (var i:int = 0; i < 6; i++) {
				var ic:MovieClip = icons[i];
				clip.addChild(ic);
				ic.x = iconLocs[i][0];
				ic.y = iconLocs[i][1];
				ic.addEventListener(MouseEvent.MOUSE_DOWN, beginScratch, false, 0, true);
				pList += ic.name + "  ";
				//trace(ic.name);
			}
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			//clip.prizeList.text = pList;
			clip.y = clip.height;//put at screen bottom
			TweenMax.to(clip, 1, { y:0, onComplete:showing } );//tween up to show
		}
		
		
		public function hide():void
		{			
			for (var i:int = 0; i < icons.length; i++) {
				var ic:MovieClip = icons[i];
				if (clip.contains(ic)) {
					clip.removeChild(ic);
				}
				ic.removeEventListener(MouseEvent.MOUSE_DOWN, beginScratch);
			}
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SCRATCH_SHOWING));
		}
		
		
		public function getIconName():String
		{
			return currentIcon.name;
		}
		
		public function getNumScratched():int
		{
			return fullyScratched.length;
		}
		
		private function beginScratch(e:MouseEvent):void
		{
			currentIcon = MovieClip(e.currentTarget);		
			currentIcon.addEventListener(MouseEvent.MOUSE_MOVE, doScratch, false, 0, true);
			container.stage.addEventListener(MouseEvent.MOUSE_UP, endScratch, false, 0, true);
		}		
		
		
		private function doScratch(e:MouseEvent):void
		{
			if (scratched.indexOf(currentIcon) == -1 && scratched.length < 3) {
				scratched.push(currentIcon);					
			}
			if(scratched.indexOf(currentIcon) != -1){
				bmd = Bitmap(currentIcon.getChildAt(2)).bitmapData;
				bmd.copyPixels(brush, new Rectangle(0, 0, 32, 32), new Point(currentIcon.mouseX - 16, currentIcon.mouseY - 16));
				var c:uint = bmd.threshold(bmd, new Rectangle(0, 0, 283, 201), new Point(0, 0), "==", 0x00000000);
				
				if (c < SCRATCH_PERCENT) {
					if (fullyScratched.indexOf(currentIcon) == -1) {
						fullyScratched.push(currentIcon);
					}
					dispatchEvent(new Event(NEW_ICON));
					
					if (scratched.length >= 2) {
						dispatchEvent(new Event(SCRATCH_COMPLETE));						
					}
				}	
			}
			if (!scratchPlaying) {
				scratchPlaying = true;				
				scratchChannel = scratch.play();
				scratchChannel.addEventListener(Event.SOUND_COMPLETE, soundDone, false, 0, true);
			}			
			
		}
		
		private final function soundDone(e:Event):void
		{
			scratchPlaying = false;
		}
		
		
		private function endScratch(e:MouseEvent):void
		{
			currentIcon.removeEventListener(MouseEvent.MOUSE_MOVE, doScratch);
		}
		
	}	
}