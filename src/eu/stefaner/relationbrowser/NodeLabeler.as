package eu.stefaner.relationbrowser {
	import flare.vis.data.Data;
	import flare.vis.operator.label.Labeler;

	import flash.text.TextFormat;

	/**
	 * @author mo
	 */
	public class NodeLabeler extends Labeler {
		public function NodeLabeler(source : * = null, format : TextFormat = null, policy : String = "child", textMode : uint = 0, filter : * = null) {
			this.textMode = textMode;
			super(source, Data.NODES, format, filter, policy);
			access = "labelSprite";
			cacheText = false;
		}
	}
}
