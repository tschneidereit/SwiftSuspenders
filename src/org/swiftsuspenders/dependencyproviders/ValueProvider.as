/*
* Copyright (c) 2009-2011 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package org.swiftsuspenders.dependencyproviders
{
	import org.swiftsuspenders.Injector;
	
	public class ValueProvider implements DependencyProvider
	{
		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		private var _value : Object;
		
		
		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function ValueProvider(value : Object)
		{
			_value = value;
		}
		
		public function apply(injector : Injector) : Object
		{
			return _value;
		}

		override public function equals(otherResult : InjectionResult) : Boolean
		{
			if (otherResult == this)
			{
				return true;
			}
			if (!(otherResult is InjectValueResult))
			{
				return false;
			}
			var castedResult : InjectValueResult =  InjectValueResult(otherResult);
			return castedResult.m_value == m_value;
		}
	}
}