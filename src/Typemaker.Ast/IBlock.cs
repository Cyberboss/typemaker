﻿using System;
using System.Collections.Generic;
using System.Text;

namespace Typemaker.Ast
{
	public interface IBlock : ISyntaxNode
	{
		IReadOnlyList<IStatement> Statements { get; }
	}
}
