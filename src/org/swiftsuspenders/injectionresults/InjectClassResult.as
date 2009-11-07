package org.swiftsuspenders.injectionresults
{
	import flash.utils.Dictionary;
	
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.Injector;
	
	public class InjectClassResult implements IInjectionResult
	{
		private var config:InjectionConfig;
		
		public function InjectClassResult(config:InjectionConfig)
		{
			this.config = config;
		}
		
		public function getResponse(injector:Injector, singletons:Dictionary):Object
		{
			return injector.instantiate(Class(config.response));
		}
	}
}