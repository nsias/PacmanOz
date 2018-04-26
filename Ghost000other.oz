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
	 if Input.isTurnByTurn == false then {Delay ({OS.rand} mod (Input.thinkMax - Input.thinkMin))+Input.thinkMin} end
        NewState = {Move State ID P}
	{TreatStream T NewState}
     [] gotKilled()|T then NewState in
	NewState = {UpdateState State [alive#false]}
	{TreatStream T NewState}
     [] pacmanPos(ID P)|T then
	{TreatStream T State}
     [] killPacman(ID)|T then 
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
     C1 C2 C3
     Rnd
  in
     if X == Input.nColumn then C1 = {Check 1 Y nil}
      else C1 = {Check X+1 Y nil} end
      if X == 1 then C2 = {Check Input.nColumn Y C1}
      else C2 = {Check X-1 Y C1} end
      if Y == Input.nRow then C3  = {Check X 1 C2}
      else C3 = {Check X Y+1 C2} end
      if Y == 1 then Choices = {Check X Input.nRow C3}
      else Choices = {Check X Y-1 C3} end
      Rnd = ({OS.rand} mod {Length Choices}) + 1
      {Nth Choices Rnd}
  end

  fun{Check X Y L}
    Val in
    if X < 1 then L
    elseif X > Input.nColumn then L
    elseif Y < 1 then L
    elseif Y > Input.nRow then L
    else
        Val = {Nth {Nth Input.map Y} X}
        if Val == 1 then L
        else pt(x:X y:Y)|L end
    end
  end

  fun{UpdateState State L}
    {AdjoinList State L}
  end

end
