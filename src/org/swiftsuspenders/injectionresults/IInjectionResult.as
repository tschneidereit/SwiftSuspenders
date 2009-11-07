package org.swiftsuspenders.injectionresults
{
	import flash.utils.Dictionary;
	
	import org.swiftsuspenders.Injector;

	public interface IInjectionResult
	{
		function getResponse(injector : Injector, singletons : Dictionary) : Object;
	}
}