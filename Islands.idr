-- vim: cc=91 tw=90 shiftwidth=3
||| Inspired by: Jérôme Cukier @ https://qr.ae/pvHKak
||| Authored by: Alexander Carter <alrunner4@gmail.com>
module Islands
import Data.HashMap
import Data.IORef
import Data.List
import Data.List1


-------------
-- Summary --

public export
interface MutableOcean (0 m: Type -> Type) where
   Ocean: Type
   newOcean: m Ocean
   (.addLand): Ocean -> (Integer, Integer) -> m Bool
   (.countIslands): Ocean -> m Nat


----------
-- Body --

IslandID: Type
IslandID = Int

record Ocean_on_IORef where
   constructor OceanRef
   islands: HashMap (Integer, Integer) (IORef (IORef IslandID))
   next_id: IORef IslandID
   count:   IORef Nat

take_id: HasIO m => Ocean_on_IORef -> m IslandID
take_id ocean = do
   i <- readIORef ocean.next_id
   modifyIORef ocean.next_id (+1)
   pure i

(.neighbors): (Integer, Integer) -> List (Integer, Integer)
(x,y).neighbors = [
   (x, y-1) , (x-1, y) ,
   (x, y+1) , (x+1, y) ]

export
HasIO m => MutableOcean m where
   Ocean = Ocean_on_IORef
   newOcean = OceanRef
      <$> newHashMap (\(x,y) => cast (x*y))
      <*> newIORef 0
      <*> newIORef 0
   ocean.addLand position = do
      Nothing <- ocean.islands.lookup position
         | Just _  => pure False
      for position.neighbors (ocean.islands.lookup)
         <&> List1.fromList . catMaybes
         >>= \case
            Nothing => do
               success <- ocean.islands.insert position !(newIORef !(newIORef !(take_id ocean)))
               when success $modifyIORef ocean.count (+1)
               pure success
            Just neighborIslandRefs => do
               neighborIslands <- for neighborIslandRefs $ \rr =>
                  readIORef rr >>= \r => (r,) <$> readIORef r
               let (joinedIsland, _) = foldl1 (\ l,r => if snd l > snd r then r else l) neighborIslands
               ignore$ ocean.islands.insert position !(newIORef joinedIsland)
               for_ neighborIslandRefs $ \r => writeIORef r joinedIsland
               modifyIORef ocean.count (`minus` (length neighborIslands `minus` 1))
               pure True
   ocean.countIslands = readIORef ocean.count


-----------
-- Tests --

lambda: Monad m => (a -> m b) -> m (a -> m b)
lambda = pure

example: IO ()
example = do
   o <- newOcean
   traceAdd <- lambda$ \p => do
      ignore (o.addLand p)
      printLn !o.countIslands
   traceAdd (1,1) -- expect 1
   traceAdd (1,2) -- expect 1
   traceAdd (2,3) -- expect 2
   traceAdd (3,2) -- expect 3
   traceAdd (2,2) -- expect 1

