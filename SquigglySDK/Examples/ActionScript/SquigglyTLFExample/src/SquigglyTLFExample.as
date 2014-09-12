package
{
	import flash.display.Sprite;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	
	import com.adobe.linguistics.spelling.SpellUIForTLF;
	
	public class SquigglyTLFExample extends Sprite
	{
		public function SquigglyTLFExample()
		{
			var markup:XML = <TextFlow xmlns='http://ns.adobe.com/textLayout/2008'><p><span>I know &nbsp;</span><span fontStyle='italic'>Enlish</span><span>. Use the context menu to see the suggestions of the missbelled word.</span></p></TextFlow>;
			var textFlow:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			textFlow.flowComposer.addController(new ContainerController(this, 500, 600));
			textFlow.flowComposer.updateAllControllers();
			
			textFlow.interactionManager = new EditManager();
			
			SpellUIForTLF.enableSpelling(textFlow, "en_US");
		}
	}
}