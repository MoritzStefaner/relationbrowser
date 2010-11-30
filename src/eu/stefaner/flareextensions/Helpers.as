package eu.stefaner.flareextensions {
	import flare.util.Property;
	import flare.util.Stats;

	import org.osflash.thunderbolt.Logger;

	/**
	 * @author mo
	 */
	public class Helpers {
		public static function normalize(sourcePropertyString : String, targetPropertyString : String, dataList : *) : void {
			var sourceProperty : Property = new Property(sourcePropertyString);
			var targetProperty : Property = new Property(targetPropertyString);
			var values : Array = [];
			for each (var n:* in dataList) {
				try {
					values.push(sourceProperty.getValue(n));
				} catch(error : Error) {
					Logger.warn("error getting property ", sourceProperty);
				}
			}
			var s : Stats = new Stats(values);
			var min : Number = s.minimum;
			var max : Number = s.maximum;
			for each (var n:* in dataList) {
				try {
					targetProperty.setValue(n, (sourceProperty.getValue(n) - min) / (max - min));
				} catch(error : Error) {
					Logger.warn("error setting property ", sourceProperty);
				}
			}
		}

		public static function normalizeTogether(sourceProperties : Array, targetProperties : Array, dataList : *) : void {
			var values : Array = [];
			for each (var n:* in dataList) {
				try {
					for each (var sourcePropertyString:String in sourceProperties) {
						var sourceProperty : Property = new Property(sourcePropertyString);
						values.push(sourceProperty.getValue(n));
					}
				} catch(error : Error) {
					Logger.warn("error getting property ", sourceProperty);
				}
			}
			var s : Stats = new Stats(values);
			var min : Number = s.minimum;
			var max : Number = s.maximum;
			Logger.info("minmax", min, max);
			for each (var n:* in dataList) {
				try {
					for (var i : int = 0; i < sourceProperties.length; i++) {
						var sourceProperty : Property = new Property(sourceProperties[i]);
						var targetProperty : Property = new Property(targetProperties[i]);
						targetProperty.setValue(n, (sourceProperty.getValue(n) - min) / (max - min));						
					}
				} catch(error : Error) {
					Logger.warn("error setting property ", targetProperty);
				}
			}
		}
	}
}
