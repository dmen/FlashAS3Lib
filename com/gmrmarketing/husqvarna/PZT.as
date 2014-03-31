/**
 * Document class for pzt.fla
 */

package com.gmrmarketing.husqvarna
{	
	import flash.system.Security;
	import flash.display.Sprite;
	import flash.external.ExternalInterface; //for calling JS on the page
	
	import flash.utils.Timer;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	import flash.display.MovieClip;
	import flash.events.*;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.media.SoundMixer;	
	
	import com.greensock.TweenLite;
	import com.greensock.TimelineLite;
	import com.greensock.easing.*;

	import com.gmrmarketing.husqvarna.ViewSelector;
	import com.gmrmarketing.husqvarna.Features;
	import com.gmrmarketing.husqvarna.Mowers;
	import com.gmrmarketing.husqvarna.Detail2;
	import com.gmrmarketing.husqvarna.CircleMove;
	

	public class PZT extends MovieClip
	{
		//library clips
		private var allNew:textAllNew;
		/*
		private var the:textThe;
		private var all:textAll;
		private var tnew:textNew;
		private var husq:textHusqvarna;
		private var pzt:textPZT;
		*/
		private var durable:textDurable;
		private var reliable:textReliable;
		private var affordable:textAffordable;		
		private var music:musicDL;
		private var bgMask:bgMasker;
		private var gradBG:videoBG;	
		
		//for playing sounds
		private var channel:SoundChannel;
		private var vol:SoundTransform;
		
		//library sounds
		private var stampSound:metallicHit;
		private var buttonSound:buttonPop;
		
		//set from Preloader		
		private var xmlURL:String;		
		
		//classes		
		private var features:Features;
		private var views:ViewSelector;
		private var mowers:Mowers;
		private var detail:Detail;
		private var mower:MovieClip; //current mower clip
		
		
		//CONSTRUCTOR
		public function PZT()
		{
			Security.allowDomain("www.husqvarna.com");
			
			//testing only - comment for prodution
			go("features.xml");
		}
		
		
		/**
		 * Called from preloader once it receives imready event from init
		 * Receives the xml url from the preloader
		 *
		 * @param	$xmlURL
		 */
		public function go($xmlURL:String)
		{
			xmlURL = $xmlURL; //passed to features object
			
			vol = new SoundTransform();
			stampSound = new metallicHit();
			
			//music icon on front view
			music = new musicDL();
			music.x = 10;
			music.y = 107;
			music.rotation = -15;
			music.addEventListener(MouseEvent.CLICK, musicIconClicked, false, 0, true);
			music.buttonMode = true;			
			
			bgMask = new bgMasker();
			bgMask.x = 470;
			bgMask.y = 381;
			
			gradBG = new videoBG();
			
			var sc:Number = 3;
			
			allNew = new textAllNew();
			allNew.x = 470;
			allNew.y = 262;
			allNew.scaleX = allNew.scaleY = sc;
			allNew.alpha = 0;
			addChild(allNew);
			
			/*
			the = new textThe();
			the.x = 59;
			the.y = 262;
			the.scaleX = the.ScaleY = sc;
			the.alpha = 0;
			addChild(the);
			
			all = new textAll();
			all.x = 184;
			all.y = 262;
			all.scaleX = all.scaleY = sc;
			all.alpha = 0;
			addChild(all);
			
			tnew = new textNew();
			tnew.x = 324;			
			tnew.y = 262;
			tnew.scaleX = tnew.scaleY = sc;
			tnew.alpha = 0;
			addChild(tnew);
			
			husq = new textHusqvarna();
			husq.x = 601;
			husq.y = 262;
			husq.scaleX = husq.scaleY = sc;
			husq.alpha = 0;
			addChild(husq);
			
			pzt = new textPZT();
			pzt.x = 874;
			pzt.y = 262;
			pzt.scaleX = pzt.scaleY = sc;
			pzt.alpha = 0;
			addChild(pzt);
			*/
			
			durable = new textDurable();
			durable.x = 230;
			durable.y = 365;
			durable.scaleX = durable.scaleY = 2;
			durable.alpha = 0;
			addChild(durable);
			
			reliable = new textReliable();
			reliable.x = 714;
			reliable.y = 365;
			reliable.scaleX = reliable.scaleY = 2;
			reliable.alpha = 0;
			addChild(reliable);
			
			affordable = new textAffordable();
			affordable.x = 470;
			affordable.y = 450;
			affordable.scaleX = affordable.scaleY = 2;
			affordable.alpha = 0;
			addChild(affordable);
			
			views = new ViewSelector(this);
			views.addEventListener(ViewSelector.VIEW_CHANGED, viewChanged, false, 0, true);
			
			//xmlURL is passed in from the preloader movie
			features = new Features(this, xmlURL);
			features.addEventListener(Features.FEATURE_CLICKED, showDetail, false, 0, true);
			features.addEventListener(Features.BOTTOM_FEATURE_CLICKED, showDetailBottom, false, 0, true);
			
			detail = new Detail(this);
			
			mowers = new Mowers();
			
			var tl:TimelineLite = new TimelineLite( { onComplete:introPause } );
			
			tl.append(new TweenLite(allNew, .01, { alpha:1 }));
			tl.append(new TweenLite(allNew, .4, { scaleX:1, scaleY:1, delay:.1, ease:Bounce.easeOut }));
			/*
			tl.append(new TweenLite(the, .01, {alpha:1}));
			tl.append(new TweenLite(the, .4, {scaleX:1, scaleY:1, delay:.1, ease:Bounce.easeOut, onComplete:playStamp, onCompleteParams:[.2]}));
			tl.append(new TweenLite(all, .01, {alpha:1}));
			tl.append(new TweenLite(all, .4, {scaleX:1, scaleY:1, delay:.1, ease:Bounce.easeOut, onComplete:playStamp, onCompleteParams:[.2]}));
			tl.append(new TweenLite(tnew, .01, {alpha:1}));
			tl.append(new TweenLite(tnew, .4, {scaleX:1, scaleY:1, delay:.1, ease:Bounce.easeOut, onComplete:playStamp, onCompleteParams:[.2]}));
			tl.append(new TweenLite(husq, .01, {alpha:1}));
			tl.append(new TweenLite(husq, .4, {scaleX:1, scaleY:1, delay:.1, ease:Bounce.easeOut, onComplete:playStamp, onCompleteParams:[.2]}));
			tl.append(new TweenLite(pzt, .01, {alpha:1}));
			tl.append(new TweenLite(pzt, .4, { scaleX:1, scaleY:1, delay:.1, ease:Bounce.easeOut, onComplete:playStamp, onCompleteParams:[.2] } ));
			*/
			
			tl.append(new TweenLite(durable, .01, {alpha:1, delay:.3}));
			tl.append(new TweenLite(durable, .4, { scaleX:1, scaleY:1, delay:.1, ease:Bounce.easeOut, onComplete:playStamp, onCompleteParams:[.5] } ));
			tl.append(new TweenLite(reliable, .01, {alpha:1, delay:.3}));
			tl.append(new TweenLite(reliable, .4, { scaleX:1, scaleY:1, delay:.1, ease:Bounce.easeOut, onComplete:playStamp, onCompleteParams:[.5] } ));
			tl.append(new TweenLite(affordable, .01, {alpha:1, delay:.3}));
			tl.append(new TweenLite(affordable, .4, {scaleX:1, scaleY:1, delay:.1, ease:Bounce.easeOut, onComplete:playStamp, onCompleteParams:[1]}));
		}
		
		private function playStamp(v:Number):void
		{			
			vol.volume = v;
			channel = stampSound.play();
			channel.soundTransform = vol;
		}
		
		private function introPause():void
		{
			var a:Timer = new Timer(500, 1);
			a.addEventListener(TimerEvent.TIMER, spreadEm, false, 0, true);
			a.start();
		}
		
		
		/**
		 * Spreads the words apart and fades in the default mower view
		 * Calls showFeatures() on completion
		 */
		private function spreadEm(e:TimerEvent = null):void
		{		
			TweenLite.to(allNew, .75, {y:40, ease:Bounce.easeOut } );
			/*
			TweenLite.to(the, .75, { y:40, ease:Bounce.easeOut } );
			TweenLite.to(all, .75, { y:40, ease:Bounce.easeOut } );
			TweenLite.to(tnew, .75, { y:40, ease:Bounce.easeOut } );
			TweenLite.to(husq, .75, { y:40, ease:Bounce.easeOut } );
			TweenLite.to(pzt, .75, { y:40, ease:Bounce.easeOut } );
			*/
			
			TweenLite.to(durable, .75, { y:626, ease:Bounce.easeOut } );
			TweenLite.to(reliable, .75, {y:626, ease:Bounce.easeOut } );
			TweenLite.to(affordable, .75, {y:714, ease:Bounce.easeOut } );
			
			mower = mowers.getMower(views.getView());
			mower.x = mowers.getMowerX();
			mower.y = mowers.getMowerY();
			mower.alpha = 0;
			mower.scaleX = mower.scaleY = .8;
			
			addChild(mower);
			
			addChildAt(bgMask, 1);
			addChildAt(gradBG, 1);
			gradBG.mask = bgMask;
			bgMask.width = 0;
			
			TweenLite.to(bgMask, .3, { width:940, delay:.3 } );
			TweenLite.to(mower, .4, { alpha:1, delay:.6, scaleX:1, scaleY:1, ease:Bounce.easeOut, onComplete:showDefaultView} );
		}
		
		
		
		/**
		 * Called from TweenLite onComplete when spreadEm() is finished
		 * Places the features for the current view and shows the small view selector
		 */
		private function showDefaultView():void
		{
			if (features.showingMusic()) {
				addMusic();				
			}
			
			features.showFeaturesForView(views.getView());			
			views.showSelector();
		}
		
		
		private function addMusic():void
		{
			music.scaleX = music.scaleY = 2;
			music.alpha = 0;
			if(!contains(music)){
				addChild(music);
			}
			var tl:TimelineLite = new TimelineLite();
			tl.append(new TweenLite(music, .001, { alpha:1, delay:.5 } ));
			tl.append(new TweenLite(music, .5, { scaleX:1, scaleY:1, ease:Bounce.easeOut} ));
		}
		
		/**
		 * Called by CLICK listener on the feature icons
		 * 
		 * @param	e FEATURE_CLICKED Event
		 */
		private function showDetail(e:Event):void
		{			
			if (contains(music)) {
				removeChild(music);				
			}
			
			views.hideSelector();
			
			features.addEventListener(Features.FEATURES_REMOVED, featuresRemoved, false, 0, true);			
			features.clearFeatures();
			
			if (contains(mower)) {
				removeChild(mower);
			}			
		}
		
		
		
		private function featuresRemoved(e:Event):void
		{
			features.removeEventListener(Features.FEATURES_REMOVED, featuresRemoved);			
			
			detail.show(features.getFeatureData(), features.showingMusic());
			
			detail.addEventListener(Detail.DETAIL_CLOSE, closeClicked, false, 0, true);
			detail.addEventListener(Detail.MUSIC_CLICK, musicTabClicked, false, 0, true);
			
			features.showFeaturesAtBottom();
		}
		
		
		
		/**
		 * Called by CLICK listener on the bottom features
		 * @param	e BOTTOM_FEATURE_CLICKED Event
		 */
		private function showDetailBottom(e:Event):void
		{			
			var data:Object = features.getFeatureData();			
			detail.show(data, features.showingMusic());			
		}
		
		
		
		/**
		 * Called by listener when the close tab inside the detail clip is clicked on
		 * 
		 * @param	e DETAIL_CLOSE Event
		 */
		private function closeClicked(e:Event):void
		{
			detail.hide();
			features.killFeatures();
			views.showSelector();
			showNewView();
		}
		
		
		
		/**
		 * Called by listener on Detail when the music tab is clicked on
		 * 
		 * @param	e MUSIC_CLICK Event
		 */
		private function musicTabClicked(e:Event):void
		{
			openMusic();
		}
		private function musicIconClicked(e:Event):void
		{
			openMusic();
		}
		private function openMusic():void
		{	
			//var myURL:String = "javascript:window.open('" + features.getMusicURL() + "', 'windowname', 'width=500, height=400'); void(0);";			
			//navigateToURL(new URLRequest(myURL), "_self");	
			//var myURL:String = "javascript:window.open('" + features.getMusicURL() + "', 'windowname', 'width=500, height=400'); void(0);";			
			navigateToURL(new URLRequest(features.getMusicURL()), "_blank");
		}
		
		
		/**
		 * Called by listener on the views object
		 * Removes the features and fades out the mower
		 * calls showNewView() when finished
		 * 
		 * @param	e ViewSelector.VIEW_CHANGED event
		 */
		private function viewChanged(e:Event):void
		{
			if (contains(music)) {
				removeChild(music);				
			}
			features.killFeatures();
			TweenLite.to(mower, .25, { alpha:0, onComplete:showNewView } );			
		}
		
		
		
		/**
		 * Called by TweenLite from viewChanged once the mower has been faded out
		 */
		private function showNewView():void
		{		
			if(contains(mower)){
				removeChild(mower);
			}
			
			mower = mowers.getMower(views.getView());			
			mower.x = mowers.getMowerX();
			mower.y = mowers.getMowerY();
			mower.alpha = 0;
			mower.scaleX = mower.scaleY = .8;
			
			addChild(mower);			
			
			TweenLite.to(mower, .4, { alpha:1, delay:.3, scaleX:1, scaleY:1, ease:Bounce.easeOut} );
			
			features.showFeaturesForView(views.getView());
			
			if (views.getView() == "front" && features.showingMusic()) {
				addMusic();
			}
			
			views.bringToFront(); //brings the view selector above the mower			
		}
		
	}
	
}