package com.gmrmarketing.associatedbank.mnwild
{
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.CornerQuit;
	import com.gmrmarketing.utilities.queue.Queue;
	import flash.desktop.NativeApplication;
	
	public class Main extends MovieClip
	{
		private var mainContainer:Sprite;
		private var cornerContainer:Sprite;
		
		private var form:Form;
		private var take:TakePhoto;
		private var review:Review;
		private var thanks:Thanks;
		private var errorDialog:ErrorDialog;
		private var configDialog:ConfigDialog;
		private var configCC:CornerQuit;
		private var cq:CornerQuit;
		private var queue:Queue;
		
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			//Mouse.hide();

			mainContainer = new Sprite();
			cornerContainer = new Sprite();
			
			addChild(mainContainer);
			addChild(cornerContainer);
			
			form = new Form();
			form.container = mainContainer;
			form.addEventListener(Form.COMPLETE, showTakePhoto, false, 0, true);
			
			take = new TakePhoto();
			take.container = mainContainer;
			
			review = new Review();
			review.container = mainContainer;
			
			thanks = new Thanks();
			thanks.container = mainContainer;
			
			errorDialog = new ErrorDialog();
			errorDialog.container = mainContainer;
			
			configDialog = new ConfigDialog();
			configDialog.container = mainContainer;
			
			configCC = new CornerQuit();
			configCC.init(cornerContainer, "ur");
			configCC.addEventListener(CornerQuit.CORNER_QUIT, showConfig);
			
			cq = new CornerQuit();
			cq.init(cornerContainer, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, exitApp);
			
			queue = new Queue();
			queue.fileName = "mnWildQueue";
			queue.service = new HubbleServiceExtender();
			queue.start();
			
			init();
		}
		
		
		private function init():void
		{
			form.addEventListener(Form.FORM_ERROR, showError, false, 0, true);
			form.show();
		}
		
		
		private function showTakePhoto(e:Event):void
		{
			review.removeEventListener(Review.RETAKE, showTakePhoto);
			review.removeEventListener(Review.SAVE, savePhoto);
			review.hide();
			
			form.removeEventListener(Form.FORM_ERROR, showError);
			form.hide();
			
			take.show(configDialog.data);
			take.addEventListener(TakePhoto.CAPTURE_COMPLETE, showReview, false, 0, true);
		}
		
		
		private function showReview(e:Event):void
		{
			take.removeEventListener(TakePhoto.CAPTURE_COMPLETE, showReview);
			take.hide();
			
			review.show(take.framesArray);
			review.addEventListener(Review.RETAKE, showTakePhoto, false, 0, true);
			review.addEventListener(Review.SAVE, savePhoto, false, 0, true);
		}
		
		
		private function savePhoto(e:Event):void
		{
			review.removeEventListener(Review.RETAKE, showTakePhoto);
			review.removeEventListener(Review.SAVE, savePhoto);
			review.addEventListener(Review.COMPLETE, showThanks, false, 0, true);
			
			var qo:Object = form.data;//only for saving gif locally - need email			
			review.process(qo.email);//send no param to disable local save of gif
		}
		
		
		private function showThanks(e:Event):void
		{
			review.removeEventListener(Review.COMPLETE, showThanks);			
			review.hide();
			
			thanks.addEventListener(Thanks.COMPLETE, reset, false, 0, true);
			thanks.show();			
			
			var qo:Object = form.data;
			qo.gif = review.GIF;
			
			queue.add(qo);
		}
		
		
		private function reset(e:Event):void
		{
			thanks.removeEventListener(Thanks.COMPLETE, reset);
			thanks.hide();
			
			init();			
		}
		
		private function showError(e:Event):void
		{
			errorDialog.show(form.error);
		}
		
		
		private function showConfig(e:Event):void
		{
			configDialog.show();
		}
		
		
		private function exitApp(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
	}
	
}