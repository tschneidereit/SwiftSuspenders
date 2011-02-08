/*
 * Copyright (c) 2009-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.dependencyproviders
{
	import org.swiftsuspenders.Injector;

	public class SingletonProvider implements DependencyProvider
	{
		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		private var _responseType : Class;
		private var _response : Object;
		
		
		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function SingletonProvider(responseType : Class)
		{
			_responseType = responseType;
		}
		
		public function apply(injector : Injector) : Object
		{
			return _response ||= createResponse(injector);
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
			return injector.instantiate(_responseType);
		}
	}
}