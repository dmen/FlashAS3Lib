package com.gmrmarketing.microsoft.halo5
{
	import com.gmrmarketing.utilities.AutoUpdate;
	import flash.desktop.NativeApplication;
	import flash.display.*;
	import flash.events.*;
	import com.gmrmarketing.utilities.queue.Queue;
	import com.gmrmarketing.utilities.CornerQuit;	
	import flash.net.SharedObject;
	import flash.utils.Timer;
	import flash.ui.Mouse;	
	
	
	public class Main extends MovieClip
	{
		private var mainContainer:Sprite;
		private var cornerContainer:Sprite;
		
		private var storeSelector:StoreSelector;
		private var selectArmor:SelectArmor;
		private var takePhoto:TakePhoto;
		private var modifyPhoto:ModifyPhoto;//head shape cutuout
		private var compositor:Compositor;//move cutout head into armor
		private var email:Email;
		private var thanks:Thanks;
		
		private var queue:Queue;
		private var authPoller:Timer;//polls queue every 3 seconds until the token is available
		private var msDef:MSDef; //once token is ready, this gets the store list
		private var so:SharedObject;//stores store list and selected store
		
		private var storeCorner:CornerQuit; //four taps upper right to open store selector
		private var quitCorner:CornerQuit;//four taps upper left to quit
		private var autoUpdate:AutoUpdate;
		private var dialogBox:DialogBox;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			mainContainer = new Sprite();
			addChild(mainContainer);
			
			cornerContainer = new Sprite();
			addChild(cornerContainer);
			
			storeSelector = new StoreSelector();
			storeSelector.container = mainContainer;
			
			selectArmor = new SelectArmor();
			selectArmor.container = mainContainer;
			
			takePhoto = new TakePhoto();
			takePhoto.container = mainContainer;
			
			modifyPhoto = new ModifyPhoto();
			modifyPhoto.container = mainContainer;
			
			compositor = new Compositor();
			compositor.container = mainContainer;
			
			email = new Email();
			email.container = mainContainer;
			
			thanks = new Thanks();
			thanks.container = mainContainer;
			
			queue = new Queue();
			queue.fileName = "msHalo5queue";
			queue.service = new HubbleServiceExtender();
			queue.start();
			
			msDef = new MSDef();
			
			so = SharedObject.getLocal("MSHalo5_storeList");
			//so.clear();
			
			storeCorner = new CornerQuit();
			storeCorner.init(cornerContainer, "ur");
			storeCorner.addEventListener(CornerQuit.CORNER_QUIT, showStoreSelector);
			
			quitCorner = new CornerQuit();
			quitCorner.init(cornerContainer, "ul");
			quitCorner.addEventListener(CornerQuit.CORNER_QUIT, quitApp);
			
			authPoller = new Timer(3000);
			
			autoUpdate = new AutoUpdate();
			autoUpdate.container = cornerContainer;
			autoUpdate.addEventListener(AutoUpdate.UPDATE_ERROR, showAutoUpdateError, false, 0, true);
			autoUpdate.init("http://design.gmrmarketing.com/microsoft/h5armor/autoupdate.xml");
			
			dialogBox = new DialogBox();
			dialogBox.container = cornerContainer;
		
			//if store selection is not made yet then wait for token and get definitions			
			if (so.data.storeSelection == undefined) {
				
				storeSelector.show("No store selected");//has default - downloading store list... text
				
				if(queue.serviceAuthData.AccessToken == ""){					
					authPoller.addEventListener(TimerEvent.TIMER, checkForToken, false, 0, true);
					authPoller.start();
				}else {
					checkForToken();
				}
			}else {
				//trace(so.data.storeSelection.id, so.data.storeSelection.label);
				showArmorSelector();
			}
			
		}
		
		
		private function checkForToken(e:TimerEvent = null):void
		{
			if (queue.serviceAuthData.AccessToken != "") {
				
				authPoller.stop();
				authPoller.removeEventListener(TimerEvent.TIMER, checkForToken);
				
				msDef.addEventListener(MSDef.COMPLETE, gotInteractionDefinitions, false, 0, true);
				msDef.addEventListener(MSDef.ERROR, interactionDefinitionError, false, 0, true);
				
				msDef.getInteractionDefinition(queue.serviceAuthData.AccessToken);
			}
		}
		
		
		private function gotInteractionDefinitions(e:Event = null):void
		{			
			msDef.removeEventListener(MSDef.COMPLETE, gotInteractionDefinitions);
			msDef.removeEventListener(MSDef.ERROR, interactionDefinitionError);
				
			so.data.storeList = msDef.data;
			so.flush();
			
			storeSelector.addEventListener(StoreSelector.COMPLETE, showArmorSelector, false, 0, true);
			storeSelector.showList(msDef.data);
		}
		
		
		//called by four taps at upper-right
		private function showStoreSelector(e:Event):void
		{
			if(so.data.storeSelection.label != undefined){
				storeSelector.show(so.data.storeSelection.label);
			}else {
				storeSelector.show("No store selected");
			}
			if(queue.serviceAuthData.AccessToken == ""){					
				authPoller.addEventListener(TimerEvent.TIMER, checkForToken, false, 0, true);
				authPoller.start();
			}else {
				checkForToken();
			}
		}		
		
		
		private function interactionDefinitionError(e:Event):void
		{
			msDef.removeEventListener(MSDef.COMPLETE, gotInteractionDefinitions);
			msDef.removeEventListener(MSDef.ERROR, interactionDefinitionError);			
			
		}
		
		
		private function showArmorSelector(e:Event = null):void
		{
			storeSelector.removeEventListener(StoreSelector.COMPLETE, showArmorSelector);
			storeSelector.hide();
			
			//save storeSelection in the sharedObject
			var o:Object = storeSelector.data;
			if(o.id != undefined){
				so.data.storeSelection = o;
				so.flush();
			}
			
			selectArmor.addEventListener(SelectArmor.COMPLETE, gotArmor, false, 0, true);
			selectArmor.show();
		}
		
		
		private function gotArmor(e:Event = null):void
		{
			selectArmor.removeEventListener(SelectArmor.COMPLETE, gotArmor);
			selectArmor.hide();
			
			takePhoto.addEventListener(TakePhoto.COMPLETE, gotPhoto, false, 0, true);
			takePhoto.show();
		}
		
		
		private function gotPhoto(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.COMPLETE, gotPhoto);
			takePhoto.hide();
			
			modifyPhoto.show(takePhoto.photo);
			modifyPhoto.addEventListener(ModifyPhoto.COMPLETE, cutoutComplete, false, 0, true);
			modifyPhoto.addEventListener(ModifyPhoto.RETAKE, retake, false, 0, true);
		}
		
		
		/**
		 * Called when modifyPhoto is COMPLETE - when head is done being cut out
		 * @param	e
		 */
		private function cutoutComplete(e:Event):void
		{
			modifyPhoto.removeEventListener(ModifyPhoto.COMPLETE, cutoutComplete);
			modifyPhoto.removeEventListener(ModifyPhoto.RETAKE, retake);
			//modifyPhoto.hide();
			modifyPhoto.suspend();//just removes enterframe/drawLines call
			
			compositor.addEventListener(Compositor.EDIT_SPLINE, editSpline, false, 0, true);
			//compositor.addEventListener(Compositor.COMPLETE, editingComplete, false, 0, true);
			compositor.addEventListener(Compositor.COMPLETE, showEmail, false, 0, true);
			compositor.show(modifyPhoto.headImage, selectArmor.armor);
		}
		
		
		private function retake(e:Event):void
		{
			modifyPhoto.removeEventListener(ModifyPhoto.COMPLETE, cutoutComplete);
			modifyPhoto.removeEventListener(ModifyPhoto.RETAKE, retake);
			modifyPhoto.hide();
			compositor.hide();
			gotArmor();
		}
		
		
		private function editSpline(e:Event):void
		{
			modifyPhoto.wake();//adds back enterFrame/drawLines call
			compositor.suspend();
			modifyPhoto.addEventListener(ModifyPhoto.COMPLETE, editSplineComplete, false, 0, true);
			modifyPhoto.addEventListener(ModifyPhoto.RETAKE, retake, false, 0, true);
		}
		
		
		private function editSplineComplete(e:Event):void
		{
			modifyPhoto.removeEventListener(ModifyPhoto.COMPLETE, editSplineComplete);
			modifyPhoto.suspend();//just removes enterframe/drawLines call
			compositor.wake(modifyPhoto.headImage);
		}
		
		
		private function showEmail(e:Event):void
		{
			modifyPhoto.hide();
			compositor.hide();
			compositor.removeEventListener(Compositor.EDIT_SPLINE, editSpline);
			//compositor.removeEventListener(Compositor.COMPLETE, editingComplete);
			
			email.addEventListener(Email.COMPLETE, processPhotos, false, 0, true);
			email.show();
		}
		
		
		//Thanks does the process of the images
		private function processPhotos(e:Event):void
		{
			email.removeEventListener(Email.COMPLETE, processPhotos);
			email.hide();
			
			thanks.addEventListener(Thanks.COMPLETE, sendToNowPik, false, 0, true);
			thanks.show(compositor.image);//cutout head and armor
		}
		
		
		private function sendToNowPik(e:Event):void
		{
			thanks.removeEventListener(Thanks.COMPLETE, sendToNowPik);
			thanks.hide();
			
			var o:Object = email.data; //object with email,optIn properties
			o.storeID = so.data.storeSelection.id;
			
			var pics:Object = thanks.images; //object with wide and square properties
			
			o.image = pics.wide;
			o.image2 = pics.square;
			
			queue.add(o);
			
			showArmorSelector();
		}
		
		
		private function showAutoUpdateError(e:Event):void
		{
			dialogBox.show(autoUpdate.error);
		}
		
		private function quitApp(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
				
	}
	
}