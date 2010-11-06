package eu.stefaner.relationbrowser.test {
	import eu.stefaner.relationbrowser.RelationBrowserApp;
	import eu.stefaner.relationbrowser.data.NodeData;
	import eu.stefaner.relationbrowser.ui.Node;

	/**
	 * @author mo
	 */
	public class LabelerTestApp extends RelationBrowserApp {
		public function LabelerTestApp() {
			super();
		}

		override protected function loadData() : void {
			for (var i : int = 0; i < 50; i++) {
				relationBrowser.addNode(new NodeData(String(i)));
			}

			for each (var n:Node in relationBrowser.data.nodes) {
				for each (var n2:Node in relationBrowser.data.nodes) {
					if (n != n2 && Math.random() < .05) {
						relationBrowser.addEdge(n.data.id, n2.data.id);
					}
				}
			}
			onDataAndDisplayReady();
		}
	}
}
