package org.swiftsuspenders
{
	import org.swiftsuspenders.injectionresults.IInjectionResult;
	import org.swiftsuspenders.injectionresults.InjectNullResult;
	import org.swiftsuspenders.injectionresults.InjectClassResult;
	import org.swiftsuspenders.injectionresults.InjectSingletonResult;
	import org.swiftsuspenders.injectionresults.InjectValueResult;

	public class InjectionResultFactory
	{
		private var injectionConfig:InjectionConfig;
		
		public function InjectionResultFactory(injectionConfig:InjectionConfig)
		{
			this.injectionConfig = injectionConfig;
		}
		
		public function getResult():IInjectionResult
		{
			switch(injectionConfig.injectionType)
			{
				case InjectionType.CLASS:
					return new InjectClassResult(injectionConfig);
				case InjectionType.VALUE:
					return new InjectValueResult(injectionConfig);
				case InjectionType.SINGLETON:
					return new InjectSingletonResult(injectionConfig);
					break;
			}
			
			return new InjectNullResult();
		}
	}
}