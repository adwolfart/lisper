{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PatternSynonyms   #-}

-- Core data strctures and functions on them
module Lisper.Core where

-- | [TODO] - Replace `Scheme` with `Scheme a`
data Scheme =
    Bool Bool
    | Char
    | List [Scheme]
    | Number Integer
    | Pair [Scheme] Scheme
    | Port
    | Procedure Env [Scheme] [Scheme]
    | String String
    | Symbol String
    | Vector
   deriving (Eq)

type Env = [(String, Scheme)]

instance Show Scheme where
    show (Symbol x) = x
    show (List x) =
      case x of
          Quote : _ -> "'" ++ unwords' (tail x)
          _ -> "(" ++ unwords' x ++ ")"
    show (Pair h t) = "(" ++ unwords' h ++ " . " ++ show t ++ ")"
    show (String s) = "\"" ++ s ++ "\""
    show (Number n) = show n
    -- [TODO] - Make show instance for functions more descriptive in test builds
    show Procedure{} = "<λ>"
    show (Bool True) = "#t"
    show (Bool False) = "#f"
    show _ = "Undefined type"

-- Patterns for pattern matching ;)
pattern NIL :: Scheme
pattern NIL = List []

-- Special forms

-- [TODO] - `define` supports only the 2 simple forms for now.
--
-- Handle expressions of the form `(define a 42)`
pattern Define1 :: String -> Scheme -> Scheme
pattern Define1 var expr = List [Symbol "define", Symbol var, expr]

-- Handle expressions of the form `(define (add a b) (+ a b))`
pattern Define2 :: String -> [Scheme] -> [Scheme] -> Scheme
pattern Define2 name args body =
    List (Symbol "define" : List (Symbol name : args) : body)

pattern If1 :: Scheme -> Scheme -> Scheme -> Scheme
pattern If1 predicate conseq alt = List [Symbol "if", predicate, conseq, alt]

pattern If2 :: Scheme -> Scheme -> Scheme
pattern If2 predicate conseq = List [Symbol "if", predicate, conseq]

pattern Lambda :: [Scheme] -> [Scheme] -> Scheme
pattern Lambda args body = List (Symbol "lambda" : List args: body)

pattern Let :: Scheme -> [Scheme] -> Scheme
pattern Let args body = List (Symbol "let" : args : body)

pattern Cond :: [Scheme] -> Scheme
pattern Cond body = List (Symbol "cond": body)

pattern Quote :: Scheme
pattern Quote = Symbol "quote"

pattern Set :: String -> Scheme -> Scheme
pattern Set var val = List [Symbol "set!", Symbol var, val]

-- Helpers
unwords' :: [Scheme] -> String
unwords' = unwords . map show
