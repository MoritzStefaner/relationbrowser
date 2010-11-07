package eu.stefaner.relationbrowser {
	import flare.display.TextSprite;
	import flare.vis.data.Data;
	import flare.vis.operator.label.Labeler;

	import flash.text.TextFormat;

	/**
	 * @author mo
	 */
	public class NodeLabeler extends Labeler {
		public function NodeLabeler(source : * = null, format : TextFormat = null, policy : String = LAYER, textMode : int = TextSprite.BITMAP, filter : * = null) {
			super(source, Data.NODES, format, filter, policy);
			this.textMode = textMode;
			access = "labelSprite";
		}
	}
}
