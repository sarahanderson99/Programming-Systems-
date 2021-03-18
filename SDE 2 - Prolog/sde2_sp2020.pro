/*
Sarah Anderson
SDE2: Hopfield Neural Network
Due: April 9, 2020
FILE: sde2_sp2020.pro
Contains: 6 predicates and helper functions for SDE2
*/

/************** hopTrainAstate *******************/
/* Predicate: hopTrainAstate(+Astate,-WforState) */
/*************************************************/

createWeight(_,[],[]).
createWeight( Input , [ H | T ], [ Unit | R ]):-
        Unit is Input * H,    
        createWeight( Input , T , R ),    
        !.

checkH(H, X):-
	H > 0.0,
	X = 0.0;
	H < 0.0,
	X = -0.0.

hopHelper( Used , [ H | []], W):- 
	checkH(H, Z),
	X=[Z] ,
	append( Used , X , A ) , 
	createWeight( H , A , WO ), 
	W = [ WO ],!.
hopHelper(Used, [ H | T ], W):-
	checkH(H, Z),						
	X=[ Z | T ] , 
	append( Used, X , Start ) , 
	append( Used,[ H ], Heads ), 
	createWeight( H , Start , WO ), 
	hopHelper( Heads , T , Y ), 
	W = [ WO | Y ].

hopTrainAstate( AState , WforState ) :-
	hopHelper( _ , AState , WforState ),!.

/******************* hopTrain ***********************/
/* Predicate: hopTrain(+ListofStates,-WeightMatrix) */
/****************************************************/

addList([H | []], [H2 | []], X):-
	addVals(H,H2,Y),
	X = [Y],!.
addList([H | T], [H2 | T2], X):-
	addVals( H , H2 , Y ),
	addList(T, T2, Result),
	X = [Y | Result],!.

addMatrix([H | []],[H2 | []], W):-
	addList( H , H2 , X ),
	W = [X].
addMatrix([H | T], [H2 | T2], W):-
	addList( H , H2 , X ),
	addMatrix( T, T2 , Y ), 
	W = [X | Y].

hopTrain([ LoSH | []], WeightMatrix ):-
	hopTrainAstate( LoSH , WeightMatrix ), !.
hopTrain([ LoSH | LoST ], WeightMatrix ):-
	hopTrainAstate( LoSH , X), 
	hopTrain( LoST ,Y),
	addMatrix( X , Y , WeightMatrix ), !.
hopTrain([],_).

/******************* Next State ***************************/
/* Predicate: nextState(+CurrentState,+WeightMatrix,-Next)*/
/**********************************************************/

nextState( [ CSH | CST ],[ WMH | [] ] , Next) :-
	netUnit( [ CSH | CST ] , WMH , Unit),
	hop11Activation( Unit , CSH , Y ),
	Next = [Y], 
	!.
nextState([ CSH | CST ] , [ WMH | WMT] , Next) :-
	netUnit([ CSH | CST ], WMH , Unit ),
	hop11Activation(Unit, CSH, State),
	nextState([ CSH | CST ], WMT, N),
	append([State],N, Next).

/***************** Energy *********************/
/* Predicate: energy(+State,+WeightMatrix,-E) */
/**********************************************/

energy(State , WeightMatrix, E ) :-
	netAll(State , WeightMatrix , Out ),
	netUnit( Out , State , Unit ),
	E is ((-0.5) * Unit),
	!.

/************************** UpdateN *******************************/
/* Predicate: updateN(+CurrentState,+WeightMatrix,+N,-ResultState)*/
/******************************************************************/

updateN(CurrentState, WeightMatrix, N, ResultState) :-
	N > 0,
	nextState(CurrentState, WeightMatrix, Out),
	decrementVal(N, Count),
	updateN(Out, WeightMatrix, Count, ResultState), !;
	ResultState = CurrentState.

/********************* findsEquailibrium **************************/
/*Predicate: findsEquilibrium(+InitialState,+WeightMatrix,+Range) */
/******************************************************************/

findsEquilibrium(InitalState , WeightMatrix , Range ) :-
	Range > 0, 
	decrementVal(Range , X),
	updateN( InitalState , WeightMatrix, Range , N1 ),
	updateN( InitalState , WeightMatrix, X, N2 ),
	N1 == N2,
	!.

/***************** Extra Func ********************************/

decrementVal(X,Y):-
        Y is X-1.
addVals(X,Y,Output):-
        Output is X + Y.

/************************************************************/
