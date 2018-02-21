// Decompiled by AS3 Sorcerer 5.64
// www.as3sorcerer.com

//com.gmrmarketing.katyperry.witness.HubbleServiceExtender

package com.gmrmarketing.katyperry.witness
{
    import com.gmrmarketing.utilities.queue.HubbleService;

    public class HubbleServiceExtender extends HubbleService 
    {

        public function HubbleServiceExtender()
        {
            super("gmrexp", "witness");
        }

        override public function send(_arg_1:Object):void
        {
            var _local_2:Object = {"MethodData":{
                    "InteractionId":556,
                    "FieldResponses":[]
                }};
            if (_arg_1.original.customer == true)
            {
                _local_2.MethodData.FieldResponses.push({
                    "FieldId":4863,
                    "OptionId":9519,
                    "Response":"Yes"
                });
            }
            else
            {
                _local_2.MethodData.FieldResponses.push({
                    "FieldId":4863,
                    "OptionId":9520,
                    "Response":"No"
                });
            };
            if (_arg_1.original.isEmail == true)
            {
                _local_2.MethodData.FieldResponses.push({
                    "FieldId":4867,
                    "Response":_arg_1.original.num
                });
            }
            else
            {
                _local_2.MethodData.FieldResponses.push({
                    "FieldId":4865,
                    "Response":_arg_1.original.num
                });
                _local_2.MethodData.FieldResponses.push({
                    "FieldId":4866,
                    "Response":_arg_1.original.opt
                });
            };
            _local_2.MethodData.FieldResponses.push({
                "FieldId":4868,
                "Response":_arg_1.original.part
            });
            _arg_1.photoFieldID = 0x1300;
            _arg_1.printed = false;
            _arg_1.responseObject = _local_2;
            super.send(_arg_1);
        }


    }
}//package com.gmrmarketing.katyperry.witness

