module Main where

import System

main :: IO ()

main = do args <- getArgs
          putStr (rem_periods (head args))
          putStr "\n"

rem_periods :: String -> String
rem_periods mystring = (reverse (if (end == "")
                        then start
                        else complex_val
                        )) where
    (start,end) = (break ('.'==) (reverse mystring))
    complex_val = start ++ ((head end):(filter (/= '.') (tail end)))

