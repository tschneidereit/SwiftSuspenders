/*
* Copyright (c) 2009 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package org.swiftsuspenders
{
	import org.swiftsuspenders.injectionresults.InjectionResult;
	
	public class InjectionConfig 
	{
		/*******************************************************************************************
		 *								public properties										   *
		 *******************************************************************************************/
		public var request : Class;
		public var injectionName : String;
		
		
		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		private var m_injector : Injector;
		private var m_result : InjectionResult;
		
		
		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function InjectionConfig(
			request : Class, injectionName : String, injector : Injector)
		{
			this.request = request;
			this.injectionName = injectionName;
			m_injector = injector;
		}
		
		public function getResponse() : Object
		{
			if (m_result)
			{
				return m_result.getResponse();
			}
			var parentConfig : InjectionConfig = m_injector.getParentMapping(request, injectionName);
			if (parentConfig)
			{
				return parentConfig.getResponse();
			}
			return null;
		}

		public function hasResponse() : Boolean
		{
			if (m_result)
			{
				return true;
			}
			var parentConfig : InjectionConfig = m_injector.getParentMapping(request, injectionName);
			if (parentConfig)
			{
				return true;
			}
			return false;
		}
		
		public function setResult(result : InjectionResult) : void
		{
			m_result = result;
		}
		
		public function setInjector(injector : Injector) : void
		{
			m_injector = injector;
			m_result.setInjector(injector);
		}
	}
}