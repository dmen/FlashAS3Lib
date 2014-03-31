package com.gmrmarketing.sap.nba
{
	
	public class QuestionItem
	{
		public var Question:String;
		public var Answers:Array;//array of AnswerItems
		public var Type:String;		
		public var VideoFile:String;
		public var ImageFilename:String;
		
		public function QuestionItem()
		{
			Answers = new Array();
		}
		
		public function setVisible():void
		{
			for (var i:int = 0; i < Answers.length; i++) {
				AnswerItem(Answers[i]).IsHidden = false;
			}
		}
		
	}
}