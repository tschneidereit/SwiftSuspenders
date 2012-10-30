package org.swiftsuspenders.dependencyproviders
{
	import org.swiftsuspenders.Injector;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.describeType;
	import org.swiftsuspenders.utils.TypeDescriptor;

	public class FreshInstanceProvider implements FallbackDependencyProvider
	{
		private var _typeDescriptor : TypeDescriptor;
	
		public function FreshInstanceProvider()
		{
			super();
		}
		
		public function get typeDescriptor():TypeDescriptor
		{
			return _typeDescriptor;
		}
		
		public function set typeDescriptor(value:TypeDescriptor):void
		{
			_typeDescriptor = value;
		}
		
		//---------------------------------------
		// FallbackDependencyProvider Implementation
		//---------------------------------------

		public function prepareNextRequest(mappingId : String) : Boolean
		{
			const mappingParts : Array = mappingId.split("|");
			
			if(mappingParts[1] && mappingParts[1].length > 0) 
				return false;
			
			const mappingFQCN : String = mappingParts[0];
			const mappingType : Class = getDefinitionByName(mappingFQCN) as Class;
			return (mappingType && _typeDescriptor.getDescription(mappingType) &&
					(_typeDescriptor.getDescription(mappingType).ctor != null) );
		}

		//---------------------------------------
		// DependencyProvider Implementation
		//---------------------------------------

		public function apply(
			targetType : Class, activeInjector : Injector, injectParameters : Dictionary) : Object
			{
				return activeInjector.instantiateUnmapped(targetType);
			}

		public function destroy() : void
		{
			_typeDescriptor = null;
		}
	}
}