%   Package: trees
%   Author : Richard A. O'Keefe
%   Updated: 8/29/89
%   Purpose: Updatable binary trees.
%   SeeAlso: library(logarr).

%   Adapted from shared code written by the same author; all changes
%   Copyright (C) 1987, Quintus Computer Systems, Inc.  All rights reserved.

%   Adapted for JIProlog by Ugo Chirico 12/07/2004 
%   all changes Copyright (C) 2004, Ugo Chirico http://www.ugosweb.com

/*  These are the routines I meant to describe in DAI-WP-150, but the
    wrong version went in.  We have
	list_to_tree : O(N)
	tree_to_list : O(N)
	tree_size    : O(N)
	map_tree     : O(N)
	get_label    : O(lg N)
	put_label    : O(lg N)
    where N is the number of elements in the tree.  The way get_label
    and put_label work is worth noting: they build up a pattern which
    is matched against the whole tree when the position number finally
    reaches 1.  In effect they start out from the desired node and
    build up a path to the root.  They still cost O(lg N) time rather
    than O(N) because the patterns contain O(lg N) distinct variables,
    with no duplications.  put_label simultaneously builds up a pattern
    to match the old tree and a pattern to match the new tree.
*/

:- module(trees, [
	get_label/3,
	list_to_tree/2,
	map_tree/3,
	put_label/4,
	put_label/5,
	tree_size/2,
	tree_to_list/2
   ]).

:- module_transparent
	map_tree/3, '$map_tree'/3.

/*  The tree starts out looking like this:

				1
		+---------------+---------------+
		2				3
	+-------+-------+		+-------+-------+
	4		5		6		7
    +---+---+	    +---+---+	    +---+---+	    +---+---+
    8	    9	   10	   11	   12	   13	   14	   15
*/

%   get_label(+Index, ?Tree, ?Label)
%   treats the tree as an array of N elements and returns the Index-th.
%   If Index < 1 or > N it simply fails, there is no such element.  As
%   Tree need not be fully instantiated, and is potentially unbounded,
%   we cannot enumerate Indices.

get_label(N, Tree, Label) :-
	integer(N),
	find_node(N, Tree, t(Label,_,_)).


find_node(N, Tree, Node) :-
    (   N > 1 ->
	M is N >> 1,
	(   N/\1 =:= 0 -> find_node(M, Tree, t(_,Node,_))
	;/* N/\1 =:= 1 */ find_node(M, Tree, t(_,_,Node))		
	)
    ;   N =:= 1 ->
	Tree = Node
    ).



%   list_to_tree(List, Tree)
%   takes a given List of N elements and constructs a binary Tree
%   where get_label(K, Tree, Lab) <=> Lab is the Kth element of List.

list_to_tree(List, Tree) :-
	list_to_tree(List, [Tree|Tail], Tail).


list_to_tree([], Qhead, []) :-
	list_to_tree(Qhead).
list_to_tree([Head|Tail], [t(Head,Left,Right)|Qhead], [Left,Right|Qtail]) :-
	list_to_tree(Tail, Qhead, Qtail).


list_to_tree([]).
list_to_tree([t|Qhead]) :-
	list_to_tree(Qhead).



%   map_tree(+Pred, ?OldTree, ?NewTree)
%   is true when OldTree and NewTree are binary trees of the same shape
%   and Pred(Old,New) is true for corresponding elements of the two trees.

map_tree(Pred, OldTree, NewTree) :-
	'$map tree'(OldTree, NewTree, Pred).

'$map tree'(t, t, _).
'$map tree'(t(Old,OLeft,ORight), t(New,NLeft,NRight), Pred) :-
	call(Pred, Old, New),
	'$map tree'(OLeft, NLeft, Pred),
	'$map tree'(ORight, NRight, Pred).



%   put_label(+Index, ?OldTree, ?Label, ?NewTree)
%   constructs a new tree the same shape as the old which moreover has the
%   same elements except that the Index-th one is Label.  Unlike the
%   "arrays" of Arrays.Pl, OldTree is not modified and you can hang on to
%   it as long as you please.  Note that O(lg N) new space is needed.

put_label(N, OldTree, Label, NewTree) :-
	integer(N),
	find_node(N, OldTree, t(_,Left,Right),
		     NewTree, t(Label,Left,Right)).

%   put_label(+Index, ?OldTree, ?OldLabel, ?NewTree, ?NewLabel)
%   is true when OldTree and NewTree are trees of the same shape having
%   the same elements except that the Index-th element of OldTree is
%   OldLabel and the Index-th element of NewTree is NewLabel.  You can
%   swap the <Tree,Label> argument pairs if you like, it makes no difference.

put_label(N, OldTree, OldLabel, NewTree, NewLabel) :-
	integer(N),
	find_node(N, OldTree, t(OldLabel,Left,Right),
		     NewTree, t(NewLabel,Left,Right)).


find_node(N, OldTree, OldNode, NewTree, NewNode) :-
    (	N > 1 ->
	M is N >> 1,
	(   N/\1 =:= 0 ->
	    find_node(M, OldTree, t(Label,OldNode,Right),
			 NewTree, t(Label,NewNode,Right))
	;/* N/\1 =:= 1 */
	    find_node(M, OldTree, t(Label,Left,OldNode),
			 NewTree, t(Label,Left,NewNode))
	)
    ;   N =:= 1 ->
	OldNode = OldTree, NewNode = NewTree
    ).



%   tree_size(Tree, Size)
%   calculates the number of elements in the Tree.  All trees made by
%   list_to_tree that are the same size have the same shape.

tree_size(Tree, Size) :-
    (	var(Size) ->
	tree_size(Tree, 0, Size)
    ;	integer(Size) ->
	length(List, Size),
	list_to_tree(List, Tree)
    ).


tree_size(t, Size, Size).
tree_size(t(_,Left,Right), Size0, Size) :-
	tree_size(Right, Size0, Size1),
	Size2 is Size1+1,
	tree_size(Left, Size2, Size).



%   tree_to_list(Tree, List)
%   is the converse operation to list_to_tree.  Any mapping or checking
%   operation can be done by converting the tree to a list, mapping or
%   checking the list, and converting the result, if any, back to a tree.
%   It is also easier for a human to read a list than a tree, as the
%   order in the tree goes all over the place.

tree_to_list(Tree, List) :-
	tree_to_list([Tree|Tail], Tail, List).


tree_to_list([], [], []) :- !.
tree_to_list([t|_], _, []) :- !.
tree_to_list([t(Head,Left,Right)|Qhead], [Left,Right|Qtail], [Head|Tail]) :-
	tree_to_list(Qhead, Qtail, Tail).

