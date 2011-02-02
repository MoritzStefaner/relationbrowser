package eu.stefaner.relationbrowser.ui {
	import flare.display.render.BackgroundRenderer;

	import flash.text.TextFormatAlign;

	import flare.display.TextSprite;

	import eu.stefaner.relationbrowser.data.NodeData;

	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	import flare.util.Displays;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;

	import flash.events.Event;

	public class Node extends NodeSprite {
		public var t : Transitioner;
		protected var _labelSprite : TextSprite;
		private var runningRollOverTransition : Boolean;
		private var doRollOutAfterTransitionEnd : Boolean;
		//private static var _devNullTextSprite : TextSprite = new TextSprite();

		/**		 *@Constructor		 */
		public function Node(data : NodeData = null) {
			super();
			this.data = data;
			mouseChildren = false;
			Displays.addStageListener(this, Event.ADDED_TO_STAGE, onStageInit);
		}

		public function show(_t : Transitioner = null) : void {
			_t = Transitioner.instance(_t);
			_t.$(this).alpha = 1;
			_t.$(this).visible = true;
			visible = true;
		}

		public function onClick() : void {
		}

		/**		 * EVENT HANDLERS		 */
		public function onRollOver(e : Event = null) : void {
			doRollOutAfterTransitionEnd = false;
			if (runningRollOverTransition) {
				return;
			}
			refreshTransitioner();
			t.$(this).scale = 1.25;
			t.play();
			runningRollOverTransition = true;
		}

		public function onRollOut(e : Event = null) : void {
			if (runningRollOverTransition) {
				doRollOutAfterTransitionEnd = true;
				return;
			}
			doRollOutAfterTransitionEnd = false;
			refreshTransitioner();
			t.$(this).scale = 1;
			t.play();
		}

		private function refreshTransitioner() : void {
			if (t != null) {
				t.reset();
				t.dispose();
			}
			t = new Transitioner(.33);
			t.addEventListener(TransitionEvent.STEP, onTransitionStep);
			t.addEventListener(TransitionEvent.END, onTransitionEnd);
		}

		private function onTransitionEnd(event : TransitionEvent) : void {
			runningRollOverTransition = false;
			if (doRollOutAfterTransitionEnd) {
				doRollOutAfterTransitionEnd = false;
				onRollOut();
			}
		}

		private function onTransitionStep(event : TransitionEvent) : void {
			visitEdges(function(e : EdgeSprite) : void {
				e.dirty();
				e.render();
			});
		}

		protected function onStageInit() : void {
			render();
		}

		/* 		 *  GETTER/SETTER		 */
		override public function get data() : Object {
			return super.data;
		}

		override public function set data(data : Object) : void {
			if (!data is NodeData) {
				throw new Error("Sorry, NodeData expected!");
			}
			super.data = data;
			render();
		}

		private var _scale : Number = 1;

		public function get scale() : Number {
			return _scale || Math.max(scaleX, scaleY);
		}

		public function set scale(scale : Number) : void {
			scaleX = scale;
			scaleY = scale;
			_scale = scale;
		}

		private var _edgeRadius : Number = -1;

		public function get edgeRadius() : Number {
			return _edgeRadius != -1 ? _edgeRadius * scale : Math.max(width, height) * .5 * 1.1;
		}

		public function set edgeRadius(edgeRadius : Number) : void {
			_edgeRadius = edgeRadius;
		}

		public function get labelSprite() : TextSprite {
			return _labelSprite;
		}

		public function set labelSprite(labelSprite : TextSprite) : void {
			_labelSprite = labelSprite;
			initLabelSprite();
		}

		protected function initLabelSprite() : void {
			_labelSprite.maxWidth = 80;
			_labelSprite.textFormat.align = TextFormatAlign.CENTER;

			_labelSprite.backgroundFill = true;
			_labelSprite.backgroundFillColor = 0xFF999999;
			_labelSprite.backgroundBorder = true;
			_labelSprite.backgroundBorderColor = 0xFF555555;
		}
	}
}