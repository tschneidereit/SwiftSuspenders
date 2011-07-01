package org.swiftsuspenders
{
	import org.swiftsuspenders.injectionpoints.InjectionPoint;

	public interface Reflector
	{
		function startReflection(type : Class) : void;

		function endReflection() : void;

		function getCtorInjectionPoint() : InjectionPoint;

		function getOptionalFlagFromXMLNode(node : XML) : Boolean;

		function gatherMethodParameters(
				parameterNodes : XMLList, nameArgs : XMLList) : Array;

		function createDummyInstance(constructorNode : XML, clazz : Class) : void;

		function addFieldInjectionPointsToList(injectionPoints : Array) : void;

		function addMethodInjectionPointsToList(injectionPoints : Array) : void;

		function addPostConstructMethodPointsToList(injectionPoints : Array) : void;
	}
}