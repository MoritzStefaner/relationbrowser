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
				var nd : NodeData = new NodeData(String(i), {}, randomLabel(String(i)));
				relationBrowser.addNode(nd);
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

		private function randomLabel(string : String) : String {
			while (Math.random() > .01) {
				if (Math.random() < .2) {
					string += " ";
				} else {
					string += Math.floor(Math.random() * 10);
				}
			}
			return string;
		}
	}
}
