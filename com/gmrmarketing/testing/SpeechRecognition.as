package com.gmrmarketing.testing
{
	import flash.display.*;
	import flash.events.*;
	import flash.media.Microphone;
	import flash.media.SoundCodec;
	import flash.utils.ByteArray;
	import flash.filesystem.*;
	
	public class SpeechRecognition extends MovieClip
	{
		private var mic:Microphone;
		private var soundData:ByteArray;
		private var recording:Boolean = false;
		private var sample:Number = 0;
		private var currentAverage:Number = 0;
		private var sampleAverageCount:int = 0;
		private var hello:ByteArray;
		
		public function SpeechRecognition()
		{
			hello = new ByteArray();
			readFileIntoByteArray();//populates hello
			
			soundData = new ByteArray();
			mic = Microphone.getMicrophone();
			mic.rate = 44;
			mic.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
		}
		
		
		private function onSampleData( e:SampleDataEvent ):void 
		{
			currentAverage += mic.activityLevel;
			sampleAverageCount++;
			
			if (sampleAverageCount == 5) {
				currentAverage /= 5;
				sampleAverageCount = 0;
				if (currentAverage < 10 && recording) {
					recording = false;
					trace("recording done");
					//process();
					check();
				}
			}
			
			if (mic.activityLevel > 20 && !recording) {
				recording = true;
				trace("recording begin");
			}
			
			if(recording){
				while(e.data.bytesAvailable)
				{
					sample = e.data.readFloat();
					soundData.writeFloat(sample);
				}
			}
		}
		
		
		private function check():void
		{
			var tot:int = hello.length;
			var same:int;
			for (var i:int = 0; i < tot; i++) {
				if (Math.abs(hello[i] - soundData[i]) <= .5) {
					same++;
				}
			}
			soundData.clear();
			trace("similarity %:", Math.round(same / tot * 100));
		}
		
		
		private function process():void
		{
			mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			//trace("process", soundData.length, soundData[0]);
			
			writeBytesToFile();
			
			soundData.clear();
		}
		
		
		private function writeBytesToFile():void 
		{ 
			var outFile:File = File.desktopDirectory; // dest folder is desktop 
			outFile = outFile.resolvePath("speechRec/speechData.bin");  // name of file to write 
			var outStream:FileStream = new FileStream(); 
			// open output file stream in WRITE mode 
			outStream.open(outFile, FileMode.WRITE); 
			// write out the file 
			outStream.writeBytes(soundData, 0, soundData.length); 
			// close it 
			outStream.close(); 
		} 
		
		
		private function readFileIntoByteArray():void 
		{ 
			var inFile:File = File.desktopDirectory; // source folder is desktop 
			inFile = inFile.resolvePath("speechRec/hello.bin");  // name of file to read 
			var inStream:FileStream = new FileStream(); 
			inStream.open(inFile, FileMode.READ); 
			inStream.readBytes(hello); 
			inStream.close(); 
		} 
		
	}
	
}