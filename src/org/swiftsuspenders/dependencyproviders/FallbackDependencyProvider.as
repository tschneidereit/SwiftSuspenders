package org.swiftsuspenders.dependencyproviders
{
	import org.swiftsuspenders.typedescriptions.TypeDescription;

	public interface FallbackDependencyProvider extends DependencyProvider
	{
		function satisfies(type : Class, description : TypeDescription):Boolean;
	}

}