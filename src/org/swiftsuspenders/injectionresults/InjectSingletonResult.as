/*
* Copyright (c) 2009 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package org.swiftsuspenders.injectionresults
{
	import flash.utils.Dictionary;
	
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.Injector;

	public class InjectSingletonResult implements IInjectionResult
	{
		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		private var config:InjectionConfig;
		private var singletons:Dictionary;
		
		
		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function InjectSingletonResult(config:InjectionConfig)
		{
			this.config = config;
		}
		
		public function getResponse(injector : Injector, singletons : Dictionary) : Object
		{
			var usedSingletonsMap : Dictionary = singletons;
			var result:Object;
			this.singletons = singletons;
			if (config.injectionName)
			{
				usedSingletonsMap = updateSingletonsMap();
			}
			result = usedSingletonsMap[config.request];
			if (!result)
			{
				result = usedSingletonsMap[config.request] = injector.instantiate(Class(config.response));
			}	
			return result;
		}
		
		
		/*******************************************************************************************
		 *								private methods											   *
		 *******************************************************************************************/
		private function updateSingletonsMap():Dictionary
		{
			var usedSingletonsMap:Dictionary = singletons[config.injectionName];
			if (!usedSingletonsMap)
			{
				usedSingletonsMap = singletons[config.injectionName] = new Dictionary();
			}	
			return usedSingletonsMap;
		}
	}
}