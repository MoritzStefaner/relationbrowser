package eu.stefaner.relationbrowser.layout {
	import eu.stefaner.relationbrowser.RelationBrowser;
	import eu.stefaner.relationbrowser.ui.Node;

	import flare.vis.data.DataList;
	import flare.vis.operator.layout.Layout;

	/**	 * @author mo	 */
	public class RadialLayout extends Layout {
		public var sortBy : Array;

		public function RadialLayout(sortBy : Array = null) {
			this.sortBy = sortBy ? sortBy : [];
			layoutType = Layout.POLAR;
		}

		protected override function layout() : void {
			autoAnchor();
			var selectedNode : Node = (layoutRoot as Node);

			var r : Number = .5 * Math.max(layoutBounds.width, layoutBounds.height);
			visualization.data.nodes.setProperties({origin:_anchor});
			visualization.data.nodes.setProperties({radius:r}, _t);
			_t.$(selectedNode).radius = .001;

			var innerRing : DataList = new DataList("inner");

			visualization.data.group(RelationBrowser.VISIBLE_NODES).visit(function(n : Node) : void {
				if (n == selectedNode) {
					return;
				} else if (n.props.distance == 1) {
					innerRing.add(n);
				}
			});

			try {
				innerRing.sortBy(sortBy);
			} catch(error : Error) {
			}

			var angleInc : Number = (Math.PI * 2.0) / innerRing.length;
			var counter : uint = innerRing.length;
			var n : Node;
			var doZigZag : uint = 0;
			if (innerRing.length > 10) {
				doZigZag = 1;
			}
			// TODO: express as fraction of layoutBounds.width
			var innerRadius : Number = layoutBounds.width * .33;
			var angle : Number = 0;
			for each (n in innerRing) {
				_t.$(n).radius = innerRadius + doZigZag * ((counter % 2) * 2 - 1) * innerRadius / 6;
				angle = Math.PI * .5 + angleInc * counter--;
				_t.$(n).angle = angle;
				n.parent.addChild(n);
			}
		}
	}
}