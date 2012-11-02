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
		private var _responseType : Class;
	
		public function FreshInstanceProvider()
		{
			super();
		}
		
		public function get typeDescriptor():TypeDescriptor
		{
			// no reading please
			return null;
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
			if (mappingType && _typeDescriptor.getDescription(mappingType) &&
					(_typeDescriptor.getDescription(mappingType).ctor != null) )
			{
				_responseType = mappingType;
				return true;
			}
			_responseType = null;
			return false;
		}

		//---------------------------------------
		// DependencyProvider Implementation
		//---------------------------------------

		public function apply(
			targetType : Class, activeInjector : Injector, injectParameters : Dictionary) : Object
		{
			var response : Object;
			if(_responseType)
			{
				response = activeInjector.instantiateUnmapped(_responseType);
			}
			_responseType = null;
			return response;
		}

		public function destroy() : void
		{
			_typeDescriptor = null;
		}
	}
}