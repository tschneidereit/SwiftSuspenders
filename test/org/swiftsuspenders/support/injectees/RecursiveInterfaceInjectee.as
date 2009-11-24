package org.swiftsuspenders.support.injectees
{
	import org.swiftsuspenders.support.types.Interface;

	public class RecursiveInterfaceInjectee implements Interface
	{
		[Inject]
		public var interfaceInjectee : InterfaceInjectee;
		
		public function RecursiveInterfaceInjectee()
		{
		}
	}
}