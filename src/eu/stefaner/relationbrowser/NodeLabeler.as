package eu.stefaner.relationbrowser {
	import flare.display.TextSprite;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.operator.label.Labeler;

	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	/**
	 * @author mo
	 */
	public class NodeLabeler extends Labeler {
		public function NodeLabeler(source : * = null, format : TextFormat = null, filter : * = null, policy : String = LAYER) {
			super(source, Data.NODES, format, filter, policy);
			access = "labelSprite";
		}

		override protected function onMouseClick(event : MouseEvent) : void {
			if ( event.target is TextSprite ) {
				if ( clickHandler != null ) {
					clickHandler(event.target);
				}
			}
			if ( event.target is DataSprite ) {
				if ( clickHandler != null ) {
					var label : TextSprite = _access.getValue(event.target);

					if ( label != null ) {
						if ( label.hitTestPoint(event.stageX, event.stageY) )
							clickHandler(label);
					}
				}
			}

			if (stopEvent == true) {
				event.stopImmediatePropagation();
				stopEvent = false;
			}
		}
	}
}
