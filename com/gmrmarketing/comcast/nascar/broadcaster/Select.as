package com.gmrmarketing.comcast.nascar.broadcaster
{
	import flash.display.*;
	import flash.events.*;
	import fl.video.FLVPlayback;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	public class Select extends EventDispatcher
	{
		public static const QUIT:String = "selectQuit";
		public static const COMPLETE:String = "selectComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var angles:Object;
		private var mySelection:int; //1,2,3
		private var tim:TimeoutHelper;
		
		public function Select()
		{
			clip = new mcSelect();
			clip.x = 112;
			clip.y = 90;
			
			clip.theVid.source = "assets\\intro.mp4";
			clip.theVid.seek(0);
			
			tim = TimeoutHelper.getInstance();
			
			angles = { };
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * returns 1,2,3
		 */
		public function get selection():int
		{
			return mySelection;
		}
		
		
		public function show():void
		{
			tim.buttonClicked();
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.theVid.alpha = 0;			
			clip.theVid.visible = true;
			
			clip.modalPlayer.visible = false;
			
			clip.theVid.addEventListener(fl.video.VideoEvent.COMPLETE, vidFinished, false, 0, true);
			clip.hLines.scaleY = 0;
			clip.title.alpha = 0;
			clip.xfinZone.alpha = 0;
			clip.xfinNascar.alpha = 0;
			
			clip.opt1.alpha = 0;
			clip.opt2.alpha = 0;
			clip.opt3.alpha = 0;
			
			clip.btnQuit.alpha = 0;
			
			clip.opt1.emptyClip.graphics.clear();
			clip.opt2.emptyClip.graphics.clear();
			clip.opt3.emptyClip.graphics.clear();
			
			mySelection = 0;
			
			//showSelect();
			clip.theVid.play();
			TweenMax.to(clip.theVid, 1, { alpha:1 } );
		}
		
		
		public function hide():void
		{
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
			
			clip.theVid.source = "assets\\intro.mp4";
			clip.theVid.seek(0);
			clip.theVid.stop();
			clip.modalPlayer.theVid.stop();
			
			clip.opt1.removeEventListener(MouseEvent.MOUSE_DOWN, selectOption1);
			clip.opt2.removeEventListener(MouseEvent.MOUSE_DOWN, selectOption2);
			clip.opt3.removeEventListener(MouseEvent.MOUSE_DOWN, selectOption3);
			clip.btnQuit.removeEventListener(MouseEvent.MOUSE_DOWN, quitSelect);
		}
		
		
		private function vidFinished(e:fl.video.VideoEvent):void
		{
			clip.theVid.removeEventListener(fl.video.VideoEvent.COMPLETE, vidFinished);
			TweenMax.to(clip.theVid, .5, { alpha:0, onComplete:showSelect } );			
		}
		
		
		private function showSelect():void
		{
			clip.theVid.visible = false;
			clip.theVid.source = "assets\\outro.mp4";
			clip.theVid.seek(0);
			
			TweenMax.to(clip.hLines, .5, { scaleY:1, ease:Back.easeOut } );
			TweenMax.to(clip.title, .5, { alpha:1, delay:.4 } );
			TweenMax.to(clip.xfinZone, 1, { alpha:1, delay:1 } );
			TweenMax.to(clip.xfinNascar, 1, { alpha:1, delay:1.25 } );
			TweenMax.to(clip.opt1, .5, { alpha:1, delay:1.5 } );			
			TweenMax.to(clip.opt2, .5, { alpha:1, delay:1.6 } );			
			TweenMax.to(clip.opt3, .5, { alpha:1, delay:1.7 } );			
			TweenMax.to(clip.btnQuit, .5, { alpha:1, delay:2 } );			
			
			angles.ang1 = 0;
			angles.ang2 = 0;
			angles.ang3 = 0;
			TweenMax.to(angles, 1, { ang1:360, onUpdate:updateAng1, delay:1.7 } );
			TweenMax.to(angles, 1, { ang2:360, onUpdate:updateAng2, delay:1.9 } );
			TweenMax.to(angles, 1, { ang3:360, onUpdate:updateAng3, delay:2.1 } );
			
			clip.opt1.addEventListener(MouseEvent.MOUSE_DOWN, selectOption1, false, 0, true);
			clip.opt2.addEventListener(MouseEvent.MOUSE_DOWN, selectOption2, false, 0, true);
			clip.opt3.addEventListener(MouseEvent.MOUSE_DOWN, selectOption3, false, 0, true);
			clip.btnQuit.addEventListener(MouseEvent.MOUSE_DOWN, quitSelect, false, 0, true);
		}
		
		
		private function updateAng1():void
		{
			Utility.drawArc(clip.opt1.emptyClip.graphics, 110, 110, 110, 0, angles.ang1, 5, 0xffffff, 1);
		}
		private function updateAng2():void
		{
			Utility.drawArc(clip.opt2.emptyClip.graphics, 110, 110, 110, 0, angles.ang2, 5, 0xffffff, 1);
		}
		private function updateAng3():void
		{
			Utility.drawArc(clip.opt3.emptyClip.graphics, 110, 110, 110, 0, angles.ang3, 5, 0xffffff, 1);
		}
		
		
		private function selectOption1(e:MouseEvent):void
		{
			tim.buttonClicked();
			mySelection = 1;
			modalPlay();
		}
		private function selectOption2(e:MouseEvent):void
		{
			tim.buttonClicked();
			mySelection = 2;
			modalPlay();
		}
		private function selectOption3(e:MouseEvent):void
		{			
			tim.buttonClicked();
			mySelection = 3;
			modalPlay();
		}
		
		
		private function modalPlay():void
		{
			switch(mySelection) {
				case 1:
					clip.modalPlayer.theTitle.text = "Race Day Intro";
					clip.modalPlayer.theVid.source = "assets\\opt1.mp4";
					break;
				case 2:
					clip.modalPlayer.theTitle.text = "Close Finish";
					clip.modalPlayer.theVid.source = "assets\\opt2.mp4";
					break;
				case 3:
					clip.modalPlayer.theTitle.text = "Chris Buescher Title Win";
					clip.modalPlayer.theVid.source = "assets\\opt3.mp4";
					break;
			}
			
			clip.modalPlayer.visible = true;
			clip.modalPlayer.alpha = 0;
			clip.modalPlayer.theVid.seek(0);
			clip.modalPlayer.theVid.play();
			clip.modalPlayer.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeModal, false, 0, true);
			clip.modalPlayer.btnRecord.addEventListener(MouseEvent.MOUSE_DOWN, showOutro, false, 0, true);
			TweenMax.to(clip.modalPlayer, .5, { alpha:1 } );
		}
		
		
		private function closeModal(e:MouseEvent = null):void
		{
			clip.modalPlayer.theVid.stop();			
			clip.modalPlayer.visible = false;
		}
		
		
		private function showOutro(e:MouseEvent):void
		{	
			closeModal();
			clip.theVid.visible = true;
			clip.theVid.alpha = 0;
			clip.theVid.play();
			TweenMax.to(clip.theVid, .5, { alpha:1 } );
			clip.theVid.addEventListener(fl.video.VideoEvent.COMPLETE, recordVideo, false, 0, true);
		}
		
		
		private function recordVideo(e:fl.video.VideoEvent):void
		{
			clip.theVid.removeEventListener(fl.video.VideoEvent.COMPLETE, recordVideo);
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function quitSelect(e:MouseEvent):void
		{
			clip.btnQuit.removeEventListener(MouseEvent.MOUSE_DOWN, quitSelect);			
			dispatchEvent(new Event(QUIT));
		}
	}
	
}