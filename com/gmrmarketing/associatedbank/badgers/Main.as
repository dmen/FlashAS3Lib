package com.gmrmarketing.associatedbank.badgers
{
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.CornerQuit;
	import com.gmrmarketing.utilities.queue.Queue;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.esurance.usopen2015.Print;
	
	public class Main extends MovieClip
	{
		private var mainContainer:Sprite;
		private var cornerContainer:Sprite;
		
		private var form:Form;
		private var take:TakePhoto;
		private var review:Review;
		private var thanks:Thanks;
		private var errorDialog:ErrorDialog;
		private var configCC:CornerQuit;
		private var cq:CornerQuit;
		private var queue:Queue;
		private var print:Print;
		
		
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
						
			print = new Print();
			
			cq = new CornerQuit();
			cq.init(cornerContainer, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, exitApp);
			
			queue = new Queue();
			queue.fileName = "abBadgersQueue";
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
			review.removeEventListener(Review.SAVE, showThanks);
			review.hide();
			
			form.removeEventListener(Form.FORM_ERROR, showError);
			form.hide();
			
			take.show();
			take.addEventListener(TakePhoto.CAPTURE_COMPLETE, showReview, false, 0, true);
		}
		
		
		private function showReview(e:Event):void
		{
			take.removeEventListener(TakePhoto.CAPTURE_COMPLETE, showReview);
			take.hide();
			
			review.show(take.userPics);
			review.addEventListener(Review.RETAKE, showTakePhoto, false, 0, true);
			review.addEventListener(Review.SAVE, showThanks, false, 0, true);
		}		
		
		
		private function showThanks(e:Event):void
		{
			review.removeEventListener(Review.RETAKE, showTakePhoto);
			review.removeEventListener(Review.SAVE, showThanks);		
			review.hide();
			
			thanks.addEventListener(Thanks.COMPLETE, reset, false, 0, true);
			thanks.show();			
			
			var qo:Object = form.data;
			qo.image = review.pic;
			
			print.doPrint(review.picData, review.numPrints);
			
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
		
		
		private function exitApp(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
	}
	
}