/*
 * Copyright (c) 2009-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.injectionresults
{
	import org.swiftsuspenders.Injector;

	public class InjectSingletonResult extends InjectionResult
	{
		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		private var m_responseType : Class;
		private var m_response : Object;
		
		
		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function InjectSingletonResult(responseType : Class)
		{
			m_responseType = responseType;
		}
		
		override public function getResponse(injector : Injector) : Object
		{
			return m_response ||= createResponse(injector);
		}

		override public function equals(otherResult : InjectionResult) : Boolean
		{
			if (otherResult == this)
			{
				return true;
			}
			if (!(otherResult is InjectSingletonResult))
			{
				return false;
			}
			var castedResult : InjectSingletonResult =  InjectSingletonResult(otherResult);
			return castedResult.m_response == m_response
					&& castedResult.m_responseType == m_responseType;
		}

		/*******************************************************************************************
		 *								private methods											   *
		 *******************************************************************************************/
		private function createResponse(injector : Injector) : Object
		{
			return injector.instantiate(m_responseType);
		}
	}
}