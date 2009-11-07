package org.swiftsuspenders.injectionresults
{
	import flash.utils.Dictionary;
	
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.Injector;
	
	public class InjectValueResult implements IInjectionResult
	{
		private var config:InjectionConfig;
		
		public function InjectValueResult(config:InjectionConfig)
		{
			this.config = config;
		}
		
		public function getResponse(injector:Injector, singletons:Dictionary):Object
		{
			injector.injectInto(config.response);
			return config.response;
		}
	}
}