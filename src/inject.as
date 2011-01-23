/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package
{
	import org.swiftsuspenders.Injector;

	public function inject(type : Class, named : String = '') : *
	{
		var injector : Injector = Injector.currentInjector;
		return injector.getMapping(type, named).getResponse(injector);
	}
}