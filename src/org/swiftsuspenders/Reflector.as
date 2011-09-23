package org.swiftsuspenders
{
	import flash.system.ApplicationDomain;

	import org.swiftsuspenders.injectionpoints.InjectionPoint;

	public interface Reflector
	{
		function getClass(value : *, applicationDomain : ApplicationDomain = null) : Class;
		function getFQCN(value : *, replaceColons : Boolean = false) : String;
		function classExtendsOrImplements(classOrClassName : Object, superclass : Class,
				application : ApplicationDomain = null) : Boolean;

		function startReflection(type : Class) : void;
		function endReflection() : void;

		function getCtorInjectionPoint() : InjectionPoint;
		function addFieldInjectionPointsToList(
				lastInjectionPoint : InjectionPoint) : InjectionPoint;
		function addMethodInjectionPointsToList(
				lastInjectionPoint : InjectionPoint) : InjectionPoint;
		function addPostConstructMethodPointsToList(
				lastInjectionPoint : InjectionPoint) : InjectionPoint;
	}
}