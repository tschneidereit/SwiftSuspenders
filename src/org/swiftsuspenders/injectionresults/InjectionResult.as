/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.injectionresults
{
	import org.swiftsuspenders.Injector;

	public class InjectionResult
	{
		/*******************************************************************************************
		 *								protected properties									   *
		 *******************************************************************************************/
		protected var m_injector : Injector;
		
		
		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function InjectionResult(injector : Injector)
		{
			m_injector = injector;
		}
		
		public function getResponse() : Object
		{
			return null;
		}
		
		public function setInjector(injector : Injector) : void
		{
			m_injector = injector;
		}
	}
}