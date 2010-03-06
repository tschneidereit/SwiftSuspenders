/*
* Copyright (c) 2009 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package org.swiftsuspenders.injectionresults
{
	import org.swiftsuspenders.Injector;
	
	public class InjectValueResult extends InjectionResult
	{
		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		private var m_value : Object
		
		
		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function InjectValueResult(value : Object, injector : Injector)
		{
			m_value = value;
			super(injector);
		}
		
		override public function getResponse() : Object
		{
			return m_value;
		}
	}
}