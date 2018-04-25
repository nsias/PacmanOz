functor
import
   Input
   Browser
   OS
export
   portPlayer:StartPlayer
define
%%%%%% Initial fonctions %%%%%%%%%%%%%%%%%
   StartPlayer
   TreatStream
%%%%%% Fonctions for the different messages %%%%%%
   AssignSpawn
   Spawn
   Move
   PacmanPos
%%%%%% Fonctions used in Move %%%%%%%%%%%%%%%%%%%%
   Check
   NextPosition
   FindCloser
   Pref
   QuickSort
%%%%%% Fonctions "utilitaires" %%%%%%%%%%%%%%%%%% 
   UpdateState
   CreateTab
   ModTab

   
in

%%%%%%%%%%%% INITIAL FUNCTIONS %%%%%%%%%%%%%%%%%%%
   
   % ID is a <ghost> ID
   fun{StartPlayer ID}
      Stream Port
      State
      PacInit
   in
      {NewPort Stream Port}
      PacInit = {CreateTab 'null' Input.nbPacman}
      State = playerGhost(id:ID spawn:_ pos:_ alive:false mode:'classic' pacPos:PacInit)
      thread
	 {TreatStream Stream State}
      end
      Port
   end
   
   
   
   proc{TreatStream Stream State} % has as many parameters as you want
      case Stream of getId(ID)|T then
        ID = State.id
        {TreatStream T State}
     [] assignSpawn(P)|T then NewState in
        NewState = {AssignSpawn P State}
	{TreatStream T NewState}
     [] spawn(ID P)|T then NewState in
        NewState = {Spawn State ID P}
	{TreatStream T NewState}
     [] move(ID P)|T then NewState in
        NewState = {Move State ID P}
	{TreatStream T NewState}
     [] gotKilled()|T then NewState in
	NewState = {UpdateState State [alive#false]}
	{TreatStream T NewState}
     [] pacmanPos(ID P)|T then NewState in
	NewState = {PacmanPos ID.id P State}
	{TreatStream T NewState}
     [] killPacman(ID)|T then NewState in
	NewState = {PacmanPos ID.id 'null' State}
	{TreatStream T NewState}
     [] deathPacman(ID)|T then NewState in
	NewState = {PacmanPos ID.id 'null' State}
	{TreatStream T NewState}
     [] setMode(M)|T then NewState in
	NewState = {UpdateState State [mode#M]}
	{TreatStream T NewState}
      end
   end
	 
%%%%%%%%% MESSAGES FUNCTIONS %%%%%%%%%%%%%%%%%%%%%

   fun{AssignSpawn P State}
      {UpdateState State [spawn#P]}
   end

   fun{Spawn State ID P}
    if State.alive then
        ID = 'null'
        P = 'null'
        State
    else NewState in
        NewState = {UpdateState State [alive#true pos#State.spawn]}
        ID = NewState.id
        P = NewState.pos
        NewState
    end
   end

   
  fun{PacmanPos ID P State}
     NewState
     NewTab
  in
     NewTab = {ModTab State.pacPos ID P}
     NewState = {UpdateState State [pacPos#NewTab]}
     NewState
  end

%%%%%% MOVE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Ã¹

 fun{Move State ID P}
    if State.alive == false then
        ID = 'null'
        P = 'null'
        State
    else NewState Pos X Y in
        X = State.pos.x
        Y = State.pos.y
        Pos = {NextPosition X Y State.pacPos State.mode}

        NewState = {UpdateState State [pos#Pos]}
        ID = NewState.id
        P = NewState.pos
        NewState
    end
   end
   

  fun{NextPosition X Y L Mode}
     Choices    % Choices have 4 elements : the positions of the cases next to the actual position :
                % [Nord Sud West East], if the case is a wall, we replace it by 'null'
     C1 C2 C3
     PacID
     PacPos
     Prefs
     fun{Available Choices Prefs}
	case Prefs of (D#N)|T then
	   if {Nth Choices N} == 'null' then {Available Choices T}
	   else {Nth Choices N} end
	end
     end
     
  in
     {FindCloser X Y L PacPos PacID}
     Prefs = {Pref X Y PacPos.x PacPos.y Mode}
        
     C1 = {Check (X+1 mod Input.nColumn) Y nil}
     if X == 1 then C2 = {Check Input.nColumn Y C1} 
     else C2 = {Check X-1 Y C1} end
     C3  = {Check X (Y+1 mod Input.nRow) C2}
     if Y == 1 then Choices = {Check X Input.nRow C3}
     else Choices = {Check X Y-1 C3} end

     {Available Choices Prefs}
  end

  proc{FindCloser X Y L PacPos PacID}
     fun{FindCloserAcc X Y L MinDist MinID I} 
	fun{Dist X1 Y1 X2 Y2}
	   (X1-X2)*(X1-X2) + (Y1-Y2)*(Y1-Y2)
	end
     in
	case L of H|T then D in
	   if H == 'null' then {FindCloserAcc X Y T MinDist MinID I+1}
	   else
	      D = {Dist X Y H.x H.y}
	      if MinDist == 'null' then {FindCloserAcc X Y T D I I+1} 
	      elseif D < MinDist then {FindCloserAcc X Y T D I I+1}
	      else {FindCloserAcc X Y T MinDist MinID I+1} end
	   end
	[] nil then MinID
	  end
     end
  in
     PacID = {FindCloserAcc X Y L 'null' 1 1}
     PacPos = {Nth L PacID}
  end
  
     
  fun{Check X Y L}
    Val in
    Val = {Nth {Nth Input.map Y} X}
    if Val == 1 then 'null'|L
    else pt(x:X y:Y)|L end
  end

  fun{Pref X1 Y1 X2 Y2 Mode}
     NordDist
     SudDist
     WestDist
     EastDist
  in
     if X1 > X2 then
	WestDist = X1 - X2
	EastDist = X2 + Input.nColumn - X1
     else
	WestDist = X1 - X2 + Input.nColumn
	EastDist = X2 - X1
     end
     if Y1 > Y2 then
	NordDist = Y1 - Y2
	SudDist = Y2 + Input.nRow - Y1
     else
	NordDist = Y1 - Y2 + Input.nRow
	SudDist = Y2 - Y1
     end
     {QuickSort [NordDist#1 SudDist#2 WestDist#3 EastDist#4] Mode}
  end


   fun{QuickSort L Mode}
     proc {Partition1 L (D1#N1) L1 L2}
	case L of (D2#N2)|M then
	   if D2 < D1 then M1 in
	      L1 = (D2#N2)|M1
	      {Partition1 M (D1#N1) M1 L2}
	   else M2 in
	      L2 = (D2#N2)|M2
	      {Partition1 M (D1#N1) L1 M2}
	   end
	[] nil then L1=nil L2=nil
	end
     end
     proc {Partition2 L (D1#N1) L1 L2}
	case L of (D2#N2)|M then
	   if D2 > D1 then M1 in
	      L1 = (D2#N2)|M1
	      {Partition2 M (D1#N1) M1 L2}
	   else M2 in
	      L2 = (D2#N2)|M2
	      {Partition2 M (D1#N1) L1 M2}
	   end
	[] nil then L1=nil L2=nil
	end
     end
     fun{Append L1 L2}
	case L1 of X|M1 then X|{Append M1 L2}
	[] nil then L2 end
     end
  in
     case L of (D#N)|M then L1 L2 S1 S2 in
	if Mode == 'classic' then {Partition1 M (D#N) L1 L2}    
	else {Partition2 M (D#N) L1 L2} end
	S1 = {QuickSort L1 Mode}    
	S2 = {QuickSort L2 Mode}   
	{Append S1 (D#N)|S2}
     [] nil then nil
     end
  end
    
  
     


  %%%%%%%%%%%%%%%%%%% FONCTIONS UTILITAIRES %%%%%%%%%%%%%%%%%%%%%%%%%%%

  fun{UpdateState State L}
    {AdjoinList State L}
  end

  fun{CreateTab Val N}
     if N > 0 then Val|{CreateTab Val N-1}
     else nil end
  end

  fun{ModTab Tab N Val}
     fun{ModTabAcc Tab N Val I}
	case Tab of H|T then
	   if I==N then Val|T
	   else H|{ModTabAcc T N Val I+1} end
	[] nil then nil
	end
     end
  in
     {ModTabAcc Tab N Val 1}
  end

 
end
