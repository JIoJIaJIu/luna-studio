---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2013
---------------------------------------------------------------------------

module Flowbox.Luna.Parser.Utils where

import Control.Applicative
import Text.Parsec hiding (parse, many, optional, (<|>))

checkIf f msg p = do
	obj <- p
	if (f obj)
		then unexpected (msg ++ show obj)
		else return obj

pl <$*> pr = do 
    n <- pr
    pl n

pl <*$> pr = do 
    n <- pl
    pr n

pl <$$> pr = do 
    l <- pl
    r <- pr
    return $ r l



sepBy2  p sep = (:) <$> p <*> try(sep *> sepBy1 p sep)

sepBy'  p sep = sepBy1' p sep <|> return []
sepBy1' p sep = (:) <$> p <*> many (try(sep *> p)) <* optional sep
sepBy2' p sep = (:) <$> p <*> try(sep *> sepBy1' p sep)

liftList p = (:[]) <$> p