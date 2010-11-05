package eu.stefaner.relationbrowser {
	import eu.stefaner.relationbrowser.encoders.Encoders;
	import eu.stefaner.relationbrowser.layout.RelationBrowserEdgeRenderer;
	import eu.stefaner.relationbrowser.ui.Node;

	import flare.scale.ScaleType;
	import flare.util.Shapes;
	import flare.util.palette.ColorPalette;
	import flare.vis.data.Data;
	import flare.vis.data.render.ArrowType;
	import flare.vis.operator.Operator;
	import flare.vis.operator.encoder.ColorEncoder;

	import com.asual.swfaddress.SWFAddress;
	import com.asual.swfaddress.SWFAddressEvent;

	import org.osflash.thunderbolt.Logger;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;

	/**	 * @author mo	 */
	public class RelationBrowserApp extends Sprite {
		public var dataURL : String;
		public var configURL : String;
		protected var relationBrowser : RelationBrowser;
		protected var baseTitle : String;

		public function RelationBrowserApp() {
			super();
			startUp();
		}

		protected function startUp() : void {
			Logger.info("startUp");
			initStage();
			initExternalInterface();
			initSWFAddress();
			loadData();
			initDisplay();
		}

		protected function initSWFAddress() : void {
			SWFAddress.addEventListener(SWFAddressEvent.EXTERNAL_CHANGE, onURLparamChanged);
			baseTitle = SWFAddress.getTitle();
		}

		protected function onURLparamChanged(event : SWFAddressEvent = null) : void {
			Logger.info("urlparam changed", getIDFromURL());
			selectNodeByID(getIDFromURL());
		}

		protected function getIDFromURL() : String {
			try {
				return SWFAddress.getValue().split("/")[1];
			} catch (error : Error) {
			}
			return null;
		}

		protected function setIDInURL(id : String = "") : void {
			SWFAddress.setValue(id);
		}

		private function storeSelectionInURL() : void {
			if (relationBrowser.selectedNode) {
				SWFAddress.setValue(relationBrowser.selectedNode.data.id);
				SWFAddress.setTitle(baseTitle + " : " + relationBrowser.selectedNode.data.label);
			} else {
				SWFAddress.setValue("");
				SWFAddress.setTitle(baseTitle);
			}
		}

		protected function initStage() : void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onResize);
			try {				// stage.displayState = StageDisplayState.FULL_SCREEN;
			} catch (e : Error) {
			}
		};

		protected function onResize(event : Event = null) : void {
			;
			relationBrowser.bounds = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			relationBrowser.x = stage.stageWidth * .5;
			relationBrowser.y = stage.stageHeight * .5;
		};

		protected function initExternalInterface() : void {
			if (ExternalInterface.available) {
				try {
					ExternalInterface.addCallback("selectNodeByID", selectNodeByID);
				} catch(e : Error) {
				}
			}
		};

		// for external JS calls
		public function selectNodeByID(id : String = null) : void {
			try {
				relationBrowser.selectNodeByID(id);
			} catch(e : Error) {
				Logger.error("Could not select node by id", id);
			}
		};

		// call when everything is set up, to get startID from Javascript
		protected function onDataAndDisplayReady() : void {
			if (ExternalInterface.available) {
				try {
					ExternalInterface.call("onFlashReady");
				} catch(e : Error) {
				}
			}
			relationBrowser.visible = true;
			addChild(relationBrowser);
			relationBrowser.nodeDefaults = getNodeDefaults();
			relationBrowser.edgeDefaults = getEdgeDefaults();
			// relationBrowser.selectNode();
			onURLparamChanged();
		};

		protected function loadData() : void {
			Logger.info("loadData");
		};

		protected function loadCSV(nodesFileURL : String, relationsFileURL : String) : void {
			Logger.info("loadCSV");
		};

		protected function loadGraphML(graphmlFileURL : String) : void {
			Logger.info("loadGraphML");
		};

		protected function initDisplay() : void {
			Logger.info("RelationBrowserApp: initDisplay");
			relationBrowser = createRelationBrowser();
			onResize();
			relationBrowser.addOperators(getOperators());
			relationBrowser.nodeDefaults = getNodeDefaults();
			relationBrowser.edgeDefaults = getEdgeDefaults();
			relationBrowser.sortBy = ["props.cluster"];
			addChild(relationBrowser);
			relationBrowser.addEventListener(RelationBrowser.NODE_CLICKED, onNodeClicked);
			relationBrowser.addEventListener(RelationBrowser.NODE_SELECTED, onNodeSelected);
			relationBrowser.addEventListener(RelationBrowser.NODE_SELECTION_FINISHED, onNodeSelectionFinished);
		};

		protected function getNodeDefaults() : Object {
			var n : Object = {};
			n.lineWidth = 2;
			n.lineColor = 0xAA666666;
			n.fillColor = 0xDD333333;
			n.shape = Shapes.CIRCLE;
			n.w = n.h = 80;
			n.size = 8;
			n.edgeRadius = 55;
			n.visible = false;
			// n.blendMode = BlendMode.MULTIPLY;
			n.filters = [new DropShadowFilter(4, 45, 0, .33, 6, 6, 1, 2)];
			// n["title_tf.filters"] = [new DropShadowFilter(4, 45, 0, .1, 6, 6, 1, 2)];
			return n;
		};

		protected function getEdgeDefaults() : Object {
			var e : Object = {};
			e.lineWidth = 1;
			e.lineColor = 0xFF000000;
			e.lineAlpha = .5;
			e.arrowType = ArrowType.TRIANGLE;
			e.visible = false;
			e.renderer = RelationBrowserEdgeRenderer.instance;
			return e;
		}

		public function getOperators() : Vector.<Operator> {
			var ops : Vector.<Operator> = new Vector.<Operator>();
			// sample:
			// color by cluster
			var c : ColorEncoder = new ColorEncoder("props.cluster", Data.NODES, "lineColor", ScaleType.CATEGORIES, new ColorPalette(ColorPalette.CATEGORY_COLORS_10));
			ops.push(c);
			ops.push(Encoders.getScaleNodesByGraphDistanceEncoder(1.25, 1, .1));
			ops.push(Encoders.getScaleEdgesByGraphDistanceEncoder(4, 1, relationBrowser.showOuterEdges));
			return ops;
		}

		protected function onNodeClicked(event : Event) : void {
			sendToJS("onNodeClicked", relationBrowser.lastClickedNode);
		}

		protected function onNodeSelected(event : Event) : void {
			sendToJS("onNodeSelected", relationBrowser.selectedNode);
			storeSelectionInURL();
		}

		protected function onNodeSelectionFinished(event : Event) : void {
			sendToJS("onNodeSelectionFinished", relationBrowser.selectedNode);
		}

		protected function sendToJS(string : String, node : Node = null) : void {
			if (node && node.data) {
				try {
					ExternalInterface.call(string, node.data);
					Logger.info("sendToJS:", string, node.data);
				} catch(e : Error) {
				}
			} else {
				try {
					ExternalInterface.call(string, {});
					Logger.info("sendToJS:", string);
				} catch(e : Error) {
				}
			}
		}

		protected function createRelationBrowser() : RelationBrowser {
			return new RelationBrowser();
		}
	}
}