package eu.stefaner.relationbrowser.layout {
	import eu.stefaner.relationbrowser.RelationBrowser;

	import flare.animate.Transitioner;
	import flare.util.Vectors;
	import flare.vis.data.DataList;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.filter.GraphDistanceFilter;

	import flash.utils.Dictionary;

	/**	 * @author mo	 */
	public class VisibilityFilter extends GraphDistanceFilter {
		public var visibleNodesGroupName : String;

		public function VisibilityFilter(visibleNodesGroupName : String, focusNodes : Array = null, distance : int = 1, links : int = 3) {
			super(Vectors.copyFromArray(focusNodes), distance, links);
			this.visibleNodesGroupName = visibleNodesGroupName;
		}

		public override function operate(t : Transitioner = null) : void {
			t = Transitioner.instance(t);
			visualization.data.nodes.setProperty("props.distance", null);
			// copy from GraphDistanceFilter
			// initialize breadth-first traversal
			var q : Array = [], depths : Dictionary = new Dictionary();
			for each (var fn:NodeSprite in focusNodes) {
				depths[fn] = 0;
				fn.visitEdges(function(e : EdgeSprite):void {
					depths[e] = 1;
					q.push(e);
				}, links);
			}
			// perform breadth-first traversal
			var xe : EdgeSprite, xn : NodeSprite, d : int;
			while (q.length > 0) {
				xe = q.shift();
				d = depths[xe];
				// -- fix to bug 1924891 by goosebumps4all
				if (depths[xe.source] == undefined) {
					xn = xe.source;
				} else if (depths[xe.target] == undefined) {
					xn = xe.target;
				} else {
					continue;
				}
				// -- end fix
				depths[xn] = d;
				if (d == distance) {
					xn.visitEdges(function(e : EdgeSprite):void {
						if (depths[e.target] == d && depths[e.source] == d) {
							depths[e] = d + 1;
						}
					}, links);
				} else {
					xn.visitEdges(function(e : EdgeSprite):void {
						if (depths[e] == undefined) {
							depths[e] = d + 1;
							q.push(e);
						}
					}, links);
				}
			}
			// now set visibility based on traversal results
			visualization.data.visit(function(ds : DataSprite):void {
				
				var visible : Boolean = (depths[ds] != undefined);
				var alpha : Number = visible ? 1 : 0;
				var obj : Object = t.$(ds);
				obj.alpha = alpha;
				
				if (ds is NodeSprite) {
					var ns : NodeSprite = ds as NodeSprite;
					ns.expanded = (visible && depths[ds] < distance);
					// added by mo
					if(depths[ds] != undefined) {
						if(ns.props.distance == null || depths[ds] < ns.props.distance) {
							ns.props.distance = depths[ds];
						}
					} else {
						ns.props.distance = distance + 1;
					}
					// end added
				}
				if (t.immediate) {
					ds.visible = visible;
				} else {
					obj.visible = visible;
				}
			});
			
			var dl : DataList = visualization.data.group(visibleNodesGroupName);
			dl.clear();
			
			visualization.data.nodes.visit(function(n : NodeSprite) : void {
				if((t.immediate && n.visible) || t.$(n).visible) {
					dl.add(n);
					/*					if(focusNodes.indexOf(n) > -1) {						n.props.distance = 0;					} else if(n.isConnected(focusNodes[0])) {						n.props.distance = 1;					} else {						n.props.distance = Math.max(2, Math.ceil(-n.props.doi));					}					 * */
				}
			});
			if(!(visualization as RelationBrowser).showInterConnections && !(visualization as RelationBrowser).showOuterEdges) {
				visualization.data.edges.setProperty("alpha", function(e : *):Boolean {
					return e.source.props.distance * e.target.props.distance == 0;
				}, t);
			}
		}
	}
}