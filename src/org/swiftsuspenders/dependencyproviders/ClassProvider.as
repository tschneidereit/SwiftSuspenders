/*
* Copyright (c) 2009-2011 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package org.swiftsuspenders.dependencyproviders
{
	import org.swiftsuspenders.Injector;

	public class ClassProvider implements DependencyProvider
	{
		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		private var _responseType : Class;
		
		
		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function ClassProvider(responseType : Class)
		{
			_responseType = responseType;
		}
		
		public function apply(injector : Injector) : Object
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