/*
 * Copyright (c) 2010-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.dependencyproviders
{
	import org.swiftsuspenders.Injector;

	public class DependencyProvider
	{
		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function DependencyProvider()
		{
		}
		
		public function getResponse(injector : Injector) : Object
		{
			return null;
		}

		public function equals(otherResult : InjectionResult) : Boolean
		{
			return false;
		}
	}
}