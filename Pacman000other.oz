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
   GotKilled
in
  % ID is a <pacman> ID
  fun{StartPlayer ID}
    Stream Port
    State
  in
    {NewPort Stream Port}
    State = playerPacman(id:ID spawn:_ pos:_ lives:Input.nbLives score:0 alive:false mode:'classic')
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
     [] bonusSpawn(P)|T then
	      {TreatStream T State}
     [] pointSpawn(P)|T then
	      {TreatStream T State}
     [] bonusRemoved(P)|T then
	      {TreatStream T State}
     [] pointRemoved(P)|T then
	      {TreatStream T State}
     [] addPoint(Add ID NewScore)|T then NewState in
	      NewState = {UpdateState State [score#(State.score + Add)]}
	      ID = NewState.id
	      NewScore = NewState.score
	      {TreatStream T NewState}
     [] gotKilled(ID NewLife NewScore)|T then NewState in
	      NewState = {GotKilled State ID NewLife NewScore}
	      {TreatStream T NewState}
     [] ghostPos(ID P)|T then
	      {TreatStream T State}
     [] killGhost(IDg IDp NewScore)|T then NewState in
	      NewState = {UpdateState State [score#(State.score + rewardKill)]}
	      IDp = NewState.id
	      NewScore = NewState.score
	      {TreatStream T NewState}
     [] deathGhost(ID)|T then
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

  fun{GotKilled State ID NewLife NewSCore}
     NewState NewScore in
     NewState = {UpdateState State [alive#false score#(State.score - Input.penalityKill) lives#(State.lives - 1)]}
     ID = NewState.id
     NewLife = NewState.lives
     NewScore = NewState.score
     NewState
  end
  

  fun{UpdateState State L}
    {AdjoinList State L}
  end
end
