package org.swiftsuspenders.injectionresults
{
	import flash.utils.Dictionary;
	
	import org.swiftsuspenders.Injector;

	public class InjectNullResult implements IInjectionResult
	{
		public function InjectNullResult()
		{
		}
		
		public function getResponse(injector : Injector, singletons : Dictionary) : Object
		{
			return {};
		}
	}
}