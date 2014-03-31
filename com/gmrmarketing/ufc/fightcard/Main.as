package com.gmrmarketing.ufc.fightcard
{	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import com.gmrmarketing.ufc.fightcard.*;	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	
	
	public class Main extends MovieClip
	{		
		//flashvars set in init - from preloader
		private var fbID:String = "";
		private var lname:String = "";
		
		private var templates:TemplateChoices; //Choose your fight card		
		private var selectImage:SelectImage; //upload photo / use webcam
		private var outliner:Outliner; //cut out person from selected image
		private var preview:CardPreview; //finished card
		private var dialog:Dialog;
		//private var thanks:MovieClip; //complete clip from the library
		
		
		public function Main()
		{			
			templates = new TemplateChoices();			
			selectImage = new SelectImage();
			outliner = new Outliner();
			preview = new CardPreview();
			dialog = new Dialog();
			//thanks = new complete();
			
			//init();//TESTING ONLY - Called from preloader
		}
		
		//adds template picker - called from preloader
		//id and lname come from flashvars
		public function init(id:String = "", $lname:String = ""):void
		{
			if(id != ""){
				fbID = id;
				lname = $lname;
			}			
			preview.removeEventListener(CardPreview.CARD_COMPLETE, cardComplete);
			
			templates.addEventListener(TemplateChoices.TEMPLATE_PICKED, templatePicked, false, 0, true);
			templates.show(this);
		}		
		
		//adds image select
		private function templatePicked(e:Event):void
		{
			selectImage.addEventListener(SelectImage.SELECT_IMAGE_ADDED, imageSelectAdded, false, 0, true);
			selectImage.addEventListener(SelectImage.IMAGE_LOADED, imageLoaded, false, 0, true);
			selectImage.show(this, templates.getTemplate(), lname);
		}
		
		
		//removes headline picker
		private function imageSelectAdded(e:Event):void
		{
			templates.hide();
			templates.removeEventListener(TemplateChoices.TEMPLATE_PICKED, templatePicked);
			
			selectImage.removeEventListener(SelectImage.SELECT_IMAGE_ADDED, imageSelectAdded);
		}
		
		
		private function imageLoaded(e:Event):void
		{
			selectImage.removeEventListener(SelectImage.IMAGE_LOADED, imageLoaded);
			
			outliner.addEventListener(Outliner.OUTLINE_CLIP_ADDED, outlinerAdded, false, 0, true);
			outliner.addEventListener(Outliner.OUTLINE_DONE, outlineDone, false, 0, true);
			outliner.addEventListener(Outliner.OUTLINE_SHOW_PREVIEW, showOutlinePreview, false, 0, true);			
			outliner.addEventListener(Outliner.OUTLINE_RESTART, restartDialog, false, 0, true);
			
			outliner.reset();
			outliner.show(this, templates.getTemplate(), selectImage.getImage());
		}
		
		
		private function outlinerAdded(e:Event):void
		{
			selectImage.hide();
			outliner.removeEventListener(Outliner.OUTLINE_CLIP_ADDED, outlinerAdded);
		}
		
		
		private function outlineDone(e:Event):void
		{
			//don't remove listeners so we can go 'back' to refine mode
			/*
			outliner.removeEventListener(Outliner.OUTLINE_CLIP_ADDED, outlinerAdded);
			outliner.removeEventListener(Outliner.OUTLINE_DONE, outlineDone);
			outliner.removeEventListener(Outliner.OUTLINE_SHOW_PREVIEW, showOutlinePreview);
			outliner.removeEventListener(Outliner.OUTLINE_HIDE_PREVIEW, hideOutlinePreview);
			outliner.removeEventListener(Outliner.OUTLINE_RESTART, restartDialog);
			
			outliner.hide();
			*/
			
			preview.show(this, templates.getTemplate(), outliner.grabImage(), lname, fbID, false);
			preview.addEventListener(CardPreview.CLOSE_PREVIEW, hideOutlinePreview, false, 0, true);
			preview.addEventListener(CardPreview.CARD_COMPLETE, cardComplete, false, 0, true);	
		}
		
		/**
		 * Shows the card preview in refine mode
		 * @param	e OUTLINE_SHOW_PREVIEW Event
		 */
		private function showOutlinePreview(e:Event):void
		{
			preview.show(this, templates.getTemplate(), outliner.grabImage(), lname, "", true);
			preview.addEventListener(CardPreview.CLOSE_PREVIEW, hideOutlinePreview, false, 0, true);
			outliner.disableDrawing();//removes stage listeners while preview is showing
		}
		
		
		/**
		 * Hides the preview when in refine mode
		 * @param	e
		 */
		private function hideOutlinePreview(e:Event):void
		{
			//trace("Main.hideOutlinePreview");
			preview.hide();
			outliner.enableDrawing(); //adds stage listeners back
		}
		
		
		/**
		 * Called if the user presses restart in the refiner
		 * @param	e
		 */
		private function restartDialog(e:Event):void
		{
			dialog.show(this, "If you restart you will lose all current work", true);
			dialog.addEventListener(Dialog.DIALOG_OK, restartOK, false, 0, true);
			dialog.addEventListener(Dialog.DIALOG_CANCEL, restartCancelled, false, 0, true);
			outliner.disableDrawing();
		}
		
		
		private function restartOK(e:Event):void
		{
			dialog.removeEventListener(Dialog.DIALOG_OK, restartOK);
			dialog.removeEventListener(Dialog.DIALOG_CANCEL, restartCancelled);
			outliner.hide();
			init();
		}
		
		
		private function restartCancelled(e:Event):void
		{
			dialog.removeEventListener(Dialog.DIALOG_OK, restartOK);
			dialog.removeEventListener(Dialog.DIALOG_CANCEL, restartCancelled);
			outliner.enableDrawing();		
		}
		
		
		/**
		 * Called when Done is pressed in CardPreview
		 * @param	e CardPreview.CARD_COMPLETE event
		 */
		private function cardComplete(e:Event):void
		{
			dialog.show(this, "Your fight card is being submitted.", false, true);
			preview.addEventListener(CardPreview.CARD_SUBMITTED, cardSubmitted, false, 0, true);
			preview.sendToService();
		}
		
		private function cardSubmitted(e:Event):void
		{
			preview.removeEventListener(CardPreview.CARD_SUBMITTED, cardSubmitted);
			
			//addChild(thanks);
			//thanks.addEventListener(MouseEvent.CLICK, done, false, 0, true);
			
			dialog.hide();
			
			try {            
                navigateToURL(new URLRequest("/Home/ViewCard/" + fbID), "_self");
            }
            catch (e:Error) {
                // handle error here
            }
			//dialog.show(this, "Complete!", false);
			//dialog.addEventListener(Dialog.DIALOG_CLOSED, done, false, 0, true);
		}
		
		private function done(e:MouseEvent):void
		{			
			outliner.hide();
			init();
		}
	}
	
}