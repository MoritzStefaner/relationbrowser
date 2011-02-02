package eu.stefaner.relationbrowser {
	import eu.stefaner.relationbrowser.data.EdgeData;
	import eu.stefaner.relationbrowser.data.NodeData;
	import eu.stefaner.relationbrowser.layout.RadialLayout;
	import eu.stefaner.relationbrowser.layout.VisibilityFilter;
	import eu.stefaner.relationbrowser.ui.Edge;
	import eu.stefaner.relationbrowser.ui.Node;

	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	import flare.vis.Visualization;
	import flare.vis.controls.ClickControl;
	import flare.vis.controls.HoverControl;
	import flare.vis.data.Data;
	import flare.vis.data.DataList;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.Tree;
	import flare.vis.events.SelectionEvent;
	import flare.vis.operator.Operator;
	import flare.vis.operator.layout.Layout;
	import flare.vis.operator.layout.RandomLayout;

	import org.osflash.thunderbolt.Logger;

	import flash.events.Event;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;

	public class RelationBrowser extends Visualization {
		public static const OVERVIEW_LAYOUT : int = 0;
		public static const DETAIL_LAYOUT : int = 1;
		public static const VISIBLE_NODES : String = "VISIBLE_NODES";
		public static const NODE_SELECTED : String = "NODE_SELECTED";
		public static const NODE_SELECTION_FINISHED : String = "NODE_SELECTION_FINISHED";
		public static const NODE_CLICKED : String = "NODE_CLICKED";
		public var selectedNode : Node;
		private var _depth : uint = 1;
		public var detailLayout : Layout;
		public var overviewLayout : Layout;
		public var visibilityOperator : VisibilityFilter;
		public var transitioner : Transitioner = new Transitioner(1);
		protected var nodesByID : Dictionary = new Dictionary();
		protected var visibleNodes : DataList;
		protected var visibleEdges : DataList;
		public var showInterConnections : Boolean = false;
		public var lastClickedNode : Node;
		private var _layoutMode : int;
		public var nodeLabeler : NodeLabeler;

		/**		 *@Constructor		 */
		public function RelationBrowser() {
			super();
		}

		public function selectNodeByID(id : String) : void {
			selectNode(nodesByID[id] as Node);
		}

		protected function initLayout() : void {
			operators.clear();

			visibilityOperator = new VisibilityFilter(VISIBLE_NODES, [], depth);
			operators.add(visibilityOperator);

			detailLayout = new RadialLayout(sortBy);
			operators.add(detailLayout);

			overviewLayout = new RandomLayout();
			operators.add(overviewLayout);

			nodeLabeler = createNodeLabeler();
			operators.add(nodeLabeler);
		}

		protected function createNodeLabeler() : NodeLabeler {
			var tf : TextFormat = new TextFormat();
			tf.align = TextFormatAlign.CENTER;
			tf.font = "Arial";
			tf.size = 11;
			tf.bold = false;
			tf.color = 0x444444;
			var l : NodeLabeler = new NodeLabeler("data.label", tf);
			return l;
		}

		public var _nodeDefaults : Object;

		public function set nodeDefaults(nodeDefaults : Object) : void {
			data.nodes.setDefaults(nodeDefaults);
			data.nodes.setProperties(nodeDefaults);
			_nodeDefaults = nodeDefaults;
		}

		public function get nodeDefaults() : Object {
			return _nodeDefaults;
		}

		private var _edgeDefaults : Object;

		public function set edgeDefaults(edgeDefaults : Object) : void {
			data.edges.setDefaults(edgeDefaults);
			data.edges.setProperties(edgeDefaults);
			_edgeDefaults = edgeDefaults;
		}

		public function get edgeDefaults() : Object {
			return _edgeDefaults;
		}

		protected function initControls() : void {
			controls.clear();
			controls.add(new ClickControl(Node, 1, onNodeClick));
			controls.add(new HoverControl(Node, HoverControl.MOVE_AND_RETURN, onNodeRollOver, onNodeRollOut));
		}

		public function addOperator(o : Operator) : void {
			operators.add(o);
		}

		public function addOperators(a : Vector.<Operator>) : void {
			for each (var i:Operator in a) {
				addOperator(i);
			}
		}

		protected function onNodeClick(e : SelectionEvent) : void {
			var n : Node = e.node as Node;
			if (n != null) {
				n.onClick();
				lastClickedNode = n;
				dispatchEvent(new Event(NODE_CLICKED));
				selectNode(n);
			}
		}

		protected function onNodeRollOver(e : SelectionEvent) : void {
			var n : Node = e.node as Node;
			if (n != null) {
				n.onRollOver();
			}
		}

		protected function onNodeRollOut(e : SelectionEvent) : void {
			var n : Node = e.node as Node;
			if (n != null) {
				n.onRollOut();
			}
		}

		public function selectNode(n : Node = null) : void {
			Logger.info("onNodeSelected " + n);
			if (n == selectedNode) {
				Logger.warn("RelationBrowser.selectNode: already selected");
				// return;
			}
			if (selectedNode != null) {
				selectedNode.selected = false;
			}
			if (n != null) {
				n.selected = true;
			}
			selectedNode = n;
			updateDisplay();
			dispatchEvent(new Event(NODE_SELECTED));
		}

		public function updateDisplay() : void {
			updateSelection(new Transitioner(1));
		}

		public function updateSelection(t : *= null) : Transitioner {
			Logger.info("updateSelection  " + selectedNode);

			transitioner = Transitioner.instance(t);
			if (!data || !data.length) return transitioner;

			if (!transitioner.hasEventListener(TransitionEvent.END)) {
				transitioner.addEventListener(TransitionEvent.END, onTransitionEnd, false, 0, true);
			}
			if (selectedNode == null) {
				layoutMode = OVERVIEW_LAYOUT;
			} else {
				layoutMode = DETAIL_LAYOUT;
			}
			preUpdate(transitioner);
			update(transitioner);
			postUpdate(transitioner);
			transitioner.play();
			return transitioner;
		}

		public function set layoutMode(m : int) : void {
			_layoutMode = m;
			switch(m) {
				case OVERVIEW_LAYOUT:
					detailLayout.enabled = false;
					visibilityOperator.mode = VisibilityFilter.MODE_SHOW_ALL;
					visibilityOperator.enabled = true;
					overviewLayout.enabled = true;
					break;
				case DETAIL_LAYOUT:
					overviewLayout.enabled = false;
					detailLayout.enabled = true;
					visibilityOperator.mode = VisibilityFilter.MODE_SHOW_NEIGHBORHOOD;
					visibilityOperator.enabled = true;
					detailLayout.layoutRoot = selectedNode;
					visibilityOperator.focusNodes = [selectedNode];
					break;
			}
		}

		public function get layoutMode() : int {
			return _layoutMode;
		}

		protected function onTransitionEnd(event : TransitionEvent) : void {
			dispatchEvent(new Event(NODE_SELECTION_FINISHED));
		}

		protected function preUpdate(t : Transitioner = null) : void {
			applyDefaults(t);
		}

		public function applyDefaults(t : Transitioner) : void {
			t = Transitioner.instance(t);
			if (nodeDefaults) {
				data.nodes.setProperties(nodeDefaults, t);
			}
			if (edgeDefaults) {
				data.nodes.setProperties(nodeDefaults, t);
			}
		}

		protected function postUpdate(t : Transitioner = null) : void {
			t = Transitioner.instance(t);
		}

		public function addNode(o : NodeData) : Node {
			var n : Node = getNodeByID(o.id);
			if (n == null) {
				// no node yet for ID: create node
				n = nodesByID[o.id] = createNode(o);
				data.nodes.applyDefaults(n);
				n.origin = (detailLayout as RadialLayout).layoutAnchor;
				n.radius = .001;
				data.addNode(n);
			} else {
				// existing node: set new data
				n.data = o;
			}
			return n;
		}

		protected function createNode(data : NodeData) : Node {
			return new Node(data);
		}

		public function getNodeByID(id : String) : Node {
			return nodesByID[id];
		}

		public function addEdge(fromID : String, toID : String, directed : Boolean = false, d : EdgeData = null) : EdgeSprite {
			var node1 : Node = getNodeByID(fromID);
			var node2 : Node = getNodeByID(toID);
			var e : Edge = createEdge(node1, node2, directed);
			if (d != null) {
				e.data = d;
			}
			try {
				node1.addOutEdge(e);
				node2.addInEdge(e);
				data.addEdge(e);
				data.edges.applyDefaults(e);
			} catch (err : Error) {
				Logger.warn("Problem adding edge ", err.message, fromID, toID, directed, d);
			}
			return e;
		}

		protected function createEdge(node1 : Node, node2 : Node, directed : Boolean) : Edge {
			return new Edge(node1, node2, directed);
		}

		public function removeUnconnectedNodes() : void {
			for each (var n:Node in data.nodes) {
				if (n.degree == 0) {
					data.removeNode(n);
				}
			}
		}

		public function get depth() : uint {
			return _depth;
		}

		public function set depth(depth : uint) : void {
			_depth = depth;
			if (visibilityOperator) {
				visibilityOperator.distance = _depth;
			}
		}

		override public function get data() : Data {
			return super.data ? super.data : data = new Tree();
		}

		override public function set data(data : Data) : void {
			super.data = data;
			visibleNodes = data.addGroup(VISIBLE_NODES);
			initControls();
			initLayout();
		}

		private var _sortBy : Array;

		public function get sortBy() : Array {
			return _sortBy;
		}

		public function set sortBy(sortBy : Array) : void {
			_sortBy = sortBy;
			if (detailLayout && detailLayout is RadialLayout) {
				(detailLayout as RadialLayout).sortBy = sortBy;
				updateDisplay();
			}
		}

		public function selectFirstNode() : void {
			selectNode(data.nodes[0]);
		}

		public function selectNodeByName(name : String) : void {
			for each (var n:Node in data.nodes) {
				if (n.data.label == name) {
					selectNode(n);
				}
			}
		}
	}
}