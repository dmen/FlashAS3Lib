package com.gmrmarketing.miller.sxsw
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import flash.text.TextFieldAutoSize;
	
	
	public class Dialog extends EventDispatcher
	{		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Dialog()
		{
			clip = new theDialog();
		}
		
		public function show($container:DisplayObjectContainer, title:String, message:String, keep:Boolean = false):void
		{			
			container = $container;
			clip.alpha = 0;
			container.addChild(clip);
			
			clip.dialog.theTitle.text = title;
			
			clip.dialog.theText.autoSize = TextFieldAutoSize.LEFT;			
			clip.dialog.theText.text = message;
			
			clip.dialog.whiteBlock.height = clip.dialog.theText.textHeight + 6;
			clip.dialog.dialogBG.height = clip.dialog.whiteBlock.y + clip.dialog.whiteBlock.height + 40;
			
			TweenMax.to(clip, .5, { alpha:1 } );
			if (!keep) {
				hide();
			}
		}
		
		public function hide():void
		{
			TweenMax.to(clip, .5, { alpha:0, delay:3, onComplete:remove } );
		}
		
		private function remove():void
		{
			container.removeChild(clip);			
		}
	}
	
}