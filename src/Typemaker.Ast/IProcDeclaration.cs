﻿using System.Collections.Generic;

namespace Typemaker.Ast
{
	public interface IProcDeclaration : IIdentifiable, IDecorated
	{
		bool IsVerb { get; }

		bool IsConstructor { get; }

		IReadOnlyList<IIdentifierDeclaration> Arguments { get; }

		INullableType ReturnType { get; }
	}
}
