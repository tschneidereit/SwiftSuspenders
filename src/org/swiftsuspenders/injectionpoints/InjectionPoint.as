/*
 * Copyright (c) 2009 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.injectionpoints
{
	import flash.utils.Dictionary;
	import org.swiftsuspenders.Injector;

	public class InjectionPoint
	{
		/*******************************************************************************************
		*								public methods											   *
		*******************************************************************************************/
		public function InjectionPoint(node : XML, injectorMappings : Dictionary)
		{
			initializeInjection(node, injectorMappings);
		}
		
		public function applyInjection(target : Object, injector : Injector, singletons : Dictionary) : Object
		{
			return target;
		}


		/*******************************************************************************************
		*								protected methods										   *
		*******************************************************************************************/
		protected function initializeInjection(node : XML, injectorMappings : Dictionary) : void
		{
		}
	}
}