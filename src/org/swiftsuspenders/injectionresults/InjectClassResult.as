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
	
	public class InjectClassResult implements IInjectionResult
	{
		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		private var config:InjectionConfig;
		
		
		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
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