/*
* Copyright (c) 2009 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package org.swiftsuspenders.injectionresults
{
	import flash.utils.Dictionary;
	
	import org.swiftsuspenders.Injector;

	public class InjectSingletonResult extends InjectionResult
	{
		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		private var m_singletons : Dictionary;
		private var m_responseType : Class;
		private var m_response : Object;
		
		
		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function InjectSingletonResult(
			responseType : Class, singletons : Dictionary, injector : Injector)
		{
			m_singletons = singletons;
			m_responseType = responseType;
			super(injector);
		}
		
		override public function getResponse() : Object
		{
			return m_response || createResponse();
		}
		
		
		/*******************************************************************************************
		 *								private methods											   *
		 *******************************************************************************************/
		private function createResponse() : Object
		{
			var response : Object = m_injector.instantiate(m_responseType);
			m_response = response;
			m_singletons[m_responseType] = response;
			return response;
		}
	}
}