package eu.stefaner.relationbrowser.encoders {
	import flare.vis.data.Data;
	import flare.vis.operator.encoder.PropertyEncoder;

	/**
	 * @author mo
	 */
	public class Encoders {

		public static function getScaleEdgesByGraphDistanceEncoder(max : Number, min : Number, showOuterEdges : Boolean = true) : PropertyEncoder {
			// edge size encoder
			var scaleEdges : Function = function(e : *) : Number {
				var lineWidth : Number = max - e.source.props.distance - e.target.props.distance;
				lineWidth = Math.max(min, lineWidth);
				if(isNaN(lineWidth)) lineWidth = 0;
				return lineWidth;
			};
			
			// edge alpha encoder
			var alphaEdges : Function = function(e : *) : Number {
				if(!showOuterEdges && e.source.props.distance * e.target.props.distance > 0) {
					return 0;
				}
				var a : Number = (4 - e.source.props.distance - e.target.props.distance) / 4;
				a = Math.max(0.1, a);
				if(isNaN(a)) a = 0;
				return a;
			};
			
			return new PropertyEncoder({"lineWidth":scaleEdges, "lineAlpha":alphaEdges}, Data.EDGES);
		}

		public static function getScaleNodesByGraphDistanceEncoder(centerScale : Number, innerRingScale : Number, outerRingScale : Number) : PropertyEncoder {
			
			var scaleByDistance : Function = function(n : *) : Number {
				if(n.props.distance == 0) {
					return centerScale;
				} else if(n.props.distance == 1) {
					return innerRingScale;
				}
				return outerRingScale;
			};
			return new PropertyEncoder({"scale":scaleByDistance}, Data.NODES);
		}
	}
}
