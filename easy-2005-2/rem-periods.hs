module Main where

import System

main :: IO ()

main = do args <- getArgs
          putStr (rem_periods (head args))
          putStr "\n"

rem_periods :: String -> String
rem_periods mystring = (fst (recurse mystring)) where
    recurse :: String -> (String,Bool)
    recurse [] = ([],False)
    recurse (a:as) = (if was_period_found
                      then ((ret_string a), True) 
                      else ((a:processed_string), (a == '.'))
                      ) where
        (processed_string,was_period_found) = (recurse as)
        ret_string :: Char -> String
        ret_string '.' = processed_string
        ret_string _ = a:processed_string


