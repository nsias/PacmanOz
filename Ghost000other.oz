functor
import
   Input
   Browser
   OS
export
   portPlayer:StartPlayer
define   
   StartPlayer
   TreatStream
   AssignSpawn
   Spawn
   Move
   Check
   NextPosition
   UpdateState
   
in
   % ID is a <ghost> ID
   fun{StartPlayer ID}
      Stream Port
      State
   in
      {NewPort Stream Port}
      State = playerGhost(id:ID spawn:_ pos:_ alive:false mode:'classic')
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
     [] pacmanPos(ID P)|T then
	{TreatStream T State}
     [] killPacman(ID)|T then State in
	{TreatStream T State}
     [] deathPacman(ID)|T then
	{TreatStream T State}
     []setMode(M)|T then NewState in
	NewState = {UpdateState State [mode#M]}
	{TreatStream T NewState} 
      end
   end
   


   fun{AssignSpawn P State}
      {UpdateState State [spawn#P]}
   end

   fun{Spawn State ID P}
    if State.alive then
        ID = 'null'
        P = 'null'
        State
    elseif State.lives < 1 then
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

   fun{Move State ID P}
    if State.alive == false then
        ID = 'null'
        P = 'null'
        State
    else NewState Pos X Y in
        X = State.pos.x
        Y = State.pos.y
        Pos = {NextPosition X Y}

        NewState = {UpdateState State [pos#Pos]}
        ID = NewState.id
        P = NewState.pos
        NewState
    end
  end



  fun{NextPosition X Y}
    Choices
    Rnd
  in
    if Y == 1 then {Check X Input.nRow Choices}
    else {Check X Y-1 Choices} end
    {Check X (Y+1 mod Input.nRow) Choices}
    if X == 1 then {Check Input.nColumn Y Choices}
    else {Check X-1 Y Choices} end
    {Check (X+1 mod Input.nColumn) Y Choices}
    Choices = nil
    Rnd = ({OS.rand} mod {Length Choices}) + 1
    {Nth Choices Rnd}
  end

  proc{Check X Y Choices}
    Val in
    Val = {Nth {Nth Input.map Y} X}
    if Val == 1 then Choices = _
    else Choices = pt(x:X y:Y)|_ end
  end

  fun{UpdateState State L}
    {AdjoinList State L}
  end

end
