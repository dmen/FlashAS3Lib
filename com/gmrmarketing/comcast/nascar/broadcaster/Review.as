
package com.gmrmarketing.comcast.nascar.broadcaster
{
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.File;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Review extends EventDispatcher
	{
		public static const COMPLETE:String = "reviewComplete";//save button pressed
		public static const RETAKE:String = "reviewRetake";//retake button pressed
		public static const CANCEL:String = "reviewCancel";//cancel button pressed
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var tim:TimeoutHelper;
		
		
		public function Review()
		{
			clip = new mcReview();
			clip.x = 112;
			clip.y = 90;
			
			tim = TimeoutHelper.getInstance();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * 
		 * @param	fileName GUID created in Capture
		 */
		public function show(fileName:String):void
		{
			tim.buttonClicked();
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.theVid.source = File.applicationStorageDirectory.nativePath + "\\" + fileName + ".mp4";
			clip.theVid.alpha = 0;
			clip.hLines.scaleY = 0;
			clip.title.alpha = 0;
			clip.xfinZone.alpha = 0;
			clip.xfinNascar.alpha = 0;
			clip.btnSave.alpha = 0;
			clip.btnRetake.alpha = 0;
			clip.btnCancel.alpha = 0;
			clip.btnQuit.alpha = 0;
			clip.pubRelease.visible = false;//dialog
			clip.pubReleaseFull.visible = false;
			
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, showPubReleaseDialog, false, 0, true);
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, videoRetake, false, 0, true);			
			clip.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, videoCancel, false, 0, true);			
			clip.btnQuit.addEventListener(MouseEvent.MOUSE_DOWN, videoCancel, false, 0, true);
			
			TweenMax.to(clip.hLines, .5, { scaleY:1, ease:Back.easeOut } );
			TweenMax.to(clip.title, .5, { alpha:1, delay:.4 } );
			TweenMax.to(clip.btnSave, .5, { alpha:1, delay:.6 } );
			TweenMax.to(clip.btnRetake, .5, { alpha:1, delay:.7 } );
			TweenMax.to(clip.btnQuit, .5, { alpha:1, delay:.9 } );
			TweenMax.to(clip.btnCancel, .5, { alpha:1, delay:.8 } );
			TweenMax.to(clip.xfinZone, 1, { alpha:1, delay:1 } );
			TweenMax.to(clip.xfinNascar, 1, { alpha:1, delay:1.25 } );
			
			TweenMax.to(clip.theVid, 1, { alpha:1, delay:1.5, onComplete:playUserVid } );
		}
		
		
		public function hide():void
		{
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
			
			clip.theVid.stop();
			
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, showPubReleaseDialog);
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, videoRetake);			
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, videoCancel);
			clip.btnQuit.removeEventListener(MouseEvent.MOUSE_DOWN, videoCancel);
			
			clip.pubRelease.btnAgree.removeEventListener(MouseEvent.MOUSE_DOWN, togglePubReleaseAgree);
			clip.pubRelease.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, videoSaved);
			clip.pubRelease.btnPubRel.removeEventListener(MouseEvent.MOUSE_DOWN, showFullPubRelease);
		}
		
		
		private function playUserVid():void
		{
			clip.theVid.play();
		}
		
		
		public function get pubRelease():Boolean
		{
			return clip.pubRelease.agree.currentFrame == 2 ? true : false;
		}
		
		
		private function showPubReleaseDialog(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, showPubReleaseDialog);
			
			clip.pubRelease.visible = true;
			clip.pubRelease.alpha = 0;
			clip.pubRelease.x = 700;
			clip.pubRelease.agree.gotoAndStop(1);//radio button
			clip.pubRelease.btnAgree.addEventListener(MouseEvent.MOUSE_DOWN, togglePubReleaseAgree, false, 0, true);
			clip.pubRelease.btnContinue.addEventListener(MouseEvent.MOUSE_DOWN, videoSaved, false, 0, true);
			clip.pubRelease.btnPubRel.addEventListener(MouseEvent.MOUSE_DOWN, showFullPubRelease, false, 0, true);
			TweenMax.to(clip.pubRelease, .5, { alpha:1, x:598, ease:Back.easeOut } );
		}
		
		
		private function togglePubReleaseAgree(e:MouseEvent):void
		{
			if (clip.pubRelease.agree.currentFrame == 1) {
				clip.pubRelease.agree.gotoAndStop(2);
			}else {
				clip.pubRelease.agree.gotoAndStop(1);
			}
		}
		
		
		private function showFullPubRelease(e:MouseEvent):void
		{
			clip.pubReleaseFull.visible = true;
			clip.pubReleaseFull.alpha = 0;
			clip.pubReleaseFull.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closePubReleaseFull, false, 0, true);
			TweenMax.to(clip.pubReleaseFull, .5, { alpha:1 } );
		}
		
		private function closePubReleaseFull(e:MouseEvent):void
		{
			clip.pubReleaseFull.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closePubReleaseFull);
			clip.pubReleaseFull.visible = false;
		}
		
		
		private function videoSaved(e:MouseEvent):void
		{
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, showPubReleaseDialog);
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, videoRetake);
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, videoCancel);
			clip.btnQuit.removeEventListener(MouseEvent.MOUSE_DOWN, videoCancel);
			
			clip.pubRelease.btnAgree.removeEventListener(MouseEvent.MOUSE_DOWN, togglePubReleaseAgree);
			clip.pubRelease.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, videoSaved);
			clip.pubRelease.btnPubRel.removeEventListener(MouseEvent.MOUSE_DOWN, showFullPubRelease);
			
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function videoRetake(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, showPubReleaseDialog);
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, videoRetake);
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, videoCancel);
			clip.btnQuit.removeEventListener(MouseEvent.MOUSE_DOWN, videoCancel);
			
			clip.pubRelease.btnAgree.removeEventListener(MouseEvent.MOUSE_DOWN, togglePubReleaseAgree);
			clip.pubRelease.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, videoSaved);
			clip.pubRelease.btnPubRel.removeEventListener(MouseEvent.MOUSE_DOWN, showFullPubRelease);
			
			dispatchEvent(new Event(RETAKE));
		}
		
		
		private function videoCancel(e:MouseEvent):void
		{
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, showPubReleaseDialog);
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, videoRetake);
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, videoCancel);
			clip.btnQuit.removeEventListener(MouseEvent.MOUSE_DOWN, videoCancel);
			
			clip.pubRelease.btnAgree.removeEventListener(MouseEvent.MOUSE_DOWN, togglePubReleaseAgree);
			clip.pubRelease.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, videoSaved);
			clip.pubRelease.btnPubRel.removeEventListener(MouseEvent.MOUSE_DOWN, showFullPubRelease);
			
			dispatchEvent(new Event(CANCEL));
		}
	}
	
}