||| Inspired by: Jérôme Cukier @ https://qr.ae/pvHKak
module Islands

import public Control.Monad.Either
import public Control.Monad.State

import Data.SortedSet
import Data.HashTable


-------------
-- Summary --

export data Ocean: Type
export emptyOcean: Ocean
export (.addLand): Ocean -> (Integer, Integer) -> Ocean
export (.countIslands): Ocean -> Nat

namespace State
   public export
   addLand: MonadState Ocean m => (Integer, Integer) -> m ()
   addLand position = state (\o => (o.addLand position, ()))
   public export
   countIslands: MonadState Ocean m => m Nat
   countIslands = (.countIslands) <$> get


----------
-- Body --

export
record Ocean where
   constructor OceanState


-----------
-- Tests --

lambda: Monad m => (a -> m b) -> m (a -> m b)
lambda = pure

example: IO ()
example = evalStateT emptyOcean $ do
   traceAdd <- lambda$ \p => addLand p >> printLn !countIslands
   traceAdd (1,1) -- expect 1
   traceAdd (1,2) -- expect 1
   traceAdd (2,3) -- expect 2
   traceAdd (3,2) -- expect 3
   traceAdd (2,2) -- expect 1


