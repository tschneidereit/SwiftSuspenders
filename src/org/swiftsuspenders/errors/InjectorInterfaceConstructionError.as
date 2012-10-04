/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.errors
{
	public class InjectorInterfaceConstructionError extends InjectorError
	{
		public function InjectorInterfaceConstructionError(message : * = "", id : * = 0)
		{
			super(message, id);
		}
	}
}