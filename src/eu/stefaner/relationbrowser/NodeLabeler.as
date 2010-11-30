package eu.stefaner.relationbrowser {
	import flare.vis.data.Data;
	import flare.vis.operator.label.RadialLabeler;

	import flash.text.TextFormat;

	/**
	 * @author mo
	 */
	public class NodeLabeler extends RadialLabeler {
		public function NodeLabeler(source : * = null, format : TextFormat = null, policy : String = "layer", textMode : uint = 1, filter : * = null, rotate : Boolean = false) {
			this.textMode = textMode;
			super(source, rotate, format, filter, policy);
			access = "labelSprite";
		}
	}
}
