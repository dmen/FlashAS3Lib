package com.gmrmarketing.crest
{
	import flash.display.LoaderInfo; //for flashvars
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;	
	import flash.display.Sprite;
	import fl.motion.Color;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	import flash.display.Loader;
	import flash.system.LoaderContext;
	import flash.events.*;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	import flash.geom.Matrix;
	
	import com.blurredistinction.validators.EmailValidator;
	
	
	
	public class Mosaic4k extends MovieClip
	{				
		private var tiles:Array;
		private var tileLoader:Loader;
		private var context:LoaderContext; 
		private var userImage:Loader;
		private var userHolder:userImageContainer; //library clip
		
		private var userTileX:int;
		private var userTileY:int;
		
		private const SERVER_TILE_WIDTH:int = 40; //individual tile size in the catalog image
		private const SERVER_TILE_HEIGHT:int = 30;
		
		private const TOTAL_TILES:int = 10600; //minimum number of tiles to use - if there are less tiles in the
		//catalog then they will be duplicated.
		private const TILES_PER_ROW:int = 124; //4960 / 40 (tiles are 40x30)
		
		private var tileWidth:int = 7; //average tile size
		private var tileHeight:int = 5;
		
		private var catX:int; //position in the tile catalog
		private var catY:int;
		private var curX:int; //position in mosaic
		private var curY:int;
		private var imX:int; //position on stage for placing tiles
		private var imY:int;
		
		private var mosaic:BitmapData; //library mosaic image to get average colors from
		private var targetImage:BitmapData;//blank 4000 x 3000 image to copy tiles into
		private var tileRect:Rectangle;
		private var tilePoint:Point;		
	
		private var tileCatalog:Bitmap; //image of the master tile image
		
		private var drawTimer:Timer;		
		
		private var tile:BitmapData;
		private var zeroPoint:Point = new Point(0, 0);
		
		private var tint:Color;		
		
		private var points:Array;
		private var pointIndex:int;
		
		//private var eighteen:eighteenCheck; //library clip
		
		private var zoomSlider:theSlider; //lib clip
		private var xZoomRatio:Number;
		private var yZoomRatio:Number;
		private var sliderStart:int;		
		
		private var target:Bitmap;
		
		private var scaleMatrix:Matrix;
		
		private var tileList:XMLList;
		private var tileXMLLoader:URLLoader = new URLLoader();		
		
		private var percentDialog:indicator; //library clip
		
		//crosshairs
		private var horizHair:hLine; //library clips
		private var vertHair:vLine;
		
		private var mainContainer:Sprite;
		private var imBorder:bord; //library clip
		private var grayOut:theGrayer; //library clip - big black rect for overlaying the mosaic then the user pic is up
		
		private var queryCode:String; //incoming flashvar barcode if the user came here from an email link
		private var userCode:String; //either the email from the query parameter or the picture ID entered in the field
		//assigned in retrieveCode()
		private var emailLoader:URLLoader;
		private var rejectLoader:URLLoader;
		
		//for panning
		//mouse offsets to image loc
		private var deltaX:int;
		private var deltaY:int;
		
		private var overlay:logos; //lib clip of crest oralb logo
		private var addOverlay:Boolean; //set in retrieveCode
		
		//private var jpgEncode:JPGEncoder;
		//private var jpgStream:ByteArray;
		private const SCALE_POINT:Point = new Point(442, 264); //mosaic image center
		
		private var theScaleX:Number;
		private var theScaleY:Number;
		private var initMouseX:int;
		private var initMouseY:int;
		
		private var emVal:EmailValidator = new EmailValidator();
		
		private var friendImage:Boolean; //true if the incoming id is set - so link came from the send a friend
		//hide the email fields in the user image holder - set in retrieveCode()
		
		private var codeSlider:userCodeInput; //library clip
		
		private var theDialog:dialog; //library clip - invalid DOB text on frame 2, we're sorry text on frame 1
		
		private var theStates:Array = new Array("Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","District of Columbia","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming");
		private var stateDialog:stateSelector; //library clip
		private var stateDragRatio:Number;
		private var stateContainer:Sprite;
		private var userSelectedState:String = "";
		
		
		
		public function Mosaic4k() 
		{	
			//flashvar for emailed barcode
			queryCode = "";			
			if (loaderInfo.parameters.id != undefined) {
				queryCode = loaderInfo.parameters.id;
				userSelectedState = "Alabama"; //set state so dialog doesn't appear
			}			
			
			overlay = new logos(); //overlay for uploaded images only - codes that are an email
			overlay.x = 5;
			overlay.y = 283;
			
			tileLoader = new Loader(); //master tile catalog image from server
			context = new LoaderContext();
			context.checkPolicyFile = true; 
			tile = new BitmapData(SERVER_TILE_WIDTH, SERVER_TILE_HEIGHT);
						
			userImage = new Loader();	
			
			grayOut = new theGrayer();
			
			userHolder = new userImageContainer(); //library clip to hold large user image
			userHolder.yourName.maxChars = 20;
			userHolder.friendName.maxChars = 20;
			userHolder.yourEmail.maxChars = 30;
			userHolder.friendEmail.maxChars = 30;
			
			theDialog = new dialog(); //library clip - the minimum eligibility requirements dialog
			theDialog.x = 267;
			theDialog.y = 205;
			
			stateDialog = new stateSelector(); //library clip
			stateDialog.x = 716;
			stateDialog.y = 20;
			
			mosaic = new mosaicBmd(880, 448); //library image
			
			codeSlider = new userCodeInput();
			
			zoomSlider = new theSlider(); //library clip
			zoomSlider.alpha = 0;
			zoomSlider.x = 627;
			zoomSlider.y = 484;
			zoomSlider.alpha = 0;
			
			//crosshairs
			horizHair = new hLine();
			vertHair = new vLine();			
			
			//empty, black image on stage
			mainContainer = new Sprite(); //contains mosaic and cross hairs - so all three can be masked with one mask
			targetImage = new BitmapData(4960, 2525, true, 0x000000);
			target = new Bitmap(targetImage);			
			mainContainer.addChild(target);
			target.x = 3;
			target.y = 40;
			
			deltaX = 442 - target.x;
			deltaY = 264 - target.y;			
			
			target.scaleX = .178; //to fit to 883 x 448 : 883 / 4960 = .17802
			target.scaleY = .178; //448 / 2525 = .1774					
			
			var mosmask = new mosMask();
			mosmask.x = 1;
			mosmask.y = 40;
			addChild(mosmask);
			//mosmask.visible = false;
			mainContainer.mask = mosmask; 
			addChild(mainContainer);		
			
			imBorder = new bord();
			addChild(imBorder);
			imBorder.x = 1;
			imBorder.y = 41;
			
			tint = new Color();
			
			tilePoint = new Point();
			scaleMatrix = new Matrix(); //used for scaling the mosaic tiles
			scaleMatrix.scale(SERVER_TILE_WIDTH / 6, SERVER_TILE_HEIGHT / 4);
			
			addChild(zoomSlider);
			
			//.00411 for 1 - .00911 for 2 - .00711 is as far a zoom as possible without having pan issues
			xZoomRatio = .00411; // (final scale - initial scale) / slider width = (1 - .178) / 200
			yZoomRatio = .00411;
			
			sliderStart = zoomSlider.slider.x;
			
			percentDialog = new indicator(); //library clip
			
			codeSlider.theCode.addEventListener(MouseEvent.CLICK, clearField, false, 0, true);
			codeSlider.btnGo.addEventListener(MouseEvent.CLICK, checkRejected, false, 0, true);			
			codeSlider.btnGo.buttonMode = true;
			
			loadTileImage("http://media2.radweblive.com/CrestMosaic/Mosaic.jpg?r=" + new Date().getDay());
			
			//This does not work in FireFox with wmode = transparent - does work in IE
			stage.addEventListener(Event.MOUSE_LEAVE, stopPanDrag);
			
			buildStateDialog();
		}
		
		
		/**
		 * Populates the state dialog with the list of state names
		 */
		private function buildStateDialog():void
		{
			var sy:int = 0; //starting y of the state fields within the state container

			stateContainer = new Sprite();
			stateContainer.name = "stateContainer";
			stateContainer.x = 4;
			stateContainer.y = 20;
			
			for (var i:int = 0; i < theStates.length; i++){
				var m:MovieClip = new aState();
				m.theText.text = theStates[i];
				m.name = theStates[i];
				m.hiliter.alpha = 0;
				m.hiliter.addEventListener(MouseEvent.MOUSE_OVER, showStateHilite, false, 0, true);
				m.hiliter.addEventListener(MouseEvent.MOUSE_OUT, hideStateHilite, false, 0, true);
				m.hiliter.addEventListener(MouseEvent.CLICK, stateSelected, false, 0, true);
				m.x = 0;
				m.y = sy;
				stateContainer.addChild(m);
				sy += m.height;
			}
			
			stateDialog.addChild(stateContainer);
			
			var mas:MovieClip = new theStateMask(); //lib clip

			stateDialog.addChild(mas);
			mas.y = 20;
			stateContainer.mask = mas;

			stateDragRatio = (stateContainer.height - mas.height) / (stateDialog.track.height - stateDialog.dragger.height);			
		}
		
		
		/**
		 * Called from click on code field from clearField()
		 */
		private function showStateDialog():void
		{
			if (!contains(stateDialog)) { addChild(stateDialog); }
			stateDialog.dragger.addEventListener(MouseEvent.MOUSE_DOWN, beginStateDragging, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, endStateDragging, false, 0, true);
		}
		
		/**
		 * State dialog event handlers		 
		 */
		private function showStateHilite(e:MouseEvent):void
		{
			TweenLite.to(e.currentTarget, .5, {alpha:.3});
		}
		private function hideStateHilite(e:MouseEvent):void
		{
			TweenLite.to(e.currentTarget, .5, {alpha:0});
		}
		private function stateSelected(e:MouseEvent):void
		{
			userSelectedState = e.currentTarget.parent.name;
			removeChild(stateDialog);
			if (userSelectedState == "Maine") {
				showRequirementsDialog();
			}
			stage.focus = codeSlider.theCode;
			stateDialog.dragger.removeEventListener(MouseEvent.MOUSE_DOWN, beginStateDragging);
			stage.removeEventListener(MouseEvent.MOUSE_UP, endStateDragging);
		}
		private function beginStateDragging(e:MouseEvent):void
		{			
			stateDialog.dragger.startDrag(false, new Rectangle(stateDialog.track.x + 1, stateDialog.track.y + 1, 0, stateDialog.track.height - stateDialog.dragger.height - 2));
			addEventListener(Event.ENTER_FRAME, updateStates, false, 0, true);
		}
		private function endStateDragging(e:MouseEvent):void
		{			
			stateDialog.dragger.stopDrag();
			removeEventListener(Event.ENTER_FRAME, updateStates);			
		}
		private function updateStates(e:Event):void
		{
			stateContainer.y = 20 - ((stateDialog.dragger.y - stateDialog.track.y) * stateDragRatio);
		}
		
		
		
		/**
		 * Called from MouseDown on mosaic
		 * listener added in showCodeSlider() once the mosaic is complete
		 * @param	e
		 */
		private function beginPan(e:MouseEvent):void
		{
			//offset to upper left corner - used by panImage()
			deltaX = mouseX - target.x;			
			deltaY = mouseY - target.y;
			
			addEventListener(Event.ENTER_FRAME, panImage, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, endPan, false, 0, true);
		}
		
		
		
		/**
		 * Called by enter frame when the mouse is down on the mosaic
		 * listener added in beginPan()
		 * @param	e
		 */
		private function panImage(e:Event = null):void
		{
			var curX:int = mouseX - deltaX;
			var curY:int = mouseY - deltaY;			
	
			if(curX <= 3 && curX + target.width >= 884){			
				target.x = curX;
			}
			//init loc y + height = 488
			if(curY <= 40 && curY + target.height >= 488){
				target.y = curY;
			}
			
		}
		
	
		/**
		 * called by mouseDown on zoom slider
		 * listener added in constructor
		 * @param	e
		 */
		private function beginDrag(e:MouseEvent):void
		{
			addEventListener(Event.ENTER_FRAME, dragSlider, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, endDrag, false, 0, true);
		}
		
		/**
		 * Called when user clicks on the slider bar in the zoom area
		 * @param	e
		 */
		private function zoomClick(e:MouseEvent):void
		{
			dragSlider();
		}
		private function dragSlider(e:Event = null):void
		{
			if(zoomSlider.mouseX >= 9 && zoomSlider.mouseX <= 209){
				zoomSlider.slider.x = zoomSlider.mouseX;
			}
			
			var delta:Number = zoomSlider.slider.x - sliderStart;				
			var sx:Number = delta * xZoomRatio + .178; //initial scaleX and scaleY are .178
			var sy:Number = delta * yZoomRatio + .178;	//varies .178 - 1			
			
			target.scaleX = sx;
			target.scaleY = sy;
			
			//subtract original deltas * scale - maintains the same distance /zoom ratio as
			//when the pan was ended
			target.x = SCALE_POINT.x - ( deltaX * sx );
			target.y = SCALE_POINT.y - ( deltaY * sy );
			
			//make sure image stays on screen
			if (target.x > 3) { target.x = 3; }
			if (target.x + target.width < 884) { target.x = 884 - target.width; }
			if (target.y > 40) { target.y = 40; }
			if (target.y + target.height < 488) { target.y = 488 - target.height; };			
		}
		
		/**
		 * Called if the mouse leaves the stage
		 * @param	e
		 */
		private function stopPanDrag(e:Event):void
		{
			//trace("stopPanDrag");
			endPan();
			endDrag();
		}

		private function endPan(e:MouseEvent = null):void
		{		
			var delta:Number = zoomSlider.slider.x - sliderStart;				
			var sx:Number = delta * xZoomRatio + .178; //initial scaleX and scaleY are .178
			var sy:Number = delta * yZoomRatio + .178;	//varies .178 - 1
			
			//scale point to image upper left / current zoom/scale level = distance / zoom ratio
			//keep the same while scaling to maintian alignment to the scale point
			deltaX = (SCALE_POINT.x - target.x) / sx;
			deltaY = (SCALE_POINT.y - target.y) / sy;			
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, endPan);
			removeEventListener(Event.ENTER_FRAME, panImage);
		}
		
		
		
		private function endDrag(e:MouseEvent = null):void
		{			
			stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
			removeEventListener(Event.ENTER_FRAME, dragSlider);			
		}
		
		
		/**
		 * Called from Constructor - loads the tile catalog
		 * @param	url - tile catalog url
		 */
		public function loadTileImage(url:String):void
		{	
			addChild(percentDialog);
			percentDialog.x = 358;
			percentDialog.y = 230;
			percentDialog.theText.text = "loading images";
			percentDialog.bar.scaleX = 0;
			
			tileLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, tilesLoaded, false, 0, true);
			tileLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progress, false, 0, true);
			tileLoader.load(new URLRequest(url), context);
		}
		
		
		private function progress(e:ProgressEvent):void
		{
			var percentDownloaded = e.bytesLoaded / e.bytesTotal;
			percentDialog.bar.scaleX = percentDownloaded;			
		}
		
		
		private function xmlProgress(e:ProgressEvent):void
		{
			var percentDownloaded = e.bytesLoaded / e.bytesTotal;
			percentDialog.bar.scaleX = percentDownloaded;
		}
		
		
		private function xmlLoaded(e:Event):void
		{			
			tileXMLLoader.removeEventListener(Event.COMPLETE, xmlLoaded);
			tileXMLLoader.removeEventListener(ProgressEvent.PROGRESS, xmlProgress);
			tileList = new XML(e.target.data).photo;			
			
			removeChild(percentDialog);			
			
			generateMosaic();
		}		
		
		
		/**
		 * Called when master tile catalog is done loading
		 * loads the xml data containing the codes for each tile
		 * @param	e
		 */
		private function tilesLoaded(e:Event):void
		{
			tileCatalog = e.target.content;
			tileLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, tilesLoaded);
			tileLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);		
			
			percentDialog.theText.text = "loading data";
			
			tileXMLLoader.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);
			tileXMLLoader.addEventListener(ProgressEvent.PROGRESS, xmlProgress, false, 0, true);
			tileXMLLoader.load(new URLRequest("http://media2.radweblive.com/CrestMosaic/Mosaic.xml?r="+ new Date().getHours()));			
		}
		
		
		/**
		 * Called when the user code field is clicked on
		 * @param	e
		 */
		private function clearField(e:MouseEvent):void
		{			
			codeSlider.theCode.text = "";
			
			//need to show state selector if user has not selected their state
			if(userSelectedState == ""){
				showStateDialog();
			}
		}
		
		
		private function checkRejected(e:MouseEvent = null):void
		{
			if (e == null) {
				userCode = queryCode;				
			}else {
				userCode = codeSlider.theCode.text;				
			}
			//trace("checking", userCode);
			if (userCode == "" || userCode == "Invalid Code") {
				retrieveCode(false);
			}else{
				var request:URLRequest = new URLRequest("http://crestmosaic.gmrmarketing.com/CheckRejected.axd");
				
				rejectLoader = new URLLoader();
				rejectLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
				
				var variables:URLVariables = new URLVariables();
				variables.search = userCode;
				
				request.data = variables;
				request.method = URLRequestMethod.GET;
				
				rejectLoader.addEventListener(Event.COMPLETE, gotRejected, false, 0, true);	
				rejectLoader.load(request);	
			}
		}
		
		private function gotRejected(e:Event):void
		{
			//trace("got", rejectLoader.data.success);
			if (rejectLoader.data.success == "true") {
				retrieveCode();
			}else {
				retrieveCode(false);
			}
		}
		
		/**
		 * Gets the index of the tile in the mosaic
		 * Called from clicking the go button near the code input field
		 * if e is null, then this was called from drawTile when the mosaic is done building
		 * because queryCode has a value - ie the page was accessed from the send to a friend link		 
		 */
		private function retrieveCode(isValid:Boolean = true):void
		{
			//trace("retrieveCode", isValid);
			var ind:int = -1;
			var l:int = tileList.length();
			for (var i:int = 0; i < l; i++) {
				var codes:Array = tileList[i].barcodes.split(",");
				if (codes.indexOf(userCode) != -1) {					
					ind = i;					
					break;
				}
			}
			
			//if userCode contains an @ sign - then it's an email so it was uploaded - and doesn't have an overlay
			addOverlay = userCode.indexOf("@") == -1 ? false : true;			
			
			if (ind == -1 || isValid == false) {
				codeSlider.theCode.text = "Invalid Code";
			}else {		
				//found code - user entered in field - check state
				if(userSelectedState == ""){
					showStateDialog();
				}else{
					retrieveImage(ind);
				}					
			}			
		}
		
		
		private function retrieveImage(ind:int):void
		{
			//make sure all of the mosaic is in view
			zoomSlider.slider.x = 9;
			dragSlider();
			
			var col:int = ind % TILES_PER_ROW;
			var row:int = Math.floor(ind / TILES_PER_ROW);
			
			var xLoc:int = col * tileWidth;
			var yLoc:int = row * tileHeight;			
			
			showCrosshairs(xLoc, yLoc);
			
			userImage.unload();
			userImage.load(new URLRequest(tileList[ind].url));
			userImage.contentLoaderInfo.addEventListener(Event.COMPLETE, addImageToHolder, false, 0, true);
			
			//reset state after user has found their image
			userSelectedState = "";
			
			//hide code slider when big image is up
			hideCodeSlider();
		}
		
		
		/**
		 * Called when the downloaded user image is ready
		 * @param	e COMPLETE event
		 */
		private function addImageToHolder(e:Event):void
		{
			var bit:Bitmap = e.target.content;
			if(bit != null){
				bit.smoothing = true;
			}
			
			userImage.contentLoaderInfo.removeEventListener(Event.COMPLETE, addImageToHolder);
			if(!userHolder.contains(userImage)){
				userHolder.addChild(userImage);
			}
			
			userImage.x = 4;
			userImage.y = 4;
			userImage.width = 517;
			userImage.height = 332;
			
			if (addOverlay) {
				userHolder.addChild(overlay);
			}			
		}
		
		
		
		/**
		 * Called from retrieveCode if the user entered code is found in the xml
		 * 
		 * @param	xTo coords of the user specific tile in the mosaic
		 * @param	yTo
		 */
		private function showCrosshairs(xTo:int, yTo:int):void
		{
			userTileX = xTo + 7; //add offset for mosaic stage starting position 3,40 plus 4,3 for centering on tile
			userTileY = yTo + 43;		
			
			if(!contains(horizHair)){
				mainContainer.addChild(horizHair);
				mainContainer.addChild(vertHair);
			}			
			//center
			horizHair.x = 443;
			horizHair.y = 245;
			vertHair.x = 443;
			vertHair.y = 245;
			horizHair.alpha = 1;
			vertHair.alpha = 1;
			
			//initial pulse
			TweenLite.to(horizHair, .2, { alpha:0} );
			TweenLite.to(vertHair, .2, { alpha:0} );
			TweenLite.to(horizHair, .2, { alpha:1, delay:.2, overwrite:0 } );
			TweenLite.to(vertHair, .2, { alpha:1, delay:.2, overwrite:0 } );
			//tile loc
			TweenLite.to(horizHair, 1.5, { x:userTileX, y:userTileY, delay:.4, overwrite:0 } );
			TweenLite.to(vertHair, 1.5, { x:userTileX, y:userTileY, delay:.4, overwrite:0 } );
			//pulse
			TweenLite.to(horizHair, .2, { alpha:0, delay:1.9, overwrite:0 } );
			TweenLite.to(vertHair, .2, { alpha:0, delay:1.9, overwrite:0 } );
			TweenLite.to(horizHair, .2, { alpha:1, delay:2.1, overwrite:0 } );
			TweenLite.to(vertHair, .2, { alpha:1, delay:2.1, overwrite:0 } );
			TweenLite.to(horizHair, .2, { alpha:0, delay:2.3, overwrite:0 } );
			TweenLite.to(vertHair, .2, { alpha:0, delay:2.3, overwrite:0 } );
			TweenLite.to(horizHair, .2, { alpha:1, delay:2.4, overwrite:0 } );
			TweenLite.to(vertHair, .2, { alpha:1, delay:2.5, overwrite:0, onComplete:fadeHairs} );
		}
		
		
		
		private function fadeHairs():void
		{
			TweenLite.to(horizHair, .2, { alpha:0 } );
			TweenLite.to(vertHair, .2, { alpha:0, onComplete:showUserImage } );	
		}
		
		
		
		/**
		 * Called by TweenLite onComplete once the crosshairs have been faded out
		 * Adds the userHolder and tweens it to full size
		 */
		private function showUserImage():void
		{
			mainContainer.removeChild(horizHair);
			mainContainer.removeChild(vertHair);			
			
			mainContainer.addChild(grayOut);
			grayOut.x = 1;
			grayOut.y = 40;
			grayOut.alpha = .6;
			
			addChild(userHolder);
			
			//if friendImage is true then coming from a send a friend link
			//hide the right hand email input from the userHolder
			var xTo:int = 66;
			if (friendImage) {
				userHolder.gotoAndStop(2);
				xTo += 115; //add 1/2 width of email fields on right so dialog is still centered
			}else {
				userHolder.gotoAndStop(1);
				userHolder.btnSend.addEventListener(MouseEvent.CLICK, checkEmail, false, 0, true);
				userHolder.btnSend.buttonMode = true;
			}
			
			userHolder.x = userTileX;
			userHolder.y = userTileY;
			userHolder.scaleX = userHolder.scaleY = .01;			
		
			TweenLite.to(userHolder, 1, { x:xTo, y:94, scaleX:1, scaleY:1 } );
			
			userHolder.xCover.addEventListener(MouseEvent.CLICK, closeUserImage, false, 0, true);
				
			userHolder.xCover.buttonMode = true;			
		}
		
		
		
		/**
		 * Called by clicking the x in the user image dialog
		 * @param	e
		 */
		private function closeUserImage(e:MouseEvent):void
		{
			userHolder.removeChild(userImage);
			if (userHolder.contains(overlay)) {
				userHolder.removeChild(overlay);
			}
			userHolder.xCover.removeEventListener(MouseEvent.CLICK, closeUserImage);
			if(!friendImage){
				userHolder.btnSend.removeEventListener(MouseEvent.CLICK, sendEmail);
			}
			userImage.unload();
			removeChild(userHolder);
			mainContainer.removeChild(grayOut);
			
			showCodeSlider();
		}
		
		
		
		/**
		 * Called by clicking the send button
		 * @param	e
		 */
		private function checkEmail(e:MouseEvent):void
		{
			
			if (!emVal.validate(userHolder.yourEmail.text)) {
				showError("Please enter a valid email");
			}else if (!emVal.validate(userHolder.friendEmail.text)) {
				showError("Please enter a valid friend's email");
			}else if (userHolder.yourName.text == "") {
				showError("Please enter your first name");
			}else if (userHolder.friendName.text == "") {
				showError("Please enter your friend's name");
			}else{
				sendEmail();
			}
		}
		
		
		/**
		 * Shows the msg in the userHolder.
		 * @param	msg
		 */
		private function showError(msg:String):void
		{
			userHolder.errorMsg.theText.text = msg;
			userHolder.errorMsg.alpha = 1;
			TweenLite.to(userHolder.errorMsg, 2, { alpha:0, delay:2 } );
		}
		
		
		
		
		/**
		 * Called from checkEmail if both email fields are populated
		 */
		private function sendEmail():void
		{
			var request:URLRequest = new URLRequest("http://crestmosaic.gmrmarketing.com/SendEmail.axd");
			
			emailLoader = new URLLoader();
			emailLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
			
			var variables:URLVariables = new URLVariables();
			variables.passKey = "p6px3jnym9im6cc7";
			variables.fromEmail = userHolder.yourEmail.text;
			variables.toEmail = userHolder.friendEmail.text;
			variables.fromName = userHolder.yourName.text;
			variables.toName = userHolder.friendName.text;
			variables.picUid = userCode; //code assigned in retrieveCode() - pic id or email from query param
			request.data = variables;
			request.method = URLRequestMethod.POST;
			
			emailLoader.addEventListener(Event.COMPLETE, emailSent, false, 0, true);
			emailLoader.addEventListener(IOErrorEvent.IO_ERROR, emailError, false, 0, true);
			
			emailLoader.load(request);		
		}
		
		
		
		/**
		 * Callbacks from sending email
		 * @param	e
		 */
		private function emailSent(e:Event):void		
		{
			if(emailLoader.data.success == "true"){
				showError("Email sent successfully.");
				userHolder.friendName.text = "";
				userHolder.friendEmail.text = "";
			}else {
				showError("Error - please try again.");
			}
		}
		
		
		private function emailError(e:IOErrorEvent):void
		{
			showError("Error - please try again.");
		}
		
		
		
		/**
		 * Called from drawTile() once the mosaic is finished
		 * shows the code input field at upper right and
		 * the zoom slider at lower left
		 */
		private function showCodeSlider():void
		{
			if (!contains(codeSlider)) {
				addChildAt(codeSlider, 0);
			}
			codeSlider.x = 491;
			codeSlider.y = 49;
			
			TweenLite.to(codeSlider, .5, { y:3 } );
			TweenLite.to(zoomSlider, .5, { alpha:1 } );
			
			//enable zooming
			zoomSlider.slider.buttonMode = true;
			zoomSlider.slider.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag, false, 0, true);
			zoomSlider.zoomClick.buttonMode = true;
			zoomSlider.zoomClick.addEventListener(MouseEvent.CLICK, zoomClick, false, 0, true);
			
			//enable panning now too
			mainContainer.buttonMode = true;
			mainContainer.addEventListener(MouseEvent.MOUSE_DOWN, beginPan, false, 0, true);
		}
		
		
		
		private function hideCodeSlider():void
		{
			TweenLite.to(codeSlider, .5, { y:49 } );
		}
		
		
		/**
		 * Show the we're sorry, eligibility requirements, dialog
		 * Called from stateSelected if user selects Maine
		 */
		private function showRequirementsDialog():void
		{
			if (!contains(theDialog)) { 
				addChild(theDialog); 
			}
			theDialog.btnHome.buttonMode = true;
			theDialog.btnClose.buttonMode = true;
			theDialog.btnHome.addEventListener(MouseEvent.CLICK, goHome, false, 0, true);
			theDialog.btnClose.addEventListener(MouseEvent.CLICK, closeRequirements, false, 0, true);
			//hideCodeSlider();
			
			//reset state if user selected Maine
			userSelectedState = "";
		}
		
		private function goHome(e:MouseEvent):void
		{
			navigateToURL(new URLRequest("default.aspx"), "_self");
		}
		
		private function closeRequirements(e:MouseEvent):void
		{
			if (contains(theDialog)) { removeChild(theDialog); }
		}	
		
		
		
		/**
		 * Called from xmlLoaded()
		 */
		private function generateMosaic():void
		{			
			catX = 0; //x,y within the tile catalog image
			catY = 0;
			curX = 0; //x,y within mosaic for taking averages
			curY = 0;
			imX = 0; //x,y inside targetImage
			imY = 0;
			
			pointIndex = 0;
			
			drawTimer = new Timer(15);
			drawTimer.addEventListener(TimerEvent.TIMER, drawTile, false, 0, true);
			drawTimer.start();
		}
	
		
		/**
		 * Called every 15 milliseconds by timer
		 * @param	e
		 */
		private function drawTile(e:TimerEvent):void
		{		
			targetImage.lock();
			for (var i:int = 0; i < 79; i++){
				//tile is a bitmapdata with that is SERVER_TILE_WIDTH x SERVER_TILE_HEIGHT
				//ie one tile within the tile catalog
				tileRect = new Rectangle(catX, catY, SERVER_TILE_WIDTH, SERVER_TILE_HEIGHT);		
				tile.copyPixels(tileCatalog.bitmapData, tileRect, zeroPoint);
					
				//get a chunk from the mosaic for averaging
				var j:BitmapData = new BitmapData(tileWidth, tileHeight);			
				j.copyPixels(mosaic, new Rectangle(curX,  curY, tileWidth, tileHeight), zeroPoint);
				
				//set tint within the color object
				tint.setTint(averageRGB(j), .75);
				tint.alphaMultiplier = .7;
				
				//create a bitmap at server tile size and then draw catalog tile into it with tinting
				var tmp:BitmapData = new BitmapData(SERVER_TILE_WIDTH, SERVER_TILE_HEIGHT);
				tmp.draw(j, scaleMatrix);
				tmp.draw(tile, null, tint);
				
				//place tinted tile into targetImage
				targetImage.copyPixels(tmp, new Rectangle(0, 0, SERVER_TILE_WIDTH, SERVER_TILE_HEIGHT), new Point(imX, imY));			
				
				//increment catalog points
				catX += SERVER_TILE_WIDTH;
				if (catX >= tileCatalog.width) {
					catX = 0;
					catY += SERVER_TILE_HEIGHT;
					
					if (catY >= tileCatalog.height) {
						catY = 0;
						catX = 0;
					}
				}			
				
				//increment mosaic points
				curX += tileWidth;
				imX += SERVER_TILE_WIDTH;
				
				if (curX >= mosaic.width) {
					curX = 0;
					curY += tileHeight;
					
					imX = 0;
					imY += SERVER_TILE_HEIGHT;
				}
				
				pointIndex++;			
				
				if(pointIndex >= TOTAL_TILES){
					drawTimer.stop();
					drawTimer.removeEventListener(TimerEvent.TIMER, drawTile);					
					
					showCodeSlider();
					endPan(); //call end pan to set initial deltaX and deltaY values - makes image initially zoom to center
					
					if (queryCode != "") {
						checkRejected();
						//retrieveCode();					
					}
					
					break;
				}
			}
			targetImage.unlock();
		}
	
		
		
		private function averageRGB( source:BitmapData ):uint
		{
			var red:Number = 0;
			var green:Number = 0;
			var blue:Number = 0;			
			var count:int = 0;			
			var pixel:Number;
		 
			for (var x:int = 0; x < source.width; x++)
			{
				for (var y:int = 0; y < source.height; y++)
				{
					pixel = source.getPixel(x, y);
		 
					red += pixel >> 16 & 0xFF;
					green += pixel >> 8 & 0xFF;
					blue += pixel & 0xFF;					
					count++;
				}
			}
		 
			red /= count;
			green /= count;
			blue /= count;
			
			return red << 16 | green << 8 | blue;
		}
	}	
}