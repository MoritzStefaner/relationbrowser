﻿package eu.stefaner.relationbrowser.layout {
	import eu.stefaner.relationbrowser.RelationBrowser;

	import flare.animate.Transitioner;
	import flare.query.Expression;
	import flare.vis.data.DataList;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.filter.GraphDistanceFilter;

	import flash.utils.Dictionary;

	/**	 * @author mo	 */
	public class VisibilityFilter extends GraphDistanceFilter {
		public static const MODE_SHOW_ALL : String = "MODE_SHOW_ALL";
		public static const MODE_SHOW_NEIGHBORHOOD : String = "MODE_SHOW_NEIGHBORHOOD";
		public var visibleNodesGroupName : String;
		public var mode : String = "MODE_SHOW_ALL";
		public var filter : *;

		public function VisibilityFilter(visibleNodesGroupName : String, focusNodes : Array = null, distance : int = 1, links : int = 3) {
			super(focusNodes, distance, links);
			this.visibleNodesGroupName = visibleNodesGroupName;
		}

		public override function operate(t : Transitioner = null) : void {
			t = Transitioner.instance(t);
			// copy from GraphDistanceFilter
			// initialize breadth-first traversal
			switch(mode) {
				case MODE_SHOW_ALL:
					visualization.data.nodes.setProperties({"props.distance":0});
					visualization.data.edges.setProperties({"props.distance":0});
					visualization.data.nodes.setProperties({alpha:1, visible:true}, t);
					visualization.data.edges.setProperties({alpha:1, visible:true}, t);
					break;
				case MODE_SHOW_NEIGHBORHOOD:
					visualization.data.nodes.setProperty("props.distance", null);
					var q : Array = [], depths : Dictionary = new Dictionary();
					for each (var fn:NodeSprite in focusNodes) {
						depths[fn] = 0;
						fn.visitEdges(function(e : EdgeSprite) : void {
							depths[e] = 1;
							q.push(e);
						}, links, filter);
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
							xn.visitEdges(function(e : EdgeSprite) : void {
								if (depths[e.target] == d && depths[e.source] == d) {
									depths[e] = d + 1;
								}
							}, links, filter);
						} else {
							xn.visitEdges(function(e : EdgeSprite) : void {
								if (depths[e] == undefined) {
									depths[e] = d + 1;
									q.push(e);
								}
							}, links, filter);
						}
					}
					// now set visibility based on traversal results
					visualization.data.visit(function(ds : DataSprite) : void {
						var visible : Boolean = (depths[ds] != undefined);
						var alpha : Number = visible ? 1 : 0;
						var obj : Object = t.$(ds);
						obj.alpha = alpha;
						if (ds is NodeSprite) {
							var ns : NodeSprite = ds as NodeSprite;
							ns.expanded = (visible && depths[ds] < distance);
							// added by mo
							if (depths[ds] != undefined) {
								if (ns.props.distance == null || depths[ds] < ns.props.distance) {
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
					break;
			}
					var dl : DataList = visualization.data.group(visibleNodesGroupName);
					dl.clear();
					visualization.data.nodes.visit(function(n : NodeSprite) : void {
						if ((t.immediate && n.visible) || t.$(n).visible) {
							dl.add(n);
						}
					});
					if (!(visualization as RelationBrowser).showInterConnections) {
						visualization.data.edges.setProperty("alpha", function(e : *) : Boolean {
							return e.source.props.distance * e.target.props.distance == 0;
						}, t);
					}
			}
		}
	}