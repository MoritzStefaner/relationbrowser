package eu.stefaner.relationbrowser.layout {
	import eu.stefaner.relationbrowser.ui.Node;

	import flare.query.methods.eq;
	import flare.vis.data.DataList;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.layout.Layout;

	import flash.display.DisplayObjectContainer;

	/**	 * @author mo	 */
	public class RadialLayout extends Layout {
		public var sortBy : Array;

		public function RadialLayout(sortBy : Array = null) {
			this.sortBy = sortBy ? sortBy : [];
			layoutType = Layout.POLAR;
		}

		protected override function layout() : void {
			// autoAnchor();
			var selectedNode : Node = (layoutRoot as Node);

			var r : Number = .5 * Math.max(visualization.bounds.width, visualization.bounds.height);

			visualization.data.nodes.setProperties({radius:r}, _t);
			_t.$(selectedNode).radius = .001;

			var innerRing : DataList = new DataList("inner");

			visualization.data.group("visibleNodes").visit(function(n : Node) : void {
				if (n == selectedNode) {
					return;
				} else if (n.props.distance == 1) {
					innerRing.add(n);
				}
			});
			innerRing.sortBy(sortBy);

			var angleInc : Number = (Math.PI * 2.0) / innerRing.length;
			var counter : uint = innerRing.length;
			var n : Node;
			var doZigZag : uint = 0;
			if (innerRing.length > 10) {
				doZigZag = 1;
			}
			// TODO: express as fraction of layoutBounds.width
			var innerRadius : Number = 240;
			var angle : Number;
			for each (n in innerRing) {
				_t.$(n).radius = innerRadius + doZigZag * ((counter % 2) * 2 - 1) * innerRadius / 6;
				angle = angleInc * counter--;
				_t.$(n).angle = angle;
				n.parent.addChild(n);
			}
		}
	}
}