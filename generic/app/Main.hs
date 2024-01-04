{-# language ViewPatterns, BangPatterns #-}
{-# OPTIONS_GHC -Wall -Wno-name-shadowing -Wno-missing-signatures -Wno-type-defaults -Wno-unused-matches -Wno-incomplete-patterns #-}

import Data.Char
import Data.List
import Data.Maybe
import Data.IORef

import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.Par.IO      -- monad-par
import Control.Monad.Par.Class   -- abstract-par

import qualified Data.Vector.Unboxed as V

import Options.Applicative

------------------------

readMaybe :: Read a => String -> Maybe a
readMaybe s | [(i, "")] <- reads s = Just i
readMaybe _ = Nothing

splitBy :: (a -> Bool) -> [a] -> [[a]]
splitBy p = f where
  f = g . dropWhile p
  g [] = []
  g (span (not . p) -> (as, bs)) = as: f bs

takes :: [Int] -> [a] -> [[a]]
takes _ [] = []
takes (i: is) as = take i as: takes is (drop i as)

takesCycle :: [Int] -> [a] -> [[a]]
takesCycle [] = pure
takesCycle is = takes $ cycle is

padLeft  c n s = replicate (n - length s) c ++ s
padRight c n s = s ++ replicate (n - length s) c

------------------------

type Vec = V.Vector Int

{-# INLINE zero #-}
zero :: Vec -> Vec
zero v = V.replicate (V.length v) 0

(.+.) :: Vec -> Vec -> Vec
a .+. b = V.zipWith (+) a b

type Norm1 = Int

type Sig = [Int]

norm1 :: Sig -> Vec -> Norm1
norm1 sig v = f sig 0 0 where
  f [] !acc j = acc
  f (s: ss) acc j = f ss (acc + V.maximum (V.slice j s v)) (j + s)

norm1' :: Sig -> [Integer] -> Integer
norm1' sig v = sum $ map maximum $ takes sig v

type VecWithNorm = (Vec, Norm1)
type VecsWithNorm = [VecWithNorm]
type VecsWithNorm' = (Vec, [VecWithNorm])

{-# INLINE withNorm1 #-}
withNorm1 :: Sig -> Vec -> VecWithNorm
withNorm1 sig v = (v, norm1 sig v)

type L2Norm = Int
type Witness = [VecsWithNorm']
type L2Witness = (L2Norm, Witness)

{-# INLINE maxWitness #-}
maxWitness :: L2Witness -> L2Witness -> L2Witness
maxWitness w1 w2 = if fst w1 < fst w2 then w2 else w1

maxWitness' :: L2Witness -> L2Witness -> L2Witness
maxWitness' w1 w2 = case compare (fst w1) (fst w2) of
  LT -> w2
  GT -> w1
  EQ -> if null (snd w1) then w2 else w1

type Vecs = [Vec]
type Mat = [Vecs]
type MatWithNorms = [(L2Norm, Vecs)]
type Order = Int

summ :: VecsWithNorm -> L2Norm
summ [] = 0
summ ((_, n): _) = n

addVec :: Vec -> VecsWithNorm -> VecsWithNorm'
addVec v rs = (v, rs)

{-# INLINE withN #-}
withN sig v [] = (v, norm1 sig v): []
withN sig v vs@((_, n): _) = (v, n + norm1 sig v): vs

{-# INLINE cons #-}
cons (va, n) vs rs = (va, n - summ vs + summ rs): rs

fD :: Sig -> Witness -> VecsWithNorm -> VecsWithNorm -> MatWithNorms -> L2Witness -> L2Witness
fD sig w rs vs m i = case m of
  [] -> maxWitness (summ rs + summ vs, w) i
  (n, v): m'
    | fst i >= n + summ rs + summ vs -> i
    | otherwise -> foldr (\v i -> fL sig w rs vs v m' (fR sig w rs vs v m' i)) i v

fR sig w rs (vv@(va, n): vs) v m i
   | n > 0 = fD sig (addVec v rs: w) rs (withN sig (v .+. va) vs) m (fR sig w (cons vv vs rs) vs v m i)
   | otherwise = fD sig (addVec v rs: w) rs (withNorm1 sig v: vs) m i
fR sig w _ _ v m i = i

fL sig w (vv@(va, _): rs) vs v m i = fL sig w rs (cons vv rs vs) v m (fD sig (addVec v rs: w) rs (withN sig (v .+. va) vs) m i)
fL sig w _ _ v m i = i

fDP :: Sig -> Witness -> VecsWithNorm -> VecsWithNorm -> MatWithNorms -> IORef L2Witness -> ParIO L2Witness
fDP sig w rs vs m i = case m of
  [] -> pure (summ rs + summ vs, w)
  ((== maxBound) -> True, v): m' -> foldr1 merge [fLP sig w rs vs v_ m' i `merge` fRP sig w rs vs v_ m' i | v_ <- v]
  _ -> do
    i_ <- liftIO $ readIORef i
    let i' = fD sig w rs vs m i_
    i' `seq` liftIO (atomicModifyIORef i (\i_ -> (maxWitness i' i_, ())))
    pure i'

fRP sig w rs (vv@(va, n): vs) v m i
  | n > 0 = fDP sig (addVec v rs: w) rs (withN sig (v .+. va) vs) m i `merge` fRP sig w (cons vv vs rs) vs v m i
  | otherwise = fDP sig (addVec v rs: w) rs (withNorm1 sig v: vs) m i
fRP sig w _ _ v m i = pure (0, [])

fLP sig w (vv@(va, _): rs) vs v m i = fLP sig w rs (cons vv rs vs) v m i `merge` fDP sig (addVec v rs: w) rs (withN sig (v .+. va) vs) m i
fLP sig w _ _ v m i = pure (0, [])

merge :: ParIO L2Witness -> ParIO L2Witness -> ParIO L2Witness
merge a b = do
  x <- spawn a
  y <- spawn b
  liftM2 maxWitness' (get x) (get y)

{-# INLINE f' #-}
f' :: Sig -> Order -> L2Norm -> Vecs -> MatWithNorms -> IO L2Witness
f' sig order guess v vs = do
  best <- newIORef (guess, [])
  runParIO $ foldr1 merge [fDP sig [addVec v_ []] [] (withNorm1 sig v_: replicate (order-1) (withNorm1 sig (zero v_))) vs best | v_ <- v]

g :: Sig -> Order -> Int -> Mat -> IO MatWithNorms
g sig _ _ [] = pure []
g sig order l (v: vs) = do
  m <- g sig order (l-1) vs
--  let m' = zipWith (\i (a, b) -> (if i < (length vs + 1) `div` 4 then maxBound else a, b)) [0..] m
  i <- if l > 0 then pure maxBound else fst <$> f' sig order 0 v m
  pure ((i, v): m)

l2 :: Sig -> Int -> Order -> L2Norm -> Mat -> IO L2Witness
l2 sig depth order guess (v:vs) = do
  m <- g sig order depth vs
  f' sig order guess v m


------------------------

parseBlocks :: String -> [[[[Integer]]]]
parseBlocks
  = (map . map) (map (catMaybes . map readMaybe) . splitBy isHBar . words)
  . splitBy isVBar
  . map (concatMap separate)
  . filter (not . all isSpace)
  . filter (all validChar)
  . lines
 where
  validChar c = isDigit c || isSpace c || c `elem` ['-','+','|']

  separate '|' = " | "
  separate c = [c]

  isVBar = all (`elem` ['-', '+', ' ', '\t'])
  isHBar = all (`elem` ['|', ' ', '\t'])

parseBlocks' :: Maybe [Int] -> Maybe [Int] -> String -> ([Int], [Int], [[Integer]])
parseBlocks' rs cs s = (rs', cs', bs)
 where
  as = parseBlocks s
  bs = map concat $ concat as
  rs' = fromMaybe (map length as) rs
  cs' = fromMaybe (head . last . sortOn length . group . sort . map (map length) . concat $ as) cs


renderBlocks :: Int -> Bool -> Int -> [Int] -> [Int] -> [[Integer]] -> String
renderBlocks outer uniform padding rs cs iss = unlines $ intersperse' bar1 bar2 $ takesCycle rs bs
 where
  ass_ = map (map show) iss
  ass = map (padRight "" $ maximum $ map length ass_) ass_
  ws_ = map maximum $ transpose $ map (map length) ass
  ws = if uniform then replicate (length ws_) (maximum ws_) else ws_

  bs = map (mkRow ' ' '|') ass
  bar1 = replicate (padding `div` 2) $ mkRow ' ' '|' ["" | _ <- ws]
  bar2 = [mkRow '-' '+' ["" | _ <- ws]]

  mkRow :: Char -> Char -> [String] -> String
  mkRow x y = intersperse' (replicate padding x) [y] . map (intercalate [x]) . takesCycle cs . zipWith (padLeft x) ws

  intersperse' :: [a] -> [a] -> [[a]] -> [a]
  intersperse' as bs xs = case outer of
    0 -> cs
    1 -> cs'
    2 -> around bs cs'
   where
    around a b = a <> b <> a
    cs = intercalate (around as bs) xs
    cs' = around as cs

----------------------------------------

compute :: Maybe Int -> Order -> L2Norm -> Bool -> Maybe FilePath -> IO ()
compute depth order guess tr f = do
  s <- maybe getContents readFile f
  let (rs_, cs_, bs_) = parseBlocks' Nothing Nothing s
      (rs, cs, bs) = if tr then (cs_, rs_, transpose bs_) else (rs_, cs_, bs_)
      minVal = minimum $ concat bs
      sumMinVals = fromIntegral (length rs * length cs) * minVal
      bs' = (map . map) (+(-minVal)) bs
      bs'' = (map . map) fromIntegral bs'
      m' = (map . map) V.fromList $ takes rs bs''
  if bs' /= (map . map) fromIntegral bs'' then error "overflow happend"
  else do
    let s = sum $ concat bs'
    when (s /= fromIntegral (fromIntegral s :: Int)) $ putStr "### WARNING: overflow may happen"

    (i_, w_) <- l2 cs (fromMaybe (length m' `div` 4) depth) order guess m'
    let
      i = fromIntegral i_ + sumMinVals
      w = zipWith3 (\i mm (v, rs) -> ((i, fromJust $ elemIndex v mm), length rs)) [0..] m' (reverse w_)

      i' = sum [ case [takes rs bs !! x !! y | ((x, y), j') <- w, j' == j] of
                   [] -> 0
                   vs -> norm1' cs $ foldr1 (zipWith (+)) vs
               | j <- [0..order-1]]

      showRow (x, y) = show (x+1) <> "-" <> show (y+1)

    putStr $ unlines $
      [ "Row numbers in the partitions:" ]
      ++ [ "  " ++ unwords [showRow i | (i, j') <- w, j' == j] | j <- [0..order-1]] ++
      [ "L" ++ show order ++ " norm:"
      , "  " ++ show i'
      ]
    when (i /= i') $ error $ unlines
      [ "", "!!! ERROR !!!"
      , "The computed L" ++ show order ++ " norm (" ++ show i ++ ") is not equal to the recalculated norm (" ++ show i' ++ ")."
      , "Maybe the guessed value was too high, try with a lower guessed value."
      ]


pprint rs cs f ofn border spikes padding even = do
  s <- maybe getContents readFile f
  let (rs', cs', bs) = parseBlocks' rs cs s
      s' = renderBlocks (if spikes then 1 else if border then 2 else 0) even (fromMaybe 1 padding) rs' cs' bs
  maybe putStrLn writeFile ofn s'


----------------------------------------

main :: IO ()
main = join (customExecParser (prefs mempty) opts)
 where
  opts = info (helper <*> options)
      ( fullDesc
     <> progDesc "Generalized K_m,n quadratic optimization."
      )

  options :: Parser (IO ())
  options = 
        hsubparser (command "print" printCommand)
    <|> computeOptions

  computeOptions = compute
      <$> optional (option auto $ short 'd' <> long "depth" <> metavar "NAT" <> help "parallel depth - default is height/4")
      <*> (fromMaybe 2 <$> optional (option auto $ long "order" <> short 'o' <> metavar "NAT" <> help "order - default is 2" <> completeWith ["2"]))
      <*> (fromMaybe 0 <$> optional (option auto $ short 'g' <> long "guessed" <> metavar "NAT" <> help "guessed result - default is 0" <> completeWith ["0"]))
      <*> switch (short 't' <> long "transpose" <> help "transpose the matrix")
      <*> optional (argument str $ metavar "INFILE" <> help "input file name")

  printCommand = flip info (progDesc "Visually partition the rows and columns of a matrix.") $ pprint
      <$> optional (option intlist $ short 'r' <> long "rows" <> metavar "ROWS" <> help "row partition size(s) separated by commas")
      <*> optional (option intlist $ short 'c' <> long "columns" <> metavar "COLUMNS" <> help "column partition size(s) separated by commas")
      <*> optional (argument str $ metavar "INFILE" <> help "input file name")
      <*> optional (option str $ long "output" <> short 'o' <> metavar "OUTFILE" <> help "output file name")
      <*> switch (long "border" <> short 'b' <> help "style: draw border") 
      <*> switch (long "spikes" <> short 's' <> help "style: draw little spikes instead of border") 
      <*> optional (option auto $ long "padding" <> short 'p' <> help "style: add more padding to blocks")
      <*> switch (long "even-columns" <> short 'e' <> help "style: make all column widths equal") 

  intlist :: ReadM [Int]
  intlist = eitherReader $ f where

    f (span isDigit -> (as, bs)) = (read as:) <$> g bs

    g [] = pure []
    g (',': s) = f s
    g s = Left $ "syntax error: " <> s

