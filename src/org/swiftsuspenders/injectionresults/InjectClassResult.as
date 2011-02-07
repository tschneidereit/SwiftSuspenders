/*
* Copyright (c) 2009-2011 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package org.swiftsuspenders.injectionresults
{
	import org.swiftsuspenders.Injector;

	public class InjectClassResult extends InjectionResult
	{
		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		private var _responseType : Class;
		
		
		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function InjectClassResult(responseType : Class)
		{
			_responseType = responseType;
		}
		
		override public function getResponse(injector : Injector) : Object
		{
			return injector.instantiate(_responseType);
		}

		override public function equals(otherResult : InjectionResult) : Boolean
		{
			if (otherResult == this)
			{
				return true;
			}
			if (!(otherResult is InjectClassResult))
			{
				return false;
			}
			var castedResult : InjectClassResult =  InjectClassResult(otherResult);
			return castedResult.m_responseType == m_responseType;
		}
	}
}