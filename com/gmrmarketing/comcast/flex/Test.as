package 
{
	import com.hairt.HairDraw;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class Test extends MovieClip 
	{
		private var hd:HairDraw;
		private var timerTest:Timer;
		private var ss:screenSaver; //lib clip
		
		
		public function Test()
		{
			ss = new screenSaver(); //lib clip			
			
			hd = new HairDraw(ss,0,0);
			//timerTest = new Timer(20000, 1);
			
			doStart();
		}
		
		private function doStop(e:TimerEvent):void
		{
			hd.turnOff();
			ss.logo.doStop();
			removeChild(ss);
			/*
			timerTest.reset();
			timerTest.removeEventListener(TimerEvent.TIMER, doStop);			
			timerTest.addEventListener(TimerEvent.TIMER, doStart, false, 0, true);
			timerTest.start();
			*/
		}
		
		
		private function doStart(e:TimerEvent = null):void
		{
			addChild(ss);
			/*
			timerTest.reset();
			timerTest.removeEventListener(TimerEvent.TIMER, doStart);
			timerTest.addEventListener(TimerEvent.TIMER, doStop, false, 0, true);
			timerTest.start();
			*/
			ss.logo.doStart();
			hd.turnOn();
		}
	}	
}