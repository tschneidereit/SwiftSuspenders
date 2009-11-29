/*
* Copyright (c) 2009 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package org.swiftsuspenders.injectionresults
{
	import org.swiftsuspenders.Injector;

	public class InjectClassResult implements IInjectionResult
	{
		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		private var m_responseType : Class;
		private var m_injector : Injector;
		
		
		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function InjectClassResult(responseType : Class, injector : Injector)
		{
			m_responseType = responseType;
			m_injector = injector;
		}
		
		public function getResponse() : Object
		{
			return m_injector.instantiate(m_responseType);
		}
	}
}