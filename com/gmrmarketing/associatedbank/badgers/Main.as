package com.gmrmarketing.associatedbank.badgers
{
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.CornerQuit;
	import com.gmrmarketing.utilities.queue.Queue;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.esurance.usopen2015.Print;
	import com.gmrmarketing.utilities.Logger;
	import com.gmrmarketing.utilities.LoggerAIR;
	import com.greensock.TweenMax;
	
	
	public class Main extends MovieClip
	{
		private var mainContainer:Sprite;
		private var cornerContainer:Sprite;
		
		private var form:Form_nov;
		private var take:TakePhoto;
		private var review:Review;
		private var thanks:Thanks;
		private var errorDialog:ErrorDialog;
		private var configCC:CornerQuit;
		private var cq:CornerQuit;
		private var queue:Queue;
		private var print:Print;
		private var log:Logger;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			//Mouse.hide();

			mainContainer = new Sprite();
			cornerContainer = new Sprite();
			
			addChild(mainContainer);
			addChild(cornerContainer);
			
			form = new Form_nov();
			form.container = mainContainer;
			form.addEventListener(Form_nov.COMPLETE, showTakePhoto, false, 0, true);
			
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
			
			log = Logger.getInstance();
			log.logger = new LoggerAIR();
			
			queue = new Queue();
			queue.fileName = "abBadgersQueue";
			queue.service = new HubbleServiceExtender_nov();
			queue.addEventListener(Queue.LOG_ENTRY, writeToLog);			
			queue.start();
			
			init();
		}
		
		
		private function writeToLog(e:Event):void
		{
			log.log(queue.logEntry);
		}
		
		
		
		private function init():void
		{
			form.addEventListener(Form_nov.FORM_ERROR, showError, false, 0, true);
			form.show();
		}
		
		
		private function showTakePhoto(e:Event):void
		{
			review.removeEventListener(Review.RETAKE, showTakePhoto);
			review.removeEventListener(Review.SAVE, showThanks);
			review.hide();
			
			form.removeEventListener(Form_nov.FORM_ERROR, showError);
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
			
			TweenMax.delayedCall(.2, sendData);
		}
		
		private function sendData():void
		{			
			var qo:Object = form.data;
			qo.image = review.makeString();
			
			trace("Main.sendData" + String(qo.image).substr(0,50));
			
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